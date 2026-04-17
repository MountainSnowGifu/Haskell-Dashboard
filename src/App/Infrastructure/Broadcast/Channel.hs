module App.Infrastructure.Broadcast.Channel
  ( BroadcastChannel,
    newBroadcastChannel,
    subscribe,
    publish,
  )
where

import Control.Concurrent.STM

newtype BroadcastChannel a = BroadcastChannel (TChan a)

newBroadcastChannel :: IO (BroadcastChannel a)
newBroadcastChannel = BroadcastChannel <$> atomically newBroadcastTChan

subscribe :: BroadcastChannel a -> STM (TChan a)
subscribe (BroadcastChannel chan) = dupTChan chan

publish :: BroadcastChannel a -> a -> IO ()
publish (BroadcastChannel chan) val = atomically (writeTChan chan val)
