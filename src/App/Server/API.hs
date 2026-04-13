{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE TypeOperators #-}

module App.Server.API
  ( API,
    HealthCheckAPI,
    SQLServerDashboardAPI,
    combinedAPI,
  )
where

import App.Presentation.Health.API (HealthCheckAPI)
import App.Presentation.SQLServerDashboard.API (SQLServerDashboardAPI)
import Servant

type API = HealthCheckAPI :<|> SQLServerDashboardAPI

combinedAPI :: Proxy API
combinedAPI = Proxy
