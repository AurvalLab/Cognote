# Mnora · 见藏当前执行计划

- 快照日期：2026-08-15（Asia/Shanghai）
- 当前阶段：阶段 1，本地记录闭环收尾
- CNG-111 实现合并锚点：PR #3 / `e3ce10cf577b0e257963d138ec7d9ee4f426d7c7`
- CNG-111 closeout 合并锚点：PR #4 / `0ab2b31df5bd076c2008124de73ba4c807cc4988`
- 当前实现任务：无；下一阶段开工包已指向 CNG-111A 规格冻结，但 CNG-111A、CNG-112、CNG-107A、CNG-110 均未授权启动
- 实时基线规则：开始任何新任务前重新核验远端 `master`；本文件中的 SHA 是已完成事项锚点，不冒充永久当前 HEAD
- 默认权限：没有活动实现授权；暂存、提交、推送、PR、下一任务实现和任何分支/worktree 清理均需按阶段单独授权

本文件是当前状态和下一步的唯一执行源。长期战略见 `docs/product/strategy.md`，全阶段任务目录见 `docs/roadmap/mvp-tasks.md`。

## 1. 当前事实

| 范围 | 状态 | 证据或边界 |
|---|---|---|
| 公开品牌 | 已定义 | 全称 `Mnora · 见藏`；技术标识 `cognote` 暂时保留，见品牌规范 |
| CNG-100～108 | 已实现并提交 | 匿名身份、Drift schema、文字/图片创建用例、时间线/详情、删除恢复、FTS、Outbox 骨架 |
| CNG-109 | **已验收关闭** | 负责人于 2026-08-14 接受 API 35 模拟器 E5/O3 证据；验收报告见 `docs/quality/cng-109-acceptance-2026-08-14.md` |
| 生产创建 UI | **CNG-111 已验收并合入** | 独立终审 `PASS`；实现提交 `ba3958d`，PR #3，merge commit `e3ce10c`；API 35 模拟器完成飞行模式文字、DocumentsUI 图片、搜索、删除和恢复闭环 |
| 本地编辑 | 缺失 | 详情页只读，Repository/Application 未提供编辑用例 |
| CNG-107A | 未开始 | 当前 `PrivacyLevel` 只有 `normal`；不得展示或声称 `private_local` 已可用 |
| CNG-110 | 未开始 | 阶段 1 无服务端；远程分析事件发送不应被偷偷引入 |
| 云 AI、账号、同步 | 不存在 | OpenAPI 和 `sync.md` 是未来契约，不是当前能力 |

主工作区仍有不得顺手处理的既有状态：`pubspec.lock` 未提交差异，以及未跟踪的 `AGENTS.md`、`cognote-agent-artifacts/` 和旧 `docs/handoff/current.md`。本 handoff-finalize worktree 不触碰它们，也不包含 Dart package、数据库、Android applicationId 或仓库路径迁移。

## 2. 先决策，再继续交付

除已关闭的 GATE-03 外，下列事项仍需要负责人明确结论。它们不影响已经关闭的 CNG-109/CNG-111，但会阻塞各自相关能力的发布或后续任务验收：

| 编号 | 决策 | 推荐 | 影响 |
|---|---|---|---|
| GATE-01 | `cognote-agent-artifacts/` 放置方式 | 移回仓库外归档；若需暂留则先加入精确忽略规则 | 防止大体积证据误入版本库 |
| GATE-02 | `pubspec.lock` 差异处理 | 单独审计依赖版本与镜像 URL，再决定保留或恢复基线 | 防止规划改动夹带依赖升级 |
| GATE-03 | CNG-109 是否接受模拟器证据 | **已关闭：负责人接受 API 35 模拟器证据** | CNG-109 已关闭；API 35 物理真机验证移至阶段 1 发布门禁 |
| GATE-04 | `private_local` 的阶段边界 | 未完成 CNG-107A 前不暴露入口；最迟在任何上传能力上线前完成 | 避免 UI 标签冒充安全边界 |
| GATE-05 | CNG-110 的事件去向 | 阶段 1 只定义事件、过滤器与本地可测试 sink；远程发送留到授权和服务端就绪后 | 避免无授权遥测和伪后端 |

## 3. 推荐执行顺序

### 3.1 CNG-109：可靠性验收已完成

结论：2026-08-14 已完成可复现验收，负责人接受 API 35 模拟器设备等级并关闭 GATE-03/CNG-109。

交付物：

- 一份 CNG-109 验收报告，列出提交、命令、设备类型、API、网络阶段、force-stop 行为和证据目录；
- 明确区分 SQLite close/reopen、Application rebuild、操作系统 force-stop 三种证据强度；
- 已记录负责人接受模拟器的 GATE-03 结论，并把物理真机验证移至阶段 1 发布门禁；
- 记录 `pubspec.lock` 是否与证据基线一致，不在该任务中夹带依赖调整。

关闭条件已满足：证据可复现、设备等级已被接受、遗留风险已有负责人结论。API 35 物理真机验证移至阶段 1 发布门禁。

### 3.2 CNG-111：生产创建入口与本地闭环

状态：**已完成并关闭**。实现前规格已冻结于 `docs/quality/cng-111-spec-2026-08-15.md`；独立终审为 `PASS`，无遗留 P0～P3 finding。

这是规划审计新增的任务，用于补上现有路线图遗漏。唯一目标是在飞行模式下，通过生产 UI 完成文字或单图片本地创建并返回时间线，不扩大到编辑、云能力或自定义相机。

范围：

- 时间线提供“记录此刻”入口；
- 支持非空文字创建；
- 支持单张图片选择/导入和可选说明；
- 显示准备、保存、校验失败和本地空间错误；
- 保存成功后返回时间线并可打开详情；
- 飞行模式下可完成创建、浏览、搜索、删除和恢复。

非范围：编辑既有记录、相机自定义实现、批量导入、Share Sheet、云 AI、上传、后台同步。

验收结论（2026-08-15）：

- format 91 files / 0 changed；analyze 0 issues；完整 Dart/Widget 测试 194/194；`git diff --check` 通过；
- Android Debug APK 构建成功，API 35 x86_64 模拟器在飞行模式下通过生产 UI 创建一条文字和一条 PNG 图片记录；
- 系统 Storage Access Framework 选择器成功返回图片，最终数据库为 2 条 Observation、1 条 LocalAsset、2 条创建 Outbox，原图存在于应用私有目录；
- 新建文字可搜索、可进入详情、可删除并从“已删除记录”恢复；最终 2 条记录均 active，Outbox 共 4 条；
- 设备验收发现并修复 Drift/SQLite DateTime 以 Unix 秒持久化时的精度冲突，新增亚秒时间回归测试，未放宽超过数据库可表达精度的真实冲突；
- 模拟器网络已恢复到验收前的飞行模式 0、Wi-Fi 1、移动数据 1。物理真机验证仍属于阶段 1 发布门禁，不由本任务冒充完成。

独立审查修复（2026-08-15 16:03，Asia/Shanghai）：

- 页面销毁时会清理延迟返回的新图片；替换旧图等待清理期间离页时，新旧临时文件各清理一次；
- 图片回调被调用即把临时文件所有权转移给 Application，页面不再并发删除；文字/图片保存 in-flight 时由 `PopScope` 阻止返回；
- picker 的 `unavailable`、`busy`、`unsupported`、`storage`、`unreadable`、`invalid_result` 与 `too_large` 均提供对应恢复指引；
- Android Provider MIME 仅作为可空 hint：`null`、`image/jpg`、`application/octet-stream` 与错误的精确 MIME 不再抢先否决合法内容；临时文件未知类型使用中性 `.img`，支持性最终由既有 magic/decode Pipeline 判断；
- Provider 的 MIME 查询、输入打开/读取/关闭失败明确映射为 `unreadable`；缓存目标的临时文件创建、输出打开、写入、`fd.sync` 与关闭失败明确映射为 `storage`；纯 Java I/O seam 通过实际编译执行覆盖上述失败路径与 `too_large`，不再只依赖 Kotlin 源码字符串断言；
- format 94 files / 0 changed；analyze 0 issues；生命周期与错误提示定向测试 38/38，平台错误分类定向测试 9/9；完整 Dart/Widget 测试 211/211；Android `assembleDebug` 成功（148 tasks）；`git diff --check` 通过；
- API 35 x86_64 模拟器覆盖安装最新 Debug APK 后，经真实 DocumentsUI 再次选择既有 PNG 并成功创建，时间线新增图片记录，picker 缓存目录为空；同一 ADB shell 在点击保存后紧接发送 BACK，最终仍成功返回时间线。由于 82 KiB 图片处理很快，设备证据不能单独证明 BACK 一定落在 busy 窗口内；确定性的 in-flight 拦截证据来自文字/图片两条延迟 Future Widget 测试；
- 测试误触发的 CNG-111 worktree `pubspec.lock` 解析差异已在负责人精确授权下恢复到 HEAD，SHA256 为 `54C0C841A46889362F665878BB667EA89B7A2F52278A4463942F1A2614F658F7`；主工作区受保护 lock 差异未触碰。

发布结论：21 个白名单文件以 `ba3958d` 提交并推送；Draft PR #3 经回读确认后转为 Ready，于 2026-08-15 合入 `master`，merge commit 为 `e3ce10c`。负责人要求保留 topic branch 与 worktree，未执行清理。

### 3.3 CNG-111A：产品体验与视觉基础

状态：**开工包已准备，未授权启动**。先冻结首页/时间线、创建、详情、搜索、已删除记录、关键状态和视觉基础，再让 UI 实现与 CNG-112 在一致页面和组件体系上推进。

唯一目标：把当前“功能可用但体验与视觉基础薄弱”的生产 UI 转化为可实现、可验收的规格，不在本任务直接改代码。

规格交付物：现状审计、核心流程与信息架构、页面/状态矩阵、最小视觉 token、基础组件清单、无障碍与适配底线、验收标准及后续实现分片顺序。

范围边界：不新增 Observation 字段，不修改 Dart/Kotlin/数据库，不实现 AI、同步、`private_local`、Share Sheet、语音、项目、知识图谱、推荐或个人画像；不以空 Tab、假数据或不可用入口制造功能感。

进入条件：本交接 finalization 先合入实时远端 `master`；独立产品体验指南改动经过审查并消除与权威文档的重复或冲突；随后由负责人从实时最新远端 `master` 单独授权 CNG-111A 分支/worktree 和精确文档范围。

关闭条件：范围内每个页面具备完整入口、返回路径和关键状态；交互与视觉规则无冲突且足以直接实现；未交付能力不被暴露；规格通过独立审查和负责人确认后，才允许拆分 UI 实现任务。

### 3.4 CNG-112：本地编辑与索引/Outbox 一致性

这是规划审计新增的第二个任务，用于兑现冻结 PRD 的离线编辑承诺。

范围：

- 文字记录可编辑 `rawText`；图片记录可编辑可选说明，不在本任务中替换原图；
- 保留 `capturedAt` 和 `createdAt`，只推进 `updatedAt`；
- 编辑与 `observation_upsert` Outbox 在同一事务提交；
- FTS 结果响应式更新，旧词不再命中、新词可以命中；
- 已删除记录不可直接编辑，恢复后才允许；
- 详情页提供编辑、取消、保存中、失败和重复提交保护。

验收：Repository/Application/Widget 测试覆盖 changed、unchanged、notFound、owner 隔离、并发更新、Outbox 冲突与 FTS 更新；飞行模式下编辑后重启仍保留新内容。

非范围：Observation 修订历史、协同编辑、冲突 UI、图片替换和 AI CardVersion 纠错；这些需要独立数据模型或后续同步协议。

### 3.5 CNG-107A：`private_local` 安全边界

在任务冻结前先做威胁模型和存储方案 spike，验证 Drift/SQLite、Android Keystore、密钥轮换、备份排除、后台预览遮蔽和卸载语义。

硬性规则：

- 未完成独立加密存储前，不能只加一个 `privacy_level` 字段就称为私密；
- 私密内容不得进入普通数据库、普通 FTS、Outbox、分析事件、日志或系统备份；
- 首次启用必须说明卸载、清除数据和设备损坏后的不可恢复风险；
- 如果阶段 1 不暴露私密入口，可把实现移到阶段 2 的上传前置门，但必须由负责人显式改期。

### 3.6 CNG-110：最小产品事件与隐私过滤

阶段 1 只建设可测试的事件契约、过滤器和本地 sink：

- 事件覆盖记录开始、保存成功/失败、编辑结果、搜索、旧记录打开、删除和恢复；
- payload 仅含随机主体/设备标识、事件时间、版本、耗时桶和错误码；
- 禁止图片、原文、路径、EXIF、搜索词、标题、OCR、完整异常栈和 `private_local` 内容；
- 私密模式下默认不产生可导出事件；
- 远程发送、供应商 SDK、ConsentSnapshot 和保留策略在阶段 2 单独冻结。

验收：允许字段采用白名单序列化；敏感字段注入测试证明无法外泄；事件失败不影响本地记录事务。

### 3.7 阶段 1 发布候选

所有前置任务完成后执行：

1. 全量 format/analyze/test 与迁移测试；
2. Android API 35 离线生产 UI 完成创建、编辑和找回验收；
3. 在 API 35 物理真机上复跑 CNG-109 runner，确认 force-stop 后 Observation、LocalAsset、墓碑和 Outbox 数量/内容一致；
4. 无创建入口断链、无数据丢失、无私密或埋点越界；
5. README、路线图、能力矩阵和验收报告同步；
6. 由负责人明确宣布阶段 1 关闭。

## 4. 阶段 2 进入门

同时满足以下条件后，才开始云端 AI 纵向切片：

- 阶段 1 退出条件已书面验收；
- 至少完成一轮真实用户的“创建并找回”可用性测试；
- DEC-007、DEC-009、DEC-010 在其对应实现前得到结论；
- 中国大陆部署和 Provider 数据处理地域可验证；
- 上传、授权、分析副本删除和失败补偿先于模型效果优化冻结；
- 第一条阶段 2 切片只支持一个输入路由、一个 Provider 和一个 Card Schema，跑通后再扩展。

## 5. 当前明确非范围

本阶段不实现登录、Token、HTTP Client、真实同步消费、WorkManager、重试队列、DLQ、媒体备份、KnowledgeCard、AIJob、Embedding、RAG、知识图谱、推荐或个人画像。

当前 Outbox 只是本地耐久 mutation 骨架；`docs/architecture/sync.md` 中的 payload、ack、retry、cursor 和冲突协议属于阶段 3。

## 6. 单任务 Definition of Done

每个任务必须同时具备：冻结范围与非范围、数据/API 影响、边界与失败测试、实际命令输出、文件清单、人工 diff 审查、遗留风险和验收结论。自动化测试通过不自动等于平台证据或产品验收通过。
