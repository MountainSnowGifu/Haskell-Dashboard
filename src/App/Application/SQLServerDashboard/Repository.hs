{-# LANGUAGE DataKinds #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE GADTs #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE TypeOperators #-}

module App.Application.SQLServerDashboard.Repository
  ( DashboardRepo (..),
    getMssqlFileIoDashboard,
    getMssqlSessionDashboard,
    getMssqlActiveRequestDashboard,
    getMssqlDbStatusDashboard,
    getMssqlOverallPerformanceDashboard,
  )
where

import App.Application.SQLServerDashboard.Command (CreateMssqlFileIoDashboardCommand (..))
import App.Domain.SQLServerDashboard.Entity
import Effectful
import Effectful.Dispatch.Dynamic (send)

data DashboardRepo :: Effect where
  FetchMssqlFileIoDashboardOp :: CreateMssqlFileIoDashboardCommand -> DashboardRepo m [MssqlFileIoDashboard]
  FetchMssqlSessionDashboardOp :: CreateMssqlFileIoDashboardCommand -> DashboardRepo m MssqlSessionDashboard
  FetchMssqlActiveRequestDashboardOp :: CreateMssqlFileIoDashboardCommand -> DashboardRepo m [MssqlActiveRequestDashboard]
  FetchMssqlDbStatusDashboardOp :: CreateMssqlFileIoDashboardCommand -> DashboardRepo m MssqlDbStatusDashboard
  FetchMssqlOverallPerformanceDashboardOp :: CreateMssqlFileIoDashboardCommand -> DashboardRepo m [MssqlOverallPerformanceDashboard]

type instance DispatchOf DashboardRepo = Dynamic

getMssqlFileIoDashboard :: (DashboardRepo :> es) => CreateMssqlFileIoDashboardCommand -> Eff es [MssqlFileIoDashboard]
getMssqlFileIoDashboard cmd = send (FetchMssqlFileIoDashboardOp cmd)

getMssqlSessionDashboard :: (DashboardRepo :> es) => CreateMssqlFileIoDashboardCommand -> Eff es MssqlSessionDashboard
getMssqlSessionDashboard cmd = send (FetchMssqlSessionDashboardOp cmd)

getMssqlActiveRequestDashboard :: (DashboardRepo :> es) => CreateMssqlFileIoDashboardCommand -> Eff es [MssqlActiveRequestDashboard]
getMssqlActiveRequestDashboard cmd = send (FetchMssqlActiveRequestDashboardOp cmd)

getMssqlDbStatusDashboard :: (DashboardRepo :> es) => CreateMssqlFileIoDashboardCommand -> Eff es MssqlDbStatusDashboard
getMssqlDbStatusDashboard cmd = send (FetchMssqlDbStatusDashboardOp cmd)

getMssqlOverallPerformanceDashboard :: (DashboardRepo :> es) => CreateMssqlFileIoDashboardCommand -> Eff es [MssqlOverallPerformanceDashboard]
getMssqlOverallPerformanceDashboard cmd = send (FetchMssqlOverallPerformanceDashboardOp cmd)