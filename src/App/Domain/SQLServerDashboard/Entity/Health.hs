{-# LANGUAGE DeriveGeneric #-}

module App.Domain.SQLServerDashboard.Entity.Health
  ( MssqlHealthDashboard (..),
    MssqlDbHealthDashboard (..),
  )
where

import App.Domain.SQLServerDashboard.Entity.ActiveRequest (MssqlActiveRequestDashboard)
import App.Domain.SQLServerDashboard.Entity.BlockStatus (MssqlBlockStatusDashboard)
import App.Domain.SQLServerDashboard.Entity.DbStatus (MssqlDbStatusDashboard)
import App.Domain.SQLServerDashboard.Entity.FileIo (MssqlFileIoDashboard)
import App.Domain.SQLServerDashboard.Entity.LogUsage (MssqlLogUsageDashboard)
import App.Domain.SQLServerDashboard.Entity.Performance (MssqlOverallPerformanceDashboard)
import App.Domain.SQLServerDashboard.Entity.Session (MssqlSessionDashboard)
import App.Domain.SQLServerDashboard.ValueObject
  ( IsServerAlive,
    SqlServerDbName,
    SqlServerIp,
    SqlServerPort,
  )
import GHC.Generics (Generic)

data MssqlHealthDashboard = MssqlHealthDashboard
  { isServerAlive :: IsServerAlive,
    sqlServerPort :: SqlServerPort,
    sqlServerIp :: SqlServerIp,
    mssqlOverallPerformanceDashboard :: [MssqlOverallPerformanceDashboard],
    mssqlDbHealthDashboards :: [MssqlDbHealthDashboard]
  }
  deriving (Show, Eq, Generic)

data MssqlDbHealthDashboard = MssqlDbHealthDashboard
  { dbhSqlServerDbName :: SqlServerDbName,
    dbhMssqlFileIoDashboard :: [MssqlFileIoDashboard],
    dbhMssqlSessionDashboard :: MssqlSessionDashboard,
    dbhMssqlActiveRequestDashboard :: [MssqlActiveRequestDashboard],
    dbhMssqlDbStatusDashboard :: MssqlDbStatusDashboard,
    dbhMssqlBlockStatusDashboard :: [MssqlBlockStatusDashboard],
    dbhMssqlLogUsageDashboard :: MssqlLogUsageDashboard
  }
  deriving (Show, Eq, Generic)
