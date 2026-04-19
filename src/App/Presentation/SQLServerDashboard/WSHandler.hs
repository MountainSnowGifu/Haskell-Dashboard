{-# LANGUAGE ScopedTypeVariables #-}

module App.Presentation.SQLServerDashboard.WSHandler
  ( sqlServerDashboardWSHandler,
  )
where

import App.Application.SQLServerDashboard.Subscription
  ( DashboardSubscription (..),
  )
import App.Presentation.SQLServerDashboard.Response (toMssqlHealthDashboardResponse)
import Control.Concurrent.STM (TVar, atomically, modifyTVar', readTVar)
import Control.Exception (SomeException, finally, try)
import Control.Monad (forever)
import Data.Aeson (encode)
import Network.WebSockets

sqlServerDashboardWSHandler ::
  DashboardSubscription ->
  TVar Int ->
  ServerApp
sqlServerDashboardWSHandler sub connCountRef pendingConn = do
  conn <- acceptRequest pendingConn
  connectedCount <- atomically $ do
    modifyTVar' connCountRef (+ 1)
    readTVar connCountRef
  putStrLn $ "[WS] connected. connections: " <> show connectedCount
  finally
    ( withPingThread conn 30 (return ()) $ do
        mLatest <- getLatestDashboard sub
        sendTextData conn (encode (toMssqlHealthDashboardResponse mLatest))
        readNext <- subscribeUpdates sub
        let loop = forever $ do
              val <- readNext
              sendTextData conn (encode (toMssqlHealthDashboardResponse val))
        _ <- (try loop :: IO (Either SomeException ()))
        return ()
    )
    ( do
        disconnectedCount <- atomically $ do
          modifyTVar' connCountRef (subtract 1)
          readTVar connCountRef
        putStrLn $ "[WS] disconnected. connections: " <> show disconnectedCount
    )
