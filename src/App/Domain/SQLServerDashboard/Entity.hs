{-# LANGUAGE DeriveGeneric #-}

module App.Domain.SQLServerDashboard.Entity
  ( MssqlHealthDashboard (..),
    MssqlFileIoDashboard (..),
    MssqlSessionDashboard (..),
  )
where

import App.Domain.SQLServerDashboard.ValueObject
  ( AvgReadMs,
    AvgWriteMs,
    IsServerAlive,
    NumOfReads,
    NumOfWrites,
    SessionCount,
    SqlServerDbName,
    SqlServerIp,
    SqlServerName,
    TypeDescription,
  )
import GHC.Generics (Generic)

data MssqlHealthDashboard = MssqlHealthDashboard
  { isServerAlive :: IsServerAlive,
    sqlServerName :: SqlServerName,
    sqlServerIp :: SqlServerIp,
    mssqlFileIoDashboard :: [MssqlFileIoDashboard],
    mssqlSessionDashboard :: [MssqlSessionDashboard]
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