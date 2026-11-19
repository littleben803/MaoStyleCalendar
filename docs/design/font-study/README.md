# 真实字体选型与授权核验

核验日期：2026-10-29。状态：用户已明确选择 B（思源宋体 + Literata）；未接入 App/Widget target。

历史状态说明：B 已被后续用户确认的五角色字体方案替代，当前以 [v2 字体清单](../handoff/v2/specs/font-roles.json) 为准；本目录样张仅保留研究过程，不再是当前字体决策。

## 已确认选择

用户选择 B：思源宋体 SC Regular 用于中文正文、语录和元数据，SemiBold 用于标题，Literata 用于英文与大日期数字。A 为单家族基线；C 更具手写阅读感。A/B 的中文相同是有意控制变量，主要比较英文和数字的差异，而不是把同源的 Noto Serif CJK 当作另一套独立中文设计。

| 方案 | 中文标题 | 中文正文/竖排 | 英文/数字 |
|---|---|---|---|
| A | 思源宋体 SC SemiBold | 思源宋体 SC Regular | 思源宋体 SC Regular |
| B（已选） | 思源宋体 SC SemiBold | 思源宋体 SC Regular | Literata Regular，wght=400，opsz 随样张字号调整至 14–72 |
| C | 霞鹜文楷 Regular | 霞鹜文楷 Regular | Literata，同 B |

没有已购商业字库或 App 嵌入合同，原计划的商业字体对照暂用开源组合替代，不使用下载站或未经许可的试用字体。这是避免虚构授权情况，不代表商业字体不适合。

## 样张

- [三方案并排对照](previews/comparison.png)
- 单方案：[A](previews/specimen-A.png)、[B](previews/specimen-B.png)、[C](previews/specimen-C.png)
- 多端参照：[A](previews/contexts-A.png)、[B](previews/contexts-B.png)、[C](previews/contexts-C.png)

所有样张由真实字库通过 AppKit/CoreText 绘制，不是 ImageGen 模拟。正文使用明确标注的编辑测试文字；引文仍属于候选样本，不升级内容状态。竖排使用 CoreText vertical forms 与从右向左列顺序，按语义断成两列，不以逐字旋转代替排版。对照页各方案相同文本、字号和容器，深色英文也使用各方案指定的 Latin 字体。

字号基线：中文正文 17 pt、标题 28 pt、竖排 27 pt、日期 108 pt、英文 22 pt；2× PNG。场景页以 iPhone 390 pt、XL 720 pt、Mac 正文栏 720 pt 作为排版参照，720 pt 不是系统 Family 固定尺寸。此轮不是 SwiftUI/WidgetKit 真机截图，不声称已验证 Dynamic Type、VoiceOver、最终屏幕渲染或所有文本的覆盖。

## 授权结论与执行条件

本轮所取三个项目均为 SIL OFL 1.1。按许可正文，可随商业软件捆绑、嵌入和分发，适用于本项目的 iOS/iPadOS/macOS App 与扩展；生成截图、壁纸等图形作品不因使用字体而必须改为 OFL，App 代码也不因此必须开源。

实际分发时须保留各字库的版权声明与完整许可证，可在 App 第三方许可说明中提供。不能单独出售字库，不能用作者名暗示背书，修改字体仍受 OFL 约束。许可证快照保存在 [licenses](licenses/) 中。

- 思源宋体保留名称 `Source`。子集化、格式转换或其他修改后若构成 Modified Version，必须遵守保留名称限制，不能默认沿用原名。
- 霞鹜文楷的保留名包含 `霞鹜`、`霞鶩`、`落霞孤鹜`、`落霞孤鶩`、`LXGW`。本次版本额外允许特定未改源码重编译和仅用于 Web 交付的子集/格式转换保留名称，不能把 Web 例外泛化为 App 字库子集化许可。
- Literata 的本次许可未声明保留字体名称；仍须保留 OFL 和版权，不把字体本身改为专有许可。
- 当前未做子集化、改名、格式转换或全局安装。后续若修改，需新清单、新校验值和命名复核。

官方来源与依据：

- [Adobe 思源宋体许可证](https://github.com/adobe-fonts/source-han-serif/blob/7889f11bf31170b5d092a083b357c8c8130f89e0/LICENSE.txt)
- [霞鹜文楷许可证](https://github.com/lxgw/LxgwWenKai/blob/db34daf997d8f38e3f5595db0a56e00368d1323f/OFL.txt)
- [Google Fonts Literata 许可证](https://github.com/google/fonts/blob/b68b528a75da7d9b73f3928899c07a23083a6633/ofl/literata/OFL.txt)
- [SIL 官方 OFL FAQ](https://openfontlicense.org/ofl-faq/)

## 字库版本、来源与完整性

研究字库缓存：`/Users/ideabox/.cache/mao-font-study/2026-10-29/`，不进入仓库，不属于已获准的正式字体资源。

| 文件 | 版本 | 上游提交及路径 | SHA-256 |
|---|---|---|---|
| SourceHanSerifSC-Regular.otf | 2.003 | adobe-fonts/source-han-serif @ 7889f11bf31170b5d092a083b357c8c8130f89e0 / OTF/SimplifiedChinese | 78aa7a328fd974df2d688c8a9fd74a33d8334dfa84ab24d9d11efb2ffc464117 |
| SourceHanSerifSC-SemiBold.otf | 2.003 | 同上 | faf16caeaf207e1926e01af8d9f1a8e71b0e9d8f51bf3b5d9a78f9f30e7e3e31 |
| LXGWWenKai-Regular.ttf | 1.530 | lxgw/LxgwWenKai @ db34daf997d8f38e3f5595db0a56e00368d1323f / fonts/TTF | 2d73eea94ad808999d90c0000c239a84a33b09d4bc6ab6c5b8bbf1eda8a7fc8b |
| Literata.ttf | 3.103 | google/fonts @ b68b528a75da7d9b73f3928899c07a23083a6633 / ofl/literata/Literata[opsz,wght].ttf | b41138c9373112f32abb589cc22e8674b06ed4048b0c513be922bdd26f274440 |

Literata 变量字体暴露的 PostScript 名称为 `Literata-Regular_ExtraLight`，不能据名称推断实际样张字重。脚本显式设定 wght=400；CoreText 轴数据显示默认值也是 400，opsz 按各次绘制设置。

## 验证与后续

- 四个文件均成功进行进程级注册，读取版本及 PostScript 名称；中文样本文字 138 个 UTF-16 单元覆盖通过，英文/数字/常用 Latin 标点覆盖通过。
- 四份字体 OS/2 fsType 均为 0；这只是技术嵌入标记检查，法律依据仍是许可证正文。
- 样张渲染设有正文高度与竖排 visible range 检查，七份 PNG 均生成成功并进行了可视检查；没有系统字体静默回退。
- 本次只验证样本，未验证全体 365 条、繁体地区字形、本地化、无障碍字号和全 target 加载。
- 完整字体约 23–25 MiB/份（中文）及 0.91 MiB（Literata），最终字重和体积预算需在字体选择后确定，不直接按研究目录全量打包。
- 设计师插画分层与暗底处理等收到实际资源后再试，本轮不处理插画。

重现（macOS，字体需先按上表官方固定提交下载）：

```sh
swift docs/design/font-study/render-specimens.swift /Users/ideabox/.cache/mao-font-study/2026-10-29 docs/design/font-study/previews
```

下一步以 B 补正式页面与各真实 Family 的排版样张和无障碍验证，保持主 App、扩展与 Mac 字体加载分别验收。A/C 留作研究历史，不进入正式字体包。
