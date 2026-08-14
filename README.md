# Mnora · 见藏

**Mnora · 见藏**是一款 Local-First 的个人观察与记忆应用：先可靠保存用户的图片或文字记录，再在明确授权下使用 AI 生成可确认、可纠错、可追溯的卡片。

> Mnora is a personal memory system that learns how you see the world.
>
> 把所见，变成可找回的记忆。

当前仓库处于 **阶段 1：本地记录闭环收尾**，目标平台为 Android。Flutter/Drift 业务代码已经存在，README 过去所称的“阶段 0、尚无业务代码”不再成立。

## 当前能力

已实现：

- 本地匿名 Principal 与 DeviceIdentity；
- 文字和图片 Observation 的 Application/Data 层创建能力；
- 时间线、详情、软删除、恢复和已删除列表；
- SQLite FTS 本地全文搜索；
- 与本地变更同事务写入的持久化 Outbox 骨架；
- 数据库重开、应用重启和 Android force-stop/飞行模式验收脚本与证据。

尚未完成：

- 面向真实用户的文字/图片创建 UI；
- 已有文字和图片说明的本地编辑能力；
- CNG-109 验收结论冻结；
- `private_local` 独立加密存储；
- 最小化且经过隐私过滤的产品埋点；
- 云端 AI、账号、同步和媒体备份。

“尚未完成”的能力不得在产品文案或测试结论中写成已经可用。

## 技术结构

```text
lib/src/
├── presentation/   Flutter 页面
├── application/    用例组合与身份绑定
├── identity/       本地匿名身份
├── observation/    记录领域、用例与 Drift Repository
├── outbox/         持久化变更日志骨架
└── database/       Drift 数据库与迁移

test/               单元与 Widget 测试
integration_test/   Android 恢复测试
docs/               产品、架构、路线与质量文档
tool/               Android E2E 编排脚本
```

## 文档入口

文档权威顺序和阅读路径见 [`docs/README.md`](docs/README.md)。

- 产品战略：[`docs/product/strategy.md`](docs/product/strategy.md)
- 品牌规范：[`docs/product/brand.md`](docs/product/brand.md)
- 当前执行计划：[`docs/roadmap/current-plan.md`](docs/roadmap/current-plan.md)
- 全阶段路线图：[`docs/roadmap/mvp-tasks.md`](docs/roadmap/mvp-tasks.md)
- 产品需求：[`docs/product/prd.md`](docs/product/prd.md)
- 架构决策：[`docs/architecture/adr/`](docs/architecture/adr/)
- 当前交接快照：[`docs/handoff/codex-handoff-2026-08-14.md`](docs/handoff/codex-handoff-2026-08-14.md)

## 本地质量门禁

在不希望改写锁文件时，使用已有依赖执行：

```powershell
D:\SDK\flutter\bin\dart.bat format --output=none --set-exit-if-changed .
D:\SDK\flutter\bin\dart.bat analyze
D:\SDK\flutter\bin\flutter.bat test --no-pub --concurrency=1 -r compact
git diff --check
```

依赖解析可能重写 `pubspec.lock` 的 hosted URL 或传递依赖版本；运行 `pub get` 前必须先确认锁文件处理策略。
