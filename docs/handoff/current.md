# Mnora · 见藏当前交接

- 核验时间：2026-08-15 18:10（Asia/Shanghai）
- 当前阶段：阶段 1“可靠的本地记录”收尾
- 远端主线：`origin/master@e3ce10cf577b0e257963d138ec7d9ee4f426d7c7`
- 当前文档分支：`codex/cng-111-closeout-docs@e3ce10c`，upstream 为 `origin/master`
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

CNG-111A、CNG-112、CNG-107A、CNG-110 均未开始。本次只补齐 CNG-111 合并后的交接和路线图，不授权实现下一任务。

## 2. 实时 Git/GitHub 核验

| 项目 | 结果 |
|---|---|
| GitHub 仓库 | `AurvalLab/Cognote` |
| 远端 URL | `https://github.com/AurvalLab/Cognote.git` |
| 远端默认分支 | `master` |
| 远端 `master` | `e3ce10cf577b0e257963d138ec7d9ee4f426d7c7` |
| PR #3 | `MERGED`，base=`master`，head=`codex/cng-111-production-create-flow` |
| PR mergeability（合并前） | `MERGEABLE/CLEAN` |
| GitHub checks | 未配置/未报告 checks，不能声称 CI 已通过 |
| CNG-111 topic branch | 远端与本地均保留，指向 `ba3958d` |
| CNG-111 worktree | 保留且 clean |
| closeout docs worktree | 从精确 `origin/master@e3ce10c` 创建 |

核验时 Git fetch 曾连续三次遇到 GitHub `southeastasia` 边缘链路连接重置。DNS、443、Git/环境/WinHTTP 代理、`schannel`、`openssl`、credential helper 和 GitHub API 均未发现配置污染；之后网页、upload-pack 与两种 TLS backend 的 `ls-remote` 同时恢复并一致返回 `e3ce10c`。最终使用单 ref fetch 成功取得精确对象。未修改全局 Git、代理、TLS 或凭据配置，也未移动陈旧的本地 `master`。

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

合并后的远端文档存在三处状态漂移：

1. `docs/roadmap/current-plan.md` 仍写 CNG-111“待复审和发布”，并声称尚未暂存、提交、推送或创建 PR；
2. `docs/roadmap/mvp-tasks.md` 仍把 CNG-109 标为待验收、CNG-111 标为计划中；
3. 远端 `docs/handoff/current.md` 不存在，主工作区只有一份停留在终审前的未跟踪旧快照。

本 closeout 文档任务只修正上述治理状态，不改变已经合并的生产代码或产品承诺。

## 6. Worktree 与受保护状态

| Worktree | 状态 |
|---|---|
| 主工作区 `codex/mnora-brand@ae7ff50` | 仍有既存 `M pubspec.lock`、`?? AGENTS.md`、`?? cognote-agent-artifacts/`、`?? docs/handoff/current.md` |
| `cng-109-evidence@d3c6f0b` | detached，clean |
| `codex/cng-109-verification@4ab0548` | clean，保留 |
| `codex/cng-111-production-create-flow@ba3958d` | clean，保留 |
| `codex/mnora-product-guide-refresh@2d59d19` | 5 个未暂存产品/路线图文档改动，独立任务，未混入本 closeout |
| `codex/cng-111-closeout-docs@e3ce10c` | 本次只允许三份交接/路线图文档修改 |

主工作区 `pubspec.lock`、未跟踪 `cognote-agent-artifacts/`、未跟踪 `AGENTS.md` 和旧 `docs/handoff/current.md` 均未触碰。任何分支、worktree、证据或受保护文件清理仍未授权。

## 7. 遗留风险与门禁

- 阶段 1 发布前仍需 API 35 物理真机 force-stop 与生产 UI 复验；
- `private_local` 独立加密存储未完成前不得暴露入口；
- 阶段 1 事件仅允许隐私过滤后的本地 sink，远程遥测未授权；
- 详情页仍只读，本地编辑与 FTS/Outbox 一致性尚未实现；
- GitHub 仓库未配置 PR checks，现有质量结论来自本地门禁、平台证据和独立审查；
- app 私有 picker cache 删除失败仍是 best-effort，当前不构成 P0～P3 阻塞项。

## 8. 唯一建议下一任务

建议下一任务：**CNG-111A 产品体验与视觉基础的规格冻结**，不直接进入实现。

进入条件：

1. 本 closeout 文档经过审查并合入 `master`；
2. `codex/mnora-product-guide-refresh` 的体验指南、战略、PRD、用户流程和路线图改动独立审查，消除与本 closeout 的重复路线图修改后再发布；
3. 负责人单独授权从最新远端 `master` 建立任务分支/worktree；
4. 明确范围只覆盖首页/时间线、创建、详情、搜索、已删除记录、空/加载/错误状态和视觉基础，不新增数据模型、AI、同步或私密入口。

CNG-112 只有在 CNG-111A 冻结页面与组件基础后再进入；当前不得自动推进。
