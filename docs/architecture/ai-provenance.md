# AI Pipeline、可信度与来源

## 1. 原则

- AI 只生成候选结构，不直接写业务表；
- Pipeline 阶段固定、可观测、可取消；
- 所有输出经 Schema 和安全策略校验；
- AI 原始结果、Prompt、模型、Pipeline 和用户纠错可追溯；
- 不把模型自报置信度包装成统计概率。

## 2. Pipeline

```text
创建 AIJob
→ 校验授权与输入清单
→ 媒体质量检查
→ OCR / Vision（按能力和领域调用）
→ 分类
→ 外部资料检索（需要百科事实时）
→ 结构化卡片生成
→ JSON Schema/Pydantic 校验
→ 自动修复一次
→ 安全与来源策略校验
→ 保存不可变 CardVersion
→ 等待用户确认
```

OCR 与 Vision 可并行，但不需要 OCR 的图片不应无条件调用。Embedding 只对被接受的卡片生成。

## 2.1 输入路由

```text
classify
├── plant_image → PlantCard Pipeline / PlantCardV1
├── general_image → GeneralImageFallback / GeneralImageCardV1
├── text → TextOrganization Pipeline / TextCardV1
└── uncertain → 返回候选类型或请求用户补充
```

- `PlantCardV1`、`TextCardV1` 和 `GeneralImageCardV1` 共享稳定 envelope，但拥有独立 payload Schema 和 Prompt。
- 植物 Pipeline 可生成候选名称、视觉依据、来源化基础知识、相似植物和补拍建议。
- Text Pipeline 必须逐字保留原文，AI 整理内容单独存储。
- General fallback 只描述大类、可见特征、OCR、标签和不确定性，并在产品文案中明确不是深度识别。
- 植物闭环通过前不得添加新的领域 Pipeline。

## 3. 来源类型

- `visual_observation`：图像中可见特征；
- `ocr_extract`：OCR 原文、页码或边界框；
- `user_input`：用户明确提供；
- `retrieved_source`：外部资料，含 URL/标识、摘录、抓取时间；
- `model_inference`：模型推断；
- `user_correction`：用户确认或修改。

“花期、毒性、分布”等知识不能引用视觉描述作为唯一证据。

## 4. 确定性显示

MVP 展示 `high | medium | low | insufficient`，而非未经校准的百分比。若未来展示数值置信度，必须：

- 在按领域分层的标注集上校准；
- 报告 reliability diagram/Brier score 或等效指标；
- 版本化校准方法；
- 区分对象识别置信度与单条事实可信度。

## 5. 高风险字段

涉及毒性、食用、药用、真伪、价值或危险性：

- 不输出确定安全结论；
- 显示风险提示；
- 要求专业来源或用户核验；
- 信息不足时不猜测；
- 产品不替代医疗、安全或鉴定意见。

## 6. Provider Adapter

每个供应商声明：

- vision/OCR/JSON Schema 能力；
- 文件格式、尺寸、上下文、并发限制；
- 超时、限流和可重试错误；
- 数据保留、训练策略和处理地域；
- 单次估算成本；
- 健康状态；
- 是否在当前 ConsentSnapshot 的 provider scope 内。

未经授权不得把同一用户数据自动发送给新的 fallback 供应商。

### AI Gateway 与区域约束

- 客户端禁止直接调用 Vision、LLM、Embedding 或 OCR 供应商。
- 服务端 AI Gateway 暴露内部能力接口：`analyze_image()`、`generate_card()`、`create_embedding()`、`extract_text()`。
- Adapter 类型至少包括 `VisionProvider`、`TextLLMProvider`、`EmbeddingProvider`、`OCRProvider`。
- 模型、Endpoint、凭证和处理地域由环境/受控配置决定，业务代码不得硬编码。
- Provider 选择必须同时满足 `home_region`、`data_residency`、`ai_processing_region` 和 ConsentSnapshot。
- `cn-mainland` 任务不得自动 fallback 到境外 Provider；供应商不可用时返回可重试失败。

## 7. Prompt 与 Schema 版本

- Prompt 存储在服务端版本库；
- 每次任务记录 Prompt hash/version；
- Schema 使用语义版本；
- breaking schema 变化必须有迁移和兼容策略；
- 评测报告绑定 provider、model、prompt、schema、pipeline 版本。

## 8. 评测

评测集至少覆盖：

- 清晰、模糊、遮挡、多人/多物体；
- 相似植物和无法确定样本；
- 图片中含文字与不含文字；
- 中文、英文和混合文本；
- 非法 JSON、缺字段、伪证据；
- 高风险问题；
- 用户纠错后的有效投影；
- 供应商超时、限流和重复回调。

指标见 `docs/quality/ai-evaluation-plan.md`。
