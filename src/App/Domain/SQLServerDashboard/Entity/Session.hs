{-# LANGUAGE DeriveGeneric #-}

module App.Domain.SQLServerDashboard.Entity.Session
  ( MssqlSessionDashboard (..),
  )
where

import App.Domain.SQLServerDashboard.ValueObject
  ( SessionCount,
    SqlServerDbName,
  )
import GHC.Generics (Generic)

data MssqlSessionDashboard = MssqlSessionDashboard
  { sessionCount :: SessionCount,
    sessionSqlServerDbName :: SqlServerDbName
  }
  deriving (Show, Eq, Generic)
