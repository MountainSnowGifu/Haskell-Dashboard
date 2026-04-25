{-# LANGUAGE DataKinds #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE GADTs #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE TypeOperators #-}

module App.Application.SQLServerDashboard.ServerReachability
  ( ServerReachability (..),
    checkServerReachable,
  )
where

import Effectful
import Effectful.Dispatch.Dynamic (send)

data ServerReachability :: Effect where
  CheckServerReachable :: String -> String -> ServerReachability m Bool

type instance DispatchOf ServerReachability = Dynamic

checkServerReachable :: (ServerReachability :> es) => String -> String -> Eff es Bool
checkServerReachable host port = send (CheckServerReachable host port)
