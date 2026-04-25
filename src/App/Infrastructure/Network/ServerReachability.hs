{-# LANGUAGE DataKinds #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE GADTs #-}
{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE TypeOperators #-}

module App.Infrastructure.Network.ServerReachability
  ( runServerReachability,
  )
where

import App.Application.SQLServerDashboard.ServerReachability (ServerReachability (..))
import App.Infrastructure.Network.TCPCheck (checkTCPPort)
import Effectful
import Effectful.Dispatch.Dynamic (interpret)

runServerReachability :: (IOE :> es) => Eff (ServerReachability : es) a -> Eff es a
runServerReachability = interpret $ \_env -> \case
  CheckServerReachable host port -> liftIO (checkTCPPort host port)
