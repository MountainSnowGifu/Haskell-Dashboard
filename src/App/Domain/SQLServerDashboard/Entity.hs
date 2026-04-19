{-# LANGUAGE DeriveGeneric #-}

module App.Domain.SQLServerDashboard.Entity
  ( MssqlHealthDashboard (..),
    MssqlFileIoDashboard (..),
  )
where

import App.Domain.SQLServerDashboard.ValueObject
  ( IsServerAlive,
    NumOfReads,
    NumOfWrites,
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
    mssqlFileIoDashboard :: [MssqlFileIoDashboard]
  }
  deriving (Show, Eq, Generic)

data MssqlFileIoDashboard = MssqlFileIoDashboard
  { sqlServerDbName :: SqlServerDbName,
    typeDescription :: TypeDescription,
    numOfReads :: NumOfReads,
    numOfWrites :: NumOfWrites
  }
  deriving (Show, Eq, Generic)