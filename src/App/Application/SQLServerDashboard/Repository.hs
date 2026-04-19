{-# LANGUAGE DataKinds #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE GADTs #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE TypeOperators #-}

module App.Application.SQLServerDashboard.Repository
  ( DashboardRepo (..),
    getMssqlFileIoDashboard,
    getMssqlSessionDashboard,
  )
where

import App.Application.SQLServerDashboard.Command (CreateMssqlFileIoDashboardCommand (..))
import App.Domain.SQLServerDashboard.Entity
import Effectful
import Effectful.Dispatch.Dynamic (send)

data DashboardRepo :: Effect where
  FetchMssqlFileIoDashboardOp :: CreateMssqlFileIoDashboardCommand -> DashboardRepo m [MssqlFileIoDashboard]
  FetchMssqlSessionDashboardOp :: CreateMssqlFileIoDashboardCommand -> DashboardRepo m MssqlSessionDashboard

type instance DispatchOf DashboardRepo = Dynamic

getMssqlFileIoDashboard :: (DashboardRepo :> es) => CreateMssqlFileIoDashboardCommand -> Eff es [MssqlFileIoDashboard]
getMssqlFileIoDashboard cmd = send (FetchMssqlFileIoDashboardOp cmd)

getMssqlSessionDashboard :: (DashboardRepo :> es) => CreateMssqlFileIoDashboardCommand -> Eff es MssqlSessionDashboard
getMssqlSessionDashboard cmd = send (FetchMssqlSessionDashboardOp cmd)