{-# LANGUAGE DeriveGeneric #-}

module App.Domain.SQLServerDashboard.Entity
  ( MssqlHealthDashboard (..),
    MssqlFileIoDashboard (..),
    MssqlSessionDashboard (..),
    MssqlActiveRequestDashboard (..),
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
    Reads,
    SessionCount,
    SessionId,
    SqlServerDbName,
    SqlServerIp,
    SqlServerName,
    Status,
    TotalElapsedTime,
    TypeDescription,
    Writes,
  )
import GHC.Generics (Generic)

data MssqlHealthDashboard = MssqlHealthDashboard
  { isServerAlive :: IsServerAlive,
    sqlServerName :: SqlServerName,
    sqlServerIp :: SqlServerIp,
    mssqlFileIoDashboard :: [MssqlFileIoDashboard],
    mssqlSessionDashboard :: [MssqlSessionDashboard],
    mssqlActiveRequestDashboard :: [MssqlActiveRequestDashboard]
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