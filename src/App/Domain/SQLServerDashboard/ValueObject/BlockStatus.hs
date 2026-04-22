module App.Domain.SQLServerDashboard.ValueObject.BlockStatus
  ( WaitType (..),
    WaitTime (..),
    WaitResource (..),
    HostName (..),
    ProgramName (..),
    LoginName (..),
    SqlText (..),
  )
where

import Data.Text (Text)

newtype WaitType = WaitType Text
  deriving (Show, Eq, Ord)

newtype WaitTime = WaitTime Text
  deriving (Show, Eq, Ord)

newtype WaitResource = WaitResource Text
  deriving (Show, Eq, Ord)

newtype HostName = HostName Text
  deriving (Show, Eq, Ord)

newtype ProgramName = ProgramName Text
  deriving (Show, Eq, Ord)

newtype LoginName = LoginName Text
  deriving (Show, Eq, Ord)

newtype SqlText = SqlText Text
  deriving (Show, Eq, Ord)
