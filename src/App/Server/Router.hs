{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RankNTypes #-}

module App.Server.Router
  ( runServant,
  )
where

import App.Application.SQLServerDashboard.ConnectionTarget (SqlServerConnectionTarget)
import App.Application.SQLServerDashboard.Subscription (DashboardSubscription (..))
import App.Application.SQLServerDashboard.UseCase (DashboardRunner)
import App.Core.Config (Config (..))
import App.Domain.SQLServerDashboard.Entity (MssqlHealthDashboard (..), MssqlOverallPerformanceDashboard (..))
import App.Domain.SQLServerDashboard.ValueObject
  ( IsServerAlive (..),
    PerformanceCounterValue (..),
    SqlServerPort (..),
    mkPerformanceCounterName,
    mkPerformanceInstanceName,
    mkPerformanceObjectName,
  )
import App.Infrastructure.Broadcast.Channel (newBroadcastChannel, subscribe)
import App.Infrastructure.Database.Types (MSSQLPool)
import App.Infrastructure.Network.ServerReachability (runServerReachability)
import App.Infrastructure.Notifier.SQLServerDashboard (runDashboardNotifier)
import App.Infrastructure.Polling.SQLServerDashboard (PollingRunner, pollDashboard)
import App.Infrastructure.Repository.SQLServerDashboard.SQLServerDashboardSQLServer (runDashboardRepo)
import App.Presentation.Health.Handler (healthHandler)
import App.Presentation.SQLServerDashboard.Handler (sqlServerConnectionsHandler, sqlServerDashboardHandler)
import App.Presentation.SQLServerDashboard.WSHandler (sqlServerDashboardWSHandler)
import App.Server.API (API, combinedAPI)
import Control.Concurrent.Async (async)
import Control.Concurrent.STM (TVar, atomically, newTVarIO, readTChan, readTVarIO)
import Control.Monad (void)
import Data.Function ((&))
import Data.String (fromString)
import Data.Text (Text)
import Database.MSSQLServer.Connection (ConnectInfo)
import Effectful (runEff)
import Network.HTTP.Types (status400)
import Network.Wai (responseLBS)
import Network.Wai.Handler.Warp
  ( defaultSettings,
    runSettings,
    setHost,
    setPort,
  )
import Network.Wai.Handler.WebSockets (websocketsOr)
import Network.Wai.Middleware.Cors
import Network.WebSockets (defaultConnectionOptions)
import Servant

-- import System.Posix.Signals (Handler (..), installHandler, sigINT, sigTERM)

server :: ConnectInfo -> SqlServerConnectionTarget -> [Text] -> DashboardRunner -> DashboardSubscription -> TVar Int -> Server API
server connInfo target dbNames runner sub connCountRef =
  healthHandler connInfo
    :<|> sqlServerDashboardHandler target dbNames runner
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

app :: ConnectInfo -> SqlServerConnectionTarget -> [Text] -> DashboardRunner -> DashboardSubscription -> TVar Int -> Application
app connInfo target dbNames runner sub connCountRef =
  cors (const $ Just corsPolicy) $
    serve combinedAPI (server connInfo target dbNames runner sub connCountRef)

runServant :: Config -> ConnectInfo -> SqlServerConnectionTarget -> MSSQLPool -> IO ()
runServant servantConfig connInfo target sqlserverPool = do
  latestRef <-
    newTVarIO
      ( MssqlHealthDashboard
          { isServerAlive = IsServerAlive False,
            sqlServerPort = SqlServerPort 0,
            sqlServerIp = "0.0.0.0",
            mssqlOverallPerformanceDashboard =
              [ MssqlOverallPerformanceDashboard
                  { pdbObjectName = mkPerformanceObjectName "",
                    pdbCounterName = mkPerformanceCounterName "",
                    pdbInstanceName = mkPerformanceInstanceName "",
                    pdbCounterValue = PerformanceCounterValue 0
                  }
              ],
            mssqlDbHealthDashboards = []
          }
      )
  broadcastChan <- newBroadcastChannel
  connCountRef <- newTVarIO (0 :: Int)

  let runner :: DashboardRunner
      runner eff = runEff (runServerReachability (runDashboardRepo sqlserverPool eff))

      pollingRunner :: PollingRunner
      pollingRunner eff = runEff (runDashboardNotifier latestRef broadcastChan (runServerReachability (runDashboardRepo sqlserverPool eff)))

      sub :: DashboardSubscription
      sub =
        DashboardSubscription
          { getLatestDashboard = readTVarIO latestRef,
            subscribeUpdates = do
              chan <- atomically (subscribe broadcastChan)
              return (atomically (readTChan chan))
          }

  let dbNames = monitoredDatabases servantConfig
  void $ async (pollDashboard target dbNames pollingRunner)

  let settings =
        defaultSettings
          & setPort (port servantConfig)
          & setHost (fromString (host servantConfig))

  runSettings settings (app connInfo target dbNames runner sub connCountRef)
