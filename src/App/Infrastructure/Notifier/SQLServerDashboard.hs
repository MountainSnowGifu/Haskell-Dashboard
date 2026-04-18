{-# LANGUAGE DataKinds #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE GADTs #-}
{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE TypeOperators #-}

module App.Infrastructure.Notifier.SQLServerDashboard
  ( runDashboardNotifier,
  )
where

import App.Application.SQLServerDashboard.Notifier (DashboardNotifier (..))
import App.Domain.SQLServerDashboard.Entity (MssqlFileIoDashboard)
import App.Infrastructure.Broadcast.Channel (BroadcastChannel, publish)
import Control.Concurrent.STM (TVar, atomically, writeTVar)
import Effectful
import Effectful.Dispatch.Dynamic (interpret)

runDashboardNotifier ::
  (IOE :> es) =>
  TVar (Maybe MssqlFileIoDashboard) ->
  BroadcastChannel MssqlFileIoDashboard ->
  Eff (DashboardNotifier : es) a ->
  Eff es a
runDashboardNotifier latestRef chan = interpret $ \_env -> \case
  NotifyDashboard dashboard -> liftIO $ do
    atomically $ writeTVar latestRef (Just dashboard)
    publish chan dashboard
