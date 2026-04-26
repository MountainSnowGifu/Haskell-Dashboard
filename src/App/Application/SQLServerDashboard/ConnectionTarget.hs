module App.Application.SQLServerDashboard.ConnectionTarget
  ( SqlServerConnectionTarget (..),
  )
where

data SqlServerConnectionTarget = SqlServerConnectionTarget
  { sqlServerHost :: String,
    sqlServerPortText :: String
  }
  deriving (Show, Eq)
