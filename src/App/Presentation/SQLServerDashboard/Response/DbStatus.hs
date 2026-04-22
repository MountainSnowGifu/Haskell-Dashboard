{-# LANGUAGE DeriveGeneric #-}

module App.Presentation.SQLServerDashboard.Response.DbStatus
  ( MssqlDbStatusDashboardResponse (..),
    toMssqlDbStatusDashboardResponse,
  )
where

import App.Domain.SQLServerDashboard.Entity (MssqlDbStatusDashboard)
import qualified App.Domain.SQLServerDashboard.Entity as Entity
import App.Domain.SQLServerDashboard.ValueObject
  ( RecoveryModelDesc (..),
    SqlServerDbName (..),
    StateDesc (..),
    UserAccessDesc (..),
  )
import Data.Aeson (FromJSON, ToJSON)
import Data.Text (Text)
import GHC.Generics (Generic)

data MssqlDbStatusDashboardResponse = MssqlDbStatusDashboardResponse
  { dbsSqlServerDbName :: Text,
    dbsStateDesc :: Text,
    dbsRecoveryModelDesc :: Text,
    dbsUserAccessDesc :: Text
  }
  deriving (Show, Generic)

instance ToJSON MssqlDbStatusDashboardResponse

instance FromJSON MssqlDbStatusDashboardResponse

toMssqlDbStatusDashboardResponse :: MssqlDbStatusDashboard -> MssqlDbStatusDashboardResponse
toMssqlDbStatusDashboardResponse dashboard =
  let SqlServerDbName dbName = Entity.dbsSqlServerDbName dashboard
      StateDesc stateDesc = Entity.dbsStateDesc dashboard
      RecoveryModelDesc recoveryModelDesc = Entity.dbsRecoveryModelDesc dashboard
      UserAccessDesc userAccessDesc = Entity.dbsUserAccessDesc dashboard
   in MssqlDbStatusDashboardResponse
        { dbsSqlServerDbName = dbName,
          dbsStateDesc = stateDesc,
          dbsRecoveryModelDesc = recoveryModelDesc,
          dbsUserAccessDesc = userAccessDesc
        }
