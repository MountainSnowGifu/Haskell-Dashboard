{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeOperators #-}

module App.Presentation.SQLServerDashboard.API
  ( SQLServerDashboardAPI,
  )
where

import App.Presentation.SQLServerDashboard.Response
import Servant

type SQLServerDashboardAPI =
  "sqlserver-dashboard" :> Get '[JSON] [MssqlHealthDashboardResponse]
    :<|> "sqlserver-dashboard" :> "ws" :> Raw
    :<|> "sqlserver-dashboard" :> "connections" :> Get '[JSON] ConnectionCountResponse