{-# LANGUAGE DeriveGeneric #-}

module App.Domain.SQLServerDashboard.Entity.ActiveRequest
  ( MssqlActiveRequestDashboard (..),
  )
where

import App.Domain.SQLServerDashboard.ValueObject
  ( Command,
    CpuTime,
    LogicalReads,
    Reads,
    SessionId,
    SqlServerDbName,
    Status,
    TotalElapsedTime,
    Writes,
  )
import GHC.Generics (Generic)

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
