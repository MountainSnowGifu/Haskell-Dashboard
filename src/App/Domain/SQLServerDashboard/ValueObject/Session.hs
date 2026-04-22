{-# LANGUAGE GeneralizedNewtypeDeriving #-}

module App.Domain.SQLServerDashboard.ValueObject.Session
  ( SessionCount (..),
    unSessionCount,
    mkSessionCount,
    SessionId (..),
    Status (..),
    Command (..),
    CpuTime (..),
    TotalElapsedTime (..),
    Reads (..),
    Writes (..),
    LogicalReads (..),
  )
where

import Data.Text (Text)

newtype SessionCount = SessionCount Int
  deriving (Show, Eq, Ord)

unSessionCount :: SessionCount -> Int
unSessionCount (SessionCount n) = n

mkSessionCount :: Int -> Either String SessionCount
mkSessionCount n
  | n < 0 = Left $ "SessionCount must be non-negative: " <> show n
  | otherwise = Right (SessionCount n)

newtype SessionId = SessionId Int
  deriving (Show, Eq, Ord)

newtype Status = Status Text
  deriving (Show, Eq, Ord)

newtype Command = Command Text
  deriving (Show, Eq, Ord)

newtype CpuTime = CpuTime Int
  deriving (Show, Eq, Ord)

newtype TotalElapsedTime = TotalElapsedTime Int
  deriving (Show, Eq, Ord)

newtype Reads = Reads Int
  deriving (Show, Eq, Ord)

newtype Writes = Writes Int
  deriving (Show, Eq, Ord)

newtype LogicalReads = LogicalReads Int
  deriving (Show, Eq, Ord)
