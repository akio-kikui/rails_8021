# データベーステーブル一覧

このドキュメントでは、Rails 8.0アプリケーションで使用されているすべてのテーブルの詳細を記載します。

## 目次

1. [アプリケーションテーブル](#アプリケーションテーブル)
2. [Solid Cableテーブル](#solid-cableテーブル)
3. [Solid Cacheテーブル](#solid-cacheテーブル)
4. [Solid Queueテーブル](#solid-queueテーブル)

---

## アプリケーションテーブル

アプリケーション固有のビジネスロジックを処理するためのテーブルです。

### books

書籍情報を管理するテーブルです。

**目的**: 書籍の名前とタイムスタンプを管理

**カラム**:
- `id` (bigint, PRIMARY KEY): 書籍の一意識別子
- `name` (string): 書籍名
- `created_at` (datetime, NOT NULL): 作成日時
- `updated_at` (datetime, NOT NULL): 更新日時

**インデックス**:
- `index_books_on_name` (UNIQUE): 書籍名の一意性を保証

**バリデーション**:
- `name`: 必須、最大32文字、一意性

---

## Solid Cableテーブル

Rails 8のAction Cableの代替となるSolid Cableが使用するテーブルです。WebSocketメッセージングに使用されます。

### solid_cable_messages

WebSocketメッセージを管理するテーブルです。

**目的**: リアルタイムメッセージングのためのメッセージデータ保存

**カラム**:
- `id` (bigint, PRIMARY KEY): メッセージの一意識別子
- `channel` (binary, limit: 1024, NOT NULL): チャンネル情報
- `payload` (binary, limit: 536870912, NOT NULL): メッセージペイロード（最大512MB）
- `created_at` (datetime, NOT NULL): 作成日時
- `channel_hash` (integer, limit: 8, NOT NULL): チャンネルのハッシュ値

**インデックス**:
- `index_solid_cable_messages_on_channel`: チャンネルでの検索を高速化
- `index_solid_cable_messages_on_channel_hash`: チャンネルハッシュでの検索を高速化
- `index_solid_cable_messages_on_created_at`: 作成日時での検索を高速化

---

## Solid Cacheテーブル

Rails 8のキャッシュ機能を提供するSolid Cacheが使用するテーブルです。

### solid_cache_entries

キャッシュエントリを管理するテーブルです。

**目的**: アプリケーションのキャッシュデータ保存

**カラム**:
- `id` (bigint, PRIMARY KEY): キャッシュエントリの一意識別子
- `key` (binary, limit: 1024, NOT NULL): キャッシュキー
- `value` (binary, limit: 536870912, NOT NULL): キャッシュ値（最大512MB）
- `created_at` (datetime, NOT NULL): 作成日時
- `key_hash` (integer, limit: 8, NOT NULL): キーのハッシュ値
- `byte_size` (integer, limit: 4, NOT NULL): データサイズ（バイト）

**インデックス**:
- `index_solid_cache_entries_on_key_hash` (UNIQUE): キーハッシュの一意性を保証
- `index_solid_cache_entries_on_key_hash_and_byte_size`: キーハッシュとサイズでの複合検索
- `index_solid_cache_entries_on_byte_size`: サイズでの検索を高速化

---

## Solid Queueテーブル

Rails 8のバックグラウンドジョブ処理を提供するSolid Queueが使用するテーブル群です。

### solid_queue_jobs

バックグラウンドジョブの基本情報を管理するメインテーブルです。

**目的**: 実行されるジョブの詳細情報管理

**カラム**:
- `id` (bigint, PRIMARY KEY): ジョブの一意識別子
- `queue_name` (string, NOT NULL): キュー名
- `class_name` (string, NOT NULL): ジョブクラス名
- `arguments` (text): ジョブの引数（シリアライズ形式）
- `priority` (integer, default: 0, NOT NULL): 優先度
- `active_job_id` (string): Active Jobの識別子
- `scheduled_at` (datetime): スケジュール実行日時
- `finished_at` (datetime): 完了日時
- `concurrency_key` (string): 並行実行制御キー
- `created_at` (datetime, NOT NULL): 作成日時
- `updated_at` (datetime, NOT NULL): 更新日時

**インデックス**:
- `index_solid_queue_jobs_on_active_job_id`: Active Job IDでの検索
- `index_solid_queue_jobs_on_class_name`: クラス名での検索
- `index_solid_queue_jobs_on_finished_at`: 完了日時での検索
- `index_solid_queue_jobs_for_filtering`: キュー名と完了日時での複合検索
- `index_solid_queue_jobs_for_alerting`: スケジュール日時と完了日時での複合検索

### solid_queue_ready_executions

実行準備完了ジョブを管理するテーブルです。

**目的**: 実行可能状態のジョブ管理

**カラム**:
- `id` (bigint, PRIMARY KEY): 実行の一意識別子
- `job_id` (bigint, NOT NULL): ジョブID（solid_queue_jobsへの外部キー）
- `queue_name` (string, NOT NULL): キュー名
- `priority` (integer, default: 0, NOT NULL): 優先度
- `created_at` (datetime, NOT NULL): 作成日時

**インデックス**:
- `index_solid_queue_ready_executions_on_job_id` (UNIQUE): ジョブIDの一意性
- `index_solid_queue_poll_all`: 優先度とジョブIDでの複合検索
- `index_solid_queue_poll_by_queue`: キュー別の優先度検索

**外部キー制約**:
- `job_id` → `solid_queue_jobs.id` (ON DELETE CASCADE)

### solid_queue_claimed_executions

実行中ジョブを管理するテーブルです。

**目的**: ワーカーによって実行権を取得されたジョブの管理

**カラム**:
- `id` (bigint, PRIMARY KEY): 実行の一意識別子
- `job_id` (bigint, NOT NULL): ジョブID（solid_queue_jobsへの外部キー）
- `process_id` (bigint): プロセスID（solid_queue_processesへの外部キー）
- `created_at` (datetime, NOT NULL): 作成日時

**インデックス**:
- `index_solid_queue_claimed_executions_on_job_id` (UNIQUE): ジョブIDの一意性
- `index_solid_queue_claimed_executions_on_process_id_and_job_id`: プロセスとジョブの複合検索

**外部キー制約**:
- `job_id` → `solid_queue_jobs.id` (ON DELETE CASCADE)

### solid_queue_failed_executions

失敗したジョブを管理するテーブルです。

**目的**: 実行に失敗したジョブの情報とエラー詳細の保存

**カラム**:
- `id` (bigint, PRIMARY KEY): 失敗実行の一意識別子
- `job_id` (bigint, NOT NULL): ジョブID（solid_queue_jobsへの外部キー）
- `error` (text): エラーメッセージ
- `created_at` (datetime, NOT NULL): 作成日時

**インデックス**:
- `index_solid_queue_failed_executions_on_job_id` (UNIQUE): ジョブIDの一意性

**外部キー制約**:
- `job_id` → `solid_queue_jobs.id` (ON DELETE CASCADE)

### solid_queue_scheduled_executions

スケジュールされたジョブを管理するテーブルです。

**目的**: 将来実行予定のジョブ管理

**カラム**:
- `id` (bigint, PRIMARY KEY): 実行の一意識別子
- `job_id` (bigint, NOT NULL): ジョブID（solid_queue_jobsへの外部キー）
- `queue_name` (string, NOT NULL): キュー名
- `priority` (integer, default: 0, NOT NULL): 優先度
- `scheduled_at` (datetime, NOT NULL): スケジュール実行日時
- `created_at` (datetime, NOT NULL): 作成日時

**インデックス**:
- `index_solid_queue_scheduled_executions_on_job_id` (UNIQUE): ジョブIDの一意性
- `index_solid_queue_dispatch_all`: スケジュール日時、優先度、ジョブIDでの複合検索

**外部キー制約**:
- `job_id` → `solid_queue_jobs.id` (ON DELETE CASCADE)

### solid_queue_blocked_executions

ブロックされたジョブを管理するテーブルです。

**目的**: 並行実行制限によりブロックされたジョブの管理

**カラム**:
- `id` (bigint, PRIMARY KEY): 実行の一意識別子
- `job_id` (bigint, NOT NULL): ジョブID（solid_queue_jobsへの外部キー）
- `queue_name` (string, NOT NULL): キュー名
- `priority` (integer, default: 0, NOT NULL): 優先度
- `concurrency_key` (string, NOT NULL): 並行実行制御キー
- `expires_at` (datetime, NOT NULL): ブロック期限
- `created_at` (datetime, NOT NULL): 作成日時

**インデックス**:
- `index_solid_queue_blocked_executions_on_job_id` (UNIQUE): ジョブIDの一意性
- `index_solid_queue_blocked_executions_for_release`: 並行キー、優先度、ジョブIDでの複合検索
- `index_solid_queue_blocked_executions_for_maintenance`: 期限と並行キーでの複合検索

**外部キー制約**:
- `job_id` → `solid_queue_jobs.id` (ON DELETE CASCADE)

### solid_queue_processes

ワーカープロセスを管理するテーブルです。

**目的**: ジョブを実行するワーカープロセスの状態管理

**カラム**:
- `id` (bigint, PRIMARY KEY): プロセスの一意識別子
- `kind` (string, NOT NULL): プロセスの種類
- `last_heartbeat_at` (datetime, NOT NULL): 最後のハートビート時刻
- `supervisor_id` (bigint): スーパーバイザーID
- `pid` (integer, NOT NULL): プロセスID
- `hostname` (string): ホスト名
- `metadata` (text): メタデータ
- `created_at` (datetime, NOT NULL): 作成日時
- `name` (string, NOT NULL): プロセス名

**インデックス**:
- `index_solid_queue_processes_on_last_heartbeat_at`: ハートビート時刻での検索
- `index_solid_queue_processes_on_name_and_supervisor_id` (UNIQUE): 名前とスーパーバイザーIDの一意性
- `index_solid_queue_processes_on_supervisor_id`: スーパーバイザーIDでの検索

### solid_queue_pauses

一時停止されたキューを管理するテーブルです。

**目的**: 特定のキューの一時停止状態の管理

**カラム**:
- `id` (bigint, PRIMARY KEY): 一時停止の一意識別子
- `queue_name` (string, NOT NULL): キュー名
- `created_at` (datetime, NOT NULL): 作成日時

**インデックス**:
- `index_solid_queue_pauses_on_queue_name` (UNIQUE): キュー名の一意性

### solid_queue_recurring_tasks

定期実行タスクを管理するテーブルです。

**目的**: 定期的に実行されるタスクの設定管理

**カラム**:
- `id` (bigint, PRIMARY KEY): タスクの一意識別子
- `key` (string, NOT NULL): タスクキー
- `schedule` (string, NOT NULL): 実行スケジュール（cron形式）
- `command` (string, limit: 2048): 実行コマンド
- `class_name` (string): ジョブクラス名
- `arguments` (text): ジョブの引数
- `queue_name` (string): キュー名
- `priority` (integer, default: 0): 優先度
- `static` (boolean, default: true, NOT NULL): 静的タスクフラグ
- `description` (text): タスクの説明
- `created_at` (datetime, NOT NULL): 作成日時
- `updated_at` (datetime, NOT NULL): 更新日時

**インデックス**:
- `index_solid_queue_recurring_tasks_on_key` (UNIQUE): タスクキーの一意性
- `index_solid_queue_recurring_tasks_on_static`: 静的タスクフラグでの検索

### solid_queue_recurring_executions

定期実行タスクの実行履歴を管理するテーブルです。

**目的**: 定期タスクの実行記録管理

**カラム**:
- `id` (bigint, PRIMARY KEY): 実行の一意識別子
- `job_id` (bigint, NOT NULL): ジョブID（solid_queue_jobsへの外部キー）
- `task_key` (string, NOT NULL): タスクキー
- `run_at` (datetime, NOT NULL): 実行日時
- `created_at` (datetime, NOT NULL): 作成日時

**インデックス**:
- `index_solid_queue_recurring_executions_on_job_id` (UNIQUE): ジョブIDの一意性
- `index_solid_queue_recurring_executions_on_task_key_and_run_at` (UNIQUE): タスクキーと実行日時の複合一意性

**外部キー制約**:
- `job_id` → `solid_queue_jobs.id` (ON DELETE CASCADE)

### solid_queue_semaphores

並行実行制御用のセマフォを管理するテーブルです。

**目的**: ジョブの並行実行数制限の管理

**カラム**:
- `id` (bigint, PRIMARY KEY): セマフォの一意識別子
- `key` (string, NOT NULL): セマフォキー
- `value` (integer, default: 1, NOT NULL): セマフォ値
- `expires_at` (datetime, NOT NULL): 有効期限
- `created_at` (datetime, NOT NULL): 作成日時
- `updated_at` (datetime, NOT NULL): 更新日時

**インデックス**:
- `index_solid_queue_semaphores_on_key` (UNIQUE): セマフォキーの一意性
- `index_solid_queue_semaphores_on_key_and_value`: キーと値での複合検索
- `index_solid_queue_semaphores_on_expires_at`: 有効期限での検索

---

## まとめ

このRails 8.0アプリケーションでは、以下の構成でデータベーステーブルが設計されています：

- **アプリケーションテーブル**: 1テーブル（書籍管理）
- **Solid Cableテーブル**: 1テーブル（WebSocketメッセージング）
- **Solid Cacheテーブル**: 1テーブル（キャッシュ管理）
- **Solid Queueテーブル**: 11テーブル（バックグラウンドジョブ処理）

**合計**: 14テーブル

各テーブルは適切なインデックスと外部キー制約により最適化されており、Rails 8.0の新機能であるSolid Cable、Solid Cache、Solid Queueの機能を支える重要な役割を果たしています。