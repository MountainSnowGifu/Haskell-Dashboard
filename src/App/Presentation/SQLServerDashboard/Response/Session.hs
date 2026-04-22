{-# LANGUAGE DeriveGeneric #-}

module App.Presentation.SQLServerDashboard.Response.Session
  ( MssqlSessionDashboardResponse (..),
    toMssqlSessionDashboardResponse,
  )
where

import App.Domain.SQLServerDashboard.Entity (MssqlSessionDashboard)
import qualified App.Domain.SQLServerDashboard.Entity as Entity
import App.Domain.SQLServerDashboard.ValueObject
  ( SqlServerDbName (..),
    unSessionCount,
  )
import Data.Aeson (FromJSON, ToJSON)
import Data.Text (Text)
import GHC.Generics (Generic)

data MssqlSessionDashboardResponse = MssqlSessionDashboardResponse
  { sessionSqlServerDbName :: Text,
    sessionCount :: Int
  }
  deriving (Show, Generic)

instance ToJSON MssqlSessionDashboardResponse

instance FromJSON MssqlSessionDashboardResponse

toMssqlSessionDashboardResponse :: MssqlSessionDashboard -> MssqlSessionDashboardResponse
toMssqlSessionDashboardResponse dashboard =
  let SqlServerDbName dbName = Entity.sessionSqlServerDbName dashboard
      count = unSessionCount (Entity.sessionCount dashboard)
   in MssqlSessionDashboardResponse
        { sessionSqlServerDbName = dbName,
          sessionCount = count
        }
