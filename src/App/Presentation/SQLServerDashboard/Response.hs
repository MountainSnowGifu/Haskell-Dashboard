{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE DuplicateRecordFields #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RecordWildCards #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TypeOperators #-}

module App.Presentation.SQLServerDashboard.Response
  ( SQLServerFileIoDashboardResponse (..),
    toSQLServerFileIoDashboardResponse,
    ConnectionCountResponse (..),
    SQLServerHealthDashboardResponse (..),
    toSQLServerHealthDashboardResponse,
  )
where

import App.Domain.SQLServerDashboard.Entity (MssqlFileIoDashboard, MssqlHealthDashboard)
import qualified App.Domain.SQLServerDashboard.Entity as Entity
import App.Domain.SQLServerDashboard.ValueObject
  ( IsServerAlive (..),
    SqlServerDbName (..),
    TypeDescription (..),
    unNumOfReads,
    unNumOfWrites,
    unSqlServerIp,
    unSqlServerName,
  )
import Data.Aeson (FromJSON, ToJSON)
import Data.Text (Text)
import GHC.Generics (Generic)

data SQLServerFileIoDashboardResponse = SQLServerFileIoDashboardResponse
  { sqlServerDbName :: Text,
    typeDescription :: Text,
    numOfReads :: Int,
    numOfWrites :: Int
  }
  deriving (Show, Generic)

instance ToJSON SQLServerFileIoDashboardResponse

instance FromJSON SQLServerFileIoDashboardResponse

toSQLServerFileIoDashboardResponse :: MssqlFileIoDashboard -> SQLServerFileIoDashboardResponse
toSQLServerFileIoDashboardResponse dashboard =
  let SqlServerDbName dbName = Entity.sqlServerDbName dashboard
      TypeDescription typeDesc = Entity.typeDescription dashboard
      numReads = unNumOfReads (Entity.numOfReads dashboard)
      numWrites = unNumOfWrites (Entity.numOfWrites dashboard)
   in SQLServerFileIoDashboardResponse
        { sqlServerDbName = dbName,
          typeDescription = typeDesc,
          numOfReads = numReads,
          numOfWrites = numWrites
        }

data SQLServerHealthDashboardResponse = SQLServerHealthDashboardResponse
  { isServerAlive :: Text,
    sqlServerName :: Text,
    sqlServerIp :: Text,
    mssqlFileIoDashboard :: [SQLServerFileIoDashboardResponse]
  }
  deriving (Show, Generic)

instance ToJSON SQLServerHealthDashboardResponse

instance FromJSON SQLServerHealthDashboardResponse

toSQLServerHealthDashboardResponse :: MssqlHealthDashboard -> SQLServerHealthDashboardResponse
toSQLServerHealthDashboardResponse dashboard =
  let IsServerAlive alive = Entity.isServerAlive dashboard
      name = unSqlServerName (Entity.sqlServerName dashboard)
      ip = unSqlServerIp (Entity.sqlServerIp dashboard)
   in SQLServerHealthDashboardResponse
        { isServerAlive = if alive then "Yes" else "No",
          sqlServerName = name,
          sqlServerIp = ip,
          mssqlFileIoDashboard = map toSQLServerFileIoDashboardResponse (Entity.mssqlFileIoDashboard dashboard)
        }

newtype ConnectionCountResponse = ConnectionCountResponse
  { connections :: Int
  }
  deriving (Show, Generic)

instance ToJSON ConnectionCountResponse
