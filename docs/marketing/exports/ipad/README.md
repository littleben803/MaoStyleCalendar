# iPad App Store 宣传材料

2026-11-13：用户确认中文四页竖版 v1 并授权归档；成品和源素材已归档、已打包，待用户自行上传。英文已确认并归档，见下方。

规格依据用户提供的 App Store Connect 13 英寸 iPad 截图栏：支持 2048×2732、2064×2752 及对应横版。本组选择每张 **2064×2752px 竖版**、RGB 无 Alpha，连续母版 8256×2752px。截图规格与 App 预览视频规格分别处理。

候选工作目录：`/Users/ideabox/.cache/MaoStyleCalendar/store-marketing-20261113/candidates/ipad-preview-v1/`。`source/` 保存四页主体、提示词、字体、连续背景、完整母版、四页缩略预览与可编辑排版；`screenshots/` 保存四张独立 PNG 与哈希 manifest。

顺序与文案沿用用户已确认的中文宣传：小组件、今日、年度册、壁纸工坊；单一连续红底。内置 ImageGen 为 iPad 独立制作四页主体，参考已有 iPad 引导素材的机身和既有宣传的纸页/插画语言，没有将 iPhone/DUO 图机械放大作为 iPad 成品。设备为正面竖向平板、对称圆角与横向状态栏；首图两张辅助 Widget 作为前景样式示意，今日页大设备居中、竖长双卡叠放；年度册利用平板宽度改为三列；壁纸页含平板与画作图库。

本组为功能宣传示意，不记为真实运行截图、iPad 功能专项验收或既有插画/内容商业授权状态升级。本轮已获用户视觉确认并按语言/日期归档；本次确认不替代实际运行验证或商业授权审计。

验证：node 渲染检查图片/字体加载；Pillow 复核四张 2064×2752px、RGB、与母版逐像素切片一致、SHA-256；已目视核对四个主体及整组预览。仅更新本文、宣传索引与项目状态，新候选在仓库外；App/Widget、iPhone/DUO 已确认成品、工程、签名、版本、后台均未修改。纯素材阶段未运行 Debug 构建，未提交或上传。

## 已确认成品与上传包

2026-11-13 用户明确“可以，归档吧，然后我上传”。四张成品原样归档至 [zh-Hans/20261113/](zh-Hans/20261113/)，[下载四图 ZIP](zh-Hans/20261113/AppStore-iPad-zh-Hans-4screenshots.zip)。ZIP 仅含以下四张独立 PNG，按前缀顺序上传：

1. [小组件](zh-Hans/20261113/01-widgets-ipad-zh.png)
2. [今日](zh-Hans/20261113/02-today-ipad-zh.png)
3. [年度册](zh-Hans/20261113/03-yearbook-ipad-zh.png)
4. [壁纸工坊](zh-Hans/20261113/04-wallpaper-ipad-zh.png)

每张 2064×2752px 竖版 RGB、无 Alpha。成品与确认候选逐字节相同；尺寸、母版精确切片、SHA-256、ZIP 完整性及解压内容哈希全部通过。成品与 ZIP 校验值见同目录 manifest.json。

母版、底图、主体、字体、完整提示词和排版源文件归档至 [source/20261113/](source/20261113/)，源文件哈希见 archive-manifest.json，已读回复核。导出路径调整为相邻成品目录，成品像素未改。

本阶段新增本设备成品与源素材归档，更新本文、宣传索引与项目状态；App/Widget、iPhone/DUO 成品、工程、签名、版本与后台均未修改。纯素材归档未运行 Debug 构建，未提交、未上传；用户自行上传。

## 英文候选（待视觉确认）

2026-11-13 本设备英文四张已制作，工作目录 `/Users/ideabox/.cache/MaoStyleCalendar/store-marketing-20261113/candidates/en-all-devices-v1/ipad/`；与另外两种设备共12张统一验收。保留中文已确认构图和本设备尺寸；英文标题、日期、月份与卡片正文完成本地化，壁纸主体无中文故原样复用。全部尺寸、RGB、精确切片和哈希检查通过，已目视检查；未归档、打包或上传。全组入口：`/Users/ideabox/.cache/MaoStyleCalendar/store-marketing-20261113/candidates/en-all-devices-v1/index.html`。既有中文成品逐字节未改。

## 英文确认成品（已归档）

2026-11-13 用户确认全部英文宣传并授权归档，覆盖上方英文待确认状态。四张原样成品在 [en/20261113/](en/20261113/)，[下载英文四图 ZIP](en/20261113/AppStore-iPad-en-4screenshots.zip)；源素材、提示词、字体和排版在 [source/20261113-en/](source/20261113-en/)。ZIP仅含四张PNG，顺序小组件、今日、年度册、壁纸工坊。尺寸/RGB/切片/哈希、ZIP完整性及解压哈希、源清单读回通过；中文成品不变，未上传、未提交，App/工程未改，未运行Debug构建。
