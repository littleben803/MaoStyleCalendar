# 每日内容数据契约与逻辑表结构

更新日期：2026-10-30。

## 1. 本阶段结论

`CalendarCore` 先提供数据库无关、可编码且可测试的领域模型与 Repository 协议。运行时使用 `MockDailyContentRepository` 生成 365 个基础内容包和 1 个闰日专属内容包；它不写入磁盘，不要求修改 App Group、签名或工程配置。

暂不选择 SwiftData、Core Data 或 SQLite。正式内容适合以只读、版本化的内置资源交付，本地偏好则属于可变存储；在 Widget 共享路径、迁移策略和资源导入格式确认前，不把两类数据过早绑定到同一个持久化实现。

Mock 只用于界面开发：所有内容包均为 `candidate`，语录类型为 `mock_placeholder`，插画状态为 `placeholder`，没有来源片段或核验记录。它们不得进入 Release 内容资源。

## 2. 领域关系

```text
content_pack 1 ── N quote_text
content_pack 1 ── N source_fragment      (同时归属 quote_text)
content_pack 1 ── N editorial_section
content_pack 1 ── N artwork_asset
content_pack 1 ── N verification_record

annual_assignment N ── 1 content_pack
```

插画与语录通过同一个 `content_pack.id` 固定配对。年度算法移动完整内容包，不单独重排插画或语录。

## 3. 逻辑表

以下是未来持久化适配器应遵循的逻辑结构。字段名使用 `snake_case`；Swift 领域模型使用对应的驼峰命名。

### `content_pack`

| 字段 | 类型 | 约束 | 说明 |
| --- | --- | --- | --- |
| `id` | text | PK | 稳定内容 ID，修订内容时不得改变 |
| `kind` | text | not null | `base` 或 `leap_day` |
| `revision` | integer | not null, >= 1 | 内容修订号 |
| `review_status` | text | not null, indexed | 内容审核状态 |
| `pairing_locked` | boolean | not null | 插画与语录是否锁定为一套 |

约束：基础池正式发布时恰好 365 条；闰日池恰好 1 条；只有 `approved` 可以进入 Release 资源。

### `quote_text`

| 字段 | 类型 | 约束 | 说明 |
| --- | --- | --- | --- |
| `id` | text | PK | 文本记录 ID |
| `content_pack_id` | text | FK, indexed | 所属内容包 |
| `language_tag` | text | not null | 例如 `zh-Hans`、`en` |
| `kind` | text | not null | 逐字原文、编辑摘编、编辑译文或 Mock |
| `text` | text | not null | 呈现文本 |
| `work_title` | text | nullable | 篇名 |
| `volume` | integer | nullable | 卷次 |
| `edition` | text | nullable | 正式底本版本 |
| `source_locator` | text | nullable | 页码或稳定定位 |
| `article_date` | text | nullable | 原文章日期；采用可审阅的公历字符串 |
| `translation_provenance` | text | not null | 非翻译、正式英文底本、项目编辑译文或待处理 |

建议唯一索引：`(content_pack_id, language_tag, kind, id)`。

### `source_fragment`

| 字段 | 类型 | 约束 | 说明 |
| --- | --- | --- | --- |
| `id` | text | PK | 来源片段 ID |
| `content_pack_id` | text | FK, indexed | 所属内容包 |
| `quote_text_id` | text | FK, indexed | 对应呈现文本 |
| `sequence` | integer | not null | 组合顺序 |
| `source_text` | text | not null | 从正式底本核验的片段 |
| `context_before` | text | nullable | 前文上下文 |
| `context_after` | text | nullable | 后文上下文 |
| `source_locator` | text | not null | 片段页码或稳定定位 |
| `is_continuous_with_previous` | boolean | not null | 是否与上一片段连续 |

唯一索引：`(quote_text_id, sequence)`。非连续摘编必须保留多个片段，不能只保存合成后的展示句。

### `editorial_section`

| 字段 | 类型 | 约束 | 说明 |
| --- | --- | --- | --- |
| `id` | text | PK | 编辑段落 ID |
| `content_pack_id` | text | FK, indexed | 所属内容包 |
| `language_tag` | text | not null | 段落语言 |
| `kind` | text | not null | 摘编说明、原文上下文、历史背景、通俗解读、翻译说明、阅读提示 |
| `display_order` | integer | not null | 详情页内顺序 |
| `body` | text | not null | 编辑正文 |

唯一索引：`(content_pack_id, language_tag, display_order)`。

### `artwork_asset`

| 字段 | 类型 | 约束 | 说明 |
| --- | --- | --- | --- |
| `id` | text | PK | 美术资源记录 ID |
| `content_pack_id` | text | FK, indexed | 所属内容包 |
| `role` | text | not null | 主图、各 Widget 画幅或壁纸 |
| `asset_name` | text | nullable | App 内资源名；Mock 可为空 |
| `creator` | text | nullable | 作者 |
| `creation_date` | text | nullable | 创作日期 |
| `delivery_batch` | text | nullable | 设计交付批次 |
| `license_scope` | text | nullable | App、Widget、宣传、海外等授权范围 |
| `source_checksum_sha256` | text | nullable | 不可变母版校验值 |
| `focus_x` / `focus_y` | real | nullable | 0...1 归一化主体焦点 |
| `safe_width` / `safe_height` | real | nullable | 0...1 归一化安全区域 |
| `approval_status` | text | not null, indexed | 占位、候选、批准或驳回 |

正式导入时应检查归一化坐标范围，且批准资源必须具有校验值、作者和授权范围。

### `verification_record`

| 字段 | 类型 | 约束 | 说明 |
| --- | --- | --- | --- |
| `id` | text | PK | 核验记录 ID |
| `content_pack_id` | text | FK, indexed | 所属内容包 |
| `scope` | text | not null | 中文底本、英文底本、语境审校或插画授权 |
| `reviewer` | text | not null | 核验人 |
| `reviewed_at` | text | not null | 核验日期 |
| `result` | text | not null | 核验结果状态 |
| `notes` | text | nullable | 版本差异或补充说明 |

核验历史采用追加记录，不覆盖旧记录。

### `annual_assignment`

| 字段 | 类型 | 约束 | 说明 |
| --- | --- | --- | --- |
| `calendar_year` | integer | PK(part) | 公历年份 |
| `algorithm_version` | integer | PK(part) | 分配算法版本 |
| `local_date` | text | PK(part) | `YYYY-MM-DD` |
| `content_pack_id` | text | FK, indexed | 当日内容包 |

当前由 `AnnualContentAllocator` 确定性计算，不要求落库。若未来缓存，以上联合主键可防止同日期重复写入。

## 4. 状态映射

领域模型完整保留以下正式状态：`candidate`、`cn_verified`、`bilingual_verified`、`editorial_reviewed`、`approved`、`blocked_version_mismatch`。

中英文无法逐句对应时必须使用 `blocked_version_mismatch`。项目编辑译文使用 `editorial_translation` 与 `project_editorial` 标记，不能伪装为外文出版社逐字原句。

## 5. 当前 Swift 映射

- `DailyContentPack`：内容包聚合根。
- `QuoteText`、`SourceFragment`、`EditorialSection`：语录、来源和编辑内容。
- `ArtworkAsset`、`NormalizedArtworkFocus`：插画元数据和不同画幅适配依据。
- `VerificationRecord`：可追溯核验记录。
- `DailyContentRepository`：存储无关的读取接口。
- `MockDailyContentRepository`：阶段 1 的内存 Mock；稳定生成 `mock-base-001...365` 和 `mock-leap-day-001`。

桌面小组件的显示偏好由 App Group 共享。正式资源导入器、内容数据库、跨 schema 迁移执行器及 Release 过滤器仍未实现。
