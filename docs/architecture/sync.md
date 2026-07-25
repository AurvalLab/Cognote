# Local-First 同步协议（MVP-B）

## 1. 目标

- 本地先写；
- 离线变更可持久恢复；
- push/pull 可安全重试；
- 不依赖设备时钟决定覆盖顺序；
- 冲突可见且不静默丢失用户内容。

## 2. 客户端 Outbox

每次本地可同步变更与业务数据在同一 Drift 事务中写入 Outbox：

```text
operation_id
entity_type, entity_id
operation_kind
base_revision
patch
created_at
attempt_count, next_attempt_at
```

只有服务端逐项返回 `applied` 或 `duplicate` 后才能移除/归档操作。

## 3. Push

`POST /v1/sync/push` 接收有上限的操作批次。服务端：

1. 校验账号、设备和 Schema；
2. 以 `operation_id` 去重；
3. 检查 `base_revision`；
4. 在事务中应用操作；
5. 分配单调 `server_revision`；
6. 写入 change log；
7. 逐项返回结果。

结果：`applied | duplicate | conflict | rejected`。

## 4. Pull

`GET /v1/sync/pull?cursor=...&limit=...` 返回：

```text
changes[]
next_cursor
has_more
```

客户端必须先在 Drift 事务中应用整页 changes，再提交本地 cursor。cursor 过期时服务端返回明确错误并提供快照恢复流程。

## 5. 冲突矩阵

| 数据 | 策略 |
|---|---|
| 标签添加/移除 | 独立 add/remove 操作；不做永久并集 |
| 用户笔记 | 保存冲突副本，用户选择或手工合并 |
| 标题/状态 | optimistic concurrency，字段级冲突 |
| AI CardVersion | 不可变，不冲突；并存 |
| Correction | 不可变事件；按目标版本应用 |
| 删除 | 传播墓碑；阻挡已知基线之前的旧更新 |
| 恢复 | 显式新操作，产生新 revision |
| 媒体 | 以 sha256 去重；生命周期按副本类型管理 |

## 6. 幂等与顺序

- 客户端生成 UUIDv7/ULID 和 `operation_id`；
- 服务端对 `(owner_id, operation_id)` 建唯一约束；
- `server_revision` 只由服务端分配；
- 客户端时间只用于展示；
- 同一设备可按 Outbox 顺序发送，但服务端仍须处理重复和迟到操作；
- 批次部分失败时只重试未确认操作。

## 7. 删除

删除传播墓碑，不立即物理删除 change log。账号级删除作业另行清除主体数据、对象、索引和导出文件。备份延迟删除策略需在隐私文档公开。

## 8. 测试矩阵

- 相同 push 重复 3 次；
- push 成功但响应丢失；
- pull 落库前崩溃、落库后 cursor 提交前崩溃；
- 两设备离线编辑同一笔记；
- 一端删标签、一端保留旧集合；
- 一端删除、一端离线编辑；
- 恢复与迟到删除；
- 乱序、分页、cursor 过期；
- 账号隔离与越权访问。
