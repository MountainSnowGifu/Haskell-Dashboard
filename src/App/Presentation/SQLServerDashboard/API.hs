{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeOperators #-}

module App.Presentation.SQLServerDashboard.API
  ( SQLServerDashboardAPI,
  )
where

import App.Presentation.SQLServerDashboard.Response
import Servant

type SQLServerDashboardAPI =
  "sqlserver-dashboard" :> Get '[JSON] SQLServerDashboardResponse
    :<|> "sqlserver-dashboard" :> "ws" :> Raw