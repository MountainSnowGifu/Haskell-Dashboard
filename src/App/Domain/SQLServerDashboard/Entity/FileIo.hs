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
  { sqlServerDbName :: SqlServerDbName,
    typeDescription :: TypeDescription,
    numOfReads :: NumOfReads,
    numOfWrites :: NumOfWrites,
    avgReadMs :: AvgReadMs,
    avgWriteMs :: AvgWriteMs
  }
  deriving (Show, Eq, Generic)
