{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE DisambiguateRecordFields #-}

module App.Presentation.SQLServerDashboard.Response
  ( SQLServerDashboardResponse (..),
    toCreatedBoardResponse,
  )
where

import App.Domain.SQLServerDashboard.Entity (MssqlHealthDashboard (..))
import qualified App.Domain.SQLServerDashboard.Entity as Entity
import App.Domain.SQLServerDashboard.ValueObject (IsServerAlive (..), SqlServerName (..))
import Data.Aeson (FromJSON, ToJSON)
import Data.Coerce (coerce)
import Data.Text (Text)
import GHC.Generics (Generic)

data SQLServerDashboardResponse = SQLServerDashboardResponse
  { isServerAlive :: Bool,
    db :: Text
  }
  deriving (Show, Generic)

instance ToJSON SQLServerDashboardResponse

instance FromJSON SQLServerDashboardResponse

toCreatedBoardResponse :: MssqlHealthDashboard -> SQLServerDashboardResponse
toCreatedBoardResponse dashboard =
  SQLServerDashboardResponse
    { isServerAlive = coerce (Entity.isServerAlive dashboard),
      db = case Entity.sqlServerName dashboard of
        SqlServerName name -> name
    }