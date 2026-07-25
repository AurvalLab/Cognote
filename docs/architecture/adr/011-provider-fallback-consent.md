# ADR-011：供应商回退与授权

- 状态：Accepted for specification v0.1
- 日期：2026-07-25

## 背景

AI fallback 只能在 ConsentSnapshot 的 provider scope 内发生。

## 决策

Provider Adapter 声明能力、地域、保留策略、成本和错误分类；任务记录实际供应商。

客户端不得直连 AI 供应商。服务端 AI Gateway 仅选择同时满足 ConsentSnapshot、`home_region=cn-mainland`、`data_residency=cn` 和 `ai_processing_region=cn-mainland` 的 Provider。MVP 禁止自动跨境 fallback；未来海外部署使用区域隔离的数据平面。

## 结果

可能降低自动恢复率，但避免未经告知跨供应商发送个人数据。

## 复审触发条件

只有产品指标、容量数据、隐私要求或已验证的工程约束发生变化时复审；修改前必须提交替代 ADR。
