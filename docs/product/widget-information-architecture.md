# Widget 信息架构与平台矩阵

更新日期：2026-10-29

## 1. 核心原则

Widget 的任务是“看一眼知道今天，并被作品吸引进入 App”。它不是可滚动小型 App。各 Family 独立构图，共用同一个已批准的每日内容包。

Apple 当前说明：系统 Widget 尺寸会因设备变化，布局不能依赖固定像素；`systemExtraLarge` 支持 iPadOS 和 macOS，但不支持普通 iPhone。iPhone Duo 仍按 iPhone 平台能力与可用宽度适配，不能假设内屏自动获得 iPad 的 Extra Large Family。

## 2. 系统 Family 设计

| Family | 平台 | 产品形态 | 内容 |
|---|---|---|---|
| `systemSmall` | iPhone、Duo、iPad、Mac | 简约日历 | 日期、插画焦点、极短摘编；整块点击进入当天 |
| `systemMedium` | iPhone、Duo、iPad、Mac | 横向日历卡 | 左侧日期/短句，右侧插画；可分区深链 |
| `systemLarge` | iPhone、Duo、iPad、Mac | 完整日历页 | 接近纸质设计稿，显示更完整摘编和小型出处 |
| `systemExtraLarge` | iPad、Mac | 双页画册 | 一侧完整插画，一侧日期、双语摘编、出处与进入详情入口 |
| `systemExtraLargePortrait` | Apple Vision Pro | 不在本项目范围 | 2026-10-29 官方 HIG 列明 iPhone、iPad、Mac 均不支持，不作为首发候选 |

## 3. 锁屏与其他环境

| Family/环境 | 形态 |
|---|---|
| `accessoryInline` | 日期 + 一句极短文字，不放复杂插画 |
| `accessoryRectangular` | 日期、短句和单色插画印记 |
| `accessoryCircular` | 仅日期或主题印章，避免塞入语录 |
| StandBy | 复用可用的系统 Family，但单独检查远距离可读性、夜间色彩和裁切 |
| Mac 桌面/通知中心 | 原生 Mac Widget，允许系统 tint/透明外观，确保插画仍可辨识 |

## 4. Widget 配置

桌面组件当前使用 App 内的「显示设置」。固定背景、每日插画与显示开关的权益规则见 [IAP 产品与解锁策略](iap-strategy.md#4-桌面小组件已确认)。以下是早期 App Intent 配置候选，待后续确认：

- 显示语言：中文、英文、中英双语；
- 样式：作品优先、语录优先；
- 日期：跟随今天或固定纪念日页（是否纳入 V1 见 MVP 文档）。

不提供过多颜色、字体和自由布局选项，保持产品识别度。

## 5. 交互

- 点击主体：打开对应日期的今日正面卡片；来源文字区域的独立深链可直接呈现复用的“语录详解”背面；
- Medium/Large/Extra Large 可为出处和作品设置独立深链；
- 锁定设备上的交互需遵守系统认证限制；
- Widget 不提供滚动、自由翻页、文本输入或复杂筛选。

## 6. 更新时间线

- 内容全部本地内置，按本地时区下的公历日期生成每日 Timeline，年度内容包使用版本化确定性映射，与 App 保持一致；
- 在午夜附近安排下一条目，但不承诺系统精确在 00:00 刷新；
- 时区、系统日期或语言变化后请求刷新；
- 不依赖后台网络拉取，也不为“实时刷新”制造不必要耗电。

## 7. 图像与文字策略

- 每幅插画登记焦点、Small/Medium/Large/Extra Large 裁切安全区；
- Widget 文字由 SwiftUI 渲染，保持本地化和无障碍；
- 允许使用经过审批的插画裁切图，但不把整个 Widget 截成一张静态图；
- 系统 tint、深色、透明和高对比度模式需要单独预览；
- Extra Large 采用真正的双页/展陈布局，不只是放大 Large。

## 7.1 本轮视觉选择

用户已选择第一组日期优先方向并要求精修。当前完成中文浅色家族精修：Small/Medium 重日期与短摘编，Large 使用完整日历构图，Extra Large 左画右文；锁屏独立单色编排。农历示例已用 Foundation 核对，但概念图不构成实际 Family 尺寸、字体或可读性验证。具体验收见 `docs/design/widget-family-specifications.md`。

随后已补齐英文（含独立长句压力样本）、深色全彩、系统着色概念样张，以及透明背景/StandBy 夜间方向。外观遵循系统环境，不新增三套可选主题；实际渲染和真实字体测量尚未完成。

## 8. 官方能力依据

- [Apple：WidgetFamily](https://developer.apple.com/documentation/widgetkit/widgetfamily/)
- [Apple：Creating a widget extension](https://developer.apple.com/documentation/widgetkit/creating-a-widget-extension)
- [Apple HIG：Widgets](https://developer.apple.com/design/human-interface-guidelines/widgets)
- [Apple：Adding interactivity to widgets](https://developer.apple.com/documentation/widgetkit/adding-interactivity-to-widgets-and-live-activities)
