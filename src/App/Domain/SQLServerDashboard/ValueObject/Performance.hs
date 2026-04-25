module App.Domain.SQLServerDashboard.ValueObject.Performance
  ( PerformanceObjectName,
    PerformanceCounterName,
    PerformanceCounterValue (..),
    mkPerformanceInstanceName,
    PerformanceInstanceName,
    mkPerformanceCounterName,
    mkPerformanceObjectName,
    unPerformanceObjectName,
    unPerformanceCounterName,
    unPerformanceInstanceName,
  )
where

import Data.Text (Text)
import qualified Data.Text as Text

newtype PerformanceObjectName = PerformanceObjectName Text
  deriving (Show, Eq, Ord)

mkPerformanceObjectName :: Text -> PerformanceObjectName
mkPerformanceObjectName name =
  let trimmedName = Text.strip name
   in PerformanceObjectName trimmedName

unPerformanceObjectName :: PerformanceObjectName -> Text
unPerformanceObjectName (PerformanceObjectName t) = t

newtype PerformanceCounterName = PerformanceCounterName Text
  deriving (Show, Eq, Ord)

mkPerformanceCounterName :: Text -> PerformanceCounterName
mkPerformanceCounterName name =
  let trimmedName = Text.strip name
   in PerformanceCounterName trimmedName

unPerformanceCounterName :: PerformanceCounterName -> Text
unPerformanceCounterName (PerformanceCounterName t) = t

newtype PerformanceInstanceName = PerformanceInstanceName Text
  deriving (Show, Eq, Ord)

mkPerformanceInstanceName :: Text -> PerformanceInstanceName
mkPerformanceInstanceName name =
  let trimmedName = Text.strip name
   in PerformanceInstanceName trimmedName

unPerformanceInstanceName :: PerformanceInstanceName -> Text
unPerformanceInstanceName (PerformanceInstanceName t) = t

newtype PerformanceCounterValue = PerformanceCounterValue Int -- todo trim スマートコンストラクタ
  deriving (Show, Eq, Ord)
