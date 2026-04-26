{-# LANGUAGE DeriveGeneric #-}

module App.Presentation.SQLServerDashboard.Response.Backup
  ( MssqlBackupDashboardResponse,
    toMssqlBackupDashboardResponse,
  )
where

import App.Domain.SQLServerDashboard.Entity (MssqlBackupDashboard)
import qualified App.Domain.SQLServerDashboard.Entity as Entity
import App.Domain.SQLServerDashboard.ValueObject.Backup
  ( BackupFinishDate (..),
    BackupPhysicalDeviceName (..),
    BackupServerName (..),
    BackupStartDate (..),
    BackupType (..),
    BackupUserName (..),
  )
import App.Domain.SQLServerDashboard.ValueObject.Connection (SqlServerDbName (..))
import Data.Aeson (FromJSON, ToJSON)
import Data.Text (Text)
import GHC.Generics (Generic)

data MssqlBackupDashboardResponse = MssqlBackupDashboardResponse
  { bakSqlServerDbName :: Text,
    bakBackupType :: Text,
    bakBackupStartDate :: Text,
    bakBackupFinishDate :: Text,
    bakPhysicalDeviceName :: Text,
    bakUserName :: Text,
    bakServerName :: Text
  }
  deriving (Show, Generic)

instance ToJSON MssqlBackupDashboardResponse

instance FromJSON MssqlBackupDashboardResponse

toMssqlBackupDashboardResponse :: MssqlBackupDashboard -> MssqlBackupDashboardResponse
toMssqlBackupDashboardResponse backup =
  let SqlServerDbName dbName = Entity.bakSqlServerDbName backup
      BackupType backupType = Entity.bakBackupType backup
      BackupStartDate backupStartDate = Entity.bakBackupStartDate backup
      BackupFinishDate backupFinishDate = Entity.bakBackupFinishDate backup
      BackupPhysicalDeviceName physicalDeviceName = Entity.bakBackupPhysicalDeviceName backup
      BackupUserName userName = Entity.bakBackupUserName backup
      BackupServerName serverName = Entity.bakBackupServerName backup
   in MssqlBackupDashboardResponse
        { bakSqlServerDbName = dbName,
          bakBackupType = backupType,
          bakBackupStartDate = backupStartDate,
          bakBackupFinishDate = backupFinishDate,
          bakPhysicalDeviceName = physicalDeviceName,
          bakUserName = userName,
          bakServerName = serverName
        }
