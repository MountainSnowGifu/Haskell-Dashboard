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
import App.Domain.SQLServerDashboard.Entity
  ( MssqlActiveRequestDashboard (..),
    MssqlBackupDashboard (..),
    MssqlBlockStatusDashboard (..),
    MssqlDbStatusDashboard (..),
    MssqlFileIoDashboard (..),
    MssqlLogUsageDashboard (..),
    MssqlOverallPerformanceDashboard (..),
    MssqlSessionDashboard (..),
  )
import App.Domain.SQLServerDashboard.ValueObject
  ( AlertLevel (..),
    BackupFinishDate (..),
    BackupPhysicalDeviceName (..),
    BackupServerName (..),
    BackupStartDate (..),
    BackupType (..),
    BackupUserName (..),
    Command (..),
    CpuTime (..),
    HostName (..),
    LogicalReads (..),
    LoginName (..),
    PerformanceCounterValue (..),
    ProgramName (..),
    Reads (..),
    RecoveryModelDesc (..),
    SessionId (..),
    SqlServerDbName (..),
    SqlText (..),
    StateDesc (..),
    Status (..),
    TotalElapsedTime (..),
    TotalLogSizeMB (..),
    TypeDescription (..),
    UsedLogSpaceMB (..),
    UsedLogSpacePercent (..),
    UserAccessDesc (..),
    WaitResource (..),
    WaitTime (..),
    WaitType (..),
    Writes (..),
    mkAvgReadMs,
    mkAvgWriteMs,
    mkNumOfReads,
    mkNumOfWrites,
    mkSessionCount,
  )
import App.Domain.SQLServerDashboard.ValueObject.Performance (mkPerformanceCounterName, mkPerformanceInstanceName, mkPerformanceObjectName)
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

-- (name, state_desc, recovery_model_desc, user_access_desc)
type DbStatusRow = (LT.Text, LT.Text, LT.Text, LT.Text)

-- (db_name, session_count)
type SessionRow = (LT.Text, Int)

-- (name, type_desc, num_of_reads, num_of_writes, avg_read_ms, avg_write_ms)
type FileIoRow = (LT.Text, LT.Text, Int, Int, Int, Int)

-- (db_name, session_id, status, command, cpu_time, total_elapsed_time, reads, writes, logical_reads)
type ActiveRequestRow = (LT.Text, Int, LT.Text, LT.Text, Int, Int, Int, Int, Int)

-- (object_name, counter_name, instance_name, cntr_value)
type OverallPerformanceRow = (LT.Text, LT.Text, LT.Text, Int)

-- (session_id, blocking_session_id, status, wait_type, wait_time, wait_resource, command, database_name, host_name, program_name, login_name, sql_text)
type BlockStatusRow = (Int, Int, LT.Text, LT.Text, Int, LT.Text, LT.Text, LT.Text, LT.Text, LT.Text, LT.Text, LT.Text)

-- (db_name, total_log_size_mb, used_log_space_mb, used_log_space_percent, alert_level)
type LogUsageRow = (LT.Text, Float, Float, Float, LT.Text)

-- (database_name, backup_type, backup_start_date, backup_finish_date, physical_device_name, user_name, server_name)
type BackupRow = (LT.Text, LT.Text, LT.Text, LT.Text, LT.Text, LT.Text, LT.Text)

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

dbStatusQuery :: Text -> Text
dbStatusQuery dbName =
  "SELECT \
  \    name, \
  \    state_desc, \
  \    recovery_model_desc, \
  \    user_access_desc \
  \FROM sys.databases \
  \WHERE name = '"
    <> dbName
    <> "'"

overallPerformanceQuery :: Text
overallPerformanceQuery =
  "SELECT object_name, counter_name, instance_name, cntr_value \
  \FROM sys.dm_os_performance_counters \
  \WHERE counter_name IN ( \
  \    'Batch Requests/sec', \
  \    'Transactions/sec', \
  \    'User Connections', \
  \    'Lock Waits/sec', \
  \    'Page life expectancy' \
  \) \
  \AND (instance_name = '' OR instance_name = '_Total') \
  \ORDER BY object_name, counter_name"

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

blockStatusQuery :: Text -> Text
blockStatusQuery dbName =
  "SELECT \
  \    CAST(r.session_id AS INT), \
  \    CAST(r.blocking_session_id AS INT), \
  \    r.status, \
  \    ISNULL(r.wait_type, N''), \
  \    r.wait_time, \
  \    ISNULL(r.wait_resource, N''), \
  \    r.command, \
  \    DB_NAME(r.database_id), \
  \    s.host_name, \
  \    s.program_name, \
  \    s.login_name, \
  \    ISNULL(CAST(t.text AS NVARCHAR(MAX)), N'') \
  \FROM sys.dm_exec_requests r \
  \JOIN sys.dm_exec_sessions s \
  \    ON r.session_id = s.session_id \
  \OUTER APPLY sys.dm_exec_sql_text(r.sql_handle) t \
  \WHERE r.session_id <> @@SPID \
  \  AND r.database_id = DB_ID('"
    <> dbName
    <> "') \
       \  AND (r.blocking_session_id <> 0 OR r.wait_type LIKE 'LCK%') \
       \ORDER BY r.wait_time DESC"

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

toDbStatusEntity :: DbStatusRow -> MssqlDbStatusDashboard
toDbStatusEntity (name, stateDesc, recoveryModel, userAccess) =
  MssqlDbStatusDashboard
    { dbsSqlServerDbName = SqlServerDbName (LT.toStrict name),
      dbsStateDesc = StateDesc (LT.toStrict stateDesc),
      dbsRecoveryModelDesc = RecoveryModelDesc (LT.toStrict recoveryModel),
      dbsUserAccessDesc = UserAccessDesc (LT.toStrict userAccess)
    }

toBlockStatusEntity :: BlockStatusRow -> MssqlBlockStatusDashboard
toBlockStatusEntity (sessionId, blockingSessionId, status, waitType, waitTime, waitResource, command, dbName, hostName, programName, loginName, sqlText) =
  MssqlBlockStatusDashboard
    { bsSessionId = SessionId sessionId,
      bsBlockingSessionId = SessionId blockingSessionId,
      bsStatus = Status (LT.toStrict status),
      bsWaitType = WaitType (LT.toStrict waitType),
      bsWaitTime = WaitTime (LT.toStrict (LT.pack (show waitTime))),
      bsWaitResource = WaitResource (LT.toStrict waitResource),
      bsCommand = Command (LT.toStrict command),
      bsDatabaseName = SqlServerDbName (LT.toStrict dbName),
      bsHostName = HostName (LT.toStrict hostName),
      bsProgramName = ProgramName (LT.toStrict programName),
      bsLoginName = LoginName (LT.toStrict loginName),
      bsSqlText = SqlText (LT.toStrict sqlText)
    }

toOverallPerformanceEntity :: OverallPerformanceRow -> MssqlOverallPerformanceDashboard
toOverallPerformanceEntity (objectName, counterName, instanceName, cntrValue) =
  MssqlOverallPerformanceDashboard
    { pdbObjectName = mkPerformanceObjectName (LT.toStrict objectName),
      pdbCounterName = mkPerformanceCounterName (LT.toStrict counterName),
      pdbInstanceName = mkPerformanceInstanceName (LT.toStrict instanceName),
      pdbCounterValue = PerformanceCounterValue cntrValue
    }

logUsageQuery :: Text -> Text
logUsageQuery dbName =
  "USE ["
    <> dbName
    <> "]; \
       \SELECT \
       \    DB_NAME(database_id) AS db_name, \
       \    CAST(total_log_size_in_bytes / 1024.0 / 1024.0 AS FLOAT) AS total_log_size_mb, \
       \    CAST(used_log_space_in_bytes / 1024.0 / 1024.0 AS FLOAT) AS used_log_space_mb, \
       \    CAST(used_log_space_in_percent AS FLOAT) AS used_log_space_percent, \
       \    CASE \
       \        WHEN used_log_space_in_percent >= 90 THEN N'CRITICAL' \
       \        WHEN used_log_space_in_percent >= 80 THEN N'WARNING' \
       \        ELSE N'OK' \
       \    END AS alert_level \
       \FROM sys.dm_db_log_space_usage"

toLogUsageEntity :: LogUsageRow -> MssqlLogUsageDashboard
toLogUsageEntity (dbName, totalSize, usedSpace, usedPercent, alert) =
  MssqlLogUsageDashboard
    { lugSqlServerDbName = SqlServerDbName (LT.toStrict dbName),
      lugTotalLogSizeMB = TotalLogSizeMB totalSize,
      lugUsedLogSpaceMB = UsedLogSpaceMB usedSpace,
      lugUsedLogSpacePercent = UsedLogSpacePercent usedPercent,
      lugAlertLevel = AlertLevel (LT.toStrict alert)
    }

backupQuery :: Text -> Text
backupQuery dbName =
  "SELECT \
  \    TOP (5) bs.database_name, \
  \    CASE bs.type \
  \        WHEN 'D' THEN N'Full' \
  \        WHEN 'I' THEN N'Differential' \
  \        WHEN 'L' THEN N'Log' \
  \        ELSE bs.type \
  \    END AS backup_type, \
  \    CONVERT(NVARCHAR(23), bs.backup_start_date, 121) AS backup_start_date, \
  \    CONVERT(NVARCHAR(23), bs.backup_finish_date, 121) AS backup_finish_date, \
  \    ISNULL(bmf.physical_device_name, N'') AS physical_device_name, \
  \    ISNULL(bs.user_name, N'') AS user_name, \
  \    bs.server_name \
  \FROM msdb.dbo.backupset bs \
  \LEFT JOIN msdb.dbo.backupmediafamily bmf \
  \    ON bs.media_set_id = bmf.media_set_id \
  \WHERE bs.database_name = '"
    <> dbName
    <> "' \
       \ORDER BY bs.backup_finish_date DESC"

toBackupEntity :: BackupRow -> MssqlBackupDashboard
toBackupEntity (dbName, backupType, startDate, finishDate, physicalDevice, userName, serverName) =
  MssqlBackupDashboard
    { bakSqlServerDbName = SqlServerDbName (LT.toStrict dbName),
      bakBackupType = BackupType (LT.toStrict backupType),
      bakBackupStartDate = BackupStartDate (LT.toStrict startDate),
      bakBackupFinishDate = BackupFinishDate (LT.toStrict finishDate),
      bakBackupPhysicalDeviceName = BackupPhysicalDeviceName (LT.toStrict physicalDevice),
      bakBackupUserName = BackupUserName (LT.toStrict userName),
      bakBackupServerName = BackupServerName (LT.toStrict serverName)
    }

toEntity :: FileIoRow -> Either String MssqlFileIoDashboard
toEntity (name, typeDesc, numReads, numWrites, avgRead, avgWrite) = do
  numOfReads' <- mkNumOfReads numReads
  numOfWrites' <- mkNumOfWrites numWrites
  avgReadMs' <- mkAvgReadMs avgRead
  avgWriteMs' <- mkAvgWriteMs avgWrite
  return
    MssqlFileIoDashboard
      { fioSqlServerDbName = SqlServerDbName (LT.toStrict name),
        fioTypeDescription = TypeDescription (LT.toStrict typeDesc),
        fioNumOfReads = numOfReads',
        fioNumOfWrites = numOfWrites',
        fioAvgReadMs = avgReadMs',
        fioAvgWriteMs = avgWriteMs'
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
  FetchMssqlDbStatusDashboardOp cmd ->
    liftIO $ withMSSQLConn pool $ \conn -> do
      rows <-
        rpcRows
          =<< ( rpc
                  conn
                  ( RpcQuery
                      SP_ExecuteSql
                      (nvarcharVal "" (Just (dbStatusQuery (cmdDbName cmd))))
                  ) ::
                  IO (RpcResponse () [DbStatusRow])
              )
      case rows of
        [] -> ioError (userError "No status data returned for the given database")
        (r : _) -> return (toDbStatusEntity r)
  FetchMssqlOverallPerformanceDashboardOp _cmd ->
    liftIO $ withMSSQLConn pool $ \conn -> do
      rows <-
        rpcRows
          =<< ( rpc
                  conn
                  ( RpcQuery
                      SP_ExecuteSql
                      (nvarcharVal "" (Just overallPerformanceQuery))
                  ) ::
                  IO (RpcResponse () [OverallPerformanceRow])
              )
      return (map toOverallPerformanceEntity rows)
  FetchMssqlBlockStatusDashboardOp cmd ->
    liftIO $ withMSSQLConn pool $ \conn -> do
      rows <-
        rpcRows
          =<< ( rpc
                  conn
                  ( RpcQuery
                      SP_ExecuteSql
                      (nvarcharVal "" (Just (blockStatusQuery (cmdDbName cmd))))
                  ) ::
                  IO (RpcResponse () [BlockStatusRow])
              )
      return (map toBlockStatusEntity rows)
  FetchMssqlLogUsageDashboardOp cmd ->
    liftIO $ withMSSQLConn pool $ \conn -> do
      rows <-
        rpcRows
          =<< ( rpc
                  conn
                  ( RpcQuery
                      SP_ExecuteSql
                      (nvarcharVal "" (Just (logUsageQuery (cmdDbName cmd))))
                  ) ::
                  IO (RpcResponse () [LogUsageRow])
              )
      case rows of
        [] -> ioError (userError "No log usage data returned for the given database")
        (r : _) -> return (toLogUsageEntity r)
  FetchMssqlBackupDashboardOp cmd ->
    liftIO $ withMSSQLConn pool $ \conn -> do
      rows <-
        rpcRows
          =<< ( rpc
                  conn
                  ( RpcQuery
                      SP_ExecuteSql
                      (nvarcharVal "" (Just (backupQuery (cmdDbName cmd))))
                  ) ::
                  IO (RpcResponse () [BackupRow])
              )
      return (map toBackupEntity rows)
