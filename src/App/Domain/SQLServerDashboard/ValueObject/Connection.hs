{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{-# LANGUAGE OverloadedStrings #-}

module App.Domain.SQLServerDashboard.ValueObject.Connection
  ( IsServerAlive (..),
    SqlServerIp,
    unSqlServerIp,
    mkSqlServerIp,
    SqlServerPort (..),
    unSqlServerPort,
    SqlServerDbName (..),
  )
where

import Data.String (IsString)
import Data.Text (Text)
import qualified Data.Text as T

newtype IsServerAlive = IsServerAlive Bool
  deriving (Show, Eq, Ord)

newtype SqlServerPort = SqlServerPort Int
  deriving (Show, Eq, Ord)

unSqlServerPort :: SqlServerPort -> Int
unSqlServerPort (SqlServerPort n) = n

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
