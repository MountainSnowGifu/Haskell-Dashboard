{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeOperators #-}

module App.Presentation.Health.API
  ( HealthCheckAPI,
  )
where

import App.Presentation.Health.Response (HealthResponse)
import Servant

type HealthCheckAPI = "health" :> Get '[JSON] HealthResponse
