{-# LANGUAGE DataKinds #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE GADTs #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE TypeOperators #-}

module App.Application.SQLServerDashboard.Notifier
  ( DashboardNotifier (..),
    notifyDashboard,
  )
where

import App.Domain.SQLServerDashboard.Entity (MssqlHealthDashboard)
import Effectful
import Effectful.Dispatch.Dynamic (send)

data DashboardNotifier :: Effect where
  NotifyDashboard :: MssqlHealthDashboard -> DashboardNotifier m ()

type instance DispatchOf DashboardNotifier = Dynamic

notifyDashboard :: (DashboardNotifier :> es) => MssqlHealthDashboard -> Eff es ()
notifyDashboard = send . NotifyDashboard
