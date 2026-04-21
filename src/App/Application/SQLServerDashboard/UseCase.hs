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
import App.Domain.SQLServerDashboard.Entity
  ( MssqlDbHealthDashboard (..),
    MssqlHealthDashboard (..),
    MssqlOverallPerformanceDashboard (..),
  )
import App.Domain.SQLServerDashboard.ValueObject
  ( IsServerAlive (..),
    PerformanceCounterName (..),
    PerformanceCounterValue (..),
    PerformanceInstanceName (..),
    PerformanceObjectName (..),
    SqlServerDbName (..),
    SqlServerPort (..),
  )
import App.Infrastructure.Network.TCPCheck (checkTCPPort)
import Data.String (fromString)
import Data.Text (Text)
import Database.MSSQLServer.Connection (ConnectInfo (..))
import Effectful (Eff, IOE, liftIO, (:>))

type DashboardRunner = forall a. Eff '[DashboardRepo, IOE] a -> IO a

fetchMssqlFileIoDashboard :: (DashboardRepo :> es, IOE :> es) => ConnectInfo -> [Text] -> Eff es MssqlHealthDashboard
fetchMssqlFileIoDashboard cfg dbNames = do
  liftIO $ putStrLn "[DashboardRepo] fetching dashboard data from SQL Server..."
  let dbHost = connectHost cfg
      dbPort = connectPort cfg

  reachable <- liftIO $ checkTCPPort dbHost dbPort
  dbHealthDashboards <- mapM fetchDbDashboard dbNames
  return
    MssqlHealthDashboard
      { isServerAlive = IsServerAlive reachable,
        sqlServerPort = SqlServerPort (read dbPort),
        sqlServerIp = fromString dbHost,
        mssqlOverallPerformanceDashboard =
          [ MssqlOverallPerformanceDashboard
              { pdbObjectName = PerformanceObjectName "Overall", -- todo
                pdbCounterName = PerformanceCounterName "Counter",
                pdbInstanceName = PerformanceInstanceName "Instance",
                pdbCounterValue = PerformanceCounterValue 0
              }
          ],
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
