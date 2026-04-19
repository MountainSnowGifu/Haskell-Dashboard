{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE DuplicateRecordFields #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE ScopedTypeVariables #-}

module App.Presentation.SQLServerDashboard.Response
  ( MssqlFileIoDashboardResponse (..),
    toMssqlFileIoDashboardResponse,
    ConnectionCountResponse (..),
    MssqlHealthDashboardResponse (..),
    toMssqlHealthDashboardResponse,
    toMssqlSessionDashboardResponse,
  )
where

import App.Domain.SQLServerDashboard.Entity (MssqlFileIoDashboard, MssqlHealthDashboard, MssqlSessionDashboard)
import qualified App.Domain.SQLServerDashboard.Entity as Entity
import App.Domain.SQLServerDashboard.ValueObject
  ( IsServerAlive (..),
    SqlServerDbName (..),
    TypeDescription (..),
    unAvgReadMs,
    unAvgWriteMs,
    unNumOfReads,
    unNumOfWrites,
    unSessionCount,
    unSqlServerIp,
    unSqlServerName,
  )
import Data.Aeson (FromJSON, ToJSON)
import Data.Text (Text)
import GHC.Generics (Generic)

data MssqlSessionDashboardResponse = MssqlSessionDashboardResponse
  { sessionSqlServerDbName :: Text,
    sessionCount :: Int
  }
  deriving (Show, Generic)

instance ToJSON MssqlSessionDashboardResponse

instance FromJSON MssqlSessionDashboardResponse

toMssqlSessionDashboardResponse :: MssqlSessionDashboard -> MssqlSessionDashboardResponse
toMssqlSessionDashboardResponse dashboard =
  let SqlServerDbName dbName = Entity.sessionSqlServerDbName dashboard
      count = unSessionCount (Entity.sessionCount dashboard)
   in MssqlSessionDashboardResponse
        { sessionSqlServerDbName = dbName,
          sessionCount = count
        }

data MssqlFileIoDashboardResponse = MssqlFileIoDashboardResponse
  { sqlServerDbName :: Text,
    typeDescription :: Text,
    numOfReads :: Int,
    numOfWrites :: Int,
    avgReadMs :: Int,
    avgWriteMs :: Int
  }
  deriving (Show, Generic)

instance ToJSON MssqlFileIoDashboardResponse

instance FromJSON MssqlFileIoDashboardResponse

toMssqlFileIoDashboardResponse :: MssqlFileIoDashboard -> MssqlFileIoDashboardResponse
toMssqlFileIoDashboardResponse dashboard =
  let SqlServerDbName dbName = Entity.sqlServerDbName dashboard
      TypeDescription typeDesc = Entity.typeDescription dashboard
      numReads = unNumOfReads (Entity.numOfReads dashboard)
      numWrites = unNumOfWrites (Entity.numOfWrites dashboard)
      avgRead = unAvgReadMs (Entity.avgReadMs dashboard)
      avgWrite = unAvgWriteMs (Entity.avgWriteMs dashboard)
   in MssqlFileIoDashboardResponse
        { sqlServerDbName = dbName,
          typeDescription = typeDesc,
          numOfReads = numReads,
          numOfWrites = numWrites,
          avgReadMs = avgRead,
          avgWriteMs = avgWrite
        }

data MssqlHealthDashboardResponse = MssqlHealthDashboardResponse
  { isServerAlive :: Text,
    sqlServerName :: Text,
    sqlServerIp :: Text,
    mssqlFileIoDashboard :: [MssqlFileIoDashboardResponse],
    mssqlSessionDashboard :: [MssqlSessionDashboardResponse]
  }
  deriving (Show, Generic)

instance ToJSON MssqlHealthDashboardResponse

instance FromJSON MssqlHealthDashboardResponse

toMssqlHealthDashboardResponse :: MssqlHealthDashboard -> MssqlHealthDashboardResponse
toMssqlHealthDashboardResponse dashboard =
  let IsServerAlive alive = Entity.isServerAlive dashboard
      name = unSqlServerName (Entity.sqlServerName dashboard)
      ip = unSqlServerIp (Entity.sqlServerIp dashboard)
   in MssqlHealthDashboardResponse
        { isServerAlive = if alive then "Yes" else "No",
          sqlServerName = name,
          sqlServerIp = ip,
          mssqlFileIoDashboard = map toMssqlFileIoDashboardResponse (Entity.mssqlFileIoDashboard dashboard),
          mssqlSessionDashboard = map toMssqlSessionDashboardResponse (Entity.mssqlSessionDashboard dashboard)
        }

newtype ConnectionCountResponse = ConnectionCountResponse
  { connections :: Int
  }
  deriving (Show, Generic)

instance ToJSON ConnectionCountResponse
