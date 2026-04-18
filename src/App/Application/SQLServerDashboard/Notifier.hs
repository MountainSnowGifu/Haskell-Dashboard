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

import App.Domain.SQLServerDashboard.Entity (MssqlFileIoDashboard)
import Effectful
import Effectful.Dispatch.Dynamic (send)

data DashboardNotifier :: Effect where
  NotifyDashboard :: MssqlFileIoDashboard -> DashboardNotifier m ()

type instance DispatchOf DashboardNotifier = Dynamic

notifyDashboard :: (DashboardNotifier :> es) => MssqlFileIoDashboard -> Eff es ()
notifyDashboard = send . NotifyDashboard
