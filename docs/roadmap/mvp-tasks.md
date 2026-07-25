# Cognote MVP 任务拆分

## 阶段 0：规格与原型

- CNG-001 冻结 PRD、非目标和术语；
- CNG-002 完成三种数据模式与授权矩阵；
- CNG-003 完成卡片原型用户测试；
- CNG-004 冻结状态机和数据模型；
- CNG-005 冻结 AI 来源协议和 KnowledgeCard Schema；
- CNG-006 冻结 OpenAPI outline 和错误模型；
- CNG-007 完成隐私数据流和删除流程；
- CNG-008 冻结 ADR；
- CNG-009 建立 AI 评测集规范与产品指标。

退出：`docs/open-decisions.md` 中 P0 决策均已拍板，规格检查通过。

## 阶段 1：本地纵向切片

- CNG-100 匿名 Principal、DeviceIdentity 与安全安装标识；
- CNG-101 Flutter/Drift 最小工程；
- CNG-102 Observation 与 LocalAsset 表及迁移；
- CNG-103 文字记录本地创建；
- CNG-104 图片记录本地创建；
- CNG-105 时间线与详情；
- CNG-106 删除/恢复；
- CNG-107 本地 FTS；
- CNG-107A private_local 独立加密存储、Keychain/Keystore、解锁与后台遮蔽；
- CNG-108 持久化 Outbox 骨架；
- CNG-109 强杀恢复和离线端到端测试；
- CNG-110 最小埋点与隐私过滤。

退出：飞行模式可完成创建、浏览、搜索、删除和恢复；强杀不丢数据。

## 阶段 2：AI 卡片闭环

- CNG-201 FastAPI 模块化单体脚手架；
- CNG-201A `cn-mainland` 区域配置、AI Gateway 和跨境路由阻断测试；
- CNG-202 PostgreSQL/Alembic 基线；
- CNG-203 ConsentSnapshot；
- CNG-203A 端侧敏感性预检、动态确认和上传副本预览/脱敏；
- CNG-204 私有对象上传；
- CNG-204A 分析副本删除状态机、生命周期兜底、补偿队列与报警；
- CNG-204B normal/private_local 转换、云端级联清理与异常恢复；
- CNG-205 AIJob/Attempt 状态机与幂等；
- CNG-206 Provider capability adapter；
- CNG-206A Vision/TextLLM/Embedding/OCR Provider 接口及区域能力注册；
- CNG-207 植物图片质量与 Vision/OCR 路由；
- CNG-207A plant/general/text/uncertain 分类路由；
- CNG-208 KnowledgeCard envelope、PlantCardV1、TextCardV1、GeneralImageCardV1 和 Pydantic 校验；
- CNG-209 来源与高风险策略；
- CNG-210 CardVersion 持久化；
- CNG-211 Flutter 处理状态与重试/取消；
- CNG-212 卡片确认和 UserCorrection；
- CNG-213 真实端到端测试与 AI 回归集；
- CNG-214 成本、日志和 trace。

退出：真实设备和真实供应商完成“本地记录—授权—上传—AI—确认/纠错”，故障测试通过。

## 阶段 3：账号与同步

- CNG-301 可选认证、设备注册与 PrincipalMerge；
- CNG-301A 匿名数据/AI 记录/额度流水的幂等无损归并测试；
- CNG-302 SyncOperation/ServerChange；
- CNG-303 push/pull/cursor；
- CNG-304 冲突矩阵实现；
- CNG-305 媒体备份独立开关；
- CNG-306 双设备故障注入；
- CNG-307 数据导出、授权撤销、账号删除；
- CNG-308 删除链路审计。

退出：重复、乱序、中断、并发编辑、删除/恢复和越权测试通过。

## 阶段 4：检索与回顾

仅在检索进入条件满足后：

- CNG-401 服务端 FTS 与过滤；
- CNG-402 真实检索问题集；
- CNG-403 接受卡片 Embedding；
- CNG-404 混合召回与评测；
- CNG-405 带 Fact/Provenance 引用的问答；
- CNG-406 每日回顾与历史上的今天；
- CNG-407 私密/删除内容排除测试。

## 单任务交付模板

每个任务必须声明：背景、范围、非范围、验收标准、数据/API 变化、测试命令、实际结果、风险。一次只完成一个边界清晰的任务；核心技术或模型变化先写 ADR。
