{-# LANGUAGE DeriveGeneric #-}

module App.Domain.SQLServerDashboard.Entity.FileIo
  ( MssqlFileIoDashboard (..),
  )
where

import App.Domain.SQLServerDashboard.ValueObject
  ( AvgReadMs,
    AvgWriteMs,
    NumOfReads,
    NumOfWrites,
    SqlServerDbName,
    TypeDescription,
  )
import GHC.Generics (Generic)

data MssqlFileIoDashboard = MssqlFileIoDashboard
  { fioSqlServerDbName :: SqlServerDbName,
    fioTypeDescription :: TypeDescription,
    fioNumOfReads :: NumOfReads,
    fioNumOfWrites :: NumOfWrites,
    fioAvgReadMs :: AvgReadMs,
    fioAvgWriteMs :: AvgWriteMs
  }
  deriving (Show, Eq, Generic)
