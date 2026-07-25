# 状态机

## 1. Observation 本地生命周期

```text
local_draft → locally_saved → archived
      └──────────────→ deleted

deleted → locally_saved  （显式恢复操作）
```

只有本地事务提交成功后才进入 `locally_saved`。

## 2. Asset 上传状态

```text
local_only → upload_queued → uploading → uploaded
                  │              ├→ failed_retryable → upload_queued
                  │              └→ failed_terminal
                  └→ blocked_by_policy
```

授权撤销、私密策略和文件校验失败可进入 `blocked_by_policy`。

## 3. AIJob 状态

```text
not_requested → queued → preparing → processing
→ validating → awaiting_confirmation → accepted
```

任一运行阶段可进入：

- `failed_retryable`
- `failed_terminal`
- `needs_review`
- `cancelled`

规则：

- `accepted` 只表示用户接受了某个 CardVersion；
- Schema 第二次校验失败进入 `needs_review`；
- 取消请求是协作式的，Worker 在阶段边界检查；
- 重试创建新 Attempt，不重置历史 Attempt；
- 最终 CardVersion 依赖唯一约束防止重复提交。

## 4. Card 工作流

```text
no_card → draft_available
  → accepted
  → archived

draft_available → discarded
accepted → new_draft_available（重新生成，不替换旧版本）
```

## 5. 同步状态（MVP-B）

```text
clean → dirty → pushing → clean
                  ├→ conflict
                  └→ failed_retryable → dirty
```

UI 展示状态由本地生命周期、上传、AI、Card 和同步状态组合派生。状态组合逻辑位于 Application 层，不放进 Widget。

## 6. 典型组合

| UI 文案 | 本地 | 上传 | AI | 卡片 |
|---|---|---|---|---|
| 仅本地 | locally_saved | local_only | not_requested | no_card |
| 等待上传 | locally_saved | upload_queued | queued | no_card |
| AI 分析中 | locally_saved | uploaded | processing | no_card |
| 待确认 | locally_saved | uploaded | awaiting_confirmation | draft_available |
| 已保存 | locally_saved | uploaded/local_only | accepted | accepted |
| 处理失败，可重试 | locally_saved | uploaded | failed_retryable | no_card |

## 7. 私密级别转换

```text
normal → localizing → private_local
              └→ localization_failed → localizing

private_local → declassifying → normal
```

- `localizing` 立即阻止新同步、上传和云 AI，并发起云端级联删除。
- 服务端删除确认前不得显示“已转为仅本地”。
- `declassifying` 只接受用户显式操作，并重新执行上传预览与授权。
- 登录、设备变化和同步设置不能触发私密级别转换。
