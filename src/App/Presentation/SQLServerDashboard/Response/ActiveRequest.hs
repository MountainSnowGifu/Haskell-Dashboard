{-# LANGUAGE DeriveGeneric #-}

module App.Presentation.SQLServerDashboard.Response.ActiveRequest
  ( MssqlActiveRequestDashboardResponse (..),
    toMssqlActiveRequestDashboardResponse,
  )
where

import App.Domain.SQLServerDashboard.Entity (MssqlActiveRequestDashboard)
import qualified App.Domain.SQLServerDashboard.Entity as Entity
import App.Domain.SQLServerDashboard.ValueObject
  ( Command (..),
    CpuTime (..),
    LogicalReads (..),
    Reads (..),
    SessionId (..),
    SqlServerDbName (..),
    Status (..),
    TotalElapsedTime (..),
    Writes (..),
  )
import Data.Aeson (FromJSON, ToJSON)
import Data.Text (Text)
import GHC.Generics (Generic)

data MssqlActiveRequestDashboardResponse = MssqlActiveRequestDashboardResponse
  { arSqlServerDbName :: Text,
    arSessionId :: Int,
    arStatus :: Text,
    arCommand :: Text,
    arCpuTime :: Int,
    arTotalElapsedTime :: Int,
    arReads :: Int,
    arWrites :: Int,
    arLogicalReads :: Int
  }
  deriving (Show, Generic)

instance ToJSON MssqlActiveRequestDashboardResponse

instance FromJSON MssqlActiveRequestDashboardResponse

toMssqlActiveRequestDashboardResponse :: MssqlActiveRequestDashboard -> MssqlActiveRequestDashboardResponse
toMssqlActiveRequestDashboardResponse dashboard =
  let SqlServerDbName dbName = Entity.arSqlServerDbName dashboard
      SessionId sessionId = Entity.arSessionId dashboard
      Status status = Entity.arStatus dashboard
      Command command = Entity.arCommand dashboard
      CpuTime cpuTime = Entity.arCpuTime dashboard
      TotalElapsedTime totalElapsedTime = Entity.arTotalElapsedTime dashboard
      Reads numReads = Entity.arReads dashboard
      Writes numWrites = Entity.arWrites dashboard
      LogicalReads numLogicalReads = Entity.arLogicalReads dashboard
   in MssqlActiveRequestDashboardResponse
        { arSqlServerDbName = dbName,
          arSessionId = sessionId,
          arStatus = status,
          arCommand = command,
          arCpuTime = cpuTime,
          arTotalElapsedTime = totalElapsedTime,
          arReads = numReads,
          arWrites = numWrites,
          arLogicalReads = numLogicalReads
        }
