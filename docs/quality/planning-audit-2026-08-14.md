# Mnora · 见藏规划一致性审计

- 审计日期：2026-08-14
- 范围：战略、PRD、用户流程、隐私、架构、ADR、路线图、指标、交接文档与当前 Flutter/Drift 实现
- 基线：`master` / `6d0a320aeda7642e759cb69a6e5467b973624ea5`

## 1. 结论

阶段 0 的核心架构原则仍然有效，不需要推翻。需要重构的是规划信息架构和阶段 1 的执行设计：旧 README 与历史交接冒充当前状态，最新战略只存在于未跟踪归档，路线图没有状态/依赖/验收，且生产创建 UI 没有任务编号。

本次采用“保留冻结决策、重建现行计划”的方式修正，不修改业务代码、数据库 schema 或 ADR 决策。

## 2. 主要发现

| 级别 | 发现 | 证据 | 处理 |
|---|---|---|---|
| P0 | README 声称阶段 0 且无业务代码 | 当前已有 44 个 Dart 源文件和完整 Flutter/Drift 分层 | 重写 README |
| P0 | 缺少仓库内的现行战略权威源 | V3.1 位于未跟踪 `cognote-agent-artifacts/` | 新增 `docs/product/strategy.md` |
| P0 | 阶段 1 退出要求生产创建，但 UI 没有创建入口，路线图也无对应任务 | `CognoteApp` 只导航时间线、详情、搜索和已删除页面 | 新增 CNG-111 |
| P0 | PRD 承诺离线编辑，但当前详情只读，且旧路线图没有编辑任务 | `ObservationDetailPage` 无编辑入口，Application/Repository 无编辑用例 | 新增 CNG-112 |
| P1 | CNG-109 有提交和模拟器证据，但“已实现/已验收”混用 | 最新 metadata 为 API 35、`qemu=1` | 状态改为待验收并增加决策门 |
| P1 | `private_local` 被写入产品承诺，但当前领域 enum 只有 `normal` | `observation.dart` | 明确未实现前不得暴露；CNG-107A 设硬门 |
| P1 | CNG-110 未说明阶段 1 无服务端时事件去向 | PRD 只列事件名 | 收敛为事件契约、过滤器和本地 sink |
| P1 | 指标把本地工程、AI 性能和首卡价值混在同一阶段 | 旧 `mvp-metrics.md` | 按阶段 1/2/Beta 重写 |
| P1 | 当前 Outbox 骨架与未来同步协议容易被误读为同一能力 | 当前表无 payload/status/retry；`sync.md` 描述完整协议 | 在当前计划和路线图明确阶段边界 |
| P2 | 历史冻结报告和旧交接文字仍称没有代码 | 2026-07-25 快照 | 保留原文并添加历史状态提示 |

## 3. 新文档结构

- `docs/README.md`：权威层级和阅读顺序；
- `docs/product/strategy.md`：稳定的产品命题、边界和解锁门；
- `docs/roadmap/current-plan.md`：当前事实、负责人决策门、下一任务和验收；
- `docs/roadmap/mvp-tasks.md`：全阶段任务目录与状态；
- `docs/quality/mvp-metrics.md`：统一指标口径和阶段门；
- 历史 handoff/report：只作为当时证据，不再承担当前状态。

## 4. 规划设计变化

1. 阶段 1 从“底层能力列表”改为“用户可执行的可靠记录闭环”；
2. 新增 CNG-111，补齐文字/图片生产创建入口；
3. 新增 CNG-112，补齐本地编辑、FTS 更新和 Outbox 原子性；
4. CNG-109 从模糊的已提交状态改为待验收，设备等级需负责人结论；
5. CNG-107A 改为能力暴露/云上传前的安全门，而不是用字段模拟私密；
6. CNG-110 在阶段 1 不引入远程分析 SDK，只定义最小事件和隐私过滤；
7. 阶段 2 改为纵向里程碑，先跑通单路由/单 Provider/单 Schema，再扩展；
8. 阶段 4、5 保持条件解锁，不形成默认交付承诺。

## 5. 仍需负责人决定

- `cognote-agent-artifacts/` 移出、忽略或暂留；
- `pubspec.lock` 的依赖与 hosted URL 差异如何处理；
- API 35 模拟器是否满足 CNG-109，或必须补物理真机；
- CNG-107A 在阶段 1 完成，还是在不暴露私密入口的前提下移动到阶段 2 上传前置门；
- 下一开发任务在 CNG-109 收尾、CNG-111、CNG-112、CNG-107A、CNG-110 中的负责人授权顺序。

## 6. 复核结果

- 代码规模：45 个 `lib/` Dart 文件、40 个 `test/` 文件、2 个 `integration_test/` 文件；
- 测试声明扫描：158 个 `test`、18 个 `testWidgets`、2 个 integration `testWidgets`；
- `dart format --output=none --set-exit-if-changed lib test integration_test`：87 个文件，0 个变化；
- `dart analyze`：通过，No issues found；
- 新增/修改文档的相对链接检查：通过；
- Markdown 结构、任务编号和 `git diff --check`：通过；
- `flutter test --no-pub --concurrency=1 -r compact`：首次运行被 `sqlite3 3.5.1` 原生库下载超时阻塞；依赖随后正常就绪，重跑完整 Dart/Widget 套件通过，共 179 个测试。未复制归档目录中的缓存 DLL绕过边界。
- `flutter build apk --debug --no-pub`：Android 资源 XML 已单独解析通过，但 Gradle 在编译前检测到当前 Java 11，要求 Java 17+，因此 APK 构建未完成；该项记录为本机 JDK 环境阻塞。

## 7. 审计边界

本次没有修改业务代码、生成代码、依赖锁文件、归档目录或 Git 历史，也没有执行暂存、提交、合并或推送。远程分支状态不属于本次规划审计结论。
