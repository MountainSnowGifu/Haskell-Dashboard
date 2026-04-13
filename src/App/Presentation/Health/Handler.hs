module App.Presentation.Health.Handler
  ( healthHandler,
  )
where

import App.Infrastructure.Network.TCPCheck (checkTCPPort)
import App.Presentation.Health.Response (HealthResponse (..))
import Control.Monad.IO.Class (liftIO)
import Data.Text (pack)
import Servant

healthHandler :: Handler HealthResponse
healthHandler = do
  dbReachable <- liftIO $ checkTCPPort "127.0.0.1" "1433"
  let dbStatus = if dbReachable then pack "ok" else pack "unreachable"
  return $ HealthResponse {status = pack "ok", db = dbStatus}
