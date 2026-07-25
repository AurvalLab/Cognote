# Cognote 阶段 0 → 阶段 1 工程交接

> 本文件是新会话进入 Cognote 项目的唯一工程交接入口。
>
> 交接原则：先阅读本文件，再按第 8 节顺序阅读规格。不得绕过冻结的 P0 决策直接设计或编码。

## 1. 当前阶段与项目状态

项目：Cognote
工作区：`D:\Hermes\cognote`
当前阶段：**阶段 0 已完成，准备进入阶段 1：本地纵向切片**。

产品定位：Local-First AI 认知日记。用户先在设备本地记录图片或文字，再按授权调用云端 AI 生成可编辑、可追溯的知识卡片。

当前核心闭环：

```text
本地记录 → 可选云端分析 → 卡片草稿 → 用户确认/纠错
→ 本地知识库 → 时间线/本地搜索找回
```

当前仓库状态：

- 当前只包含产品、架构、隐私、AI、同步、API、质量、路线和 ADR 规格文档。
- 尚未编写 Flutter、FastAPI、数据库迁移或业务代码。
- 阶段 0 P0 决策 DEC-001～DEC-006 已全部确认。
- 阶段 0 规格一致性检查已通过。
- 当前分支：`master`。
- 当前 Git 仓库尚未创建首个提交；工作区中的 `README.md` 和 `docs/` 均为未跟踪文件。

## 2. DEC-001～DEC-006 最终结论

### DEC-001：渐进式账户

- 首次启动创建匿名用户身份和设备身份。
- 本地记录、编辑、搜索、浏览完全可用，不强制登录。
- 匿名用户可体验有限次数的 AI 识别和重新生成。
- 仅在多设备同步、云端备份与恢复、匿名 AI 额度耗尽、订阅或购买套餐时要求登录。
- 登录后，匿名期间的 Observation、AI 任务、CardVersion、Correction 和额度流水必须幂等、无损地归并到账户。
- 不能用简单改 `owner_id` 或可重复计数器实现归并；必须有可恢复的 `PrincipalMerge` 和不可变额度流水。

### DEC-002：首次统一授权 + 敏感内容动态确认

- 首次使用云端 AI 时说明上传数据、目的、AI 服务类型、保留策略和撤回方式。
- 普通内容在首次授权后默认沿用。
- 普通记录中的人脸/证件/车牌、精确位置或地址、医疗/财务/凭证文本、第三方私人信息，每次上传前单独确认。
- 无法判断敏感级别时按较高等级处理。
- 上传前必须允许查看最终分析副本，并支持裁剪、打码、移除位置、仅本次允许或取消。
- 拒绝上传不影响本地记录、编辑、浏览和搜索。
- `private_local` 是不可上传的硬边界，不适用逐次授权。

### DEC-003：分析副本最小留存

- AI 分析成功并持久化 CardVersion 后立即触发删除，最迟 1 小时内完成。
- AI 失败任务的分析副本最多保留 24 小时，用于自动重试；超时必须删除。
- 用户取消任务时立即删除。
- 清理范围包括对象存储、临时目录、处理缓存和分析缩略图。
- 失败图片默认禁止工作人员查看；人工排障需要用户单次明确授权，不自动延长默认保留期限。
- 原图云备份是独立能力，默认关闭；开启时展示用途、期限、空间占用和删除入口。
- 删除必须有持久状态、补偿队列和报警，不能静默忽略失败。

### DEC-004：植物深度领域 + 文字整理 + 通用 fallback

- 植物是唯一深度垂直领域，拥有独立 Schema、Prompt 和评测集。
- 支持文字输入整理，完整保留用户原文；AI 摘要、关键词和整理内容必须与原文分离。
- 通用图片只提供基础 fallback：物品大类、简短描述、可见特征、OCR、标签和不确定性。
- 通用 fallback 必须明确提示当前版本主要针对植物进行深度分析。
- 通用 fallback 不承诺品牌/型号、专业鉴定、价格、真伪、医疗、安全或食用结论。
- 输入路由固定为：`plant_image`、`general_image`、`text`、`uncertain`。
- 植物闭环通过产品和质量门槛前，不增加葡萄酒、鞋履、建筑、鸟类等独立领域。

### DEC-005：中国大陆单地域优先

- MVP 的 API、PostgreSQL、Redis、对象存储、日志和任务队列全部位于中国大陆。
- 中国大陆用户数据默认不得复制、备份或传输至境外。
- 客户端不得直接调用 AI 供应商，所有 AI 请求必须经过服务端 AI Gateway。
- 不允许主供应商故障时无感切换至境外 Provider。
- `home_region`、`region_code`、`data_residency` 和 `ai_processing_region` 必须约束 Provider、凭证、对象存储和路由。
- 未来海外版本使用独立 global deployment；区域之间默认不复制数据。
- MVP 不做双活、跨区域复制、全球统一对象存储、自动跨境故障转移或第二套海外生产环境。

### DEC-006：MVP 私密记录仅支持 `private_local`

- `private_local` 记录及其全部关联数据只能保存在当前设备：原始文字、备注、媒体、OCR、AI 结果、标签、实体、关系、Embedding、时间和位置均包括在内。
- 禁止上传、同步、云端 AI/OCR/Embedding、云备份，以及进入服务端日志、分析事件和崩溃报告。
- 使用独立本地加密存储，密钥进入 iOS Keychain 或 Android Keystore。
- 支持私密空间解锁、后台预览遮蔽和通知脱敏。
- 普通记录转私密时，先停止云任务并完成服务端级联清除；收到删除确认后才显示“已转为仅本地”。
- 私密转普通只能由用户主动发起，必须重新展示上传清单并获得同步/AI 授权。
- 首次启用提示：卸载、清除数据或设备损坏后可能无法恢复。
- MVP 仅支持手动加密导出，不做自动跨设备恢复。
- 未来只有完成 E2EE、设备密钥管理、恢复机制和安全审计后，才考虑 `private_e2ee_sync`。

## 3. 核心规格文件索引

### 必读入口

- `README.md`：项目定位、核心原则和规格索引。
- `docs/open-decisions.md`：P0/P1 决策状态；P0 不得擅自修改。
- `docs/roadmap/mvp-tasks.md`：阶段、任务编号、退出条件和单任务交付格式。
- `docs/quality/spec-consistency-report.md`：阶段 0 实际检查结果和当前边界。

### 产品规格

- `docs/product/prd.md`：MVP 目标、非目标、功能需求、页面和埋点。
- `docs/product/user-flows.md`：首次启动、匿名升级、本地记录、AI 分析、纠错、删除和私密转换流程。
- `docs/product/privacy-modes.md`：数据模式、授权目的、敏感确认、`private_local` 和删除规则。

### 架构规格

- `docs/architecture/overview.md`：模块化单体、客户端分层、服务端边界和区域部署。
- `docs/architecture/data-model.md`：Principal、Observation、Asset、CardVersion、Provenance、AIJob 和同步实体。
- `docs/architecture/state-machines.md`：记录、媒体、AI、卡片、同步和私密级别状态机。
- `docs/architecture/sync.md`：MVP-B 的 Outbox、push/pull、cursor、幂等和冲突矩阵。
- `docs/architecture/ai-provenance.md`：输入路由、AI Pipeline、来源、Provider Adapter 和评测约束。
- `docs/architecture/privacy-data-flow.md`：数据分类、上传链路、区域边界、私密数据和删除状态机。
- `docs/architecture/adr/`：12 个已冻结架构决策。

### API 与质量

- `docs/api/openapi-outline.yaml`：OpenAPI 3.1 outline，包含匿名身份、归并、上传、AIJob、卡片、同步、搜索和删除契约。
- `docs/quality/mvp-metrics.md`：产品北极星指标、Alpha/Beta 门槛和检索进入条件。
- `docs/quality/ai-evaluation-plan.md`：植物、文字、通用 fallback 分层评测和发布门禁。

## 4. 已完成、未完成与当前明确不做

### 已完成

- 阶段 0 PRD、用户流程和非目标。
- 三种数据模式和授权矩阵的基础规格。
- 渐进式账户、敏感确认、分析副本删除、领域范围、区域部署和 `private_local` 决策。
- 模块化单体、Local-First、确定性 AI Pipeline、同步操作日志、卡片版本、事实来源、媒体目的分离、契约源、搜索演进、派生投影、Provider fallback 和删除保留 ADR。
- 核心数据模型和状态机。
- OpenAPI outline：匿名 Principal、PrincipalMerge、上传、AIJob、Card、Correction、Sync、Search、Account deletion。
- MVP 指标、AI 评测计划和阶段任务清单。
- 文档一致性、Markdown 代码块、YAML 解析、OpenAPI 引用和 Git whitespace 检查。

### 未完成

- `CNG-100` 及全部阶段 1 业务代码。
- Flutter/Drift 工程和本地迁移。
- 匿名 Principal、DeviceIdentity 和安全安装标识的实现。
- Observation、LocalAsset、本地 FTS、时间线、删除/恢复。
- `private_local` 独立加密存储、Keychain/Keystore、解锁和后台遮蔽。
- 持久化 Outbox 和强杀恢复测试。
- FastAPI、PostgreSQL、对象存储、AI Gateway、Provider Adapter、AIJob 和卡片 Pipeline。
- 真实设备测试、供应商调用、AI 回归集和端到端测试。
- 账号认证、PrincipalMerge、多设备同步、媒体备份、数据导出和账号删除。

### 明确不在当前范围

阶段 1 不实现：

- 云端 AI 和上传；
- FastAPI、PostgreSQL、Redis/ARQ、S3 和 AI Provider；
- 多设备同步和冲突解决；
- pgvector、RAG、自然语言问答；
- 复杂知识图谱、Entity/Relation UI、偏好画像和项目规划；
- 语音、Share Sheet、Widget、地理标签和情境唤醒；
- 社区、电商、自动购买和公开内容；
- 第二垂直领域；
- 私密云同步、服务端可解密备份和 E2EE。

“当前不在范围”不代表删除规格；只代表本次任务不得实现这些内容。

## 5. 下一任务：CNG-100

### 5.1 任务名称

**实现匿名 Principal、DeviceIdentity 与安全安装标识。**

### 5.2 背景

Cognote 采用渐进式账户。首次启动不要求登录，但必须创建稳定的本地匿名主体和设备身份，使本地记录、AI 额度、未来上传和后续登录归并具备明确归属。匿名身份不是一次启动即丢失的临时游客标记。

`CNG-100` 是阶段 1 的第一个任务，只建立身份边界和本地持久化基础，不实现认证、云同步或 AI。

### 5.3 本次范围

- 在 Flutter/Drift 工程中建立最小本地身份存储边界；
- 定义并持久化 `Principal`：`id`、`kind=anonymous`、`status=active`、`home_region=cn-mainland`、`data_residency=cn`、创建时间；
- 定义并持久化 `DeviceIdentity`：设备 ID、Principal 关联、安装标识、创建时间和最近使用时间；
- 生成稳定、不可预测的本地 ID；禁止使用手机号、广告 ID、硬件序列号或可识别个人信息；
- 首次启动幂等初始化；重复启动不得创建第二个 active anonymous Principal；
- 将本地身份封装在 Repository/Application 层，不让 Widget 直接操作 Drift；
- 为后续 Observation/LocalAsset 使用 owner/device 关联预留；
- 为未来 `PrincipalMerge` 保留兼容的状态和 ID，不提前实现归并 API；
- 编写单元测试和数据库重启/迁移测试。

### 5.4 明确非范围

- 登录、注册、密码、短信、OAuth、刷新令牌；
- 账号主体创建和匿名数据归并；
- AI 额度扣减或计费服务；
- 云端 Principal 注册 API；
- Observation、Asset、KnowledgeCard 业务表；
- 上传、同步、Outbox、AI、Provider、S3、PostgreSQL；
- private_local 加密数据库、Keychain/Keystore、生物识别和后台遮蔽；这些属于 `CNG-107A`，不可在 CNG-100 顺手扩张；
- 任何 UI 大改或产品设计新增。

### 5.5 验收标准

1. 新安装首次启动创建且只创建一个 `anonymous` + `active` Principal。
2. Principal 的 `home_region` 为 `cn-mainland`，`data_residency` 为 `cn`。
3. 同一安装重复启动返回相同 Principal ID，不产生重复 active Principal。
4. 同一安装拥有稳定 DeviceIdentity，并能关联当前 Principal。
5. 生成的身份标识不包含手机号、账号、硬件序列号或其他可识别个人信息。
6. App 重启、数据库关闭重开和 schema migration 后身份仍可恢复。
7. 初始化失败时不返回伪造成功；错误可诊断且不会创建部分脏数据。
8. Repository/Application 层有单元测试；Widget 不直接访问 Drift 表。
9. 代码中不出现 API Key、Token、密码或其他凭证。
10. 本次变更不引入登录、网络请求、业务记录表或未批准的新框架。

### 5.6 交付要求

完成 CNG-100 后必须报告：

- 修改/新增文件；
- 本地数据库变化；
- 是否需要迁移；
- Repository/Application API 变化；
- 测试文件和覆盖场景；
- 实际执行的格式检查、静态检查、单元测试和迁移测试命令；
- 实际命令输出摘要；
- 已知风险和未实现内容。

不得仅凭代码阅读声称通过；不得伪造测试结果。

## 6. 阶段 1 开发约束

### 工程边界

- 一次只完成一个任务编号；当前只做 `CNG-100`。
- 先读完第 8 节文件，再输出任务理解、影响范围和实施计划。
- 不修改已冻结的 DEC-001～DEC-006，不擅自修改核心技术栈、数据模型语义或区域策略。
- 若发现规格冲突，停止编码并指出冲突，不自行猜测。
- 不新增产品设计；缺失 UI 细节时使用最小实现并记录为后续决策。

### Local-First

- 所有创建操作本地先写；网络不得成为阶段 1 的前置依赖。
- 本地事务成功才报告成功；异常必须可见，不吞掉。
- App 强杀或重启后状态必须可恢复。
- Drift 是本地即时事实源；Repository 是数据访问边界。
- 持久化模型、迁移和测试必须一并交付。

### 安全与隐私

- 不在客户端保存模型 API Key、Token、密码或供应商凭证。
- 不把匿名身份标识建立在广告 ID、硬件序列号或个人信息上。
- `private_local` 的硬边界必须保持；即使当前任务暂不实现加密，也不得加入任何上传、同步或云端依赖。
- 日志不输出原始日记、图片内容、私密字段或凭证。
- 默认 ASCII 编辑；只有已有文件和产品内容需要中文时使用中文。

### 分层与契约

- Widget 只负责展示和事件转发。
- 用例、业务规则和 Repository 不写在 Widget。
- 网络 DTO、领域模型和 Drift 表模型分离；CNG-100 可先建立领域接口和本地实现，但不要伪造网络 DTO。
- API 变更必须同步 OpenAPI；本任务不需要 API 变更。
- 数据库变化必须有迁移或明确说明无需迁移。
- 新增框架、依赖或核心表结构前必须先说明理由；不要为未来功能预建几十张表。

### 验证

至少执行：

- Flutter format check；
- Dart analyze；
- CNG-100 定向单元测试；
- 数据库迁移/重启恢复测试；
- `git diff --check`。

实际命令以仓库脚手架和平台可用工具为准；缺少 Flutter SDK 时必须如实报告，不得用静态阅读替代运行验证。

## 7. 当前 Git 状态与建议检查命令

### 当前状态（交接时）

在 `D:\Hermes\cognote` 执行：

```text
?? README.md
?? docs/
```

当前分支：

```text
master
```

当前没有首个提交。因为整个 `docs/` 目录尚未跟踪，`git status --short` 会将交接文档与其他规格一起折叠显示为 `?? docs/`，不会单独列出 handoff 文件。

不要为了“干净”而删除或回滚现有未跟踪规格文件；它们是阶段 0 交付物。

### 建议进入新任务前检查

```bash
cd /d/Hermes/cognote
git status --short
git branch --show-current
git diff --check
python -c "import yaml; p=yaml.safe_load(open('docs/api/openapi-outline.yaml', encoding='utf-8')); print(p['openapi'], len(p['paths']), len(p['components']['schemas']))"
```

### CNG-100 完成后检查

```bash
flutter pub get
dart format --output=none --set-exit-if-changed .
dart analyze
flutter test
flutter test test/path/to/cng100_test.dart -r expanded
git diff --check
git status --short
```

上面测试路径是占位示例，实际 Agent 必须替换成仓库中真实存在的测试路径；不存在的命令或路径不得被报告为成功。

## 8. 新 Agent 开始工作前必须阅读的文件顺序

严格按以下顺序阅读：

1. `docs/handoff/stage-0-to-stage-1.md`（本文件，唯一交接入口）
2. `README.md`
3. `docs/open-decisions.md`
4. `docs/product/prd.md`
5. `docs/product/user-flows.md`
6. `docs/product/privacy-modes.md`
7. `docs/architecture/overview.md`
8. `docs/architecture/data-model.md`
9. `docs/architecture/state-machines.md`
10. `docs/architecture/privacy-data-flow.md`
11. `docs/architecture/ai-provenance.md`
12. `docs/architecture/adr/001-modular-monolith.md`
13. `docs/architecture/adr/002-local-first.md`
14. `docs/architecture/adr/003-deterministic-ai-pipeline.md`
15. `docs/architecture/adr/007-media-purpose-separation.md`
16. `docs/architecture/adr/011-provider-fallback-consent.md`
17. `docs/roadmap/mvp-tasks.md`
18. `docs/quality/spec-consistency-report.md`
19. `docs/api/openapi-outline.yaml`

阅读完成后，Agent 必须先复述：

- 当前只做 `CNG-100`；
- 六个 P0 决策不可修改；
- 当前不写业务范围外代码；
- 交付必须有真实测试命令和结果。

然后才能开始修改代码。
