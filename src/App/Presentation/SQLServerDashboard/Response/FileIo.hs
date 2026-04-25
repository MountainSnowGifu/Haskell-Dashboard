{-# LANGUAGE DeriveGeneric #-}

module App.Presentation.SQLServerDashboard.Response.FileIo
  ( MssqlFileIoDashboardResponse (..),
    toMssqlFileIoDashboardResponse,
  )
where

import App.Domain.SQLServerDashboard.Entity (MssqlFileIoDashboard)
import qualified App.Domain.SQLServerDashboard.Entity as Entity
import App.Domain.SQLServerDashboard.ValueObject
  ( SqlServerDbName (..),
    TypeDescription (..),
    unAvgReadMs,
    unAvgWriteMs,
    unNumOfReads,
    unNumOfWrites,
  )
import Data.Aeson (FromJSON, ToJSON)
import Data.Text (Text)
import GHC.Generics (Generic)

data MssqlFileIoDashboardResponse = MssqlFileIoDashboardResponse
  { sqlServerDbName :: Text,
    typeDescription :: Text,
    numOfReads :: Int,
    numOfWrites :: Int,
    avgReadMs :: Int,
    avgWriteMs :: Int
  }
  deriving (Show, Generic)

instance ToJSON MssqlFileIoDashboardResponse

instance FromJSON MssqlFileIoDashboardResponse

toMssqlFileIoDashboardResponse :: MssqlFileIoDashboard -> MssqlFileIoDashboardResponse
toMssqlFileIoDashboardResponse dashboard =
  let SqlServerDbName dbName = Entity.fioSqlServerDbName dashboard
      TypeDescription typeDesc = Entity.fioTypeDescription dashboard
      numReads = unNumOfReads (Entity.fioNumOfReads dashboard)
      numWrites = unNumOfWrites (Entity.fioNumOfWrites dashboard)
      avgRead = unAvgReadMs (Entity.fioAvgReadMs dashboard)
      avgWrite = unAvgWriteMs (Entity.fioAvgWriteMs dashboard)
   in MssqlFileIoDashboardResponse
        { sqlServerDbName = dbName,
          typeDescription = typeDesc,
          numOfReads = numReads,
          numOfWrites = numWrites,
          avgReadMs = avgRead,
          avgWriteMs = avgWrite
        }
