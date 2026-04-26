module App.Domain.SQLServerDashboard.ValueObject.Backup
  ( BackupType (..),
    BackupStartDate (..),
    BackupFinishDate (..),
    BackupPhysicalDeviceName (..),
    BackupUserName (..),
    BackupServerName (..),
  )
where

import Data.Text (Text)

newtype BackupType = BackupType Text
  deriving (Show, Eq, Ord)

newtype BackupStartDate = BackupStartDate Text
  deriving (Show, Eq, Ord)

newtype BackupFinishDate = BackupFinishDate Text
  deriving (Show, Eq, Ord)

newtype BackupPhysicalDeviceName = BackupPhysicalDeviceName Text
  deriving (Show, Eq, Ord)

newtype BackupUserName = BackupUserName Text
  deriving (Show, Eq, Ord)

newtype BackupServerName = BackupServerName Text
  deriving (Show, Eq, Ord)
