# 附件原稿字体匹配研究

日期：2026-10-29。范围：针对 v2 原稿中的中文、英文、日期数字，寻找真实可嵌入字体；不修改当前 B 字体决策，不把候选等同于已识别原字体。

后续决定：用户已明确采用中文 Bold 标题、SemiBold 竖排、Regular 正文，Source Serif 4 SemiBold 英文语录与 Libre Bodoni Bold 大日期，正式替代 B；见 [当前字体清单](../../design/handoff/v2/specs/font-roles.json)。下文保留研究当时的候选排序，不再作为未决事项。

## 结论

能够找到适合 iOS/SwiftUI 的字体来接近原稿。原稿由图像生成工具生成，没有可读取的字体元数据，甚至同张图中的字形可能不完全一致，因此无法保证识别到唯一同名字库或百分之百逐笔画复现。

[真实字体对照图](comparison.png) 使用原生 CoreText/AppKit 绘制，包含同文本、同字号的字重对照，不是又一张 AI 模拟字形稿。

| 类型 | 原稿视觉特征 | 优先候选 | 本轮判断 |
|---|---|---|---|
| 中文主标题 | 宋体/明朝体，高粗细反差，笔画厚重 | 思源宋体 SC Bold，SemiBold 作次选 | Bold 比此前 SemiBold 更值得对照“语录详解”；不意味着所有标题一律改 Bold |
| 中文竖排语录 | 有印刷感、较醒目，列内自然排布 | 思源宋体 SC SemiBold/Bold | Regular 在此前稿中偏弱，应按原稿字面大小与粗细单独配准 |
| 中文正文/出处 | 宋体正文，层级克制，细节清楚 | 思源宋体 SC Regular/Medium | Regular 可沿用；本轮未下载 Medium，仅作为后续字重候选，不冒充已实绘比较 |
| 英文语录 | 出版衬线、墨色较重、较紧凑 | Source Serif 4 SemiBold；Literata 600 对照 | 两者技术上可用，当前视觉上更倾向 Source Serif 4 做原稿匹配；尚未进行像素配准，属于主观候选排序 |
| 大日期数字 | 极醒目的粗竖画、细横画与高反差衬线 | Libre Bodoni Bold；Bodoni Moda Bold；Literata 700 对照 | 优先继续用 Libre Bodoni Bold 配准；原 Literata 400 太细，不能代表原稿 |

这里的候选排序是视觉判断，不是字体身份鉴定或量化相似率。若追求更贴合原稿，最终可能需要中文、英文、大日期分别采用三个家族；不应为了保持“两字体组合”而牺牲原稿视觉。是否调整 B 方案由产品确认，本轮未自动替换。

## iOS 技术可用性

Apple 支持将 TTF/OTF 字库放入 App Bundle 并通过注册名称使用，SwiftUI 同样支持自定义字体。App 内使用不要求用户安装字体描述文件，也不等于注册系统范围字体提供服务。

- [Apple：Adding a custom font to your app](https://developer.apple.com/documentation/uikit/adding-a-custom-font-to-your-app)
- [Apple：Applying custom fonts to text](https://developer.apple.com/documentation/swiftui/applying-custom-fonts-to-text)

本轮实测七份研究字库在 macOS CoreText 中进程级注册成功，版本和字体嵌入技术标记可读取，fsType 均为 0。变量字体的 wght/opsz 显式设置并读取确认：不是只按文件名把 Regular 假装成 Bold。该结果不等同于已建立 iOS target 或通过 WidgetKit 加载测试。

实际 iOS 实现仍需逐 target 打包与验证，字体 PostScript 名称、变量轴、竖排标点、地区字形和 Dynamic Type 单独检查。不可把本机已安装字体直接拷进 App，必须使用有分发授权的字库文件。

## 授权核验

本轮新增 Bodoni Moda、Libre Bodoni、Source Serif 4 均来自 Google Fonts 官方仓库，许可为 SIL OFL 1.1；思源宋体 Bold 来自 Adobe 官方 release，适用已归档思源宋体许可。

按 OFL 条件可以用于商业设计、嵌入和随软件分发；需保留版权及完整许可，修改/子集化需遵守实际字库的保留名称条件，不能单独销售字体或暗示作者背书。fsType=0 是辅助技术检查，不代替许可证。

- [Bodoni Moda OFL](https://github.com/google/fonts/blob/b68b528a75da7d9b73f3928899c07a23083a6633/ofl/bodonimoda/OFL.txt)
- [Libre Bodoni OFL](https://github.com/google/fonts/blob/b68b528a75da7d9b73f3928899c07a23083a6633/ofl/librebodoni/OFL.txt)
- [Source Serif 4 OFL](https://github.com/google/fonts/blob/b68b528a75da7d9b73f3928899c07a23083a6633/ofl/sourceserif4/OFL.txt)
- [思源宋体许可](https://github.com/adobe-fonts/source-han-serif/blob/7889f11bf31170b5d092a083b357c8c8130f89e0/LICENSE.txt)

三份新增许可原文保存在 licenses/；思源宋体原文已有 docs/design/font-study/licenses/SourceHanSerif-OFL.txt。此轮不使用商业字库试用文件，未新增采购承诺。

## 版本与文件完整性

新增文件仅保存在研究缓存 `/Users/ideabox/.cache/mao-font-matching/2026-10-29/`，没有进入业务工程或替换 handoff/v2 原稿。已有字体从 `/Users/ideabox/.cache/mao-font-study/2026-10-29/` 读取。

| 文件 | 版本 | SHA-256 |
|---|---|---|
| BodoniModa.ttf | 2.005 | 550f5e34ee0a828d7941b1fe9bc58b34e5260d3f33a61532e6d0a0114e79a5cf |
| LibreBodoni.ttf | 2.005 | 0d543665bd869819ffd7d46608804e245497ba835960832d44be89e561b0c717 |
| SourceSerif4.ttf | 4.004 | 97b2d4da6e3cb494b5a1e66ae176914d852ccabef49e0c02c0df25f3e39aca0b |
| SourceHanSerifSC-Bold.otf | 2.003 | 706b8c0de2deff6cbc0c87e2cdedfd33a78b7ffd76cebb4549012f197ba611fe |

前三份固定上游 google/fonts 提交 b68b528a75da7d9b73f3928899c07a23083a6633，分别位于 ofl/bodonimoda、ofl/librebodoni、ofl/sourceserif4；思源宋体固定 adobe-fonts/source-han-serif 提交 7889f11bf31170b5d092a083b357c8c8130f89e0 的 OTF/SimplifiedChinese。

对照图：中文 42 pt 标题、24 pt 短句；数字同为 112 pt，另有 35 pt “19 27 04”；英文语录 34 pt/wght=600。光学字号限制在各字体实际轴范围内，不能以名义相同字号推断字面高度相同。字号差异本身就是原稿配准必须处理的问题。

## 后续匹配方法

分别从原稿确定中文标题、竖排语录、英文语录和日期的可见字面边界，按同一文本和同一可见高度叠加比较：笔画粗细、衬线、数字 2/9 的曲线、英文 g/r/s、行宽与间距。先确定字体/字重，再把它放回原稿构图，不能先改构图给字体让路。

本阶段新增本报告、真实对照图、渲染脚本及许可快照。未修改字体决策、原稿、业务逻辑或工程。未运行 Debug 构建；尚未完成原稿逐字像素配准或 iOS 真机验证。
