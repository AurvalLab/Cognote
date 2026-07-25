# ADR-008：跨端契约源

- 状态：Accepted for specification v0.1
- 日期：2026-07-25

## 背景

OpenAPI 与 KnowledgeCard JSON Schema 是跨端契约源。

## 决策

FastAPI/Pydantic 输出或校验契约；Dart DTO 由契约生成；网络 DTO、领域模型和 Drift 表分离。

## 结果

需要 CI contract diff 和 mapper，但减少手写类型漂移。

## 复审触发条件

只有产品指标、容量数据、隐私要求或已验证的工程约束发生变化时复审；修改前必须提交替代 ADR。
