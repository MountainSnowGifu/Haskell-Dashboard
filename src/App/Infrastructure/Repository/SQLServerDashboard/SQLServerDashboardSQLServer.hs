{-# LANGUAGE DataKinds #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE GADTs #-}
{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TypeOperators #-}

module App.Infrastructure.Repository.SQLServerDashboard.SQLServerDashboardSQLServer
  ( runDashboardRepo,
  )
where

import App.Application.SQLServerDashboard.Repository (DashboardRepo (..))
import App.Domain.SQLServerDashboard.Entity (MssqlFileIoDashboard (..))
import App.Domain.SQLServerDashboard.ValueObject
  ( SqlServerDbName (..),
    TypeDescription (..),
    mkNumOfReads,
    mkNumOfWrites,
  )
import App.Infrastructure.Database.SqlServer (withMSSQLConn)
import App.Infrastructure.Database.Types (MSSQLPool)
import Data.Text (Text)
import qualified Data.Text.Lazy as LT
import Database.MSSQLServer.Query
  ( RpcQuery (..),
    RpcResponse (..),
    StoredProcedure (..),
    nvarcharVal,
    rpc,
  )
import Effectful
import Effectful.Dispatch.Dynamic (interpret)

-- (name, type_desc, num_of_reads, num_of_writes, avg_read_ms, avg_write_ms)
type FileIoRow = (LT.Text, LT.Text, Int, Int, Int, Int)

fileIoQuery :: Text
fileIoQuery =
  "SELECT \
  \    mf.name, \
  \    mf.type_desc, \
  \    vfs.num_of_reads, \
  \    vfs.num_of_writes, \
  \    CASE WHEN vfs.num_of_reads = 0 THEN 0 \
  \         ELSE vfs.io_stall_read_ms / vfs.num_of_reads END AS avg_read_ms, \
  \    CASE WHEN vfs.num_of_writes = 0 THEN 0 \
  \         ELSE vfs.io_stall_write_ms / vfs.num_of_writes END AS avg_write_ms \
  \FROM sys.dm_io_virtual_file_stats(NULL, NULL) vfs \
  \JOIN sys.master_files mf \
  \    ON vfs.database_id = mf.database_id \
  \   AND vfs.file_id = mf.file_id \
  \WHERE mf.database_id = DB_ID('testdb')"

rpcRows :: RpcResponse a b -> IO b
rpcRows (RpcResponse _ _ rs) = return rs
rpcRows (RpcResponseError info) = ioError (userError $ "SQL Server error: " ++ show info)

toEntity :: FileIoRow -> Either String MssqlFileIoDashboard
toEntity (name, typeDesc, numReads, numWrites, _, _) = do
  numOfReads' <- mkNumOfReads numReads
  numOfWrites' <- mkNumOfWrites numWrites
  return
    MssqlFileIoDashboard
      { sqlServerDbName = SqlServerDbName (LT.toStrict name),
        typeDescription = TypeDescription (LT.toStrict typeDesc),
        numOfReads = numOfReads',
        numOfWrites = numOfWrites'
      }

runDashboardRepo ::
  (IOE :> es) =>
  MSSQLPool ->
  Eff (DashboardRepo : es) a ->
  Eff es a
runDashboardRepo pool = interpret $ \_ -> \case
  FetchMssqlFileIoDashboardOp ->
    liftIO $ withMSSQLConn pool $ \conn -> do
      putStrLn "[DashboardRepo] fetching dashboard data from SQL Server..."
      rows <-
        rpcRows
          =<< ( rpc
                  conn
                  ( RpcQuery
                      SP_ExecuteSql
                      (nvarcharVal "" (Just fileIoQuery))
                  ) ::
                  IO (RpcResponse () [FileIoRow])
              )
      case rows of
        [] -> return Nothing
        row : _ -> either (ioError . userError) (return . Just) (toEntity row)
