{-# LANGUAGE DeriveGeneric #-}

module App.Domain.SQLServerDashboard.Entity.DbStatus
  ( MssqlDbStatusDashboard (..),
  )
where

import App.Domain.SQLServerDashboard.ValueObject
  ( RecoveryModelDesc,
    SqlServerDbName,
    StateDesc,
    UserAccessDesc,
  )
import GHC.Generics (Generic)

data MssqlDbStatusDashboard = MssqlDbStatusDashboard
  { dbsSqlServerDbName :: SqlServerDbName,
    dbsStateDesc :: StateDesc,
    dbsRecoveryModelDesc :: RecoveryModelDesc,
    dbsUserAccessDesc :: UserAccessDesc
  }
  deriving (Show, Eq, Generic)
