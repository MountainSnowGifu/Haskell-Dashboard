{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE OverloadedStrings #-}

module App.Presentation.SQLServerDashboard.Response.Health
  ( MssqlHealthDashboardResponse (..),
    toMssqlHealthDashboardResponse,
    MssqlDbHealthDashboardResponse (..),
    toMssqlDbHealthDashboardResponse,
    ConnectionCountResponse (..),
  )
where

import App.Domain.SQLServerDashboard.Entity (MssqlHealthDashboard)
import qualified App.Domain.SQLServerDashboard.Entity as Entity
import App.Domain.SQLServerDashboard.ValueObject
  ( IsServerAlive (..),
    SqlServerDbName (..),
    unSqlServerIp,
    unSqlServerPort,
  )
import App.Presentation.SQLServerDashboard.Response.ActiveRequest
  ( MssqlActiveRequestDashboardResponse,
    toMssqlActiveRequestDashboardResponse,
  )
import App.Presentation.SQLServerDashboard.Response.BlockStatus
  ( MssqlBlockStatusDashboardResponse,
    toBlockStatusResponse,
  )
import App.Presentation.SQLServerDashboard.Response.DbStatus
  ( MssqlDbStatusDashboardResponse,
    toMssqlDbStatusDashboardResponse,
  )
import App.Presentation.SQLServerDashboard.Response.FileIo
  ( MssqlFileIoDashboardResponse,
    toMssqlFileIoDashboardResponse,
  )
import App.Presentation.SQLServerDashboard.Response.Performance
  ( MssqlOverallPerformanceDashboardResponse,
    toMssqlOverallPerformanceDashboardResponse,
  )
import App.Presentation.SQLServerDashboard.Response.Session
  ( MssqlSessionDashboardResponse,
    toMssqlSessionDashboardResponse,
  )
import Data.Aeson (FromJSON, ToJSON)
import Data.Text (Text)
import GHC.Generics (Generic)

data MssqlHealthDashboardResponse = MssqlHealthDashboardResponse
  { isServerAlive :: Text,
    sqlServerPort :: Int,
    sqlServerIp :: Text,
    mssqlOverallPerformanceDashboard :: [MssqlOverallPerformanceDashboardResponse],
    mssqlDbHealthDashboards :: [MssqlDbHealthDashboardResponse]
  }
  deriving (Show, Generic)

instance ToJSON MssqlHealthDashboardResponse

instance FromJSON MssqlHealthDashboardResponse

toMssqlHealthDashboardResponse :: MssqlHealthDashboard -> MssqlHealthDashboardResponse
toMssqlHealthDashboardResponse dashboard =
  let IsServerAlive alive = Entity.isServerAlive dashboard
      port = unSqlServerPort (Entity.sqlServerPort dashboard)
      ip = unSqlServerIp (Entity.sqlServerIp dashboard)
   in MssqlHealthDashboardResponse
        { isServerAlive = if alive then "Yes" else "No",
          sqlServerPort = port,
          sqlServerIp = ip,
          mssqlOverallPerformanceDashboard = map toMssqlOverallPerformanceDashboardResponse (Entity.mssqlOverallPerformanceDashboard dashboard),
          mssqlDbHealthDashboards = map toMssqlDbHealthDashboardResponse (Entity.mssqlDbHealthDashboards dashboard)
        }

data MssqlDbHealthDashboardResponse = MssqlDbHealthDashboardResponse
  { dbHealthSqlServerDbName :: Text,
    mssqlFileIoDashboard :: [MssqlFileIoDashboardResponse],
    mssqlSessionDashboard :: MssqlSessionDashboardResponse,
    mssqlActiveRequestDashboard :: [MssqlActiveRequestDashboardResponse],
    mssqlDbStatusDashboard :: MssqlDbStatusDashboardResponse,
    mssqlBlockStatusDashboard :: [MssqlBlockStatusDashboardResponse]
  }
  deriving (Show, Generic)

instance ToJSON MssqlDbHealthDashboardResponse

instance FromJSON MssqlDbHealthDashboardResponse

toMssqlDbHealthDashboardResponse :: Entity.MssqlDbHealthDashboard -> MssqlDbHealthDashboardResponse
toMssqlDbHealthDashboardResponse dashboard =
  let SqlServerDbName dbName = Entity.dbhSqlServerDbName dashboard
      fileIo = map toMssqlFileIoDashboardResponse (Entity.dbhMssqlFileIoDashboard dashboard)
      session = toMssqlSessionDashboardResponse (Entity.dbhMssqlSessionDashboard dashboard)
      activeRequests = map toMssqlActiveRequestDashboardResponse (Entity.dbhMsqlActiveRequestDashboard dashboard)
      dbStatus = toMssqlDbStatusDashboardResponse (Entity.dbhMssqlDbStatusDashboard dashboard)
      blockStatus = map toBlockStatusResponse (Entity.dbhMssqlBlockStatusDashboard dashboard)
   in MssqlDbHealthDashboardResponse
        { dbHealthSqlServerDbName = dbName,
          mssqlFileIoDashboard = fileIo,
          mssqlSessionDashboard = session,
          mssqlActiveRequestDashboard = activeRequests,
          mssqlDbStatusDashboard = dbStatus,
          mssqlBlockStatusDashboard = blockStatus
        }

newtype ConnectionCountResponse = ConnectionCountResponse
  { connections :: Int
  }
  deriving (Show, Generic)

instance ToJSON ConnectionCountResponse
