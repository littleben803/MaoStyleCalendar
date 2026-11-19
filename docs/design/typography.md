# 字体系统与内置字体约束

更新日期：2026-10-29

## 1. 已确认方向

当前高保真稿中的字体气质已被确认：庄重、专业、具有中文出版物和纸质日历质感。最终主标题、副标题和正文不使用系统字体替代，项目需要随 App 打包自定义字体。

概念图是视觉目标，不是字体授权或字体文件来源。无法仅凭生成图片准确识别并取得同一字体，因此实现前必须用真实候选字体制作对照样张。

## 2. 字体角色

| Token | 用途 | 视觉要求 |
|---|---|---|
| `DisplayDate` | 日期大数字 | 高对比衬线、朱红色、具有实体印刷感 |
| `DisplayTitle` | “语录详解”等主标题 | 中文宋体/明朝体气质，庄重且有明显笔画层次 |
| `SectionTitle` | 原文与出处、历史背景、当下解读 | 与主标题同家族的中粗字重，朱红强调 |
| `QuoteVertical` | 正面竖排语录 | 适合竖排、标点与中英文混排稳定 |
| `BodyReading` | 详情正文 | 长文清晰、字面不过小、屏幕阅读不疲劳 |
| `Metadata` | 日期、出处、卷次 | 可选同家族较轻字重或匹配的授权字体 |

## 3. 授权门禁

候选字体进入工程前必须确认：

- 允许随付费 App 二进制嵌入；
- 允许用于 Widget Extension 和 macOS App；
- 允许在 App Store 截图、宣传图和导出壁纸中使用；
- 是否允许字体子集化、重命名或转换格式；
- 是否要求保留许可证或作者声明；
- 中文简体、繁体、英文、数字和常用标点的覆盖范围。

优先评估具有明确开源商业许可或已购移动 App 嵌入授权的字体。未经书面确认，不使用“个人免费”“仅桌面授权”或来源不明的字体包。

## 4. 技术要求

- 字体文件纳入资源清单并记录原始文件 SHA-256、版本和许可证；
- 主 App、Widget Extension 和 macOS target 分别声明和验证；
- SwiftUI 使用语义字号并通过 `relativeTo` 支持 Dynamic Type，不把字号完全写死；
- 竖排排版需要单独验证标点方向、换行和 VoiceOver 阅读顺序；
- 英文权威译文如果与中文字体气质不匹配，可配置第二套已授权的 Latin 字体；总家族数保持克制；
- 字体加载失败时允许系统字体作为故障回退，但回退状态不得通过正式视觉验收。

## 5. 选型过程（已完成）

在 Coding 前制作至少三套真实字体样张，统一使用同一段日期、竖排语录、详情标题和正文比较：

1. 开源可嵌入宋体/明朝体方案；
2. 已购商业出版字体方案；
3. 中文展示字体 + 高可读正文字体的双家族方案。

样张需同时在 iPhone、Extra Large Widget 和 Mac 窗口中检查，最终由产品和设计共同确认。

## 6. 本轮实际进展（2026-10-29）

已完成 A/B/C 对照，用户曾选择 B。随后针对原稿重新匹配，用户明确采用下方最新五角色方案，替代 B。此前对照仅作为历史，不作为默认字体或新增选项。商业字体因暂无已购字库和嵌入合同未进入样张。

详见 [字体研究与许可证核验](font-study/README.md)，包含许可快照、固定上游提交、SHA-256、真实 CoreText 样张与重现脚本。样张包含 iPhone/XL/Mac 参照宽度；未创建工程，未验证真实 WidgetKit Family 或全平台加载。

## 7. 已确认字体映射

| Token/文字类型 | 字体与基准字重 |
|---|---|
| DisplayDate / 大日期数字 | Libre Bodoni Bold，wght=700 |
| DisplayTitle / 中文主标题 | Source Han Serif SC Bold |
| SectionTitle / 中文分节标题 | Source Han Serif SC SemiBold |
| QuoteVertical / 中文竖排语录 | Source Han Serif SC SemiBold |
| BodyReading / 中文正文 | Source Han Serif SC Regular |
| Metadata / 中文日期、农历与出处 | Source Han Serif SC Regular |
| 英文语录 | Source Serif 4 SemiBold，wght=600 |

日期元数据中的数字允许跟随中文所在字体，避免同一句中文日期反复切换字库；独立大日期数字使用 Libre Bodoni Bold。英文章节标题、正文与篇名在 Source Serif 4 家族内按原稿另行确定字重/斜体，不把“英文语录 SemiBold”自动推广至所有英文。

当前锁定思源宋体 SC 2.003、Source Serif 4 4.004、Libre Bodoni 2.005。变量字体的 PostScript 名称不代表实际字重，必须显式应用 wght=600/700 并核验，不能伪加粗。文件与 SHA-256 见 [v2 字体角色清单](handoff/v2/specs/font-roles.json)，字库与许可证已归档在 v2/fonts 和 v2/licenses。

本次字体确认不等同于字体已进入 target。主 App、Widget、Mac 分别打包加载、Dynamic Type、极端文本、繁体地区字形及最终体积仍待实现与验证；不在本阶段自动做子集化或改名。

## 8. 正式页面排版参照

已用 B 字体生成六个核心 App 页面和中英文四 Family 排版参照，含长正文与长句降级样张。详见 [排版研究](layout-study/README.md)。这是 AppKit/CoreText 实绘与测量，不等同于 SwiftUI/WidgetKit 真实界面，保留后续系统容器与动态字号验收。

以上 B 字体样张是历史研究，不能覆盖最新字体决定，也未通过原稿贴合验收。当前阶段只锁定字库和角色；字号、字距、行距与原稿可见字面占比仍需重新配准，原稿构图保持不变。
