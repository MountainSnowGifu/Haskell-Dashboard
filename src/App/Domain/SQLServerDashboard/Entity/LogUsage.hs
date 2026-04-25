{-# LANGUAGE DeriveGeneric #-}

module App.Domain.SQLServerDashboard.Entity.LogUsage
  ( MssqlLogUsageDashboard (..),
  )
where

import App.Domain.SQLServerDashboard.ValueObject
import GHC.Generics

data MssqlLogUsageDashboard = MssqlLogUsageDashboard
  { lugSqlServerDbName :: SqlServerDbName,
    lugTotalLogSizeMB :: TotalLogSizeMB,
    lugUsedLogSpaceMB :: UsedLogSpaceMB,
    lugUsedLogSpacePercent :: UsedLogSpacePercent,
    lugAlertLevel :: AlertLevel
  }
  deriving (Show, Eq, Generic)