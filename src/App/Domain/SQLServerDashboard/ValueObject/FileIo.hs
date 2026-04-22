{-# LANGUAGE GeneralizedNewtypeDeriving #-}

module App.Domain.SQLServerDashboard.ValueObject.FileIo
  ( TypeDescription (..),
    NumOfReads,
    unNumOfReads,
    mkNumOfReads,
    NumOfWrites,
    unNumOfWrites,
    mkNumOfWrites,
    AvgReadMs,
    unAvgReadMs,
    mkAvgReadMs,
    AvgWriteMs,
    unAvgWriteMs,
    mkAvgWriteMs,
  )
where

import Data.Text (Text)

newtype TypeDescription = TypeDescription Text
  deriving (Show, Eq, Ord)

newtype NumOfReads = NumOfReads Int
  deriving (Show, Eq, Ord)

unNumOfReads :: NumOfReads -> Int
unNumOfReads (NumOfReads n) = n

mkNumOfReads :: Int -> Either String NumOfReads
mkNumOfReads n
  | n < 0 = Left $ "NumOfReads must be non-negative: " <> show n
  | otherwise = Right (NumOfReads n)

newtype NumOfWrites = NumOfWrites Int
  deriving (Show, Eq, Ord)

unNumOfWrites :: NumOfWrites -> Int
unNumOfWrites (NumOfWrites n) = n

mkNumOfWrites :: Int -> Either String NumOfWrites
mkNumOfWrites n
  | n < 0 = Left $ "NumOfWrites must be non-negative: " <> show n
  | otherwise = Right (NumOfWrites n)

newtype AvgReadMs = AvgReadMs Int
  deriving (Show, Eq, Ord)

unAvgReadMs :: AvgReadMs -> Int
unAvgReadMs (AvgReadMs n) = n

mkAvgReadMs :: Int -> Either String AvgReadMs
mkAvgReadMs n
  | n < 0 = Left $ "AvgReadMs must be non-negative: " <> show n
  | otherwise = Right (AvgReadMs n)

newtype AvgWriteMs = AvgWriteMs Int
  deriving (Show, Eq, Ord)

unAvgWriteMs :: AvgWriteMs -> Int
unAvgWriteMs (AvgWriteMs n) = n

mkAvgWriteMs :: Int -> Either String AvgWriteMs
mkAvgWriteMs n
  | n < 0 = Left $ "AvgWriteMs must be non-negative: " <> show n
  | otherwise = Right (AvgWriteMs n)
