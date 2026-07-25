# 阶段 0 规格一致性报告

- 检查日期：2026-07-25
- 工作区：`D:\Hermes\cognote`
- 范围：产品、架构、隐私、AI、同步、API、质量、路线和 ADR

## 实际检查结果

```text
Specification files: 28
Markdown/YAML lines: 2411
Missing required files: 0
Empty specification files: 0
Unbalanced Markdown code fences: 0
P0 decisions confirmed: 6/6
OpenAPI version: 3.1.0
OpenAPI paths: 16
OpenAPI operations: 17
OpenAPI operationId unique: PASS
OpenAPI schemas: 17
OpenAPI missing local refs: 0
YAML parse: PASS
Git diff whitespace check: PASS
```

## 跨文档不变量

| 不变量 | 结果 |
|---|---|
| 渐进式账户与匿名身份 | PASS |
| 匿名数据、AI 记录和额度可幂等归并 | PASS |
| 云端 AI 首次授权 + 敏感内容动态确认 | PASS |
| `private_local` 禁止任何云端处理 | PASS |
| AI 成功副本最迟 1 小时删除、失败最多 24 小时 | PASS |
| 植物/文字/通用 fallback 独立路由与 Schema | PASS |
| 中国大陆单地域与禁止跨境无感 fallback | PASS |
| 云端 AI、结构同步、媒体备份独立授权 | PASS |
| 同步包含 operation_id/base_revision/server_revision | PASS |
| AI CardVersion 不可变、Correction 独立 | PASS |
| 来源区分视觉/OCR/外部资料/模型推断 | PASS |
| MVP-A 明确排除 pgvector/RAG | PASS |

## 已冻结的 P0 决策

1. DEC-001：渐进式账户与匿名身份升级；
2. DEC-002：首次统一授权 + 按敏感级别动态确认；
3. DEC-003：分析副本成功即删、失败最多 24 小时；
4. DEC-004：植物深度领域 + 文字整理 + 通用 fallback；
5. DEC-005：中国大陆单地域，架构预留区域隔离扩展；
6. DEC-006：MVP 私密记录仅支持 `private_local`。

## 仍未验证

当前阶段没有业务代码，因此未执行 Flutter 构建、Python 类型检查、数据库迁移和端到端测试。它们属于后续单任务实现的交付门禁，不能由本报告声称通过。

DEC-007～DEC-010 仍为 P1 决策，应在对应功能进入排期前确认；不阻塞阶段 1 的本地工程脚手架与离线纵向切片。

## 结论

规格 v0.1 的 P0 决策已经冻结，文件结构、核心架构约束和 OpenAPI outline 一致。可以进入阶段 1 的第一个工程任务，但仍应按 `docs/roadmap/mvp-tasks.md` 单任务推进，不并行铺开完整 App。
