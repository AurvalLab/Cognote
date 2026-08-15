# CNG-109 可靠性验收报告

> 日期：2026-08-14
>
> 产品：Mnora · 见藏
>
> 结论：负责人已接受 API 35 模拟器证据，GATE-03 与 CNG-109 于 2026-08-14 关闭；API 35 物理真机验证移至阶段 1 发布门禁。

## 1. 验收范围

CNG-109 验证应用在完全离线条件下，经 Android `am force-stop` 强杀并重新启动后，仍能恢复本地身份、Observation、图片资产和 Outbox；重复恢复操作保持幂等。

本报告不验收物理设备特有能力、生产创建 UI、编辑流程、云同步、远程分析或历史 `Cognote` 技术标识迁移。

## 2. 被验收基线

- 应用 Git HEAD：`d3c6f0b1fdafe8657bde6a26e360dd5773af8cd1`（PR #1 的普通 merge commit）。
- 证据 worktree：detached HEAD，运行前后均无 staged、tracked 或 untracked 变化。
- CNG-109 历史实现提交：
  - `60a113a`：Application close/rebuild 恢复覆盖；
  - `43e3eac`：Android force-stop 恢复覆盖；
  - `6d0a320`：Android 恢复基线参数化。
- 验收 runner SHA-256：`30237cb945b9e2aca099b7907453f301e79f376ce7ae8379b7f6c28639bf68a7`。
- `pubspec.lock` Git blob：`05fcd429795dbb72995751b6ac630b1290033bd5`。
- `pubspec.lock` SHA-256：`54c0c841a46889362f665878bb667ea89b7a2f52278a4463942f1a2614f658f7`，严格离线解析前后相同。
- 锁文件唯一 hosted source：`https://pub.flutter-io.cn`；runner 先验证该值，再执行 `pub get --offline --enforce-lockfile`。

仓库主 worktree 中既有的未提交 `pubspec.lock` 改动和未跟踪 `cognote-agent-artifacts/` 没有被删除、恢复、移动、暂存或提交，也未被用作本次证据输入。

## 3. 质量门禁

| 门禁 | 结果 |
|---|---|
| PowerShell parser | 通过 |
| `tool/cng109_runner_contract_test.ps1` | 通过 |
| `git diff --check` | 通过 |
| Dart format，87 files | 通过，0 changed |
| `dart analyze` | 通过，0 issues |
| CNG-109 定向 Application 测试 | 通过，1/1 |
| 完整 Dart/Widget 回归 | 通过，179/179 |
| Android prepare integration test | 通过，1/1 |
| Android verify integration test | 通过，1/1 |
| 最终机器证据断言 | `CNG109_EVIDENCE_ASSERTIONS=PASS` |

关键命令采用以下约束：

```powershell
$env:PUB_HOSTED_URL='https://pub.flutter-io.cn'
$env:FLUTTER_STORAGE_BASE_URL='https://storage.flutter-io.cn'
D:\SDK\flutter\bin\flutter.bat pub get --offline --enforce-lockfile
D:\SDK\flutter\bin\cache\dart-sdk\bin\dart.exe format --output=none --set-exit-if-changed lib test integration_test
D:\SDK\flutter\bin\cache\dart-sdk\bin\dart.exe analyze
D:\SDK\flutter\bin\cache\dart-sdk\bin\dart.exe D:\SDK\flutter\bin\cache\flutter_tools.snapshot test --no-pub --concurrency=1 -r compact
```

正式 Android runner 使用 `D:\java——JDK` 作为本次进程的 `JAVA_HOME`；未修改全局 Java 配置。

## 4. Android E5/O3 平台证据

- Run ID：`cng109-20260814T140844Z-f0a3`。
- 证据目录：`D:\Hermes\cognote-agent-artifacts\cng-109-e5-o3\cng109-20260814T140844Z-f0a3`。
- 设备：`emulator-5554`，`qemu=1`，Android API 35，x86_64。
- 型号：Google `sdk_gphone64_x86_64`；build fingerprint 为 Android 15 API 35 userdebug 镜像。
- 网络控制：`cmd connectivity airplane-mode enable`、`svc wifi disable`、`svc data disable`。
- 网络硬断言：prepare、force-stop、verify 三个阶段均为飞行模式 enabled、Wi-Fi 关闭、`Active default network: none`，对 `223.5.5.5` 的设备内 ping 均失败（exit 2）。
- `mobile_data` 同时记录，但不单独充当离线判据；部分 API 35 模拟器上该 setting 不稳定，系统命令成功、默认网络为空和真实探针失败共同构成硬证据。
- 强杀行为：PID `7009` → `am force-stop` 后 PID 为空 → 重启 PID `7062`，`forceStopExit=0`。
- Outbox：强杀前后均为 6 条，逐行 JSON 完全一致。
- 身份：`principalId`、`deviceId`、`publicInstallId` 强杀前后完全一致。
- 图片：源文件、prepare 落盘图片和 verify 恢复图片 SHA-256 完全一致。
- 幂等恢复：`idempotentRestore=unchanged`。
- APK：integration test 会重新构建并安装 APK，因此分别记录 initial `c66d3e140eca40985e2f0c4f9b240a726e3571fb0618d6885660982d0f72138d`、after-prepare `566006078624a7073d22ade5ef3874bccebce1ab8cf1fc70341eaa093731916e` 和 after-verify `9a49eec6a99dca8108c17f0e361bd5e2a8730455f9631f41ff411e547a303001`；最终磁盘 APK 与 after-verify 哈希一致。三次构建均来自同一 exact HEAD 和 clean worktree。
- 清理：网络由 `0/1/1` 恢复到 `0/1/1`，飞行模式命令为 disabled；测试包卸载成功；设备仍在线；最终 Git diff/check、staged 和 changed 均为空。

## 5. 证据强度分层

1. SQLite close/reopen：证明数据库文件与 schema 可重新打开，不能证明 Application bootstrap 或 Android 进程生命周期。
2. Application close/rebuild：证明依赖重建后本地身份和数据可恢复，不能证明操作系统强杀。
3. Android `am force-stop`：在 Android API 35 系统环境中终止进程、确认 PID 消失并重新启动，再验证身份、Observation、图片和 Outbox；这是本次最高强度证据。

本次完成第 3 层，但设备类型是模拟器，不是物理真机。

## 6. 被作废的运行

以下运行不用于验收结论：

- `cng109-20260814T135210Z-cd9f`：detached branch 的 null handling 缺陷，构建前失败；应用未安装、网络未变。
- 在最终 Run ID 之前的成功运行：分别暴露 `network-before.json` 参数序列化和 integration test 重建 APK 后哈希链不完整的问题；两项均修复并由最终运行重新取证。

保留这些目录仅用于审计 runner 演进，不得与最终证据混用。

## 7. 风险与负责人决策

- **GATE-03 已关闭**：负责人于 2026-08-14 书面接受当前 API 35 模拟器证据并关闭 CNG-109。本任务验证 Android 生命周期、SQLite/文件持久化和离线恢复，不依赖相机、基带、厂商电源管理或硬件 Keystore；API 35 物理真机验证移至阶段 1 发布门禁，不再阻塞 CNG-109。
- JDK 25 + Gradle 9.1.0 输出 native-access 未来兼容性警告，本次 build exit 0，不影响当前结论；后续工具链升级需重新核验。
- runner、契约测试与本报告纳入同一 CNG-109 收尾提交；仓库外证据目录不进入 Git 历史。

## 8. 验收结论

自动化、应用层和 Android API 35 模拟器平台证据均通过，且最终证据包经独立机器断言复核。负责人已接受设备等级并授权将可复现 harness、契约测试和本报告纳入仓库历史。

GATE-03 与 CNG-109 正式关闭。API 35 物理真机验证作为阶段 1 发布门禁继续保留，不影响本任务结论。
