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
import App.Domain.SQLServerDashboard.Entity (MssqlDbHealthDashboard (..), MssqlHealthDashboard (..))
import App.Domain.SQLServerDashboard.ValueObject (IsServerAlive (..), SqlServerDbName (..))
import Data.Text (Text)
import Effectful (Eff, IOE, liftIO, (:>))

type DashboardRunner = forall a. Eff '[DashboardRepo, IOE] a -> IO a

fetchMssqlFileIoDashboard :: (DashboardRepo :> es, IOE :> es) => [Text] -> Eff es MssqlHealthDashboard
fetchMssqlFileIoDashboard dbNames = do
  liftIO $ putStrLn "[DashboardRepo] fetching dashboard data from SQL Server..."
  dbHealthDashboards <- mapM fetchDbDashboard dbNames
  return
    MssqlHealthDashboard
      { isServerAlive = IsServerAlive True, -- 仮の値
        sqlServerName = "testServer", -- 仮の値
        sqlServerIp = "127.0.0.1", -- 仮の値
        mssqlDbHealthDashboards = dbHealthDashboards
      }
  where
    fetchDbDashboard dbName = do
      let cmd = CreateMssqlFileIoDashboardCommand dbName
      fileIoRows <- DashboardRepo.getMssqlFileIoDashboard cmd
      sessionRow <- DashboardRepo.getMssqlSessionDashboard cmd
      activeRequestRows <- DashboardRepo.getMssqlActiveRequestDashboard cmd
      dbStatusRows <- DashboardRepo.getMssqlDbStatusDashboard cmd
      return
        MssqlDbHealthDashboard
          { dbhSqlServerDbName = SqlServerDbName dbName,
            dbhMssqlFileIoDashboard = fileIoRows,
            dbhMssqlSessionDashboard = sessionRow,
            dbhMsqlActiveRequestDashboard = activeRequestRows,
            dbhMssqlDbStatusDashboard = dbStatusRows
          }
