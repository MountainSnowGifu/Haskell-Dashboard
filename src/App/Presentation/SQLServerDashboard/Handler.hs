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
    SQLServerHealthDashboardResponse (..),
    toSQLServerHealthDashboardResponse,
  )
import Control.Concurrent.STM (TVar, readTVarIO)
import Control.Monad.IO.Class (liftIO)
import Servant

sqlServerDashboardHandler :: DashboardRunner -> Handler [SQLServerHealthDashboardResponse]
sqlServerDashboardHandler runner = do
  dashboards <- liftIO $ runner fetchMssqlFileIoDashboard
  return [toSQLServerHealthDashboardResponse dashboards]

sqlServerConnectionsHandler :: TVar Int -> Handler ConnectionCountResponse
sqlServerConnectionsHandler connCountRef = do
  count <- liftIO $ readTVarIO connCountRef
  return (ConnectionCountResponse count)
