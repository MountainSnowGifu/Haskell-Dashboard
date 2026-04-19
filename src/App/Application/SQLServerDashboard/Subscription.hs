module App.Application.SQLServerDashboard.Subscription
  ( DashboardSubscription (..),
    MssqlHealthDashboard,
  )
where

import App.Domain.SQLServerDashboard.Entity (MssqlHealthDashboard)
import Control.Concurrent.STM (STM, TChan)

data DashboardSubscription = DashboardSubscription
  { getLatestDashboard :: IO MssqlHealthDashboard,
    subscribeDashboardUpdates :: STM (TChan MssqlHealthDashboard)
  }
