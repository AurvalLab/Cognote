# Mnora · 见藏当前交接

- 核验时间：2026-08-15 19:07（Asia/Shanghai）
- 当前阶段：阶段 1“可靠的本地记录”收尾
- CNG-111 实现合并锚点：PR #3 / `e3ce10cf577b0e257963d138ec7d9ee4f426d7c7`
- CNG-111 closeout 合并锚点：PR #4 / `0ab2b31df5bd076c2008124de73ba4c807cc4988`
- 当前文档任务：在 `codex/cng-111-handoff-finalize@0ab2b31` 完成交接终态与下一阶段开工包；仅修改本文件和 `docs/roadmap/current-plan.md`
- 下一阶段候选：CNG-111A 产品体验与视觉基础规格冻结；已明确开工边界，但尚未授权启动
- 文档性质：动态项目快照；新会话必须重新执行只读核验

## 1. 当前结论

CNG-111“生产文字/图片创建 UI 与本地闭环”已经完成代码、测试、独立终审和 GitHub 治理闭环。

- 实现提交：`ba3958d5f703f76f57d0085abb2cde44e566dda8`
- PR：`https://github.com/AurvalLab/Cognote/pull/3`
- PR 状态：`MERGED`
- merge commit：`e3ce10cf577b0e257963d138ec7d9ee4f426d7c7`
- 合并时间：2026-08-15 17:53:29（Asia/Shanghai）
- 独立终审：`PASS`，无遗留 P0～P3 finding
- 远端 topic branch 与本地 worktree 按负责人要求保留

CNG-111 closeout 文档已经通过 PR #4 合入 `master`：

- closeout 提交：`bfe6423152417d2d4aff7e100b82703da9130d94`
- PR：`https://github.com/AurvalLab/Cognote/pull/4`
- PR 状态：`MERGED`
- merge commit：`0ab2b31df5bd076c2008124de73ba4c807cc4988`
- 合并时间：2026-08-15 18:40:23（Asia/Shanghai）

CNG-111A、CNG-112、CNG-107A、CNG-110 均未开始。下一阶段的唯一候选、范围、非范围、交付物和验收条件已在第 8 节冻结为开工输入；这不等于授权启动或实现。

## 2. 实时 Git/GitHub 核验

| 项目 | 结果 |
|---|---|
| GitHub 仓库 | `AurvalLab/Cognote` |
| 远端 URL | `https://github.com/AurvalLab/Cognote.git` |
| 远端默认分支 | `master` |
| 远端 `master`（2026-08-15 18:58 核验） | `0ab2b31df5bd076c2008124de73ba4c807cc4988`；该值是带时间的核验事实，不是永久当前值 |
| PR #3 | `MERGED`，base=`master`，head=`codex/cng-111-production-create-flow` |
| PR #4 | `MERGED`，base=`master`，head=`codex/cng-111-closeout-docs` |
| PR mergeability（合并前） | `MERGEABLE/CLEAN` |
| GitHub checks | 未配置/未报告 checks，不能声称 CI 已通过 |
| CNG-111 topic branch | 远端与本地均保留，指向 `ba3958d` |
| CNG-111 worktree | 保留且 clean |
| closeout docs branch/worktree | 远端与本地均保留，指向 `bfe6423` |
| handoff finalize worktree | 从精确 `origin/master@0ab2b31` 创建，只允许本交接与当前计划两份文档修改 |

核验时 Git fetch 曾连续三次遇到 GitHub `southeastasia` 边缘链路连接重置。DNS、443、Git/环境/WinHTTP 代理、`schannel`、`openssl`、credential helper 和 GitHub API 均未发现配置污染；之后网页、upload-pack 与两种 TLS backend 的 `ls-remote` 同时恢复并一致返回 `0ab2b31`。最终使用单 ref fetch 成功取得精确对象。未修改全局 Git、代理、TLS 或凭据配置，也未移动陈旧的本地 `master`。

## 3. CNG-111 已交付能力

- 时间线提供“记录此刻”生产入口；
- 飞行模式可创建非空文字记录；
- 通过 Android DocumentsUI/SAF 选择单张图片并附加可选说明；
- 本地保存后返回时间线，可打开详情、搜索、删除和恢复；
- 保存中阻止返回与重复提交，临时图片所有权在页面与 Application 之间明确转移；
- 页面销毁、延迟 picker 返回和图片替换等待期间均有确定清理语义；
- Provider MIME 只作为 hint，真实支持性由既有 magic/decode Pipeline 判断；
- Provider 查询、打开、读取和输入关闭失败映射为 `unreadable`；
- 缓存创建、输出打开、写入、`fd.sync` 和输出关闭失败映射为 `storage`；
- 超过 25 MiB 独立映射为 `too_large`；失败时 best-effort 删除部分缓存文件；
- Drift/SQLite Outbox 冲突比较只归一到数据库可表达的 Unix 秒精度，跨秒冲突仍保留。

明确未交付：编辑既有记录、自定义相机、批量导入、Share Sheet、云 AI、上传、账号、真实同步、`private_local` UI、知识图谱或个人画像。

## 4. 验证证据

| 门禁 | 结果 |
|---|---|
| Dart format | 94 files / 0 changed |
| Dart analyze | 0 issues |
| 生命周期与错误提示定向测试 | 38/38 |
| Android 平台错误分类定向测试 | 9/9 |
| 全量 Dart/Widget | 211/211 |
| Android `assembleDebug` | BUILD SUCCESSFUL，148 tasks |
| `git diff --check` | PASS |
| 独立终审 | PASS |
| API 35 生产 UI | x86_64 模拟器 DocumentsUI 图片创建成功，picker cache 为空 |

设备证据边界：API 35 证据来自 x86_64 模拟器，不替代阶段 1 发布前的物理真机门禁；82 KiB 图片上的紧接 BACK 不能单独证明按键一定落入 busy 窗口，确定性证据来自文字/图片 delayed Future Widget 测试；真实磁盘写满未在设备上注入，错误分类证据来自生产 Java seam 的可执行故障注入与 Android 完整编译。

## 5. 旧快照差异与本次修正

PR #4 之前的远端文档存在三处状态漂移：

1. `docs/roadmap/current-plan.md` 仍写 CNG-111“待复审和发布”，并声称尚未暂存、提交、推送或创建 PR；
2. `docs/roadmap/mvp-tasks.md` 仍把 CNG-109 标为待验收、CNG-111 标为计划中；
3. 远端 `docs/handoff/current.md` 不存在，主工作区只有一份停留在终审前的未跟踪旧快照。

PR #4 已修正上述治理状态，不改变已经合并的生产代码或产品承诺。PR #4 合并后，文档顶部把其编辑基线 `e3ce10c` 写成“当前 master”，并仍把 closeout 写成进行中，形成一次自指陈旧。本 finalization 只把这些字段改为带语义的历史锚点和实时核验规则，避免每次 merge 后无限追写新的“当前 SHA”。

## 6. Worktree 与受保护状态

| Worktree | 状态 |
|---|---|
| 主工作区 `codex/mnora-brand@ae7ff50` | 仍有既存 `M pubspec.lock`、`?? AGENTS.md`、`?? cognote-agent-artifacts/`、`?? docs/handoff/current.md` |
| `cng-109-evidence@d3c6f0b` | detached，clean |
| `codex/cng-109-verification@4ab0548` | clean，保留 |
| `codex/cng-111-production-create-flow@ba3958d` | clean，保留 |
| `codex/mnora-product-guide-refresh@2d59d19` | 5 个未暂存产品/路线图文档改动，独立任务，未混入本 closeout |
| `codex/cng-111-closeout-docs@bfe6423` | clean，保留；PR #4 已合并 |
| `codex/cng-111-handoff-finalize@0ab2b31` | 本次只允许 `docs/handoff/current.md` 与 `docs/roadmap/current-plan.md` 修改 |

主工作区 `pubspec.lock`、未跟踪 `cognote-agent-artifacts/`、未跟踪 `AGENTS.md` 和旧 `docs/handoff/current.md` 均未触碰。任何分支、worktree、证据或受保护文件清理仍未授权。

## 7. 遗留风险与门禁

- 阶段 1 发布前仍需 API 35 物理真机 force-stop 与生产 UI 复验；
- `private_local` 独立加密存储未完成前不得暴露入口；
- 阶段 1 事件仅允许隐私过滤后的本地 sink，远程遥测未授权；
- 详情页仍只读，本地编辑与 FTS/Outbox 一致性尚未实现；
- GitHub 仓库未配置 PR checks，现有质量结论来自本地门禁、平台证据和独立审查；
- app 私有 picker cache 删除失败仍是 best-effort，当前不构成 P0～P3 阻塞项。

## 8. 下一阶段开工包

唯一建议下一任务：**CNG-111A 产品体验与视觉基础规格冻结**。本任务先定义可实现、可验收的产品体验基线，不直接改 Flutter UI。

### 8.1 唯一目标

针对当前生产 UI 功能可用但视觉与体验基础薄弱的问题，冻结阶段 1 核心页面的导航、信息层级、状态、交互规则和视觉基础，使后续 UI 实现与 CNG-112 本地编辑建立在同一套页面和组件体系上。

### 8.2 范围与交付物

- 审计首页/时间线、文字与图片创建、详情、搜索、已删除记录的现状和断点；
- 冻结上述页面的用户流程、信息架构、关键操作优先级与返回语义；
- 覆盖空、加载、成功、校验失败、存储失败、无搜索结果和删除/恢复反馈；
- 定义颜色、字体、间距、圆角、层级、图标、按钮、输入、卡片、列表与反馈组件的最小视觉基础；
- 明确无障碍、触控尺寸、文本缩放、深浅色和窄屏适配的最低要求；
- 形成可供实现任务引用的页面清单、状态矩阵、组件清单、验收标准和分片顺序。

### 8.3 非范围

- 不修改 Dart、Kotlin、数据库、Application/Repository API 或生成文件；
- 不实现本地编辑、AI、同步、账号、`private_local`、Share Sheet、语音、项目、知识图谱、推荐或个人画像；
- 不用假数据、空 Tab、不可用入口或品牌概念图冒充已交付能力；
- 不夹带技术标识迁移、依赖调整、受保护文件处理或历史 worktree 清理。

### 8.4 进入门

1. 新会话只读确认本交接所在提交已进入实时远端 `master`；若仍只存在于 topic branch，不得开始 CNG-111A；
2. `codex/mnora-product-guide-refresh` 的体验指南、战略、PRD、用户流程和路线图改动完成独立审查，消除与当前权威文档的重复或冲突后发布；
3. 负责人从实时最新远端 `master` 单独授权 CNG-111A 分支/worktree 和精确文档范围；
4. 开工时再次记录唯一目标、范围、非范围、验收标准以及 Git/GitHub 权限边界。

### 8.5 规格冻结验收

- 每个范围内页面都有入口、主任务、返回路径和空/加载/错误/成功状态；
- 页面、状态和组件之间没有互相矛盾的命名或交互规则；
- 视觉规范足以让执行者实现首个纵向切片，无需临场发明产品决策；
- 所有当前未交付能力都保持隐藏或明确不可用，不产生虚假承诺；
- 规格经过独立审查并得到负责人确认后，才拆分 UI 实现任务。

CNG-112 只有在 CNG-111A 冻结页面与组件基础后再进入；当前不得自动推进。
