{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RankNTypes #-}

module App.Server.Router
  ( runServant,
  )
where

import App.Core.Config (Config (..))
import App.Domain.SQLServerDashboard.Entity (MssqlFileIoDashboard (..))
import App.Domain.SQLServerDashboard.ValueObject
  ( NumOfReads (..),
    NumOfWrites (..),
    SqlServerDbName (..),
    TypeDescription (..),
  )
import App.Infrastructure.Broadcast.Channel (BroadcastChannel, newBroadcastChannel, publish)
import App.Infrastructure.Database.Types (MSSQLPool)
import App.Infrastructure.Repository.SQLServerDashboard.SQLServerDashboardSQLServer (runDashboardRepo)
import App.Presentation.Health.Handler (healthHandler)
import App.Presentation.SQLServerDashboard.Handler (SqlServerDashboardRunner, sqlServerDashboardHandler)
import App.Presentation.SQLServerDashboard.Response (SQLServerDashboardResponse, toCreatedBoardResponse)
import App.Presentation.SQLServerDashboard.WSHandler (sqlServerDashboardWSHandler)
import App.Server.API (API, combinedAPI)
import Control.Concurrent (newEmptyMVar, putMVar, takeMVar, threadDelay)
import Control.Concurrent.Async (async, cancel)
import Control.Concurrent.STM (TVar, atomically, newTVarIO, writeTVar)
import Control.Monad (forever, void)
import Data.Function ((&))
import Effectful (runEff)
import Network.HTTP.Types (status400)
import Network.Wai (responseLBS)
import Network.Wai.Handler.Warp
  ( defaultSettings,
    runSettings,
    setGracefulShutdownTimeout,
    setInstallShutdownHandler,
    setPort,
  )
import Network.Wai.Handler.WebSockets (websocketsOr)
import Network.Wai.Middleware.Cors
import Network.WebSockets (defaultConnectionOptions)
import Servant
import System.Posix.Signals (Handler (..), installHandler, sigINT, sigTERM)

server :: MSSQLPool -> TVar (Maybe SQLServerDashboardResponse) -> BroadcastChannel SQLServerDashboardResponse -> Server API
server pool latestRef chan =
  healthHandler
    :<|> sqlServerDashboardHandler runner
    :<|> Tagged (websocketsOr defaultConnectionOptions (sqlServerDashboardWSHandler latestRef chan) fallback)
  where
    runner :: SqlServerDashboardRunner
    runner eff = runEff (runDashboardRepo pool eff)
    fallback _ sendResponse = sendResponse $ responseLBS status400 [] "Not a WebSocket request"

corsPolicy :: CorsResourcePolicy
corsPolicy =
  simpleCorsResourcePolicy
    { corsOrigins = Nothing,
      corsMethods = ["GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"],
      corsRequestHeaders = ["Content-Type", "Authorization"]
    }

app :: MSSQLPool -> TVar (Maybe SQLServerDashboardResponse) -> BroadcastChannel SQLServerDashboardResponse -> Application
app sqlserverPool latestRef chan =
  cors (const $ Just corsPolicy) $
    serve combinedAPI (server sqlserverPool latestRef chan)

pollSQLServer :: TVar (Maybe SQLServerDashboardResponse) -> BroadcastChannel SQLServerDashboardResponse -> IO ()
pollSQLServer latestRef chan = forever $ do
  let dashboard =
        MssqlFileIoDashboard
          { sqlServerDbName = SqlServerDbName "SampleDB",
            typeDescription = TypeDescription "Data File",
            numOfReads = NumOfReads 100,
            numOfWrites = NumOfWrites 50
          }
  let response = toCreatedBoardResponse dashboard
  atomically $ writeTVar latestRef (Just response)
  publish chan response
  threadDelay (5 * 1000000)

runServant :: Config -> MSSQLPool -> IO ()
runServant servantConfig sqlserverPool = do
  shutdown <- newEmptyMVar
  latestRef <- newTVarIO Nothing
  broadcastChan <- newBroadcastChannel

  pollingThread <- async (pollSQLServer latestRef broadcastChan)

  let settings =
        defaultSettings
          & setPort (port servantConfig)
          & setGracefulShutdownTimeout (Just 30)
          & setInstallShutdownHandler
            ( \closeSocket -> do
                let handler = Catch $ do
                      putStrLn "シャットダウン中..."
                      cancel pollingThread
                      closeSocket
                      putMVar shutdown ()
                void $ installHandler sigTERM handler Nothing
                void $ installHandler sigINT handler Nothing
            )

  runSettings settings (app sqlserverPool latestRef broadcastChan)
  takeMVar shutdown
  putStrLn "サーバーを終了しました"
