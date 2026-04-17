{-# LANGUAGE DataKinds #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE GADTs #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE TypeOperators #-}

module App.Application.SQLServerDashboard.Repository
  ( DashboardRepo (..),
    getMssqlFileIoDashboard,
  )
where

import App.Domain.SQLServerDashboard.Entity
import Effectful
import Effectful.Dispatch.Dynamic (send)

data DashboardRepo :: Effect where
  FetchMssqlFileIoDashboardOp :: DashboardRepo m (Maybe MssqlFileIoDashboard)

type instance DispatchOf DashboardRepo = Dynamic

getMssqlFileIoDashboard :: (DashboardRepo :> es) => Eff es (Maybe MssqlFileIoDashboard)
getMssqlFileIoDashboard = send FetchMssqlFileIoDashboardOp