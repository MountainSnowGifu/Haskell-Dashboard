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
  )
where

import Data.Text (Text)
import qualified Data.Text as T

newtype IsServerAlive = IsServerAlive Bool
  deriving (Show, Eq, Ord)

newtype SqlServerName = SqlServerName Text
  deriving (Show, Eq, Ord)

unSqlServerName :: SqlServerName -> Text
unSqlServerName (SqlServerName t) = t

mkSqlServerName :: Text -> Either String SqlServerName
mkSqlServerName t
  | T.null t = Left "SqlServerName must not be empty"
  | otherwise = Right (SqlServerName t)

newtype SqlServerIp = SqlServerIp Text
  deriving (Show, Eq, Ord)

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
