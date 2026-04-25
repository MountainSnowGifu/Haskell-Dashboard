{-# LANGUAGE OverloadedStrings #-}

module Main where

import App.Core.Config (Config (..))
import App.Infrastructure.Database.SqlServer (createMSSQLPool)
import App.Server.Router (runServant)
import qualified Database.MSSQLServer.Connection as MSSQL
import Data.List (isPrefixOf)
import System.Environment (getEnv, setEnv)
import System.IO.Error (catchIOError, isDoesNotExistError)

loadDotEnv :: FilePath -> IO ()
loadDotEnv path = do
  contents <- readFile path `catchIOError` \e ->
    if isDoesNotExistError e then return "" else ioError e
  mapM_ setEnvLine (lines contents)
  where
    setEnvLine line
      | "#" `isPrefixOf` line = return ()
      | null line = return ()
      | otherwise =
          let (key, rest) = break (== '=') line
           in case rest of
                ('=' : val) -> setEnv key val
                _ -> return ()

main :: IO ()
main = do
  loadDotEnv ".env"

  let servantConfig =
        Config
          { port = 8081,
            host = "localhost",
            monitoredDatabases = ["testdb", "testdb2", "testdb3"]
          }
  print servantConfig

  dbHost <- getEnv "MSSQL_HOST"
  dbPort <- getEnv "MSSQL_PORT"
  dbDatabase <- getEnv "MSSQL_DATABASE"
  dbUser <- getEnv "MSSQL_USER"
  dbPassword <- getEnv "MSSQL_PASSWORD"
  dbPoolSize <- read <$> getEnv "MSSQL_POOL_SIZE"

  let sqlserverInfo =
        MSSQL.defaultConnectInfo
          { MSSQL.connectHost = dbHost,
            MSSQL.connectPort = dbPort,
            MSSQL.connectDatabase = dbDatabase,
            MSSQL.connectUser = dbUser,
            MSSQL.connectPassword = dbPassword
          }
  sqlserverPool <- createMSSQLPool sqlserverInfo dbPoolSize

  runServant servantConfig sqlserverInfo sqlserverPool
