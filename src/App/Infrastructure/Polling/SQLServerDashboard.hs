{-# LANGUAGE DataKinds #-}
{-# LANGUAGE RankNTypes #-}

module App.Infrastructure.Polling.SQLServerDashboard
  ( PollingRunner,
    pollDashboard,
  )
where

import App.Application.SQLServerDashboard.Notifier (DashboardNotifier, notifyDashboard)
import App.Application.SQLServerDashboard.Repository (DashboardRepo)
import App.Application.SQLServerDashboard.ServerReachability (ServerReachability)
import App.Application.SQLServerDashboard.UseCase (fetchMssqlFileIoDashboard)
import Control.Concurrent (threadDelay)
import Control.Exception (SomeException, try)
import Control.Monad (forever)
import Data.Text (Text)
import Database.MSSQLServer.Connection (ConnectInfo)
import Effectful (Eff, IOE)
import System.IO (hPutStrLn, stderr)

type PollingRunner = forall a. Eff '[DashboardRepo, ServerReachability, DashboardNotifier, IOE] a -> IO a

pollDashboard :: ConnectInfo -> [Text] -> PollingRunner -> IO ()
pollDashboard cfg dbNames runner = forever $ do
  result <- try $ runner $ do
    dashboard <- fetchMssqlFileIoDashboard cfg dbNames
    notifyDashboard dashboard
  case result of
    Left err -> hPutStrLn stderr $ "[Polling] error: " <> show (err :: SomeException)
    Right _ -> pure ()
  threadDelay (10 * 1000000) -- 10 seconds
