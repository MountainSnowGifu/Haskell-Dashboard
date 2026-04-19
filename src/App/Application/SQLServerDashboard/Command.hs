{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE DuplicateRecordFields #-}

module App.Application.SQLServerDashboard.Command
  ( CreateMssqlFileIoDashboardCommand (..),
  )
where

import Data.Text (Text)
import GHC.Generics (Generic)

newtype CreateMssqlFileIoDashboardCommand
  = CreateMssqlFileIoDashboardCommand {cmdDbName :: Text}
  deriving (Show, Eq, Generic)