{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE DisambiguateRecordFields #-}

module App.Presentation.SQLServerDashboard.Response
  ( SQLServerDashboardResponse (..),
    toCreatedBoardResponse,
  )
where

import App.Domain.SQLServerDashboard.Entity (MssqlFileIoDashboard (..))
import qualified App.Domain.SQLServerDashboard.Entity as Entity
import App.Domain.SQLServerDashboard.ValueObject
  ( NumOfReads (..),
    NumOfWrites (..),
    SqlServerDbName (..),
    TypeDescription (..),
  )
import Data.Aeson (FromJSON, ToJSON)
import Data.Coerce (coerce)
import Data.Text (Text)
import GHC.Generics (Generic)

data SQLServerDashboardResponse = SQLServerDashboardResponse
  { sqlServerDbName :: Text,
    typeDescription :: Text,
    numOfReads :: Int,
    numOfWrites :: Int
  }
  deriving (Show, Generic)

instance ToJSON SQLServerDashboardResponse

instance FromJSON SQLServerDashboardResponse

toCreatedBoardResponse :: MssqlFileIoDashboard -> SQLServerDashboardResponse
toCreatedBoardResponse dashboard =
  SQLServerDashboardResponse
    { sqlServerDbName = case Entity.sqlServerDbName dashboard of
        SqlServerDbName name -> name,
      typeDescription = case Entity.typeDescription dashboard of
        TypeDescription desc -> desc,
      numOfReads = coerce (Entity.numOfReads dashboard),
      numOfWrites = coerce (Entity.numOfWrites dashboard)
    }