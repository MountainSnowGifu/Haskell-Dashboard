{-# LANGUAGE OverloadedStrings #-}

module Main where

import App.Core.Config (Config (..))
import App.Infrastructure.Database.SqlServer (createMSSQLPool)
import App.Server.Router (runServant)
import Configuration.Dotenv (defaultConfig, loadFile)
import qualified Database.MSSQLServer.Connection as MSSQL
import qualified Env

data DbEnv = DbEnv
  { dbHost :: String,
    dbPort :: String,
    dbName :: String,
    dbUser :: String,
    dbPassword :: String,
    dbPoolSize :: Int
  }

dbEnvParser :: Env.Parser Env.Error DbEnv
dbEnvParser =
  DbEnv
    <$> Env.var Env.str "MSSQL_HOST" (Env.help "SQL Server host")
    <*> Env.var Env.str "MSSQL_PORT" (Env.help "SQL Server port")
    <*> Env.var Env.str "MSSQL_DATABASE" (Env.help "SQL Server database name")
    <*> Env.var Env.str "MSSQL_USER" (Env.help "SQL Server user")
    <*> Env.var Env.str "MSSQL_PASSWORD" (Env.help "SQL Server password")
    <*> Env.var Env.auto "MSSQL_POOL_SIZE" (Env.help "SQL Server connection pool size")

main :: IO ()
main = do
  loadFile defaultConfig

  let servantConfig =
        Config
          { port = 8081,
            host = "localhost",
            monitoredDatabases = ["testdb", "testdb2", "testdb3"]
          }
  print servantConfig

  dbEnv <- Env.parse (Env.header "SQL Server configuration") dbEnvParser

  let sqlserverInfo =
        MSSQL.defaultConnectInfo
          { MSSQL.connectHost = dbHost dbEnv,
            MSSQL.connectPort = dbPort dbEnv,
            MSSQL.connectDatabase = dbName dbEnv,
            MSSQL.connectUser = dbUser dbEnv,
            MSSQL.connectPassword = dbPassword dbEnv
          }
  sqlserverPool <- createMSSQLPool sqlserverInfo (dbPoolSize dbEnv)

  runServant servantConfig sqlserverInfo sqlserverPool
