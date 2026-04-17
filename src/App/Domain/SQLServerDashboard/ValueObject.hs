module App.Domain.SQLServerDashboard.ValueObject
  ( IsServerAlive (..),
    SqlServerName (..),
    SqlServerIp (..),
    SqlServerDbName (..),
    TypeDescription (..),
    NumOfReads (..),
    NumOfWrites (..),
  )
where

import Data.Text (Text)

newtype IsServerAlive = IsServerAlive Bool
  deriving (Show, Eq, Ord)

newtype SqlServerName = SqlServerName Text
  deriving (Show, Eq, Ord)

newtype SqlServerIp = SqlServerIp Text
  deriving (Show, Eq, Ord)

newtype SqlServerDbName = SqlServerDbName Text
  deriving (Show, Eq, Ord)

newtype TypeDescription = TypeDescription Text
  deriving (Show, Eq, Ord)

newtype NumOfReads = NumOfReads Int
  deriving (Show, Eq, Ord)

newtype NumOfWrites = NumOfWrites Int
  deriving (Show, Eq, Ord)