# Mnora · 见藏品牌规范

- 生效日期：2026-08-14
- 前产品名：Cognote
- 状态：当前公开品牌定义

## 1. 标准名称

| 场景 | 标准写法 |
|---|---|
| 公开全称 | **Mnora · 见藏** |
| 英文简称 | **Mnora** |
| 中文简称 | **见藏** |
| 英文品类描述 | **Local-First personal memory system** |
| 中文品类描述 | **本地优先的个人观察与记忆系统** |
| 英文愿景语 | **Mnora is a personal memory system that learns how you see the world.** |
| 中文标语 | **把所见，变成可找回的记忆。** |

首次出现优先写“Mnora · 见藏”，后续可按语言环境简称为“Mnora”或“见藏”。中点使用全角两侧空格形式 `Mnora · 见藏`，不写成 `Mnora·见藏`、`Mnora 见藏` 或 `Mnora - 见藏`。

## 2. 名称含义

`Mnora` 是面向长期品牌使用的自造词，传达 memory、remember 与个人记忆空间的联想，同时不把产品限制为传统 Note App。

“见藏”表达两层含义：

1. 保存用户真实看见、想到和经历的事物；
2. 让这些记录在未来仍可被找到、理解和回顾。

名称服务于产品闭环：

```text
所见与所感
→ 本地可靠保存
→ 经授权的 AI 整理
→ 用户确认或纠错
→ 可找回的个人记忆
```

## 3. 品牌语气

- 可信、克制、有人味；
- 强调用户拥有记忆、AI 只做整理；
- 强调真实观察、来源和可纠错；
- 不宣称“比用户更懂自己”；
- 不使用“全能第二大脑”“永不遗忘”“自动理解人生”等不可验证承诺。

英文愿景语中的 `learns` 有严格边界：Mnora 只能从用户主动保存、确认或明确授权参与分析的内容中逐步学习，并且结果必须可理解、可纠正、可关闭、可删除。它不表示后台秘密画像，不表示从 `private_local` 内容跨边界学习，也不表示当前阶段已经实现长期个性化模型。

`Memory OS` 可用于内部讨论产品愿景，但不是正式产品名。外部品类描述优先使用 `personal memory system`，避免与现有同名产品混淆，也避免在能力尚未成立时过度承诺“操作系统”。

## 4. 推荐文案

### 中文

```text
Mnora · 见藏
把所见，变成可找回的记忆。
```

### 英文

```text
Mnora
Mnora is a personal memory system that learns how you see the world.
```

当文案需要严格描述当前已交付能力时，使用较窄表述：

```text
Mnora is a local-first personal memory system for preserving how you see the world.
```

### 一句话介绍

> Mnora · 见藏是一款本地优先的个人观察与记忆系统：先可靠保存真实记录，再由用户授权 AI 整理成可确认、可纠错、可追溯的卡片。

## 5. 技术命名边界

本次改名只改变公开产品身份，不迁移已有技术标识。以下名称暂时保留：

- Dart package：`cognote`；
- Dart 类型：`CognoteApp`、`CognoteApplication`、`CognoteDatabase`；
- 数据库文件：`cognote.sqlite`；
- Android namespace/applicationId：`com.cognote.cognote`；
- 仓库路径、远程仓库、历史提交、CNG 任务编号和证据目录。

这些标识不会直接面向用户。若未来迁移，必须单独冻结范围，验证数据库升级、Android 包升级、Deep Link、测试包、签名、远程仓库和历史证据兼容性，不与普通功能任务混做。

## 6. 历史文档

2026-08-14 之前的提交、交接快照和阶段 0 报告可保留 `Cognote`，但文件顶部必须说明它是前产品名。当前产品文档和用户可见界面统一使用 `Mnora · 见藏`。
