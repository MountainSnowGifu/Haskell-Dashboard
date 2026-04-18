module App.Application.SQLServerDashboard.Subscription
  ( DashboardSubscription (..),
    MssqlFileIoDashboard,
  )
where

import App.Domain.SQLServerDashboard.Entity (MssqlFileIoDashboard)
import Control.Concurrent.STM (STM, TChan)

data DashboardSubscription = DashboardSubscription
  { getLatestDashboard :: IO (Maybe MssqlFileIoDashboard),
    subscribeDashboardUpdates :: STM (TChan MssqlFileIoDashboard)
  }
