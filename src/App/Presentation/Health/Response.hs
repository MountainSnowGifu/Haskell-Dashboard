{-# LANGUAGE DeriveGeneric #-}

module App.Presentation.Health.Response
  ( HealthResponse (..),
  )
where

import Data.Aeson (ToJSON)
import Data.Text (Text)
import GHC.Generics (Generic)

data HealthResponse = HealthResponse
  { status :: Text,
    db :: Text
  }
  deriving (Show, Generic)

instance ToJSON HealthResponse
