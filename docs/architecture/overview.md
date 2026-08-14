# 系统架构概览

## 1. 架构目标

- 本地交互不依赖网络；
- 云端能力按目的授权；
- AI 结果可验证、可追溯、可重放；
- 同步可幂等重试且不静默丢失用户修改；
- MVP 以模块化单体交付，避免微服务和双份业务规则。

## 2. 逻辑架构

```text
Flutter App
├── Presentation: 页面与组件
├── Application: 用例与状态组合
├── Domain: 业务规则和值对象
├── Data
│   ├── Drift repositories
│   ├── API repositories
│   ├── Outbox
│   └── Sync cursor
├── Local FTS
├── Upload Manager
└── Sync Engine (MVP-B)
          │ OpenAPI / HTTPS
FastAPI Modular Monolith
├── auth
├── consent
├── observations
├── media
├── cards
├── ai_jobs
├── sync
├── search
└── export_delete
          ├── PostgreSQL
          ├── private S3-compatible storage
          └── Redis + ARQ when durable workers are enabled

Deterministic AI Pipeline
quality → OCR/vision → classify → retrieve(optional)
→ compose → schema validate → policy check → persist version
```

## 3. 边界规则

- Widget 不包含业务规则；
- Controller 仅做协议适配；
- 应用服务定义事务边界；
- Worker 通过应用服务写入结果；
- LLM 不直接写数据库或调用任意工具；
- 客户端不保存模型 API Key 或 Prompt；
- 网络 DTO、领域模型和 Drift 表模型分离；
- OpenAPI 和 KnowledgeCard JSON Schema 是跨端契约源。

## 4. 数据权威

- 单设备 UI：Drift 是即时事实源；
- 用户编辑：本地先写；MVP-B 由服务端 revision 协调多设备顺序；
- AI 派生结果：服务端生成不可变版本，本地缓存；
- 媒体：本地原件和云端副本生命周期独立；
- 搜索索引、Entity、Relation：均为可重建投影。

## 5. 部署演进

### 区域边界

- MVP 仅部署 `cn-mainland`：API、PostgreSQL、Redis、对象存储、日志、任务队列和优先 AI Provider 均位于中国大陆。
- 客户端只访问 Mnora API，不直接访问 AI 供应商；AI Gateway 按 `home_region`、数据驻留和授权范围选择 Provider。
- 主供应商故障不得触发境外无感 fallback。
- 未来 `global` 是独立 API、数据库、对象存储和 Provider 栈，不与大陆生产数据实时互通。
- MVP 不部署第二生产区域，不做跨境复制或双活。

### MVP-A

Flutter + FastAPI 单实例 + PostgreSQL + 私有对象存储。AI 调用必须具备持久任务记录；若需要跨进程恢复则启用 Redis/ARQ。

### MVP-B

启用账号、change log、同步 API、媒体备份和删除链路。

### MVP-C

真实检索需求成立后启用 pgvector、混合检索和带引用问答。

## 6. 可观测性

- 结构化日志仅记录 id、阶段、耗时、错误码和版本；
- 不记录 API Key、图片、原始日记、完整 AI 原始输出；
- AIJobAttempt 保存供应商、模型、usage、成本和校验结果；
- 指标覆盖上传、任务、Schema、卡片确认、同步冲突和删除作业；
- trace id 串联客户端请求、上传、AIJob 和 CardVersion。
- 日志平台与监控数据也必须服从数据地域和内容最小化规则。
