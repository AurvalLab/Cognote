# Mnora · 见藏项目交接文档：Codex 接管基线

> 当前公开产品名为 **Mnora · 见藏**；本文其余 Cognote 引用仅作为历史快照和暂未迁移的技术标识保留。品牌规范见 `docs/product/brand.md`。发生状态冲突时，按 `docs/roadmap/current-plan.md`、`docs/product/strategy.md`、当前代码、可复现证据的顺序重新核验。

> 初始生成：2026-08-14（Asia/Shanghai）
> 最近更新：2026-08-14（Mnora 品牌、GitHub 治理与账号迁移完成后）
> 用途：将本文件交给新 Codex 会话，使其接续 Mnora 的技术负责人、项目经理与开发 Agent 指导者角色。
> 关键原则：本文件是交接记录，不是实时命令结果。Codex 必须先重新核验仓库、远程与测试，之后才能据此推进。

---

## 0. 本文档定位

本文件是 Mnora · 见藏在 2026-08-14 时点的**全量交接快照**，覆盖四类内容：

1. 项目内容（是什么、架构、代码现状）；
2. 进展（阶段 0/1 的真实完成度、CNG-100～109 提交基线）；
3. 按计划的规划期望（阶段 1 收尾 → 阶段 5 的路线与解锁条件）；
4. 治理规则与陷阱（Codex 接手后必须遵守的边界）。

历史遗留文档只作参考，不得覆盖现行规划：

- `docs/handoff/stage-0-to-stage-1.md`：写于阶段 0 结束，声称"仓库尚无业务代码"。现已过时。

当前产品战略以 `docs/product/strategy.md` 为准，执行顺序以 `docs/roadmap/current-plan.md` 为准。`cognote-agent-artifacts/` 中的材料仅作为历史输入与证据，不得反向覆盖已审计的现行文档。

---

## 1. 项目定位与产品战略

Mnora · 见藏是一款 **Local-First 的个人观察与记忆系统**：

```text
用户记录真实经历（图片/文字）
→ 经授权的 AI 整理
→ 用户确认或纠错的卡片
→ 可被再次找到与回顾的个人记忆
```

战略主张：**不先做"懂你"的 AI 大脑；先证明用户愿意记录、认可卡片价值、并能在未来找回它们。**

### 1.1 与传统知识库的核心差异

| 传统知识库 | Mnora · 见藏 |
|---|---|
| 管理已有资料 | 保存用户与现实世界发生关系的记录 |
| 整理后搜索 | 记录、理解、确认、找回与回顾 |
| 知识通常是外部输入 | 原始观察、AI 派生内容、用户修正可区分、可追溯 |

### 1.2 不可妥协原则

1. **Local-First 是产品承诺**：无账号、无网络时仍可创建、浏览、搜索、删除、恢复。保存成功只由本地事务决定，AI/登录/同步/服务端故障不得导致原始记录丢失。
2. **用户是记忆的最终权威**：`Observation + CardVersion + UserCorrection = EffectiveCard`。AI 不替用户创造或覆盖记忆，来源必须分存。
3. **隐私与地域先于便利**：渐进式账户、AI 逐级授权、`private_local` 硬边界、中国大陆单地域。
4. **AI 走确定性 Pipeline，不引入自主 Agent**：`质量检查 → OCR/Vision → 分类路由 → 可选检索 → 结构化生成 → Schema 校验 → 策略校验 → 持久化 CardVersion`。LLM 不直接写库、不持任意工具权限。
5. **关系/Embedding/搜索均是派生能力**：必须可从接受的卡片、纠错和来源重建，随删除与私密策略完整清理。

### 1.3 能力分层与解锁条件

| 能力层 | 用户问题 | 核心对象 | 解锁条件 |
|---|---|---|---|
| 记录层 | 如何可靠留下当下 | Principal、DeviceIdentity、Observation、LocalAsset | 当前优先完成 |
| 理解层 | AI 能否帮我整理 | ConsentSnapshot、AIJob、CardVersion、Provenance | 记录闭环稳定后 |
| 记忆层 | 以后如何找回 | Timeline、FTS、EffectiveCard、Correction | 卡片价值成立后 |
| 关联与回顾层 | 有什么值得再次看见 | 可重建 Entity/Relation、回顾规则 | 有足够真实记录和找回需求后 |
| 个人认知层 | 长期记录揭示什么 | 可解释、可关闭的派生洞察 | 长期留存与隐私价值均被验证 |

---

## 2. 技术栈与仓库信息

| 项 | 值 |
|---|---|
| 公开产品名 | Mnora · 见藏 |
| 暂存技术名 | `cognote`（Dart package、数据库、Android applicationId 等，后续单独迁移） |
| 主仓库 | `D:\Hermes\cognote` |
| GitHub 账号 | `AurvalLab`（Profile name：`Aurval`） |
| 远程 | `https://github.com/AurvalLab/Cognote.git` |
| Git 作者 | `Aurval <201062279+AurvalLab@users.noreply.github.com>`（仅仓库级配置） |
| 语言/框架 | Flutter + Dart（SDK `^3.12.2`） |
| 本地数据库 | Drift `^2.34.2` + SQLite（sqlite3 `^3.5.0`） |
| 依赖 | crypto、image、path、path_provider、uuid |
| dev 依赖 | flutter_test、integration_test、flutter_lints、drift_dev、build_runner |
| 目标平台 | Android；CNG-109 验收设备 API 35；当前构建 `targetSdkVersion=36` |
| 未来服务端 | FastAPI 模块化单体 + PostgreSQL + 私有对象存储 + Redis/ARQ |

---

## 3. 实时 Git 基线（2026-08-14 核验）

以下为本次交接时的真实核验结果。Codex 接手后必须重新核验，不得直接采信。

```text
branch        = codex/mnora-brand
HEAD          = 56c603e43b3aa728038e1918458d0ece60ca89fc
upstream      = origin/codex/mnora-brand
master        = 6d0a320aeda7642e759cb69a6e5467b973624ea5
origin/HEAD   = origin/master
GitHub default branch = master
Draft PR      = https://github.com/AurvalLab/Cognote/pull/1
```

工作区状态（非 clean）：

```text
 M pubspec.lock               （既有依赖解析差异，未纳入 Mnora 品牌提交）
 ?? cognote-agent-artifacts/  （仓库根目录内未跟踪，未纳入 Mnora 品牌提交）
```

分支与 worktree：

```text
本地分支：feat/cng-100、feat/cng-101、feat/cng-102、master、codex/mnora-brand（当前）
远程分支：origin/feat/cng-100、origin/master、origin/codex/mnora-brand
origin/HEAD   → origin/master（已修复）
worktree 列表 = 仅主仓库
.worktrees/feat-cng-103 = 空残留物理目录（元数据已注销）
.git/worktrees/          = 空（无活跃 worktree 元数据）
```

远程治理结论：`feat/cng-100` 是 `master` 的祖先；CNG-100～109 的实现提交均已进入 `master`，没有遗漏代码。此前 GitHub 贡献统计异常的主因是默认分支错误指向 `feat/cng-100`，现已改为 `master`。历史提交使用 `05jly0325@gmail.com`；该邮箱迁移并验证到 `AurvalLab` 后，无需重写 Git 历史即可重新关联贡献。

---

## 4. 阶段与任务进展总览

### 4.1 阶段 0：规格冻结 —— 已完成

已冻结：PRD、用户流程、数据模型、隐私数据流、状态机、12 个 ADR、OpenAPI outline、AI 评测、MVP 指标。6 项 P0 决策全部确认：

- DEC-001 渐进式账户（匿名可用，登录后幂等无损归并）
- DEC-002 首次统一授权 + 敏感内容动态确认
- DEC-003 分析副本最小留存（成功即时删、失败 24h）
- DEC-004 植物唯一深度领域 + 文字整理 + 通用 fallback
- DEC-005 中国大陆单地域优先
- DEC-006 MVP 私密记录仅支持 `private_local`

P1 待决策：DEC-007（Provider fallback）、DEC-008（MVP-B 公开测试）、DEC-009（Redis/ARQ 时点）、DEC-010（卡片信息密度）。

### 4.2 阶段 1：本地纵向切片 —— 进行中

路线图任务与真实状态：

| 任务 | 名称 | 状态 |
|---|---|---|
| CNG-100 | 匿名 Principal、DeviceIdentity 与安全安装标识 | 已提交 |
| CNG-101 | Flutter/Drift 最小工程 | 已提交 |
| CNG-102 | Observation 与 LocalAsset 表及迁移 | 已提交 |
| CNG-103 | 文字记录本地创建 | 已提交 |
| CNG-104 | 图片记录本地创建 | 已提交 |
| CNG-105 | 时间线与详情 | 已提交 |
| CNG-106 | 删除/恢复 | 已提交 |
| CNG-107 | 本地 FTS | 已提交 |
| CNG-107A | private_local 独立加密存储、Keychain/Keystore | **未开始** |
| CNG-108 | 持久化 Outbox 骨架 | 已提交 |
| CNG-109 | 强杀恢复和离线端到端测试 | **已提交 3 个 commit，验收收尾状态未冻结** |
| CNG-110 | 最小埋点与隐私过滤 | **未开始** |
| CNG-111 | 生产创建入口与本地记录 UI 闭环 | **规划新增，未开始** |
| CNG-112 | 本地编辑与 FTS/Outbox 一致性 | **规划新增，未开始** |

阶段 1 退出条件：飞行模式可完成创建、浏览、搜索、删除和恢复；强杀不丢数据。仅有 Dart 测试通过不替代 E5/O3 真机/模拟器证据。

### 4.3 提交历史基线

```text
a48fe5f docs: freeze Cognote stage 0 specifications
70f584b chore: initialize Android Flutter scaffold
158500c feat: implement local anonymous identity            (CNG-100)
34addb4 feat: wire application bootstrap                    (CNG-101)
731979c feat: add observation and local asset schema        (CNG-102)
4ed23a5 feat: add text observation creation                 (CNG-103)
3db47b1 feat: add local image observation creation          (CNG-104)
6439f75 feat: add observation timeline and detail           (CNG-105)
c84ecb8 feat: add observation deletion and restore          (CNG-106)
e2bde73 feat: add local observation search                  (CNG-107)
2a9c4e7 feat: add persistent observation outbox             (CNG-108)
60a113a test: cover application restart recovery            (CNG-109)
43e3eac test: add android force-stop recovery coverage      (CNG-109)
6d0a320 test: parameterize android recovery baselines       (CNG-109)
56c603e feat: rebrand product as Mnora                      (Draft PR #1，尚未进入 master)
```

---

## 5. 当前代码能力矩阵

源码 44 个 Dart 文件、40 个测试文件。分层为 Presentation → Application → Domain → Data(Drift)。

### 5.1 身份（Identity）

- 本地匿名 Principal、持久化 DeviceIdentity；
- Application 启动时完成身份初始化，ownerId/deviceId 自动绑定；
- 已有 SQLite transaction 与完整性测试。

### 5.2 Observation 领域模型

```text
id, ownerId, inputType(image|text), rawText, capturedAt,
timezoneOffset, privacyLevel(仅 normal), cloudAiPolicy,
syncPolicy(localOnly|syncEnabled), createdByDeviceId,
createdAt, updatedAt, deletedAt, serverRevision
```

时间统一 UTC；历史记录显示应结合记录时保存的 timezoneOffset，不应用当前设备时区重新解释。

### 5.3 已实现的本地闭环

- 文字 Observation 创建、图片 Observation 创建；
- 时间线、只读详情、软删除、恢复、已删除列表；
- 本地 FTS 全文搜索（FTS5 trigram、owner 隔离、墓碑过滤、响应式 Stream、Unicode-safe snippet）；
- 持久化 Outbox（本地耐久 mutation 队列骨架，非网络队列）。

### 5.4 明确不存在 / 禁止提前实现

账号登录、Token、服务端 API、HTTP Client、图片上传、后台 Worker、WorkManager、网络状态监听、定时同步、指数退避、DLQ、push/pull/cursor、ServerChange、完整 SyncOperation、冲突解决、多设备合并、媒体备份、KnowledgeCard、AI 分析、Embedding、向量检索、同步状态 UI、手动重试 UI。

`docs/architecture/sync.md` 描述的是 MVP-B 未来同步协议，不得反向扩大当前任务。

---

## 6. 数据库 Schema 现状

`schemaVersion = 4`。

业务表：

```text
principals
device_identities
observations
local_assets
outbox_operations
```

FTS5 虚拟表及 trigger（CNG-107 创建）：

```text
observation_search_fts
```

### 6.1 Outbox 冻结语义（CNG-108）

- 表 `outbox_operations`：`operation_id`(PK)、`owner_id`(FK→principals, RESTRICT)、`device_id`(FK→device_identities, RESTRICT)、`aggregate_type`(仅 observation)、`aggregate_id`(无 Observation FK)、`operation_kind`(observation_upsert|observation_delete)、`created_at`。
- 索引 `(owner_id, created_at, operation_id)`；固定读取顺序 `createdAt ASC → operationId ASC`。
- 明确无 payload/status/attemptCount/nextAttemptAt/lastError/serverRevision/baseRevision/localPath 等字段；无 ack/retry/消费接口。
- mutation 映射：文字创建→upsert、图片创建→upsert、软删除 changed→delete、恢复 changed→upsert；unchanged/notFound/FTS/搜索/文件复制不写 Outbox。
- 原子性：业务 mutation 与 Outbox 同 transaction；冲突或插入失败整体回滚。
- 幂等：operationId 用 UUIDv7；相同 operationId 全字段比对，相同则幂等成功，任一不同抛 `OutboxOperationConflictException`。
- 并发：不得先 SELECT 再 UPDATE；真实 Future.wait 测试证明 changed-only 语义。

---

## 7. 架构分层与边界规则

- Presentation 不直接访问数据库；
- Application 自动绑定 owner/device；
- Repository 负责真实 Drift/SQLite 语义；
- FTS 由数据库层过滤 owner 与 deletedAt；
- 业务 mutation 与 Outbox 同 transaction；
- 生产 Application mutation 必须用 Outbox capability；缺失时抛 StateError，不得 fallback 旧写接口；
- 测试 fake 必须显式实现接口，不得用 `noSuchMethod` 掩盖缺失；
- Drift generated row 与领域模型不同名（`OutboxOperation` vs `OutboxOperationRow`）；
- 网络 DTO、领域模型、Drift 表模型分离。

---

## 8. Git 治理规则（强制）

### 8.1 始终禁止（除非负责人单项授权）

```text
git reset / reset --hard / restore / checkout -- . / clean / stash / rebase /
cherry-pick / commit --amend / push --force / push --force-with-lease /
branch -D / worktree remove --force / worktree prune /
手工删除 .git/worktrees 元数据
```

### 8.2 暂存规则

禁止 `git add .` / `-A` / `--all` / `*`。只能在人工 Diff 审查通过后，对明确白名单执行 `git add -- <精确文件列表>`。

### 8.3 权限分阶段（前一阶段通过不代表获得下一阶段权限）

```text
只读审计 → 规格冻结 → 创建 branch/worktree → 开发与测试 → 人工 Diff 审查
→ 精确白名单暂存 → staged Diff 审查 → 普通 commit → 推送 topic branch
→ Draft PR（base=master）→ CI/人工审查 → 负责人授权合并 → 远程核验
```

### 8.4 合并与推送

默认从最新 `master` 创建 `codex/<topic>` 分支，普通推送 topic branch，并创建显式以 `master` 为基线的 Draft PR。禁止直接推送 `master`、force push、rebase、cherry-pick，以及未经授权自行合并 PR。合并策略由负责人结合 PR 与 GitHub 设置决定；不得为了补齐历史记录伪造已完成的 CNG 分支。删除本地/远程分支或 worktree 前必须单独确认，不能把“PR 已合并”视为删除授权。

---

## 9. 环境与命令规则

### 9.1 Git 远程代理（Clash Verge 逐命令代理，禁改全局）

```powershell
git -c http.proxy=http://127.0.0.1:7897 `
    -c https.proxy=http://127.0.0.1:7897 `
    <git command>
```

### 9.2 Flutter 镜像

```powershell
$env:PUB_HOSTED_URL="https://pub.flutter-io.cn"
$env:FLUTTER_STORAGE_BASE_URL="https://storage.flutter-io.cn"
```

### 9.3 测试前移除会话代理变量

```powershell
Remove-Item Env:HTTP_PROXY -ErrorAction SilentlyContinue
Remove-Item Env:HTTPS_PROXY -ErrorAction SilentlyContinue
Remove-Item Env:ALL_PROXY -ErrorAction SilentlyContinue
```

### 9.4 标准质量门禁（Flutter SDK 位于 `D:\SDK\flutter`）

```powershell
D:\SDK\flutter\bin\flutter.bat pub get
D:\SDK\flutter\bin\dart.bat format --output=none --set-exit-if-changed .
D:\SDK\flutter\bin\dart.bat analyze
D:\SDK\flutter\bin\flutter.bat test --no-pub --concurrency=1 -r compact
git diff --check
```

必须报告真实文件数与测试数。

### 9.5 build_runner

生成 Drift 代码用 `D:\SDK\flutter\bin\dart.bat run build_runner build`；不得手工编辑 generated 文件（`cognote_database.g.dart`）。

---

## 10. 当前工作区待决策风险点（Codex 与负责人必须对齐）

以下为本交接时仍需显式处理或持续注意的状态问题，Codex 不得顺手清理：

1. **`cognote-agent-artifacts/` 位于仓库根目录且未跟踪**：不得删除、修改或提交。Git 写操作必须继续使用精确文件白名单，避免误纳；是否移回仓库外或加入精确忽略规则仍需负责人单独决策。
2. **`pubspec.lock` 有未提交改动**（117+/109-，近期 `flutter pub get` 重排）。需确认是否提交、还是 revert 回 CNG-109 基线。
3. **Mnora 品牌变更仍在 Draft PR #1**：`codex/mnora-brand` 已推送，提交 `56c603e` 尚未进入 `master`。新任务开始前必须核验 PR 状态，不得假定已合并。
4. **CNG-109 缺规格冻结报告/handoff**：三个 commit 已直接落在 master，未见《CNG-109 规格冻结报告》或 handoff 文档，需负责人确认 CNG-109 是否已验收关闭，还是仍需补冻结报告。
5. **E5/O3 证据设备等级**：最新证据 `cng109-20260803T131234Z-7ba0` 的 `run-metadata.json` 显示 `serial=emulator-5554, qemu=1, api=35`，即 API 35 **模拟器**，非物理真机。战略规划要求"真实 Android API 35 E5/O3 执行"，需确认模拟器证据是否满足验收，还是必须补真机证据。
6. **Android APK 构建需显式选择 JDK**：PATH 默认仍指向 Java 11，但本机已有 `D:\java——JDK`（Temurin JDK 25）。2026-08-14 已仅对命令设置 `JAVA_HOME`，补齐官方构建缓存并完成 `android\gradlew.bat assembleDebug --no-daemon --console=plain`（exit 0）；新 APK 为 178,861,555 bytes，`aapt dump badging` 确认 package=`com.cognote.cognote.cng109`、`targetSdkVersion=36`、label=`Mnora · 见藏`。不得改全局 Java 配置，也不得把 PATH 默认值误报成代码编译失败。

---

## 11. CNG-109 状态与 E5/O3 证据

### 11.1 已提交内容

- `60a113a`：应用重启恢复测试（`test/application/cng109_recovery_test.dart`，317 行）。
- `43e3eac`：Android force-stop 恢复覆盖（`integration_test/cng109_prepare_test.dart` 227 行、`cng109_verify_test.dart` 160 行、`tool/cng109_android_e2e.ps1` 349 行、`android/app/build.gradle.kts`、pubspec）。
- `6d0a320`：参数化 Android 恢复基线（`tool/cng109_android_e2e.ps1` 41 行增量）。

### 11.2 E5/O3 测试设计

- 测试包名 `com.cognote.cognote.cng109`，活动 `com.cognote.cognote.MainActivity`。
- 脚本 `tool/cng109_android_e2e.ps1` 通过 adb 编排：prepare → 飞行模式(O3) → force-stop(E5) → 重启 → verify → 网络恢复 → 测试包卸载。
- 产物协议 `application-support-export-via-run-as`，产出 `prepare-result.json`、`verify-result.json`、`outbox-before/after.json`、`network-before/airplane/after.json`、`force-stop.log`、`airplane-broadcast.log`、`restore-broadcast.log`、`cleanup-result.json`、`run-metadata.json` 等。
- 证据目录：`cognote-agent-artifacts/cng-109-e5-o3/`（`master-rerun/` 为空目录；`cng109-20260803T131234Z-7ba0/` 为最新完整证据）。

### 11.3 三种证据强度（必须区分）

```text
A. 数据库 close/reopen（真实 SQLite 文件）
B. 应用关闭并重建 bootstrap（Application 级）
C. 操作系统级 force-stop（adb am force-stop / 飞行模式）
```

不得把 A 伪装成 C；也不得为"看起来更真实"无边界引入测试平台。

---

## 12. 规划期望（按计划的路线）

### 12.1 阶段 1 收尾：可靠的本地记录系统（当前焦点）

目标：用户可放心记录，系统不因离线、重启、强杀丢内容。

1. **确认 Draft PR #1 的处理**：先审查 Mnora 品牌变更，合并后再从最新 `master` 建立功能分支。
2. **完成 CNG-109 收尾**：确认 E5/O3 证据等级是否达标，必要时补真机证据；补《CNG-109 规格冻结报告》或明确验收关闭。
3. **完成 CNG-111**：补齐文字和图片的生产创建入口，形成飞行模式下可实际操作的本地记录闭环。
4. **完成 CNG-112**：支持本地编辑，并冻结 FTS、Outbox、时间字段和删除状态的一致性语义。
5. **处理 CNG-107A**：先完成 `private_local` 威胁模型与存储方案 spike；在独立加密边界成立前不得暴露伪私密入口。
6. **完成 CNG-110**：只采集最小产品验证事件，不采集图片、原文、私密内容、EXIF、完整 AI 输出；阶段 1 仅定义本地可测试 sink，不引入远程发送。

本阶段不扩展：云 AI、同步、知识图谱、推荐、个体画像。

### 12.2 阶段 2：AI Card MVP

目标：验证 AI 卡片是否比"只保存原始内容"更有价值。

按路线图推进：FastAPI 模块化单体、cn-mainland AI Gateway、PostgreSQL/Alembic、ConsentSnapshot、私有对象上传与分析副本删除、AIJob/Attempt 幂等状态机、Provider 能力适配、植物/通用图片/文字路由、KnowledgeCard Schema、Provenance、CardVersion、Flutter 处理态与用户纠错。

退出条件：真实设备与真实 Provider 完成"本地记录 → 授权 → 上传 → AI → 确认/纠错"；失败不丢原始记录；隐私、区域、删除策略验证通过。

### 12.3 阶段 3：账号与同步（不是知识关联）

目标：不损失匿名阶段数据、不静默覆盖冲突的前提下支持可选账户与多设备。

包括：认证、Device 注册、匿名主体幂等归并、SyncOperation/ServerChange、push/pull/cursor、冲突矩阵、媒体备份开关、双设备故障注入、导出、撤销与账号删除。

退出条件：重复、乱序、中断、并发编辑、删除/恢复、越权访问测试通过。

### 12.4 阶段 4：检索与回顾（按需求解锁，非默认承诺）

前置条件至少满足一项：用户累计卡片超 20 张；30% 以上用户反馈找不到旧记录；收集 50 个真实检索问题；本地 FTS 与时间线无法满足找回。

然后才逐步建设：服务端 FTS、真实检索问题集、接受卡片的 Embedding、混合召回、带引用问答、每日回顾、历史上的今天、私密与删除内容排除测试。

### 12.5 阶段 5：关联与个人认知洞察（远期探索）

研究方向，不写成预设交付承诺。不做黑箱人格画像；不以"更了解用户"为理由扩大采集、上传或跨域使用数据。

### 12.6 北极星指标与决策门

- 北极星：第二周有效记录留存率（完成首卡用户中，第二周仍至少保存 2 张卡、分布在 2 个不同日期），初始门槛 ≥25%。
- 早期决策指标：无指导完成首卡 8/10、AI 卡片保存率 ≥70%、实质纠错率 ≤20%、D7 回访 ≥30%、20 秒内找回旧卡 ≥80%、数据丢失/严重崩溃/隐私事故 = 0。
- 明确不当成功指标：下载量、注册数、累计卡片数、页面浏览、AI 调用量、会话时长、无留存支撑的"功能很酷"。

---

## 13. 规格文件必读索引

严格按顺序阅读（阶段 0 冻结的权威规格）：

1. `README.md`
2. `docs/README.md`
3. `docs/product/brand.md`
4. `docs/product/strategy.md`
5. `docs/roadmap/current-plan.md`
6. `docs/open-decisions.md`
7. `docs/product/prd.md`
8. `docs/product/user-flows.md`
9. `docs/product/privacy-modes.md`
10. `docs/architecture/overview.md`
11. `docs/architecture/data-model.md`
12. `docs/architecture/state-machines.md`
13. `docs/architecture/privacy-data-flow.md`
14. `docs/architecture/ai-provenance.md`
15. `docs/architecture/sync.md`（MVP-B 未来协议，勿扩大当前任务）
16. `docs/architecture/adr/001`～`012`
17. `docs/roadmap/mvp-tasks.md`
18. `docs/quality/spec-consistency-report.md`
19. `docs/quality/mvp-metrics.md`
20. `docs/quality/ai-evaluation-plan.md`
21. `docs/api/openapi-outline.yaml`

---

## 14. 关键代码位置（优先审计）

```text
lib/src/database/cognote_database.dart
lib/src/database/cognote_database.g.dart
lib/src/application/cognote_application.dart
lib/src/presentation/cognote_app.dart
lib/src/identity/
lib/src/observation/domain/observation.dart
lib/src/observation/domain/local_asset.dart
lib/src/observation/domain/observation_repository.dart
lib/src/observation/domain/observation_outbox_mutation_repository.dart
lib/src/observation/application/create_text_observation.dart
lib/src/observation/application/create_image_observation.dart
lib/src/observation/data/drift_observation_repository.dart
lib/src/observation/data/file_asset_storage.dart
lib/src/outbox/
lib/src/presentation/timeline_page.dart
lib/src/presentation/observation_detail_page.dart
lib/src/presentation/deleted_observations_page.dart
lib/src/presentation/observation_search_page.dart
```

---

## 15. 陷阱与经验教训（历史审查总结）

1. Drift generated row 与领域模型不要同名（`OutboxOperation` / `OutboxOperationRow`）；不得用 import hide 掩盖命名冲突。
2. 测试 fake 不得用 `noSuchMethod` 万能实现掩盖接口缺失。
3. 不可变领域值必须原样持久化（`operation.createdAt` 不能被 deletedAt/restoredAt 替代）。
4. 数据库关闭重开测试必须严格串行（`await first.close()` 后再建 reopened），避免 Drift multiple-database warning。
5. 迁移失败测试必须直接检查失败后的真实 SQLite 文件、user_version、原数据和半成品 schema，不能只证明"之后还能成功迁移"。
6. 全量测试通过只是中间证据；任何后续改动都必须重跑 analyze、定向测试、全量测试。
7. `git worktree remove` 报错后必须检查 physical/metadata 组合，不能自动 force。`physical=True, metadata=False` 表示已注销只剩孤立目录，应移动到仓库外保存，禁止 force/prune。
8. Windows 下 worktree 删除常被 ignored 生成物（`.dart_tool/`、`build/`、`android/local.properties`、`GeneratedPluginRegistrant.java`）阻塞。
9. build_runner 的 `--delete-conflicting-outputs` 已移除并忽略，直接用 `build_runner build`。
10. 远程 fetch 失败必须停止，不得把缓存 ref 当最新事实；实时远程核验需走第 9.1 节代理。

---

## 16. Codex 接管后建议首动作

```text
只读核验，不做任何 Git 写操作
```

1. 重新核验 `git status --short --untracked-files=all`、当前分支、`HEAD/master/origin/master`、`git log --oneline -15`、`git worktree list`。
2. 核验 GitHub 仓库为 `AurvalLab/Cognote`、默认分支为 `master`，并读取 Draft PR #1 的实时状态。
3. 用代理核验实时远程：`git -c http.proxy=http://127.0.0.1:7897 -c https.proxy=http://127.0.0.1:7897 ls-remote origin refs/heads/master refs/heads/codex/mnora-brand refs/heads/feat/cng-100`。
4. 确认 `git config --local user.name` 为 `Aurval`，`user.email` 为 `201062279+AurvalLab@users.noreply.github.com`。
5. 明确排除 `pubspec.lock` 与 `cognote-agent-artifacts/`，除非负责人针对其中某项另行授权。
6. 按 `docs/roadmap/current-plan.md` 选择单一下一目标；当前推荐先处理 PR #1 与 CNG-109 验收，再进入 CNG-111。
7. 任何 Git 写操作（add/commit/merge/push）必须等待负责人单独授权。

---

## 17. 交接复核清单

- [ ] 已读取本文件
- [ ] 已读取 `docs/product/brand.md`、`docs/product/strategy.md`、`docs/roadmap/current-plan.md`
- [ ] 已实时核验 branch、HEAD、master、origin/master、worktree
- [ ] 已用代理核验真实远程 master hash
- [ ] 已核验 GitHub 账号、远程 URL、默认分支、Draft PR #1 与仓库级 Git 作者身份
- [ ] 已与负责人对齐 cognote-agent-artifacts / pubspec.lock / CNG-109 验收 / E5-O3 设备等级 / 构建 JDK 选择
- [ ] 已确认当前授权边界（只读审计为默认态）
- [ ] 未执行任何未授权 Git 写操作

---

## 18. 新会话标准开场白

每次建立新的项目会话，复制以下文本作为第一条消息；日期、PR 编号和目标任务发生变化时，先更新本节再交接。

```text
阅读 `docs/handoff/codex-handoff-2026-08-14.md`、`docs/roadmap/current-plan.md`、`docs/product/brand.md` 和 `docs/product/strategy.md`，接管 Mnora · 见藏项目。

先执行只读核验：检查当前 Git 分支、HEAD、工作区、worktree、远程 URL、GitHub 默认分支和 Draft PR 状态，并将结果与交接文件对照。不要直接相信快照，也不要执行任何 Git 写操作。

特别保留并排除既有的 `pubspec.lock` 未提交改动与 `cognote-agent-artifacts/` 未跟踪目录；不得删除、恢复、移动、暂存或提交它们，除非我单独授权。

确认当前公开产品名为 `Mnora · 见藏`，GitHub 账号为 `AurvalLab`，仓库级 Git 作者应为 `Aurval <201062279+AurvalLab@users.noreply.github.com>`。历史 `Cognote` 仅作为暂未迁移的技术标识与历史记录保留。

完成核验后，先用中文向我汇报：当前真实状态、与交接文件的差异、主要风险，以及你建议推进的唯一下一任务。得到我的确认后，再进入规划或实现。
```

若新会话已经明确指定任务，可在末尾追加：

```text
本次唯一目标：<任务编号与一句话目标>。除完成该目标所必需的正常实现与验证外，不扩大范围。
```
