# Cognote

Cognote 是一款 Local-First 的 AI 认知日记：用户先在设备本地记录图片或文字，再按授权调用云端 AI 生成可编辑、可追溯的知识卡片。

当前仓库处于 **阶段 0：规格冻结**，不包含 Flutter 或 FastAPI 业务代码。

## 核心闭环

```text
本地记录 → 可选云端分析 → 卡片草稿 → 用户确认/纠错 → 本地知识库 → 找回与回顾
```

## 架构原则

1. 无账号、无网络时仍可创建、编辑、删除和浏览本地记录。
2. 云端 AI、知识同步、媒体备份是三个独立授权能力。
3. AI 运行时使用确定性 Pipeline，不使用自主 Agent。
4. AI 结果不可变且版本化；用户纠错作为覆盖事件保存。
5. 跨设备同步使用操作日志、幂等键和服务端修订号，不依赖设备时间戳裁决。
6. 事实必须区分视觉观察、OCR、用户输入、外部来源、模型推断和用户纠错。
7. MVP 先验证“用户是否持续记录并认可 AI 卡片”，不提前建设完整知识图谱与 RAG。

## 规格索引

- 产品：`docs/product/`
- 架构：`docs/architecture/`
- ADR：`docs/architecture/adr/`
- API：`docs/api/openapi-outline.yaml`
- 质量：`docs/quality/`
- 路线：`docs/roadmap/mvp-tasks.md`
- 待决策：`docs/open-decisions.md`
