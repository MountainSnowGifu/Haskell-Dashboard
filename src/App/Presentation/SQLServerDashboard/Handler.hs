{-# LANGUAGE OverloadedStrings #-}

module App.Presentation.SQLServerDashboard.Handler
  ( sqlServerDashboardHandler,
  )
where

import App.Domain.SQLServerDashboard.Entity (MssqlHealthDashboard (..))
import App.Domain.SQLServerDashboard.ValueObject (IsServerAlive (..), SqlServerName (..))
import App.Presentation.SQLServerDashboard.Response (SQLServerDashboardResponse, toCreatedBoardResponse)
import Servant

sqlServerDashboardHandler :: Handler SQLServerDashboardResponse
sqlServerDashboardHandler = do
  -- Simulate fetching data from the domain layer
  let dashboard = MssqlHealthDashboard {isServerAlive = IsServerAlive True, sqlServerName = SqlServerName "MySQLServer"}
  return $ toCreatedBoardResponse dashboard