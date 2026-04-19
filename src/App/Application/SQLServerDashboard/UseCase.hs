{-# LANGUAGE DataKinds #-}
{-# LANGUAGE DuplicateRecordFields #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE ImportQualifiedPost #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RankNTypes #-}
{-# LANGUAGE TypeOperators #-}

module App.Application.SQLServerDashboard.UseCase
  ( DashboardRunner,
    fetchMssqlFileIoDashboard,
  )
where

import App.Application.SQLServerDashboard.Command (CreateMssqlFileIoDashboardCommand (..))
import App.Application.SQLServerDashboard.Repository (DashboardRepo)
import App.Application.SQLServerDashboard.Repository qualified as DashboardRepo
import App.Domain.SQLServerDashboard.Entity (MssqlHealthDashboard (..))
import App.Domain.SQLServerDashboard.ValueObject (IsServerAlive (..))
import Effectful (Eff, IOE, liftIO, (:>))

type DashboardRunner = forall a. Eff '[DashboardRepo, IOE] a -> IO a

fetchMssqlFileIoDashboard :: (DashboardRepo :> es, IOE :> es) => Eff es MssqlHealthDashboard
fetchMssqlFileIoDashboard = do
  liftIO $ putStrLn "[DashboardRepo] fetching dashboard data from SQL Server..."
  r1 <- DashboardRepo.getMssqlFileIoDashboard (CreateMssqlFileIoDashboardCommand "testdb")
  r2 <- DashboardRepo.getMssqlFileIoDashboard (CreateMssqlFileIoDashboardCommand "testdb2")
  r3 <- DashboardRepo.getMssqlFileIoDashboard (CreateMssqlFileIoDashboardCommand "testdb3")
  return
    ( MssqlHealthDashboard
        { isServerAlive = IsServerAlive True, -- 仮の値
          sqlServerName = "testServer", -- 仮の値
          sqlServerIp = "127.0.0.1", -- 仮の値
          mssqlFileIoDashboard = concat [r1, r2, r3] -- 取得したダッシュボードデータを結合
        }
    )
