{-# LANGUAGE DataKinds #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE GADTs #-}
{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TypeOperators #-}

module App.Infrastructure.Repository.SQLServerDashboard.SQLServerDashboardSQLServer
  ( runDashboardRepo,
  )
where

import App.Application.SQLServerDashboard.Repository (DashboardRepo (..))
import App.Domain.SQLServerDashboard.Entity (MssqlFileIoDashboard (..))
import App.Domain.SQLServerDashboard.ValueObject
  ( NumOfReads (..),
    NumOfWrites (..),
    SqlServerDbName (..),
    TypeDescription (..),
  )
import App.Infrastructure.Database.Types (MSSQLPool)
import Effectful
import Effectful.Dispatch.Dynamic (interpret)

runDashboardRepo ::
  (IOE :> es) =>
  MSSQLPool ->
  Eff (DashboardRepo : es) a ->
  Eff es a
runDashboardRepo _pool = interpret $ \_env -> \case
  FetchMssqlFileIoDashboardOp ->
    return $
      Just $
        MssqlFileIoDashboard
          { sqlServerDbName = SqlServerDbName "SampleDB",
            typeDescription = TypeDescription "Data File",
            numOfReads = NumOfReads 100,
            numOfWrites = NumOfWrites 50
          }
