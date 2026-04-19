{-# LANGUAGE DataKinds #-}
{-# LANGUAGE RankNTypes #-}

module App.Presentation.SQLServerDashboard.Handler
  ( sqlServerDashboardHandler,
    sqlServerConnectionsHandler,
  )
where

import App.Application.SQLServerDashboard.UseCase (DashboardRunner, fetchMssqlFileIoDashboard)
import App.Presentation.SQLServerDashboard.Response
  ( ConnectionCountResponse (..),
    MssqlHealthDashboardResponse (..),
    toMssqlHealthDashboardResponse,
  )
import Control.Concurrent.STM (TVar, readTVarIO)
import Control.Monad.IO.Class (liftIO)
import Data.Text (Text)
import Servant

sqlServerDashboardHandler :: [Text] -> DashboardRunner -> Handler [MssqlHealthDashboardResponse]
sqlServerDashboardHandler dbNames runner = do
  dashboards <- liftIO $ runner (fetchMssqlFileIoDashboard dbNames)
  return [toMssqlHealthDashboardResponse dashboards]

sqlServerConnectionsHandler :: TVar Int -> Handler ConnectionCountResponse
sqlServerConnectionsHandler connCountRef = do
  count <- liftIO $ readTVarIO connCountRef
  return (ConnectionCountResponse count)
