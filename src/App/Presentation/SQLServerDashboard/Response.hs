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
  ( Command (..),
    CpuTime (..),
    IsServerAlive (..),
    LogicalReads (..),
    Reads (..),
    SessionId (..),
    SqlServerDbName (..),
    Status (..),
    TotalElapsedTime (..),
    TypeDescription (..),
    Writes (..),
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
    mssqlSessionDashboard :: [MssqlSessionDashboardResponse],
    mssqlActiveRequestDashboard :: [MssqlActiveRequestDashboardResponse]
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
          mssqlSessionDashboard = map toMssqlSessionDashboardResponse (Entity.mssqlSessionDashboard dashboard),
          mssqlActiveRequestDashboard = map toMssqlActiveRequestDashboardResponse (Entity.mssqlActiveRequestDashboard dashboard)
        }

data MssqlDbHealthDashboardResponse = MssqlDbHealthDashboardResponse
  { sqlServerDbName :: Text,
    mssqlFileIoDashboard :: [MssqlFileIoDashboardResponse],
    mssqlSessionDashboard :: MssqlSessionDashboardResponse,
    mssqlActiveRequestDashboard :: [MssqlActiveRequestDashboardResponse]
  }
  deriving (Show, Generic)

data MssqlActiveRequestDashboardResponse = MssqlActiveRequestDashboardResponse
  { arSqlServerDbName :: Text,
    arSessionId :: Int,
    arStatus :: Text,
    arCommand :: Text,
    arCpuTime :: Int,
    arTotalElapsedTime :: Int,
    arReads :: Int,
    arWrites :: Int,
    arLogicalReads :: Int
  }
  deriving (Show, Generic)

instance ToJSON MssqlActiveRequestDashboardResponse

instance FromJSON MssqlActiveRequestDashboardResponse

toMssqlActiveRequestDashboardResponse :: Entity.MssqlActiveRequestDashboard -> MssqlActiveRequestDashboardResponse
toMssqlActiveRequestDashboardResponse dashboard =
  let SqlServerDbName dbName = Entity.arSqlServerDbName dashboard
      SessionId sessionId = Entity.arSessionId dashboard
      Status status = Entity.arStatus dashboard
      Command command = Entity.arCommand dashboard
      CpuTime cpuTime = Entity.arCpuTime dashboard
      TotalElapsedTime totalElapsedTime = Entity.arTotalElapsedTime dashboard
      Reads numReads = Entity.arReads dashboard
      Writes numWrites = Entity.arWrites dashboard
      LogicalReads numLogicalReads = Entity.arLogicalReads dashboard
   in MssqlActiveRequestDashboardResponse
        { arSqlServerDbName = dbName,
          arSessionId = sessionId,
          arStatus = status,
          arCommand = command,
          arCpuTime = cpuTime,
          arTotalElapsedTime = totalElapsedTime,
          arReads = numReads,
          arWrites = numWrites,
          arLogicalReads = numLogicalReads
        }

newtype ConnectionCountResponse = ConnectionCountResponse
  { connections :: Int
  }
  deriving (Show, Generic)

instance ToJSON ConnectionCountResponse
