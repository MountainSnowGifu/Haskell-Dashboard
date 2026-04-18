{-# LANGUAGE DataKinds #-}
{-# LANGUAGE RankNTypes #-}

module App.Infrastructure.Polling.SQLServerDashboard
  ( PollingRunner,
    pollDashboard,
  )
where

import App.Application.SQLServerDashboard.Notifier (DashboardNotifier, notifyDashboard)
import App.Application.SQLServerDashboard.Repository (DashboardRepo)
import App.Application.SQLServerDashboard.UseCase (fetchMssqlFileIoDashboard)
import Control.Concurrent (threadDelay)
import Control.Exception (SomeException, try)
import Control.Monad (forever)
import Data.Foldable (for_)
import Effectful (Eff, IOE)
import System.IO (hPutStrLn, stderr)

type PollingRunner = forall a. Eff '[DashboardRepo, DashboardNotifier, IOE] a -> IO a

pollDashboard :: PollingRunner -> IO ()
pollDashboard runner = forever $ do
  result <- try $ runner $ do
    mDashboard <- fetchMssqlFileIoDashboard
    for_ mDashboard notifyDashboard
  case result of
    Left err -> hPutStrLn stderr $ "[Polling] error: " <> show (err :: SomeException)
    Right _ -> pure ()
  threadDelay (10 * 1000000) -- 10 seconds
