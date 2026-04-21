module App.Application.Health.UseCase
  ( HealthStatus (..),
    checkHealth,
  )
where

import App.Infrastructure.Network.TCPCheck (checkTCPPort)

newtype HealthStatus = HealthStatus {dbReachable :: Bool}

checkHealth :: String -> String -> IO HealthStatus
checkHealth host port = do
  reachable <- checkTCPPort host port
  print reachable
  return $ HealthStatus {dbReachable = reachable}
