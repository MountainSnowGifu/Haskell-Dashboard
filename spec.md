# SQL Server 監視項目一覧

SQL Server の監視は、**死活・負荷・待機・I/O・DB状態** の5系統で押さえるのが実務的です。  
パフォーマンスカウンターは `sys.dm_os_performance_counters`、待機統計は `sys.dm_os_wait_stats`、DB状態は `sys.databases` が基本の取得元です。

---

## 監視項目一覧表

| 監視カテゴリ      | 監視項目                   | 代表メトリクス / 確認値           | 主な取得元                                 | 何を見るか                     | しきい値の考え方                              | 優先度     |
| ----------------- | -------------------------- | --------------------------------- | ------------------------------------------ | ------------------------------ | --------------------------------------------- | ---------- |
| 死活監視          | インスタンス稼働           | サービス起動状態、接続可否        | OS監視、疎通確認                           | SQL Server が応答しているか    | 応答不可なら即アラート                        | **最優先** |
| 死活監視          | DB状態                     | state_desc                        | sys.databases                              | ONLINE 以外の DB がないか      | OFFLINE / RECOVERY_PENDING / SUSPECT は即対応 | **最優先** |
| 接続              | 現在接続数                 | User Connections                  | SQLServer:General Statistics               | 接続急増、接続枯渇の兆候       | 固定閾値より平常時比の急増を見る              | 高         |
| 接続              | 接続/切断頻度              | Logins/sec, Logouts/sec           | SQLServer:General Statistics               | アプリ接続プール不備、スパイク | 短時間急増で警戒                              | 中         |
| スループット      | バッチ要求数               | Batch Requests/sec                | SQLServer:General Statistics               | サーバー全体の処理量           | 通常レンジからの急変を見る                    | 高         |
| スループット      | トランザクション数         | Transactions/sec                  | Databases 系カウンター                     | 業務負荷の増減                 | 平常値との乖離で判断                          | 中         |
| CPU               | CPU使用率                  | SQL Server プロセスCPU、ホストCPU | OS監視、DMV補助                            | CPU飽和の有無                  | 高止まり継続でアラート                        | 高         |
| メモリ            | バッファ健全性             | Page life expectancy              | Buffer Manager 系 / perf counters          | メモリ圧迫の兆候               | 単発値より急落・継続低下を見る                | 高         |
| メモリ            | キャッシュ効率             | Buffer cache hit ratio            | Buffer Manager 系                          | データキャッシュ効率           | 長期傾向で評価                                | 中         |
| メモリ            | メモリ逼迫                 | grants pending、使用量            | DMV                                        | メモリ不足で待ちが出ていないか | pending 発生継続で警戒                        | 高         |
| 待機              | 全体待機                   | 上位 wait_type, wait_time_ms      | sys.dm_os_wait_stats                       | どこがボトルネックか           | 上位待機の構成変化を監視                      | **最優先** |
| 待機              | ロック待機                 | LCK*M*% 系                        | sys.dm_os_wait_stats, sys.dm_exec_requests | ブロッキング増加               | 発生件数・時間の継続でアラート                | 高         |
| 待機              | I/O待機                    | PAGEIOLATCH\_%, WRITELOG など     | sys.dm_os_wait_stats                       | ストレージ遅延、ログ遅延       | 通常時より増加で調査                          | 高         |
| 待機              | 並列処理待機               | CXPACKET, CXCONSUMER              | sys.dm_os_wait_stats                       | 並列計画の偏り                 | CPUや実行計画と併せて判断                     | 中         |
| ブロッキング      | ブロック中セッション       | blocking_session_id               | sys.dm_exec_requests                       | 実害のある競合                 | 1件でも長時間継続なら重要                     | **最優先** |
| ブロッキング      | デッドロック               | Deadlock 件数                     | Extended Events, エラーログ                | 排他競合の深刻化               | 1件でも要確認、連続発生は即対策               | **最優先** |
| クエリ            | 長時間実行クエリ           | 実行時間、CPU、logical reads      | sys.dm_exec_requests, Query Store          | 遅い SQL の特定                | SLA 超過や急増で通知                          | 高         |
| クエリ            | 失敗クエリ                 | エラー率、タイムアウト            | アプリログ、XEvent                         | 利用者影響の把握               | 一定件数超でアラート                          | 高         |
| I/O               | データファイル遅延         | 読み取り/書き込みレイテンシ       | sys.dm_io_virtual_file_stats               | データファイルI/O性能          | ms単位の継続悪化で調査                        | 高         |
| I/O               | ログファイル遅延           | ログ書き込み遅延                  | sys.dm_io_virtual_file_stats               | COMMIT 遅延の原因              | 継続悪化で即調査                              | **最優先** |
| 容量              | データファイル使用率       | 使用量、空き容量、伸長率          | sys.database_files, FILEPROPERTY           | 容量逼迫                       | 残容量率と増加速度の両方で判定                | 高         |
| 容量              | トランザクションログ使用率 | ログ使用率、空き容量              | DBCC SQLPERF(LOGSPACE) など                | ログ肥大・詰まり               | 高使用率継続でアラート                        | **最優先** |
| 容量              | tempdb 使用量              | tempdb サイズ、使用率             | DMV                                        | ソート・ハッシュ・一時表負荷   | 急増や枯渇に注意                              | 高         |
| DB運用            | バックアップ成否           | 最終成功時刻、失敗有無            | msdb                                       | 復旧可能性の担保               | 未取得・失敗は即アラート                      | **最優先** |
| DB運用            | 復旧モデル                 | recovery_model_desc               | sys.databases                              | 運用設計との不整合確認         | 意図しない変更を検知                          | 中         |
| DB運用            | 自動成長発生               | autogrowth 回数                   | XEvent、既定トレース補助                   | 性能劣化や容量設計不備         | 頻発なら要改善                                | 高         |
| 可用性            | Always On 状態             | レプリカ状態、同期状態、遅延      | HADR DMV                                   | HA 構成の正常性                | 非同期化・切断は即確認                        | **最優先** |
| 可用性            | ジョブ状態                 | SQL Agent Job 成否                | msdb                                       | バッチ/ETL/保守失敗            | 失敗即通知                                    | 高         |
| セキュリティ/運用 | ログイン失敗               | failed logins                     | エラーログ、監査                           | 不正試行、資格情報不整合       | 連続増加で通知                                | 中         |
| セキュリティ/運用 | 権限変更・設定変更         | 監査イベント                      | Audit / XEvent                             | 想定外変更の検知               | 重要環境では即通知                            | 中         |

---

## 最小構成：まず最低限これだけ見る10項目

| 優先 | 項目                            | 目的                    |
| ---- | ------------------------------- | ----------------------- |
| 1    | インスタンス応答可否            | 死活監視                |
| 2    | sys.databases.state_desc        | DB異常検知              |
| 3    | User Connections                | 接続急増検知            |
| 4    | Batch Requests/sec              | 負荷把握                |
| 5    | CPU使用率                       | 飽和検知                |
| 6    | 上位待機 (sys.dm_os_wait_stats) | ボトルネック特定        |
| 7    | ブロッキングセッション数        | 実害検知                |
| 8    | ログ使用率                      | ディスク/ログ詰まり検知 |
| 9    | tempdb 使用量                   | 一時領域枯渇防止        |
| 10   | バックアップ成功有無            | 復旧性担保              |

---

## アラートレベル分け（設計書向け）

### P1 — 即時アラート

- インスタンス停止 / 接続不可
- DB が ONLINE 以外
- トランザクションログ逼迫
- バックアップ失敗
- デッドロック多発
- 長時間ブロッキング

### P2 — 早期対応

- CPU 高止まり
- I/O 遅延悪化
- tempdb 使用率急増
- メモリ逼迫
- Always On 同期異常

### P3 — 傾向監視

- Batch Requests/sec
- Transactions/sec
- User Connections
- キャッシュ効率
- autogrowth 発生頻度

---

## しきい値設定の考え方

SQL Server 監視では、**固定閾値**と**傾向監視**を使い分けることが重要です。

| 種別                         | 代表例                                                                    | 考え方                       |
| ---------------------------- | ------------------------------------------------------------------------- | ---------------------------- |
| 固定的に危険と判断できる項目 | DB が ONLINE 以外、ログ空き不足、バックアップ失敗、ブロッキング長時間継続 | 即アラートで対応             |
| 傾向で見るべき項目           | User Connections、Batch Requests/sec、Page life expectancy                | 平常値からの乖離・急変を検知 |

> **ポイント**: `User Connections` や `Batch Requests/sec` はシステム特性によって正常値が大きく異なるため、絶対値ではなく平常時比の変化で判断する。

---

## 確認 SQL

### 1. 主要パフォーマンスカウンター

```sql
SELECT object_name, counter_name, instance_name, cntr_value
FROM sys.dm_os_performance_counters
WHERE counter_name IN (
    'Batch Requests/sec',
    'Transactions/sec',
    'User Connections',
    'Lock Waits/sec',
    'Page life expectancy'
)
ORDER BY object_name, counter_name;

改良版
SELECT object_name, counter_name, instance_name, cntr_value
FROM sys.dm_os_performance_counters
WHERE counter_name IN (
    'Batch Requests/sec',
    'Transactions/sec',
    'User Connections',
    'Lock Waits/sec',
    'Page life expectancy'
)
AND (instance_name = '' OR instance_name = '_Total')
ORDER BY object_name, counter_name;

SELECT counter_name, instance_name, cntr_value
FROM sys.dm_os_performance_counters
WHERE object_name LIKE '%:Databases%'
  AND instance_name = 'あなたのデータベース名' -- ここを書き換える
  AND counter_name IN (
    'Transactions/sec',
    'Log Growths',        -- ログの自動拡張回数（多いと遅延の原因）
    'Active Transactions', -- 現在動いているトランザクション数
    'Data File(s) Size (KB)',
    'Log File(s) Size (KB)'
  );

sqlcmd -S <サーバ名> -U <ユーザー> -P <パスワード> -Q "SET NOCOUNT ON;

PRINT '=== Active Requests ===';
SELECT
    DB_NAME(r.database_id) AS db_name,
    r.session_id,
    r.status,
    r.command,
    r.cpu_time,
    r.total_elapsed_time,
    r.reads,
    r.writes,
    r.logical_reads
FROM sys.dm_exec_requests r
WHERE r.database_id = DB_ID('YourDB')
ORDER BY r.cpu_time DESC;

PRINT '=== Sessions ===';
SELECT
    DB_NAME(database_id) AS db_name,
    COUNT(*) AS session_count
FROM sys.dm_exec_sessions
WHERE database_id = DB_ID('YourDB')
GROUP BY database_id;

PRINT '=== File IO ===';
SELECT
    mf.name,
    mf.type_desc,
    vfs.num_of_reads,
    vfs.num_of_writes,
    CASE WHEN vfs.num_of_reads = 0 THEN 0
         ELSE vfs.io_stall_read_ms / vfs.num_of_reads END AS avg_read_ms,
    CASE WHEN vfs.num_of_writes = 0 THEN 0
         ELSE vfs.io_stall_write_ms / vfs.num_of_writes END AS avg_write_ms
FROM sys.dm_io_virtual_file_stats(NULL, NULL) vfs
JOIN sys.master_files mf
    ON vfs.database_id = mf.database_id
   AND vfs.file_id = mf.file_id
WHERE mf.database_id = DB_ID('YourDB');"
```

### 2. 現在の接続数

```sql
SELECT COUNT(*) AS current_sessions
FROM sys.dm_exec_sessions
WHERE is_user_process = 1;
```

### 3. ブロッキング確認

```sql
SELECT
    session_id,
    blocking_session_id,
    wait_type,
    wait_time,
    last_wait_type,
    status,
    cpu_time,
    logical_reads,
    reads,
    writes
FROM sys.dm_exec_requests
WHERE blocking_session_id <> 0
ORDER BY wait_time DESC;
```

### 4. DB状態確認

```sql
SELECT
    name,
    state_desc,
    recovery_model_desc,
    user_access_desc
FROM sys.databases
ORDER BY name;
```

### 5. 待機統計の概要（上位20件）

```sql
SELECT TOP 20
    wait_type,
    waiting_tasks_count,
    wait_time_ms,
    signal_wait_time_ms
FROM sys.dm_os_wait_stats
WHERE wait_type NOT LIKE 'SLEEP%'
ORDER BY wait_time_ms DESC;
```

---

## 取得元の整理

| 取得元                         | 主な用途                                |
| ------------------------------ | --------------------------------------- |
| sys.dm_os_performance_counters | SQL Server パフォーマンスカウンター全般 |
| sys.dm_os_wait_stats           | 全体待機分析                            |
| sys.dm_exec_requests           | 実行中要求、待機、ブロッキング確認      |
| sys.dm_exec_sessions           | 接続セッション確認                      |
| sys.databases                  | DB状態、復旧モデル、アクセス状態確認    |
| sys.dm_io_virtual_file_stats   | ファイル単位のI/O遅延分析               |
| msdb                           | バックアップ、ジョブ履歴確認            |
| OS監視                         | CPU、メモリ、ディスク、サービス状態     |

---

## 監視ツール向けメトリクス名（参考）

Zabbix / Datadog / Prometheus / SQL Agent 監視ジョブ向けの命名例：

```
sqlserver.up
sqlserver.connections.current
sqlserver.batch_requests_per_sec
sqlserver.transactions_per_sec
sqlserver.blocked_sessions
sqlserver.waits.total_ms
sqlserver.database.state
sqlserver.log.used_percent
```
