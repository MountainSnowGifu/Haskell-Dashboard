{-# LANGUAGE DeriveGeneric #-}

module App.Domain.SQLServerDashboard.Entity.Backup
  ( MssqlBackupDashboard (..),
  )
where

import App.Domain.SQLServerDashboard.ValueObject.Backup
  ( BackupFinishDate,
    BackupPhysicalDeviceName,
    BackupServerName,
    BackupStartDate,
    BackupType,
    BackupUserName,
  )
import App.Domain.SQLServerDashboard.ValueObject.Connection (SqlServerDbName)
import GHC.Generics (Generic)

data MssqlBackupDashboard = MssqlBackupDashboard
  { bakSqlServerDbName :: SqlServerDbName,
    bakBackupType :: BackupType,
    bakBackupStartDate :: BackupStartDate,
    bakBackupFinishDate :: BackupFinishDate,
    bakBackupPhysicalDeviceName :: BackupPhysicalDeviceName,
    bakBackupUserName :: BackupUserName,
    bakBackupServerName :: BackupServerName
  }
  deriving (Show, Eq, Generic)
