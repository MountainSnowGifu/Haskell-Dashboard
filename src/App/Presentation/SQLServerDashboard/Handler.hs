{-# LANGUAGE DataKinds #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RankNTypes #-}

module App.Presentation.SQLServerDashboard.Handler
  ( SqlServerDashboardRunner,
    sqlServerDashboardHandler,
  )
where

import App.Application.SQLServerDashboard.Repository (DashboardRepo)
import App.Domain.SQLServerDashboard.Entity (MssqlFileIoDashboard (..))
import App.Domain.SQLServerDashboard.ValueObject (NumOfReads (..), NumOfWrites (..), SqlServerDbName (..), TypeDescription (..))
import App.Presentation.SQLServerDashboard.Response (SQLServerDashboardResponse, toCreatedBoardResponse)
import Effectful (Eff, IOE)
import Servant

type SqlServerDashboardRunner = forall a. Eff '[DashboardRepo, IOE] a -> IO a

sqlServerDashboardHandler :: SqlServerDashboardRunner -> Handler SQLServerDashboardResponse
sqlServerDashboardHandler _runner = do
  let dashboard =
        MssqlFileIoDashboard
          { sqlServerDbName = SqlServerDbName "SampleDB",
            typeDescription = TypeDescription "Data File",
            numOfReads = NumOfReads 100,
            numOfWrites = NumOfWrites 50
          }
  return $ toCreatedBoardResponse dashboard
