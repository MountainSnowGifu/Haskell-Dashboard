{-# LANGUAGE DeriveGeneric #-}

module App.Domain.SQLServerDashboard.Entity.Performance
  ( MssqlOverallPerformanceDashboard (..),
  )
where

import App.Domain.SQLServerDashboard.ValueObject
  ( PerformanceCounterName,
    PerformanceCounterValue,
    PerformanceInstanceName,
    PerformanceObjectName,
  )
import GHC.Generics (Generic)

data MssqlOverallPerformanceDashboard = MssqlOverallPerformanceDashboard
  { pdbObjectName :: PerformanceObjectName,
    pdbCounterName :: PerformanceCounterName,
    pdbInstanceName :: PerformanceInstanceName,
    pdbCounterValue :: PerformanceCounterValue
  }
  deriving (Show, Eq, Generic)
