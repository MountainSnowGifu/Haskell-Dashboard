{-# LANGUAGE DataKinds #-}
{-# LANGUAGE RankNTypes #-}

module App.Presentation.SQLServerDashboard.Handler
  ( sqlServerDashboardHandler,
    sqlServerConnectionsHandler,
  )
where

import App.Application.SQLServerDashboard.UseCase (DashboardRunner, fetchMssqlFileIoDashboard)
import App.Presentation.SQLServerDashboard.Response (ConnectionCountResponse (..), SQLServerDashboardResponse, toDashboardResponse)
import Control.Concurrent.STM (TVar, readTVarIO)
import Control.Monad.IO.Class (liftIO)
import Servant

sqlServerDashboardHandler :: DashboardRunner -> Handler SQLServerDashboardResponse
sqlServerDashboardHandler runner = do
  mBoard <- liftIO $ runner fetchMssqlFileIoDashboard
  case mBoard of
    Nothing -> throwError err404
    Just board -> return (toDashboardResponse board)

sqlServerConnectionsHandler :: TVar Int -> Handler ConnectionCountResponse
sqlServerConnectionsHandler connCountRef = do
  count <- liftIO $ readTVarIO connCountRef
  return (ConnectionCountResponse count)
