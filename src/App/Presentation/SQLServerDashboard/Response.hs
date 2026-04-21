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
    toMssqlDbStatusDashboardResponse,
    toMssqlOverallPerformanceDashboardResponse,
  )
where

import App.Domain.SQLServerDashboard.Entity
  ( MssqlDbStatusDashboard,
    MssqlFileIoDashboard,
    MssqlHealthDashboard,
    MssqlOverallPerformanceDashboard,
    MssqlSessionDashboard,
  )
import qualified App.Domain.SQLServerDashboard.Entity as Entity
import App.Domain.SQLServerDashboard.ValueObject
  ( Command (..),
    CpuTime (..),
    IsServerAlive (..),
    LogicalReads (..),
    PerformanceCounterName (..),
    PerformanceCounterValue (..),
    PerformanceInstanceName (..),
    PerformanceObjectName (..),
    Reads (..),
    RecoveryModelDesc (..),
    SessionId (..),
    SqlServerDbName (..),
    StateDesc (..),
    Status (..),
    TotalElapsedTime (..),
    TypeDescription (..),
    UserAccessDesc (..),
    Writes (..),
    unAvgReadMs,
    unAvgWriteMs,
    unNumOfReads,
    unNumOfWrites,
    unSessionCount,
    unSqlServerIp,
    unSqlServerPort,
  )
import Data.Aeson (FromJSON, ToJSON)
import Data.Text (Text)
import GHC.Generics (Generic)

data MssqlOverallPerformanceDashboardResponse = MssqlOverallPerformanceDashboardResponse
  { pdbObjectName :: Text,
    pdbCounterName :: Text,
    pdbInstanceName :: Text,
    pdbCounterValue :: Int
  }
  deriving (Show, Generic)

instance ToJSON MssqlOverallPerformanceDashboardResponse

instance FromJSON MssqlOverallPerformanceDashboardResponse

toMssqlOverallPerformanceDashboardResponse :: MssqlOverallPerformanceDashboard -> MssqlOverallPerformanceDashboardResponse
toMssqlOverallPerformanceDashboardResponse dashboard =
  let PerformanceObjectName objName = Entity.pdbObjectName dashboard
      PerformanceCounterName counterName = Entity.pdbCounterName dashboard
      PerformanceInstanceName instanceName = Entity.pdbInstanceName dashboard
      PerformanceCounterValue counterValue = Entity.pdbCounterValue dashboard
   in MssqlOverallPerformanceDashboardResponse
        { pdbObjectName = objName,
          pdbCounterName = counterName,
          pdbInstanceName = instanceName,
          pdbCounterValue = counterValue
        }

data MssqlDbStatusDashboardResponse = MssqlDbStatusDashboardResponse
  { dbsSqlServerDbName :: Text,
    dbsStateDesc :: Text,
    dbsRecoveryModelDesc :: Text,
    dbsUserAccessDesc :: Text
  }
  deriving (Show, Generic)

instance ToJSON MssqlDbStatusDashboardResponse

instance FromJSON MssqlDbStatusDashboardResponse

toMssqlDbStatusDashboardResponse :: MssqlDbStatusDashboard -> MssqlDbStatusDashboardResponse
toMssqlDbStatusDashboardResponse dashboard =
  let SqlServerDbName dbName = Entity.dbsSqlServerDbName dashboard
      StateDesc stateDesc = Entity.dbsStateDesc dashboard
      RecoveryModelDesc recoveryModelDesc = Entity.dbsRecoveryModelDesc dashboard
      UserAccessDesc userAccessDesc = Entity.dbsUserAccessDesc dashboard
   in MssqlDbStatusDashboardResponse
        { dbsSqlServerDbName = dbName,
          dbsStateDesc = stateDesc,
          dbsRecoveryModelDesc = recoveryModelDesc,
          dbsUserAccessDesc = userAccessDesc
        }

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
  { sqlServerDbName :: Text,
    mssqlFileIoDashboard :: [MssqlFileIoDashboardResponse],
    mssqlSessionDashboard :: MssqlSessionDashboardResponse,
    mssqlActiveRequestDashboard :: [MssqlActiveRequestDashboardResponse],
    mssqlDbStatusDashboard :: MssqlDbStatusDashboardResponse
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
   in MssqlDbHealthDashboardResponse
        { sqlServerDbName = dbName,
          mssqlFileIoDashboard = fileIo,
          mssqlSessionDashboard = session,
          mssqlActiveRequestDashboard = activeRequests,
          mssqlDbStatusDashboard = dbStatus
        }

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
