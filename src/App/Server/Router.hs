{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RankNTypes #-}

module App.Server.Router
  ( runServant,
  )
where

import App.Core.Config (Config (..))
import App.Infrastructure.Database.Types (MSSQLPool)
import App.Presentation.Health.Handler (healthHandler)
import App.Presentation.SQLServerDashboard.Handler (sqlServerDashboardHandler)
import App.Server.API (API, combinedAPI)
import Control.Concurrent (newEmptyMVar, putMVar, takeMVar)
import Control.Monad (void)
import Data.Function ((&))
import Network.Wai.Handler.Warp
  ( defaultSettings,
    runSettings,
    setGracefulShutdownTimeout,
    setInstallShutdownHandler,
    setPort,
  )
import Network.Wai.Middleware.Cors
import Servant
import System.Posix.Signals (Handler (..), installHandler, sigINT, sigTERM)

server :: MSSQLPool -> Server API
server _pool = healthHandler :<|> sqlServerDashboardHandler

corsPolicy :: CorsResourcePolicy
corsPolicy =
  simpleCorsResourcePolicy
    { corsOrigins = Nothing,
      corsMethods = ["GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"],
      corsRequestHeaders = ["Content-Type", "Authorization"]
    }

app :: MSSQLPool -> Application
app sqlserverPool = cors (const $ Just corsPolicy) $ serve combinedAPI (server sqlserverPool)

runServant :: Config -> MSSQLPool -> IO ()
runServant servantConfig sqlserverPool = do
  shutdown <- newEmptyMVar

  let settings =
        defaultSettings
          & setPort (port servantConfig)
          & setGracefulShutdownTimeout (Just 30)
          & setInstallShutdownHandler
            ( \closeSocket -> do
                let handler = Catch $ do
                      putStrLn "シャットダウン中..."
                      closeSocket
                      putMVar shutdown ()
                void $ installHandler sigTERM handler Nothing
                void $ installHandler sigINT handler Nothing
            )

  runSettings settings (app sqlserverPool)
  takeMVar shutdown
  putStrLn "サーバーを終了しました"
