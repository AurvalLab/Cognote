# ADR-004：同步操作日志

- 状态：Accepted for specification v0.1
- 日期：2026-07-25

## 背景

多设备同步使用 operation log、幂等键、base revision 和服务端单调 revision。

## 决策

不以 updated_at 或设备墙钟做最终冲突裁决；pull cursor 指向服务端 change log。

## 结果

需要 change log、Outbox 和冲突 UI，但可避免离线旧写静默覆盖。

## 复审触发条件

只有产品指标、容量数据、隐私要求或已验证的工程约束发生变化时复审；修改前必须提交替代 ADR。
