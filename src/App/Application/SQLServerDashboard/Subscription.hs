module App.Application.SQLServerDashboard.Subscription
  ( DashboardSubscription (..),
    MssqlHealthDashboard,
  )
where

import App.Domain.SQLServerDashboard.Entity (MssqlHealthDashboard)

data DashboardSubscription = DashboardSubscription
  { getLatestDashboard :: IO MssqlHealthDashboard,
    subscribeUpdates :: IO (IO MssqlHealthDashboard)
  }
