# ADR-010：知识关系为可重建投影

- 状态：Accepted for specification v0.1
- 日期：2026-07-25

## 背景

Entity、Relation、Embedding 和 SearchDocument 不作为用户原始数据唯一存储。

## 决策

从接受的 CardVersion、Correction 和 Provenance 重建派生投影。

## 结果

模型或算法升级时可重建，删除和私密策略也更容易完整传播。

## 复审触发条件

只有产品指标、容量数据、隐私要求或已验证的工程约束发生变化时复审；修改前必须提交替代 ADR。
