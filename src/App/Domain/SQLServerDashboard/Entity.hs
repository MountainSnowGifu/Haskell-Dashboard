{-# LANGUAGE DeriveGeneric #-}

module App.Domain.SQLServerDashboard.Entity
  ( MssqlHealthDashboard (..),
    MssqlDbHealthDashboard (..),
    MssqlFileIoDashboard (..),
    MssqlSessionDashboard (..),
    MssqlActiveRequestDashboard (..),
    MssqlDbStatusDashboard (..),
    MssqlOverallPerformanceDashboard (..),
  )
where

import App.Domain.SQLServerDashboard.ValueObject
  ( AvgReadMs,
    AvgWriteMs,
    Command,
    CpuTime,
    IsServerAlive,
    LogicalReads,
    NumOfReads,
    NumOfWrites,
    PerformanceCounterName,
    PerformanceCounterValue,
    PerformanceInstanceName,
    PerformanceObjectName,
    Reads,
    RecoveryModelDesc,
    SessionCount,
    SessionId,
    SqlServerDbName,
    SqlServerIp,
    SqlServerPort,
    StateDesc,
    Status,
    TotalElapsedTime,
    TypeDescription,
    UserAccessDesc,
    Writes,
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

data MssqlOverallPerformanceDashboard = MssqlOverallPerformanceDashboard
  { pdbObjectName :: PerformanceObjectName,
    pdbCounterName :: PerformanceCounterName,
    pdbInstanceName :: PerformanceInstanceName,
    pdbCounterValue :: PerformanceCounterValue
  }
  deriving (Show, Eq, Generic)

data MssqlDbHealthDashboard = MssqlDbHealthDashboard
  { dbhSqlServerDbName :: SqlServerDbName,
    dbhMssqlFileIoDashboard :: [MssqlFileIoDashboard],
    dbhMssqlSessionDashboard :: MssqlSessionDashboard,
    dbhMsqlActiveRequestDashboard :: [MssqlActiveRequestDashboard],
    dbhMssqlDbStatusDashboard :: MssqlDbStatusDashboard
  }
  deriving (Show, Eq, Generic)

data MssqlFileIoDashboard = MssqlFileIoDashboard
  { sqlServerDbName :: SqlServerDbName,
    typeDescription :: TypeDescription,
    numOfReads :: NumOfReads,
    numOfWrites :: NumOfWrites,
    avgReadMs :: AvgReadMs,
    avgWriteMs :: AvgWriteMs
  }
  deriving (Show, Eq, Generic)

data MssqlSessionDashboard = MssqlSessionDashboard
  { sessionCount :: SessionCount,
    sessionSqlServerDbName :: SqlServerDbName
  }
  deriving (Show, Eq, Generic)

data MssqlActiveRequestDashboard = MssqlActiveRequestDashboard
  { arSqlServerDbName :: SqlServerDbName,
    arSessionId :: SessionId,
    arStatus :: Status,
    arCommand :: Command,
    arCpuTime :: CpuTime,
    arTotalElapsedTime :: TotalElapsedTime,
    arReads :: Reads,
    arWrites :: Writes,
    arLogicalReads :: LogicalReads
  }
  deriving (Show, Eq, Generic)

data MssqlDbStatusDashboard = MssqlDbStatusDashboard
  { dbsSqlServerDbName :: SqlServerDbName,
    dbsStateDesc :: StateDesc,
    dbsRecoveryModelDesc :: RecoveryModelDesc,
    dbsUserAccessDesc :: UserAccessDesc
  }
  deriving (Show, Eq, Generic)
