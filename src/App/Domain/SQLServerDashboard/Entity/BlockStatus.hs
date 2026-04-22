{-# LANGUAGE DeriveGeneric #-}

module App.Domain.SQLServerDashboard.Entity.BlockStatus
  ( MssqlBlockStatusDashboard (..),
  )
where

import App.Domain.SQLServerDashboard.ValueObject
  ( Command,
    HostName,
    LoginName,
    ProgramName,
    SessionId,
    SqlServerDbName,
    SqlText,
    Status,
    WaitResource,
    WaitTime,
    WaitType,
  )
import GHC.Generics (Generic)

data MssqlBlockStatusDashboard = MssqlBlockStatusDashboard
  { bsSessionId :: SessionId,
    bsBlockingSessionId :: SessionId,
    bsStatus :: Status,
    bsWaitType :: WaitType,
    bsWaitTime :: WaitTime,
    bsWaitResource :: WaitResource,
    bsCommand :: Command,
    bsDatabaseName :: SqlServerDbName,
    bsHostName :: HostName,
    bsProgramName :: ProgramName,
    bsLoginName :: LoginName,
    bsSqlText :: SqlText
  }
  deriving (Show, Eq, Generic)
