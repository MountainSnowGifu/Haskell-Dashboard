{-# LANGUAGE DataKinds #-}
{-# LANGUAGE RankNTypes #-}

module App.Presentation.SQLServerDashboard.Handler
  ( sqlServerDashboardHandler,
    sqlServerConnectionsHandler,
  )
where

import App.Application.SQLServerDashboard.UseCase (DashboardRunner, fetchMssqlFileIoDashboard)
import Database.MSSQLServer.Connection (ConnectInfo (..))
import App.Presentation.SQLServerDashboard.Response
  ( ConnectionCountResponse (..),
    MssqlHealthDashboardResponse (..),
    toMssqlHealthDashboardResponse,
  )
import Control.Concurrent.STM (TVar, readTVarIO)
import Control.Monad.IO.Class (liftIO)
import Data.Text (Text)
import Servant

sqlServerDashboardHandler :: ConnectInfo -> [Text] -> DashboardRunner -> Handler [MssqlHealthDashboardResponse]
sqlServerDashboardHandler cfg dbNames runner = do
  dashboards <- liftIO $ runner (fetchMssqlFileIoDashboard cfg dbNames)
  return [toMssqlHealthDashboardResponse dashboards]

sqlServerConnectionsHandler :: TVar Int -> Handler ConnectionCountResponse
sqlServerConnectionsHandler connCountRef = do
  count <- liftIO $ readTVarIO connCountRef
  return (ConnectionCountResponse count)
