{-# LANGUAGE DeriveGeneric #-}

module App.Presentation.SQLServerDashboard.Response.LogUsage
  ( MssqlLogUsageDashboardResponse,
    toMssqlLogUsageDashboardResponse,
  )
where

import App.Domain.SQLServerDashboard.Entity (MssqlLogUsageDashboard)
import qualified App.Domain.SQLServerDashboard.Entity as Entity
import App.Domain.SQLServerDashboard.ValueObject
  ( AlertLevel (..),
    SqlServerDbName (..),
    TotalLogSizeMB (..),
    UsedLogSpaceMB (..),
    UsedLogSpacePercent (..),
  )
import Data.Aeson (FromJSON, ToJSON)
import Data.Text (Text)
import GHC.Generics (Generic)

data MssqlLogUsageDashboardResponse = MssqlLogUsageDashboardResponse
  { lugSqlServerDbName :: Text,
    lugTotalLogSizeMB :: Float,
    lugUsedLogSpaceMB :: Float,
    lugUsedLogSpacePercent :: Float,
    lugAlertLevel :: Text
  }
  deriving (Show, Generic)

instance ToJSON MssqlLogUsageDashboardResponse

instance FromJSON MssqlLogUsageDashboardResponse

toMssqlLogUsageDashboardResponse :: MssqlLogUsageDashboard -> MssqlLogUsageDashboardResponse
toMssqlLogUsageDashboardResponse dashboard =
  let SqlServerDbName dbName = Entity.lugSqlServerDbName dashboard
      TotalLogSizeMB totalLogSize = Entity.lugTotalLogSizeMB dashboard
      UsedLogSpaceMB usedLogSpace = Entity.lugUsedLogSpaceMB dashboard
      UsedLogSpacePercent usedLogSpacePercent = Entity.lugUsedLogSpacePercent dashboard
      AlertLevel alertLevel = Entity.lugAlertLevel dashboard
   in MssqlLogUsageDashboardResponse
        { lugSqlServerDbName = dbName,
          lugTotalLogSizeMB = totalLogSize,
          lugUsedLogSpaceMB = usedLogSpace,
          lugUsedLogSpacePercent = usedLogSpacePercent,
          lugAlertLevel = alertLevel
        }