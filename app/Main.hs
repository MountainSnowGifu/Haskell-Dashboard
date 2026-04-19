{-# LANGUAGE OverloadedStrings #-}

module Main where

import App.Core.Config (Config (..))
import App.Infrastructure.Database.SqlServer (createMSSQLPool)
import App.Server.Router (runServant)
import qualified Database.MSSQLServer.Connection as MSSQL

main :: IO ()
main = do
  let servantConfig =
        Config
          { port = 8081,
            host = "localhost",
            monitoredDatabases = ["testdb", "testdb2", "testdb3"]
          }
  print servantConfig

  let sqlserverInfo =
        MSSQL.defaultConnectInfo
          { MSSQL.connectHost = "127.0.0.1",
            MSSQL.connectPort = "1433",
            MSSQL.connectDatabase = "master",
            MSSQL.connectUser = "sa",
            MSSQL.connectPassword = "MyPass@word1"
          }
  sqlserverPool <- createMSSQLPool sqlserverInfo 10

  runServant servantConfig sqlserverPool
