{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{-# LANGUAGE OverloadedStrings #-}

module App.Domain.SQLServerDashboard.ValueObject
  ( IsServerAlive (..),
    SqlServerName,
    unSqlServerName,
    mkSqlServerName,
    SqlServerIp,
    unSqlServerIp,
    mkSqlServerIp,
    SqlServerDbName (..),
    TypeDescription (..),
    NumOfReads,
    unNumOfReads,
    mkNumOfReads,
    NumOfWrites,
    unNumOfWrites,
    mkNumOfWrites,
    AvgReadMs,
    unAvgReadMs,
    mkAvgReadMs,
    AvgWriteMs,
    unAvgWriteMs,
    mkAvgWriteMs,
    SessionCount (..),
    unSessionCount,
    mkSessionCount,
    SessionId (..),
    Status (..),
    Command (..),
    CpuTime (..),
    TotalElapsedTime (..),
    Reads (..),
    Writes (..),
    LogicalReads (..),
  )
where

import Data.String (IsString)
import Data.Text (Text)
import qualified Data.Text as T

newtype IsServerAlive = IsServerAlive Bool
  deriving (Show, Eq, Ord)

newtype SqlServerName = SqlServerName Text
  deriving (Show, Eq, Ord, IsString)

unSqlServerName :: SqlServerName -> Text
unSqlServerName (SqlServerName t) = t

mkSqlServerName :: Text -> Either String SqlServerName
mkSqlServerName t
  | T.null t = Left "SqlServerName must not be empty"
  | otherwise = Right (SqlServerName t)

newtype SqlServerIp = SqlServerIp Text
  deriving (Show, Eq, Ord, IsString)

unSqlServerIp :: SqlServerIp -> Text
unSqlServerIp (SqlServerIp t) = t

-- | IPv4 (e.g. "192.168.0.1") or "localhost" を受け付ける
mkSqlServerIp :: Text -> Either String SqlServerIp
mkSqlServerIp t
  | T.null t = Left "SqlServerIp must not be empty"
  | t == "localhost" = Right (SqlServerIp t)
  | isValidIpv4 t = Right (SqlServerIp t)
  | otherwise = Left $ "SqlServerIp is not a valid IPv4 address or 'localhost': " <> T.unpack t

isValidIpv4 :: Text -> Bool
isValidIpv4 t =
  let parts = T.splitOn "." t
   in length parts == 4 && all isOctet parts
  where
    isOctet part =
      not (T.null part)
        && T.all (`elem` ['0' .. '9']) part
        && let n = read (T.unpack part) :: Int in n >= 0 && n <= 255

newtype SqlServerDbName = SqlServerDbName Text
  deriving (Show, Eq, Ord)

newtype TypeDescription = TypeDescription Text
  deriving (Show, Eq, Ord)

newtype NumOfReads = NumOfReads Int
  deriving (Show, Eq, Ord)

unNumOfReads :: NumOfReads -> Int
unNumOfReads (NumOfReads n) = n

mkNumOfReads :: Int -> Either String NumOfReads
mkNumOfReads n
  | n < 0 = Left $ "NumOfReads must be non-negative: " <> show n
  | otherwise = Right (NumOfReads n)

newtype NumOfWrites = NumOfWrites Int
  deriving (Show, Eq, Ord)

unNumOfWrites :: NumOfWrites -> Int
unNumOfWrites (NumOfWrites n) = n

mkNumOfWrites :: Int -> Either String NumOfWrites
mkNumOfWrites n
  | n < 0 = Left $ "NumOfWrites must be non-negative: " <> show n
  | otherwise = Right (NumOfWrites n)

newtype AvgReadMs = AvgReadMs Int
  deriving (Show, Eq, Ord)

unAvgReadMs :: AvgReadMs -> Int
unAvgReadMs (AvgReadMs n) = n

mkAvgReadMs :: Int -> Either String AvgReadMs
mkAvgReadMs n
  | n < 0 = Left $ "AvgReadMs must be non-negative: " <> show n
  | otherwise = Right (AvgReadMs n)

newtype AvgWriteMs = AvgWriteMs Int
  deriving (Show, Eq, Ord)

unAvgWriteMs :: AvgWriteMs -> Int
unAvgWriteMs (AvgWriteMs n) = n

mkAvgWriteMs :: Int -> Either String AvgWriteMs
mkAvgWriteMs n
  | n < 0 = Left $ "AvgWriteMs must be non-negative: " <> show n
  | otherwise = Right (AvgWriteMs n)

newtype SessionCount = SessionCount Int
  deriving (Show, Eq, Ord)

unSessionCount :: SessionCount -> Int
unSessionCount (SessionCount n) = n

mkSessionCount :: Int -> Either String SessionCount
mkSessionCount n
  | n < 0 = Left $ "SessionCount must be non-negative: " <> show n
  | otherwise = Right (SessionCount n)

newtype SessionId = SessionId Int
  deriving (Show, Eq, Ord)

newtype Status = Status Text
  deriving (Show, Eq, Ord)

newtype Command = Command Text
  deriving (Show, Eq, Ord)

newtype CpuTime = CpuTime Int
  deriving (Show, Eq, Ord)

newtype TotalElapsedTime = TotalElapsedTime Int
  deriving (Show, Eq, Ord)

newtype Reads = Reads Int
  deriving (Show, Eq, Ord)

newtype Writes = Writes Int
  deriving (Show, Eq, Ord)

newtype LogicalReads = LogicalReads Int
  deriving (Show, Eq, Ord)
