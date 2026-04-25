{-# LANGUAGE DeriveGeneric #-}

module App.Presentation.SQLServerDashboard.Response.Performance
  ( MssqlOverallPerformanceDashboardResponse (..),
    toMssqlOverallPerformanceDashboardResponse,
  )
where

import App.Domain.SQLServerDashboard.Entity (MssqlOverallPerformanceDashboard)
import qualified App.Domain.SQLServerDashboard.Entity as Entity
import App.Domain.SQLServerDashboard.ValueObject
  ( PerformanceCounterValue (..),
    unPerformanceCounterName,
    unPerformanceInstanceName,
    unPerformanceObjectName,
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
  let PerformanceCounterValue counterValue = Entity.pdbCounterValue dashboard
      objName = unPerformanceObjectName (Entity.pdbObjectName dashboard)
      counterName = unPerformanceCounterName (Entity.pdbCounterName dashboard)
      instanceName = unPerformanceInstanceName (Entity.pdbInstanceName dashboard)
   in MssqlOverallPerformanceDashboardResponse
        { pdbObjectName = objName,
          pdbCounterName = counterName,
          pdbInstanceName = instanceName,
          pdbCounterValue = counterValue
        }
