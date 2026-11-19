# 毛选日历品牌资源

2026-11-09 确认的第 1 稿「引文日历」。主题朱红为 `#B81211`，字标墨色为 `#1F1B17`，启动暖纸色为 `#F6F0E4`。

| 用途 | 中文 | 英文 |
| --- | --- | --- |
| App 主屏幕名称 | 毛选日历 | Mao Quotes |
| App 图标，1024 × 1024 px | [中文 PNG](app-icon-zh.png) | [英文 PNG](app-icon-en.png) |
| 官网横版 Logo，路径化透明 SVG | [中文 SVG](logo-zh.svg) | [英文 SVG](logo-en.svg) |
| 透明 Logo，2048 px 宽 | [中文 PNG](logo-zh.png) | [英文 PNG](logo-en.png) |

官网浅色背景优先使用 SVG。Logo 的字形已转为路径，图形和文字为透明背景上的独立路径。网页上的 Logo 可分别使用「毛选日历」和「Mao Quotes」作为替代文字。上表两张 PNG 图标保留为 2026-11-09 文字版历史原稿。英文商店建议名为 `Mao Quotes: Daily Calendar`。

2026-11-17 用户确认制作无字头像候选 v1 后，授权部署真机预览。该版使用[头像候选 v1](app-icon-portrait-candidate-v1.png)的 1024 × 1024 导出；原始候选为 1254 × 1254。用户随后要求深色与着色交由系统处理并删除无用资源：现仅引用 Any.png，Dark/Tinted 槽位不引用文件，四张对应 PNG 已删除；不提供自定义深色或着色版本。见[v1 候选及接入记录](app-icon-portrait-candidate-v1.md)。

2026-11-19 当前 iOS 中英文图标改用[红底头像重绘候选 v2](app-icon-portrait-red-candidate-v2.png)的 1024 × 1024 导出，透明高清头像另见[独立人物层](app-icon-portrait-red-source-v2.png)。保留既有日历构图与两套资源 ID；官网 Logo、历史文字版图标及宣传图不变。详情见[v2 制作记录](app-icon-portrait-red-candidate-v2.md)。重绘不等同于原参考图的商用授权。

## 中英文品牌提示语

用于官网和 App 开场页的品牌文案。

### 中文

同志，每日一页，非时光重复，是平凡坚守，终凝不凡力量！

### English

Comrade, one page a day—not merely marking time, but a quiet act of perseverance that builds extraordinary strength!

中英文逐行排版和生成提示词见[设计提示词](prompts.md)。

## 开场底图

[透明卡片原稿](launch-card.png)为 971 × 1619 px。铜环、纸孔、纸叠、阴影、纸纹和窗边翻书插画合成在同一张图里。iOS 资源采用同一原始像素，最大常规 iPhone 宽度下略低于原生 3× 密度。标题、短线与品牌提示语由 App 排版。系统 Launch Screen 使用同色暖纸底。iPhone、Duo 和 iPad 冷启动展示品牌开场，按安全区内的可用尺寸排版。窄窗口保留上下版式，可用宽度达到 600 pt 时采用左侧文案、右侧等比卡片的布局。辅助功能大字号或可用高度低于 300 pt 时使用可滚动版式。

### 宽屏开场引文

- 来源条目 `pack-0015`。2026-11-10 由 Codex 对照中英文底本核验，供 Debug 预览，待项目负责人确认后进入 Release。
- 中文「读书是学习，使用也是学习，而且是更重要的学习。」出自《中国革命战争的战略问题》（1936 年 12 月）第一章第四节。《毛泽东选集》第 1 卷，人民出版社 1991 年第 2 版，第 181 页。[中文书影，第 194 个 PDF 页](https://www.flamelephant.com/images/20230421/party/mao-1.pdf#page=194)
- 英文采用对应出版译文。*Problems of Strategy in China’s Revolutionary War*，*Selected Works of Mao Tse-tung* 第 1 卷，外文出版社 1965 年 8 月第 1 版，第 189 页。[英文底本，第 197 个 PDF 页](https://www.marxists.org/reference/archive/mao/selected-works/sw-in-pdf/sw-flp-1965-v1.pdf#page=197)
- 引用为完整原句，中文展示分三行。原段在讨论如何从既有战争经验和亲身实践中学习，前文说明用自己的经验检验结论，后文举在实践中学习为例。完整上下文见以上页码。
- PDF SHA-256。中文 `fb5aaa4c3924d373af1f9d6f0a5bcd2d865f2ffaa511d9354816d67858430e21`，英文 `3cd54393058e5026092346088a8fdb54248857f10fb484ee429fbdda09c0265c`。
