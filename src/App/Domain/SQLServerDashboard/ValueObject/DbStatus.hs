{-# LANGUAGE GeneralizedNewtypeDeriving #-}

module App.Domain.SQLServerDashboard.ValueObject.DbStatus
  ( StateDesc (..),
    RecoveryModelDesc (..),
    UserAccessDesc (..),
  )
where

import Data.Text (Text)

newtype StateDesc = StateDesc Text
  deriving (Show, Eq, Ord)

newtype RecoveryModelDesc = RecoveryModelDesc Text
  deriving (Show, Eq, Ord)

newtype UserAccessDesc = UserAccessDesc Text
  deriving (Show, Eq, Ord)
