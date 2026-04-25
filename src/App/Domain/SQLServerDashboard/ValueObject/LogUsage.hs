module App.Domain.SQLServerDashboard.ValueObject.LogUsage
  ( TotalLogSizeMB (..),
    UsedLogSpaceMB (..),
    UsedLogSpacePercent (..),
    AlertLevel (..),
  )
where

import Data.Text (Text)

newtype TotalLogSizeMB = TotalLogSizeMB Float
  deriving (Show, Eq, Ord)

newtype UsedLogSpaceMB = UsedLogSpaceMB Float
  deriving (Show, Eq, Ord)

newtype UsedLogSpacePercent = UsedLogSpacePercent Float
  deriving (Show, Eq, Ord)

newtype AlertLevel = AlertLevel Text
  deriving (Show, Eq, Ord)