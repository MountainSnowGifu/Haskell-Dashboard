{-# LANGUAGE DataKinds #-}
{-# LANGUAGE DuplicateRecordFields #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE ImportQualifiedPost #-}
{-# LANGUAGE RankNTypes #-}
{-# LANGUAGE TypeOperators #-}

module App.Application.SQLServerDashboard.UseCase
  ( DashboardRunner,
    fetchMssqlFileIoDashboard,
  )
where

import App.Application.SQLServerDashboard.Repository (DashboardRepo)
import App.Application.SQLServerDashboard.Repository qualified as DashboardRepo
import App.Domain.SQLServerDashboard.Entity (MssqlFileIoDashboard (..))
import Effectful (Eff, IOE, (:>))

type DashboardRunner = forall a. Eff '[DashboardRepo, IOE] a -> IO a

fetchMssqlFileIoDashboard :: (DashboardRepo :> es) => Eff es (Maybe MssqlFileIoDashboard)
fetchMssqlFileIoDashboard = do
  DashboardRepo.getMssqlFileIoDashboard
