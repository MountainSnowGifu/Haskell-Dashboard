module App.Presentation.Health.Handler
  ( healthHandler,
  )
where

import App.Application.Health.UseCase (checkHealth, dbReachable)
import App.Presentation.Health.Response (HealthResponse (..))
import Control.Monad.IO.Class (liftIO)
import Data.Text (pack)
import Database.MSSQLServer.Connection (ConnectInfo (..))
import Servant

healthHandler :: ConnectInfo -> Handler HealthResponse
healthHandler cfg = do
  result <- liftIO $ checkHealth (connectHost cfg) (connectPort cfg)
  let dbStatus = if dbReachable result then pack "ok" else pack "unreachable"
  return $ HealthResponse {status = pack "ok", db = dbStatus}
