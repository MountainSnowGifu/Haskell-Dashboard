{-# LANGUAGE GeneralizedNewtypeDeriving #-}

module App.Domain.SQLServerDashboard.ValueObject.Performance
  ( PerformanceObjectName (..),
    PerformanceCounterName (..),
    PerformanceInstanceName (..),
    PerformanceCounterValue (..),
  )
where

import Data.Text (Text)

newtype PerformanceObjectName = PerformanceObjectName Text
  deriving (Show, Eq, Ord)

newtype PerformanceCounterName = PerformanceCounterName Text
  deriving (Show, Eq, Ord)

newtype PerformanceInstanceName = PerformanceInstanceName Text
  deriving (Show, Eq, Ord)

newtype PerformanceCounterValue = PerformanceCounterValue Int -- todo trim スマートコンストラクタ
  deriving (Show, Eq, Ord)
