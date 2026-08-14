# Mnora · 见藏文档地图与治理规则

更新日期：2026-08-14。

本文件解决一个问题：区分长期决策、当前计划和历史快照，避免不同年代的文档互相冒充“最新事实”。

## 1. 权威层级

发生冲突时，按以下顺序解释；若涉及代码真实行为，以当前代码和可复现测试证据为最终事实。

| 层级 | 内容 | 文件 | 更新规则 |
|---|---|---|---|
| A | 已接受的品牌、产品与架构约束 | `product/brand.md`、`open-decisions.md` 中已确认项、`product/prd.md`、`architecture/adr/` | 改变承诺前需负责人确认；架构变化补替代 ADR |
| B | 长期产品战略与能力解锁条件 | `product/strategy.md` | 战略假设或阶段门变化时更新 |
| C | 当前执行状态与下一步 | `roadmap/current-plan.md` | 每个任务验收、阻塞或优先级变化时更新 |
| D | 全阶段任务目录 | `roadmap/mvp-tasks.md` | 新增、拆分、移动或关闭任务时更新 |
| E | 历史证据与交接快照 | `quality/spec-consistency-report.md`、`handoff/` | 保留原始结论，只允许添加醒目的历史状态说明 |

OpenAPI、未来同步协议和 AI Pipeline 描述的是目标契约，不等于当前客户端已经实现。

## 2. 推荐阅读顺序

接手当前开发任务时：

1. `product/brand.md`：确认公开名称、标语和技术命名边界；
2. `product/strategy.md`：确认产品假设和不可妥协原则；
3. `roadmap/current-plan.md`：确认当前状态、待决策项和下一任务；
4. `roadmap/mvp-tasks.md`：确认任务编号和阶段依赖；
5. `product/prd.md`、`product/user-flows.md`、`product/privacy-modes.md`；
6. 与任务相关的架构文档和 ADR；
7. 代码、测试和真实运行证据。

进行阶段 2/3 的契约设计时，再阅读 `api/openapi-outline.yaml`、`architecture/ai-provenance.md` 和 `architecture/sync.md`，不得把未来协议反向扩大为阶段 1 的实现范围。

## 3. 状态词定义

- `已实现`：代码已进入当前基线，且存在与风险相称的自动化测试；
- `已验证`：除自动化测试外，要求的平台或外部证据已产生并审查；
- `已验收`：验收标准、证据和遗留风险已由负责人确认；
- `已冻结`：需求或架构边界已明确，变更需走决策流程；
- `计划中`：尚未授权开发，不表示承诺日期；
- `研究项`：只有解锁条件满足后才进入路线图。

“已提交”不等于“已验收”，“有脚本”不等于“真机证据通过”，“Application 层可调用”不等于“用户 UI 可用”。

## 4. 更新纪律

- 当前状态只写在 `roadmap/current-plan.md`，避免在多个文档维护不同版本；
- 任务编号、阶段归属和退出条件同步更新 `roadmap/mvp-tasks.md`；
- 指标定义和分母只写在 `quality/mvp-metrics.md`；
- 历史交接和检查报告不承担当前状态职责；
- 每个任务必须留下范围、非范围、验收标准、实际命令、结果和风险；
- 未经负责人授权，不执行 Git 暂存、提交、合并或推送。
