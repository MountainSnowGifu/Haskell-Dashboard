module App.Domain.SQLServerDashboard.ValueObject
  ( IsServerAlive (..),
    SqlServerName (..),
  )
where

import Data.Text (Text)

newtype IsServerAlive = IsServerAlive Bool
  deriving (Show, Eq, Ord)

newtype SqlServerName = SqlServerName Text
  deriving (Show, Eq, Ord)
