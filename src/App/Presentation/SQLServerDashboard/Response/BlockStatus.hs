{-# LANGUAGE DeriveGeneric #-}

module App.Presentation.SQLServerDashboard.Response.BlockStatus
  ( MssqlBlockStatusDashboardResponse (..),
    toBlockStatusResponse,
  )
where

import App.Domain.SQLServerDashboard.Entity (MssqlBlockStatusDashboard)
import qualified App.Domain.SQLServerDashboard.Entity as Entity
import App.Domain.SQLServerDashboard.ValueObject
  ( Command (..),
    HostName (..),
    LoginName (..),
    ProgramName (..),
    SessionId (..),
    SqlServerDbName (..),
    SqlText (..),
    Status (..),
    WaitResource (..),
    WaitTime (..),
    WaitType (..),
  )
import Data.Aeson (FromJSON, ToJSON)
import Data.Text (Text)
import GHC.Generics (Generic)

data MssqlBlockStatusDashboardResponse = MssqlBlockStatusDashboardResponse
  { bsResSessionId :: Int,
    bsResBlockingSessionId :: Int,
    bsResStatus :: Text,
    bsResWaitType :: Text,
    bsResWaitTime :: Text,
    bsResWaitResource :: Text,
    bsResCommand :: Text,
    bsResDatabaseName :: Text,
    bsResHostName :: Text,
    bsResProgramName :: Text,
    bsResLoginName :: Text,
    bsResSqlText :: Text
  }
  deriving (Show, Generic)

instance ToJSON MssqlBlockStatusDashboardResponse

instance FromJSON MssqlBlockStatusDashboardResponse

toBlockStatusResponse :: MssqlBlockStatusDashboard -> MssqlBlockStatusDashboardResponse
toBlockStatusResponse blockStatus =
  let SessionId sessionId = Entity.bsSessionId blockStatus
      SessionId blockingSessionId = Entity.bsBlockingSessionId blockStatus
      Status status = Entity.bsStatus blockStatus
      WaitType waitType = Entity.bsWaitType blockStatus
      WaitTime waitTime = Entity.bsWaitTime blockStatus
      WaitResource waitResource = Entity.bsWaitResource blockStatus
      Command command = Entity.bsCommand blockStatus
      SqlServerDbName dbName = Entity.bsDatabaseName blockStatus
      HostName hostName = Entity.bsHostName blockStatus
      ProgramName programName = Entity.bsProgramName blockStatus
      LoginName loginName = Entity.bsLoginName blockStatus
      SqlText sqlText = Entity.bsSqlText blockStatus
   in MssqlBlockStatusDashboardResponse
        { bsResSessionId = sessionId,
          bsResBlockingSessionId = blockingSessionId,
          bsResStatus = status,
          bsResWaitType = waitType,
          bsResWaitTime = waitTime,
          bsResWaitResource = waitResource,
          bsResCommand = command,
          bsResDatabaseName = dbName,
          bsResHostName = hostName,
          bsResProgramName = programName,
          bsResLoginName = loginName,
          bsResSqlText = sqlText
        }
