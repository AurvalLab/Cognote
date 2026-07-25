# 核心数据模型

## 1. 通用字段

所有可同步聚合包含：

```text
id: UUIDv7/ULID
owner_id: 本地匿名主体或已认证账户主体
region_code: cn-mainland（MVP）
data_residency: cn（MVP）
created_at: UTC instant
updated_at: UTC instant
created_by_device_id
server_revision: nullable integer
deleted_at: nullable UTC instant
```

设备时间只用于展示和诊断，不用于多设备冲突裁决。

## 1.1 身份与归并

```text
Principal:
  id, kind(anonymous|account), status
  home_region, data_residency
  created_at, upgraded_at nullable

DeviceIdentity:
  id, principal_id, public_install_id
  created_at, last_seen_at

PrincipalMerge:
  id, anonymous_principal_id, account_principal_id
  idempotency_key unique, status
  source_manifest_json, result_manifest_json
  created_at, completed_at nullable

AIQuotaLedger:
  id, principal_id, operation_id unique
  units_delta, reason, ai_job_id nullable
  created_at
```

首次启动创建本地匿名 Principal。登录后不改写历史对象 ID，而是在单个服务端事务/可恢复归并作业中转移所有权并保存映射。额度使用采用不可变流水，禁止只维护一个可被重复扣减的计数器。

`Principal/Account`、`Observation`、`Asset`、`KnowledgeCard`、`AIJob` 均显式保存或从不可变所属关系继承 `region_code`、`data_residency`；`AIJob` 另存 `ai_processing_region`。跨区域归并禁止仅靠改字段完成，必须走未来专门的数据迁移与授权流程。

## 2. Observation

原始用户记录：

```text
id, owner_id, input_type(image|text)
raw_text
captured_at, timezone_offset
privacy_level(normal|localizing|private_local|localization_failed|declassifying)
cloud_ai_policy, sync_policy
created_by_device_id
created_at, updated_at, deleted_at, server_revision
```

本地生命周期、AI 状态和同步状态不得混入同一个 `status`。

## 3. LocalAsset（客户端）

```text
id, observation_id
local_uri, analysis_derivative_uri
local_original_present
mime_type, bytes, width, height, sha256
exif_removed
upload_state
created_at, updated_at
```

## 4. Asset（服务端）

```text
id, observation_id
object_key, derivative_kind(analysis|backup|thumbnail)
mime_type, bytes, width, height, sha256
upload_status
retention_policy, expires_at
created_at, deleted_at, server_revision
deletion_status(pending|processing|completed|failed)
deletion_attempts, next_deletion_attempt_at
```

服务端不保存 `local_path`；客户端不持久依赖预签名 `remote_url`。

## 5. KnowledgeCard

可变聚合根：

```text
id, observation_id
accepted_version_id nullable
user_title_override nullable
user_note
workflow_status(draft|accepted|archived)
schema_version
created_at, updated_at, deleted_at, server_revision
```

## 6. KnowledgeCardVersion

不可变 AI 或手工版本：

```text
id, card_id, version_no
origin(ai|manual)
pipeline_version, prompt_version, model_version
schema_version, card_type
title, summary, payload_json
raw_ai_output_ref
certainty_display
created_at
```

唯一约束：`(card_id, version_no)`。

## 7. Fact 与 Provenance

```text
Fact:
  id, card_version_id, field_path, predicate
  value_json, unit, certainty_level, risk_level

Provenance:
  id, type(visual_observation|ocr_extract|user_input|
           retrieved_source|model_inference|user_correction)
  asset_id/source_url/source_document_id
  quote_or_visual_description
  retrieved_at, provider_metadata

FactProvenance:
  fact_id, provenance_id
```

外部来源应保存可审计标识、摘录和抓取时间；模型推断不得标记为外部来源。

## 8. UserCorrection

不可变覆盖事件：

```text
id, card_id, target_card_version_id
target_fact_id nullable, field_path
original_value_json, corrected_value_json
reason nullable
operation_id, created_by_device_id
created_at, deleted_at, server_revision
```

## 9. AIJob 与 AIJobAttempt

```text
AIJob:
  id, observation_id, idempotency_key unique
  pipeline_version, input_manifest_hash
  consent_snapshot_id
  region_code, data_residency, ai_processing_region
  status, current_stage
  cancel_requested_at
  created_at, updated_at

AIJobAttempt:
  id, job_id, attempt_no
  provider, model
  started_at, finished_at
  outcome, error_code
  usage_json, cost_estimate
  raw_output_ref, validation_errors_json
```

唯一约束：`(job_id, attempt_no)`。

## 10. ConsentSnapshot

```text
ConsentSnapshot:
  id, owner_id nullable, device_id
  purpose(ai_analysis|structured_sync|media_backup|location|analytics)
  authorization_scope(persistent|single_use)
  sensitivity_level(normal|elevated|sensitive|unknown_high)
  provider_scope, retention_policy, policy_version
  upload_manifest_hash, redactions_json
  accepted_at, revoked_at
```

AIJob 必须绑定当时的授权快照，不能只读取当前设置。

## 11. 同步实体（MVP-B）

```text
SyncOperation:
  operation_id unique, device_id
  entity_type, entity_id
  base_revision, operation_kind
  patch_json, client_created_at

ServerChange:
  server_revision monotonic
  owner_id, entity_type, entity_id
  operation_id, changed_fields
  server_created_at
```

## 12. 投影

- EffectiveCard = accepted CardVersion + 按顺序应用的有效 Correction；
- SearchDocument = EffectiveCard + 用户说明 + OCR；
- Entity/Relation = accepted CardVersion 的可重建派生结果；
- 删除和私密策略改变时必须同步清理派生投影。
