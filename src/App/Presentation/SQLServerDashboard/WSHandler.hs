{-# LANGUAGE ScopedTypeVariables #-}

module App.Presentation.SQLServerDashboard.WSHandler
  ( sqlServerDashboardWSHandler,
  )
where

import App.Infrastructure.Broadcast.Channel (BroadcastChannel, subscribe)
import App.Presentation.SQLServerDashboard.Response (SQLServerDashboardResponse)
import Control.Concurrent.STM
import Control.Exception (SomeException, try)
import Control.Monad (forever)
import Data.Aeson (encode)
import Network.WebSockets

sqlServerDashboardWSHandler ::
  TVar (Maybe SQLServerDashboardResponse) ->
  BroadcastChannel SQLServerDashboardResponse ->
  ServerApp
sqlServerDashboardWSHandler latestRef chan pendingConn = do
  conn <- acceptRequest pendingConn
  withPingThread conn 30 (return ()) $ do
    mLatest <- readTVarIO latestRef
    mapM_ (sendTextData conn . encode) mLatest
    readChan <- atomically (subscribe chan)
    let loop = forever $ do
          val <- atomically (readTChan readChan)
          sendTextData conn (encode val)
    _ <- (try loop :: IO (Either SomeException ()))
    return ()
