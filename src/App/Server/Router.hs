{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RankNTypes #-}

module App.Server.Router
  ( runServant,
  )
where

import App.Application.SQLServerDashboard.Subscription (DashboardSubscription (..))
import App.Application.SQLServerDashboard.UseCase (DashboardRunner)
import App.Core.Config (Config (..))
import App.Domain.SQLServerDashboard.Entity (MssqlHealthDashboard (..))
import App.Domain.SQLServerDashboard.ValueObject (IsServerAlive (..), SqlServerPort (..))
import App.Infrastructure.Broadcast.Channel (newBroadcastChannel, subscribe)
import App.Infrastructure.Database.Types (MSSQLPool)
import App.Infrastructure.Notifier.SQLServerDashboard (runDashboardNotifier)
import App.Infrastructure.Polling.SQLServerDashboard (PollingRunner, pollDashboard)
import App.Infrastructure.Repository.SQLServerDashboard.SQLServerDashboardSQLServer (runDashboardRepo)
import App.Presentation.Health.Handler (healthHandler)
import App.Presentation.SQLServerDashboard.Handler (sqlServerConnectionsHandler, sqlServerDashboardHandler)
import App.Presentation.SQLServerDashboard.WSHandler (sqlServerDashboardWSHandler)
import App.Server.API (API, combinedAPI)
import Control.Concurrent (newEmptyMVar, putMVar, takeMVar)
import Control.Concurrent.Async (async, cancel)
import Control.Concurrent.STM (TVar, atomically, newTVarIO, readTChan, readTVarIO)
import Control.Monad (void)
import Data.Function ((&))
import Data.Text (Text)
import Database.MSSQLServer.Connection (ConnectInfo)
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

server :: ConnectInfo -> [Text] -> DashboardRunner -> DashboardSubscription -> TVar Int -> Server API
server connInfo dbNames runner sub connCountRef =
  healthHandler connInfo
    :<|> sqlServerDashboardHandler connInfo dbNames runner
    :<|> Tagged (websocketsOr defaultConnectionOptions (sqlServerDashboardWSHandler sub connCountRef) fallback)
    :<|> sqlServerConnectionsHandler connCountRef
  where
    fallback _ sendResponse = sendResponse $ responseLBS status400 [] "Not a WebSocket request"

corsPolicy :: CorsResourcePolicy
corsPolicy =
  simpleCorsResourcePolicy
    { corsOrigins = Nothing,
      corsMethods = ["GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"],
      corsRequestHeaders = ["Content-Type", "Authorization"]
    }

app :: ConnectInfo -> [Text] -> DashboardRunner -> DashboardSubscription -> TVar Int -> Application
app connInfo dbNames runner sub connCountRef =
  cors (const $ Just corsPolicy) $
    serve combinedAPI (server connInfo dbNames runner sub connCountRef)

runServant :: Config -> ConnectInfo -> MSSQLPool -> IO ()
runServant servantConfig connInfo sqlserverPool = do
  shutdown <- newEmptyMVar
  latestRef <-
    newTVarIO
      ( MssqlHealthDashboard
          { isServerAlive = IsServerAlive False,
            sqlServerPort = SqlServerPort 0,
            sqlServerIp = "0.0.0.0",
            mssqlDbHealthDashboards = []
          }
      )
  broadcastChan <- newBroadcastChannel
  connCountRef <- newTVarIO (0 :: Int)

  let runner :: DashboardRunner
      runner eff = runEff (runDashboardRepo sqlserverPool eff)

      pollingRunner :: PollingRunner
      pollingRunner eff = runEff (runDashboardNotifier latestRef broadcastChan (runDashboardRepo sqlserverPool eff))

      sub :: DashboardSubscription
      sub =
        DashboardSubscription
          { getLatestDashboard = readTVarIO latestRef,
            subscribeUpdates = do
              chan <- atomically (subscribe broadcastChan)
              return (atomically (readTChan chan))
          }

  let dbNames = monitoredDatabases servantConfig
  pollingThread <- async (pollDashboard connInfo dbNames pollingRunner)

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

  runSettings settings (app connInfo dbNames runner sub connCountRef)
  takeMVar shutdown
  putStrLn "サーバーを終了しました"
