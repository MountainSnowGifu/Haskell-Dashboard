module App.Core.Config
  ( Config (..),
  )
where

import Data.Text (Text)

data Config = Config
  { port :: Int,
    host :: String,
    monitoredDatabases :: [Text]
  }
  deriving (Show)
