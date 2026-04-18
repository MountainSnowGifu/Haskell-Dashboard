{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE DuplicateRecordFields #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RecordWildCards #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TypeOperators #-}

module App.Presentation.SQLServerDashboard.Response
  ( SQLServerDashboardResponse (..),
    toDashboardResponse,
    ConnectionCountResponse (..),
  )
where

import App.Domain.SQLServerDashboard.Entity (MssqlFileIoDashboard)
import qualified App.Domain.SQLServerDashboard.Entity as Entity
import App.Domain.SQLServerDashboard.ValueObject
  ( SqlServerDbName (..),
    TypeDescription (..),
    unNumOfReads,
    unNumOfWrites,
  )
import Data.Aeson (FromJSON, ToJSON)
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

newtype ConnectionCountResponse = ConnectionCountResponse
  { connections :: Int
  }
  deriving (Show, Generic)

instance ToJSON ConnectionCountResponse

toDashboardResponse :: MssqlFileIoDashboard -> SQLServerDashboardResponse
toDashboardResponse dashboard =
  let SqlServerDbName dbName = Entity.sqlServerDbName dashboard
      TypeDescription typeDesc = Entity.typeDescription dashboard
      numReads = unNumOfReads (Entity.numOfReads dashboard)
      numWrites = unNumOfWrites (Entity.numOfWrites dashboard)
   in SQLServerDashboardResponse
        { sqlServerDbName = dbName,
          typeDescription = typeDesc,
          numOfReads = numReads,
          numOfWrites = numWrites
        }