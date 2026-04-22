{-# LANGUAGE DeriveGeneric #-}

module App.Presentation.SQLServerDashboard.Response.Performance
  ( MssqlOverallPerformanceDashboardResponse (..),
    toMssqlOverallPerformanceDashboardResponse,
  )
where

import App.Domain.SQLServerDashboard.Entity (MssqlOverallPerformanceDashboard)
import qualified App.Domain.SQLServerDashboard.Entity as Entity
import App.Domain.SQLServerDashboard.ValueObject
  ( PerformanceCounterName (..),
    PerformanceCounterValue (..),
    PerformanceInstanceName (..),
    PerformanceObjectName (..),
  )
import Data.Aeson (FromJSON, ToJSON)
import Data.Text (Text)
import GHC.Generics (Generic)

data MssqlOverallPerformanceDashboardResponse = MssqlOverallPerformanceDashboardResponse
  { pdbObjectName :: Text,
    pdbCounterName :: Text,
    pdbInstanceName :: Text,
    pdbCounterValue :: Int
  }
  deriving (Show, Generic)

instance ToJSON MssqlOverallPerformanceDashboardResponse

instance FromJSON MssqlOverallPerformanceDashboardResponse

toMssqlOverallPerformanceDashboardResponse :: MssqlOverallPerformanceDashboard -> MssqlOverallPerformanceDashboardResponse
toMssqlOverallPerformanceDashboardResponse dashboard =
  let PerformanceObjectName objName = Entity.pdbObjectName dashboard
      PerformanceCounterName counterName = Entity.pdbCounterName dashboard
      PerformanceInstanceName instanceName = Entity.pdbInstanceName dashboard
      PerformanceCounterValue counterValue = Entity.pdbCounterValue dashboard
   in MssqlOverallPerformanceDashboardResponse
        { pdbObjectName = objName,
          pdbCounterName = counterName,
          pdbInstanceName = instanceName,
          pdbCounterValue = counterValue
        }
