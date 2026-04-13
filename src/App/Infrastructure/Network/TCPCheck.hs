module App.Infrastructure.Network.TCPCheck
  ( checkTCPPort,
  )
where

import Control.Exception (SomeException, try)
import Network.Socket

checkTCPPort :: String -> String -> IO Bool
checkTCPPort host port = do
  let hints = defaultHints {addrSocketType = Stream}
  result <- try $ do
    addrs <- getAddrInfo (Just hints) (Just host) (Just port)
    case addrs of
      [] -> return False
      (addr : _) -> do
        sock <- socket (addrFamily addr) Stream defaultProtocol
        connect sock (addrAddress addr)
        close sock
        return True
  return $ case (result :: Either SomeException Bool) of
    Left _ -> False
    Right b -> b
