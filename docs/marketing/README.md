# App Store 宣传材料

2026-11-13 启动。当前阶段：按用户最新授权完成中文 iPhone 四页连续背景与自由创作构图候选（四页均有手机），用户已确认 iPhone 中文视觉并报告已上传；DUO 中文四页 v4 已确认并归档打包，待用户自行上传。iPad 中文四页 2064×2752px 竖版已确认并归档打包，待用户自行上传。

- 英文创意素材：[标题 · 3840×1646](exports/header/en/20261113/AppStore-header-en-3840x1646.png) · [搜索结果 · 3840×2560](exports/search-results/en/20261113/AppStore-search-en-3840x2560.png)
- [中文搜索图确认成品 · 3840×2560](exports/search-results/zh-Hans/20261113/AppStore-search-zh-Hans-3840x2560.png)
- [中文标题图确认成品 · 3840×1646](exports/header/zh-Hans/20261113/AppStore-header-zh-Hans-3840x1646.png)
- 英文上传包：[iPhone](exports/iphone/en/20261113/AppStore-iPhone-en-4screenshots.zip) · [DUO](exports/DUO/en/20261113/AppStore-DUO-en-4screenshots.zip) · [iPad](exports/ipad/en/20261113/AppStore-iPad-en-4screenshots.zip)
- [英文三设备 12 张已确认视觉预览](/Users/ideabox/.cache/MaoStyleCalendar/store-marketing-20261113/candidates/en-all-devices-v1/index.html)
- [四页连续宣传及中文成品记录](iphone-panorama-preview-20261113.md)
- [DUO 中文四页成品与源素材](exports/DUO/README.md)
- [iPad 中文四页成品与源素材](exports/ipad/README.md)
- [iPad 中文四张截图下载包](exports/ipad/zh-Hans/20261113/AppStore-iPad-zh-Hans-4screenshots.zip)
- [DUO 中文四张截图下载包](exports/DUO/zh-Hans/20261113/AppStore-DUO-zh-Hans-4screenshots.zip)
- [中文四张截图下载包](exports/iphone/zh-Hans/20261113/AppStore-iPhone-zh-Hans-4screenshots.zip)
- [历史中文小组件首图候选](iphone-widget-first-shot.md)

- [官方要求与制作计划](app-store-research-20261113.md)
- [资源盘点清单](asset-inventory-20261113.json)

先做普通 iPhone，之后按平台专项验收结果补充 Duo、iPad；Mac 单独处理。每批以中英两个本地化版本交付，不能将占位图、QA 图、内部候选或机器尺寸检查标成发布批准。

后续大型源文件、视频、候选及导出先存放在仓库外 `~/.cache/MaoStyleCalendar/store-marketing-20261113/`，分别设 `sources/`、`candidates/`、`approved/`、`exports/`、`checks/`。此缓存目录是工作区，不是长期备份；最终成品归档位置在交付时确认。仓库只记录清单、来源、哈希、版本、审核状态与交付索引；未经允许不提交大文件。

2026-11-13 英文三设备候选完成：iPhone 1206×2622、DUO 2007×2853、iPad 2064×2752，各四张 RGB 竖版 PNG。保留中文确认构图与连续红底，九张主体由内置 ImageGen 本地化；三张无中文壁纸主体原样复用，仅外部标题改为英文。标题用随候选保存的 Source Serif 4 独立排版；卡片语录沿用 english-editorial.json 及短编辑摘句、说明为项目宣传释义，不伪称出版底本逐字英译。全部候选与提示词位于 `/Users/ideabox/.cache/MaoStyleCalendar/store-marketing-20261113/candidates/en-all-devices-v1/`，index.html 提供三组与原尺寸单张入口，尚未视觉批准、归档、打包或上传。图片/字体加载、标题溢出及间距、12张尺寸/RGB/切片/哈希已验证，九个本地化主体和三组预览已目视检查；中文12张成品哈希保持一致。App/Widget、工程、签名、版本及后台未改；纯素材制作未运行 Debug 构建。

2026-11-13 用户确认三设备全部12张英文视觉并授权归档。成品位于各设备 `en/20261113/`，源素材、提示词、字体与可编辑排版位于各设备 `source/20261113-en/`；每设备一个仅含四张 PNG 的上传 ZIP。归档成品与确认候选逐字节一致，尺寸/RGB/精确切片/哈希、ZIP成员及解压内容哈希、源文件清单读回均通过；12张中文成品哈希保持不变。各成品目录有 manifest.json，汇总见 exports/english-archives-20261113.json。本条替代此前英文候选待确认状态；未上传、未提交，内容出版核验与商业授权状态不因此升级。

2026-11-13 标题图中文 v1 候选完成，待视觉确认。用户先要求参考 Apple 官方示例、暂停制作，随后授权先做标题并强调产品主打桌面小组件；本轮改以两张不同尺寸的 Widget 为主视觉，品牌“毛选日历”及短句“把好句子放在桌面上”独立排版，无手机或功能清单。内置 ImageGen 新生成卡片主体，延续既有朱红底图。工作目录 `/Users/ideabox/.cache/MaoStyleCalendar/store-marketing-20261113/candidates/header-widget-zh-v1/`，完整标题图在 preview/header-zh-3840x1646.png；提示词、字体、可编辑排版和规格在 source/。标题规格3840×1646px RGB无Alpha，品牌与Widget元素边界位于官方安全区x1097/y493/w1646/h661内；尺寸/图片字体加载/文字溢出/元素边界/哈希通过，已目视核对主体、整图和安全区截取。安全区截取仅离线检查，不冒充后台实际预览。此次仅中文标题，搜索图与英文未制作；未归档打包或上传，原24张中英宣传成品、App/Widget、工程及后台未改，未运行Debug构建。官方参考：https://developer.apple.com/app-store/asset-best-practices/ 与 https://developer.apple.com/help/app-store-connect/reference/app-information/creative-assets-specifications 。

2026-11-13 标题图 v2 替代带品牌名/标语的v1：用户要求无外部文字，仅小中大多种Widget，可层叠；随后要求日数字下面必须有月和星期。内置ImageGen重做8张Widget错落层叠画面，保留卡片内语录；13下为11月/星期五、18下为11月/星期三，与2026年11月核对一致。中央主卡向下调整以在官方安全区保留日期、语录及主人物面部，周边卡片作为辅助画面，可被裁切。候选目录 `/Users/ideabox/.cache/MaoStyleCalendar/store-marketing-20261113/candidates/header-widget-zh-v2/`，source保存生成母图、两次修正提示词及规格，preview保存3840×1646px RGB无Alpha整图、缩略与离线安全区截取。尺寸/模式/日期星期/SHA-256通过，已目视检查整图与安全区主内容；未进行后台实际跨设备预览。待用户视觉确认，未归档、打包、上传；只更新本文和项目状态，App/Widget、工程与既有成品未改，未运行Debug构建。

2026-11-13 用户确认Widget-only中文标题v2并授权归档供自行上传。原样成品位于 `exports/header/zh-Hans/20261113/AppStore-header-zh-Hans-3840x1646.png`，母图、三份提示词、规格、缩略及离线安全区截取位于 `exports/header/source/20261113-zh-Hans-v2/`。单图可直接上传，不另做ZIP。成品与候选逐字节一致，3840×1646px RGB无Alpha、SHA-256读回及源清单复核通过；本条替代上方v2待确认状态，v1弃用。尚未上传或后台跨设备预览，搜索图及英文标题未制作。仅新增标题归档和更新索引、项目状态，App/Widget、工程、既有宣传成品、签名及后台未改，未运行Debug构建、未提交。

2026-11-13 搜索结果中文v1候选完成，待视觉确认。用户提供Apple官方搜索图示例并明确可加标题/宣传语；本轮独立采用左文案“好句子，就在桌面”与“每日语录，遇见手绘之美”，右正面iPhone桌面Widget及浮层样式，聚焦核心桌面小组件价值，不画外层App Store搜索框/获取按钮。内置ImageGen生成主体，日期13/11月/星期五完整；标题/副文案以项目内置字体独立排版。仓库外候选 `/Users/ideabox/.cache/MaoStyleCalendar/store-marketing-20261113/candidates/search-widget-zh-v1/` 保存母图、提示词、字体、可编辑排版及规格；完整图在preview/search-zh-3840x2560.png。3840×2560px RGB无Alpha，标题边界处于官方x836/y765/w2168/h1030安全区；已目视核对离线裁切中的日期、主要语录和人物面部，手机上下缘及前景下部不作为保证完整的关键区。图片字体加载、文字溢出、尺寸/模式、星期与哈希通过；未后台跨设备预览。只更新本文与项目状态，App/Widget、工程、标题确认稿及既有成品未改，未运行Debug构建，未归档打包或上传；本轮仅中文搜索图。

2026-11-13 用户确认中文搜索结果v1并授权归档。确认PNG原样位于 `exports/search-results/zh-Hans/20261113/AppStore-search-zh-Hans-3840x2560.png`，源素材、提示词、字体、可编辑排版、缩略及离线安全区截取位于 `exports/search-results/source/20261113-zh-Hans-v1/`，源排版重建输出定向至独立rebuild-preview以保护确认成品。单图直接供上传，无ZIP；3840×2560px RGB无Alpha，候选与归档逐字节相同，尺寸/模式/哈希读回和源清单复核通过。本条替代上方搜索图待确认状态；尚未上传或后台跨设备预览，英文搜索图未制作。只新增搜索归档并更新本文和项目状态；App/Widget、工程、标题成品及既有截图未改，未运行Debug构建、未提交。

2026-11-13 用户授权“继续完成En的吧，标题和搜索，然后归档”。英文标题和搜索图已完成并按本次授权直接归档，替代前文英文未制作状态；不将本次授权写成用户已逐图视觉确认。标题沿用8种Widget层叠、无外部品牌/标语，日历完整为13/Nov/Fri及18/Nov/Wed；搜索图沿用左文案右手机，文案为“Good words, at a glance.”和“Daily quotes meet hand-drawn art.”。内置ImageGen本地化两份主体，英文语录沿用项目编辑译文及短摘句，不升级出版底本核验；搜索标题以Source Serif 4独立排版。英文标题位于 `exports/header/en/20261113/AppStore-header-en-3840x1646.png`，搜索图位于 `exports/search-results/en/20261113/AppStore-search-en-3840x2560.png`；各自源素材/提示词/规格或排版/缩略及离线安全区截取在相应 `source/20261113-en-v1/`，汇总清单为exports/creative-en-archives-20261113.json。两张均RGB无Alpha，尺寸/星期/英文拼写换行/安全区离线裁切已检查；搜索图片字体加载、文字溢出与标题安全边界通过，归档逐字节一致、哈希读回及源清单复核通过。既有26张确认PNG哈希不变。单图直接供用户上传，无ZIP；未上传或后台跨设备预览。只新增英文创意归档并更新本文与项目状态，App/Widget、工程、签名、版本、后台未改；未运行Debug构建、未提交。
