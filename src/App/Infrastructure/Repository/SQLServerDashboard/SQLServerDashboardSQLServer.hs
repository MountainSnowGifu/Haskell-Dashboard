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

import App.Application.SQLServerDashboard.Command (CreateMssqlFileIoDashboardCommand (..))
import App.Application.SQLServerDashboard.Repository (DashboardRepo (..))
import App.Domain.SQLServerDashboard.Entity (MssqlActiveRequestDashboard (..), MssqlFileIoDashboard (..), MssqlSessionDashboard (..))
import App.Domain.SQLServerDashboard.ValueObject
  ( Command (..),
    CpuTime (..),
    LogicalReads (..),
    Reads (..),
    SessionId (..),
    SqlServerDbName (..),
    Status (..),
    TotalElapsedTime (..),
    TypeDescription (..),
    Writes (..),
    mkAvgReadMs,
    mkAvgWriteMs,
    mkNumOfReads,
    mkNumOfWrites,
    mkSessionCount,
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

-- (db_name, session_count)
type SessionRow = (LT.Text, Int)

-- (name, type_desc, num_of_reads, num_of_writes, avg_read_ms, avg_write_ms)
type FileIoRow = (LT.Text, LT.Text, Int, Int, Int, Int)

-- (db_name, session_id, status, command, cpu_time, total_elapsed_time, reads, writes, logical_reads)
type ActiveRequestRow = (LT.Text, Int, LT.Text, LT.Text, Int, Int, Int, Int, Int)

sessionQuery :: Text -> Text
sessionQuery dbName =
  "SELECT \
  \    DB_NAME(DB_ID('"
    <> dbName
    <> "')) AS db_name, \
       \    COUNT(*) AS session_count \
       \FROM sys.dm_exec_sessions \
       \WHERE database_id = DB_ID('"
    <> dbName
    <> "')"

fileIoQuery :: Text -> Text
fileIoQuery dbName =
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
  \WHERE mf.database_id = DB_ID('"
    <> dbName
    <> "')"

activeRequestQuery :: Text -> Text
activeRequestQuery dbName =
  "SELECT \
  \    DB_NAME(r.database_id) AS db_name, \
  \    CAST(r.session_id AS INT), \
  \    r.status, \
  \    r.command, \
  \    r.cpu_time, \
  \    r.total_elapsed_time, \
  \    CAST(r.reads AS INT), \
  \    CAST(r.writes AS INT), \
  \    CAST(r.logical_reads AS INT) \
  \FROM sys.dm_exec_requests r \
  \WHERE r.database_id = DB_ID('"
    <> dbName
    <> "') \
       \ORDER BY r.cpu_time DESC"

rpcRows :: RpcResponse a b -> IO b
rpcRows (RpcResponse _ _ rs) = return rs
rpcRows (RpcResponseError info) = ioError (userError $ "SQL Server error: " ++ show info)

toSessionEntity :: SessionRow -> Either String MssqlSessionDashboard
toSessionEntity (dbName, count) = do
  sessionCount' <- mkSessionCount count
  return
    MssqlSessionDashboard
      { sessionCount = sessionCount',
        sessionSqlServerDbName = SqlServerDbName (LT.toStrict dbName)
      }

toActiveRequestEntity :: ActiveRequestRow -> MssqlActiveRequestDashboard
toActiveRequestEntity (dbName, sessionId, status, command, cpuTime, totalElapsed, numReads, numWrites, numLogicalReads) =
  MssqlActiveRequestDashboard
    { arSqlServerDbName = SqlServerDbName (LT.toStrict dbName),
      arSessionId = SessionId sessionId,
      arStatus = Status (LT.toStrict status),
      arCommand = Command (LT.toStrict command),
      arCpuTime = CpuTime cpuTime,
      arTotalElapsedTime = TotalElapsedTime totalElapsed,
      arReads = Reads numReads,
      arWrites = Writes numWrites,
      arLogicalReads = LogicalReads numLogicalReads
    }

toEntity :: FileIoRow -> Either String MssqlFileIoDashboard
toEntity (name, typeDesc, numReads, numWrites, avgRead, avgWrite) = do
  numOfReads' <- mkNumOfReads numReads
  numOfWrites' <- mkNumOfWrites numWrites
  avgReadMs' <- mkAvgReadMs avgRead
  avgWriteMs' <- mkAvgWriteMs avgWrite
  return
    MssqlFileIoDashboard
      { sqlServerDbName = SqlServerDbName (LT.toStrict name),
        typeDescription = TypeDescription (LT.toStrict typeDesc),
        numOfReads = numOfReads',
        numOfWrites = numOfWrites',
        avgReadMs = avgReadMs',
        avgWriteMs = avgWriteMs'
      }

runDashboardRepo ::
  (IOE :> es) =>
  MSSQLPool ->
  Eff (DashboardRepo : es) a ->
  Eff es a
runDashboardRepo pool = interpret $ \_ -> \case
  FetchMssqlFileIoDashboardOp cmd ->
    liftIO $ withMSSQLConn pool $ \conn -> do
      rows <-
        rpcRows
          =<< ( rpc
                  conn
                  ( RpcQuery
                      SP_ExecuteSql
                      (nvarcharVal "" (Just (fileIoQuery (cmdDbName cmd))))
                  ) ::
                  IO (RpcResponse () [FileIoRow])
              )
      mapM (either (ioError . userError) return . toEntity) rows
  FetchMssqlSessionDashboardOp cmd ->
    liftIO $ withMSSQLConn pool $ \conn -> do
      rows <-
        rpcRows
          =<< ( rpc
                  conn
                  ( RpcQuery
                      SP_ExecuteSql
                      (nvarcharVal "" (Just (sessionQuery (cmdDbName cmd))))
                  ) ::
                  IO (RpcResponse () [SessionRow])
              )
      case rows of
        [] -> ioError (userError "No session data returned for the given database")
        (r : _) -> either (ioError . userError) return (toSessionEntity r)
  FetchMssqlActiveRequestDashboardOp cmd ->
    liftIO $ withMSSQLConn pool $ \conn -> do
      rows <-
        rpcRows
          =<< ( rpc
                  conn
                  ( RpcQuery
                      SP_ExecuteSql
                      (nvarcharVal "" (Just (activeRequestQuery (cmdDbName cmd))))
                  ) ::
                  IO (RpcResponse () [ActiveRequestRow])
              )
      return (map toActiveRequestEntity rows)
