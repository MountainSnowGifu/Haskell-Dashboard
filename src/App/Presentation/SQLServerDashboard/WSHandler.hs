{-# LANGUAGE ScopedTypeVariables #-}

module App.Presentation.SQLServerDashboard.WSHandler
  ( sqlServerDashboardWSHandler,
  )
where

import App.Application.SQLServerDashboard.Subscription
  ( DashboardSubscription (..),
  )
import App.Presentation.SQLServerDashboard.Response (toDashboardResponse)
import Control.Concurrent.STM
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
        mapM_ (sendTextData conn . encode . toDashboardResponse) mLatest
        readChan <- atomically (subscribeDashboardUpdates sub)
        let loop = forever $ do
              val <- atomically (readTChan readChan)
              sendTextData conn (encode (toDashboardResponse val))
        _ <- (try loop :: IO (Either SomeException ()))
        return ()
    )
    ( do
        disconnectedCount <- atomically $ do
          modifyTVar' connCountRef (subtract 1)
          readTVar connCountRef
        putStrLn $ "[WS] disconnected. connections: " <> show disconnectedCount
    )
