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

type instance DispatchOf DashboardRepo = Dynamic

getMssqlFileIoDashboard :: (DashboardRepo :> es) => CreateMssqlFileIoDashboardCommand -> Eff es [MssqlFileIoDashboard]
getMssqlFileIoDashboard cmd = send (FetchMssqlFileIoDashboardOp cmd)

getMssqlSessionDashboard :: (DashboardRepo :> es) => CreateMssqlFileIoDashboardCommand -> Eff es MssqlSessionDashboard
getMssqlSessionDashboard cmd = send (FetchMssqlSessionDashboardOp cmd)

getMssqlActiveRequestDashboard :: (DashboardRepo :> es) => CreateMssqlFileIoDashboardCommand -> Eff es [MssqlActiveRequestDashboard]
getMssqlActiveRequestDashboard cmd = send (FetchMssqlActiveRequestDashboardOp cmd)