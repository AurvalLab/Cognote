# ADR-005：卡片版本与纠错覆盖

- 状态：Accepted for specification v0.1
- 日期：2026-07-25

## 背景

AI CardVersion 不可变，用户纠错保存为独立事件。

## 决策

KnowledgeCard 指向接受版本；EffectiveCard 由版本和 Correction 投影产生。

## 结果

增加投影逻辑，但保留原始 AI 输出、用户意图和重跑历史。

## 复审触发条件

只有产品指标、容量数据、隐私要求或已验证的工程约束发生变化时复审；修改前必须提交替代 ADR。
