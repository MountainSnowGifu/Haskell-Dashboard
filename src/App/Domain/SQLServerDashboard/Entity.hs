{-# LANGUAGE DeriveGeneric #-}

module App.Domain.SQLServerDashboard.Entity
  ( MssqlHealthDashboard (..),
  )
where

-- MssqlHealthDashboard

import App.Domain.SQLServerDashboard.ValueObject (IsServerAlive, SqlServerName)
import GHC.Generics (Generic)

data MssqlHealthDashboard = MssqlHealthDashboard
  { isServerAlive :: IsServerAlive,
    sqlServerName :: SqlServerName
  }
  deriving (Show, Eq, Generic)