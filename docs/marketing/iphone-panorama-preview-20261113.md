# 中文 iPhone 四页连续宣传候选

2026-11-13；状态：已完成整组构图候选和小组件首图，等待用户视觉确认。未上传、未送审；未开始英文版本。

## 最新授权与方向

用户明确要求自由创作宣传视觉，不再使用原生渲染图拼版；四页都要精修，今日与年度册也必须有手机。参考既有新手引导的立体日历卡片、纸张和插画布局，保留平视正面 iPhone；年度册结合手机年度浏览和散落纸页。允许创作不代表修改产品内界面，也不作为实际运行截图或功能验证证据。

整张母版 4824×2622，使用一张连续朱红背景；横坐标 1206、2412、3618 等分，导出四张 1206×2622 RGB PNG。没有顶部品牌行、页码、付费/解锁说明或免费承诺。铜环不作为宣传背景装饰；今日页依最新引导图参考，在卡片上保留单个小铜环。

| 页 | 主标题 | 副标题 |
|---|---|---|
| 小组件 | 让每次点亮，都有好句子 | 每日语录，遇见手绘之美 |
| 今日 | 非凡时光，是平凡坚守，终凝不凡力量 | 翻阅手绘日历，读懂语录背后的故事 |
| 年度册 | 一年的好句子，慢慢品读 | 浏览全年日历，重温经典，指引当下 |
| 壁纸工坊 | 把红色薪火，留在屏幕上 | 挑选心仪作品，制作你的手绘壁纸 |

## 构图

- 小组件：正面手机、蓝绿山景桌面、群像语录主卡、少女阅读小卡和横向阅读语录卡；重新设计配色、卡片、阴影与插画。
- 今日：正面手机、叠层日历与语录详解双卡，借鉴新手引导构图；出处标题已修正为《中国革命战争的战略问题》，未使用未经核对的卷次、页码。
- 年度册：手机中的年度册浏览与前方六张纸页组合；每张包含日期、短语录和插画，保留纸页重叠与投影。
- 壁纸工坊：正面锁屏手机、两张背景画作及三联插画局部。

背景、四页主体采用内置 ImageGen 创作；主副标题使用项目思源宋体以独立排版层输出，便于后续修订和英文适配。完整提示词保存在候选目录 prompts.json；产品内原资源没有被覆盖。

## 候选文件

工作目录：`/Users/ideabox/.cache/MaoStyleCalendar/store-marketing-20261113/candidates/panorama-creative-v1/`。

- `four-page-preview.png`：整组缩略预览。
- `panorama-zh-master.png`：4824×2622 完整母版。
- `background-4824x2622.png`：连续底图。
- `01-widgets-zh.png`、`02-today-zh.png`、`03-yearbook-zh.png`、`04-wallpaper-zh.png`：四张等分单页。
- `layout.html`、`render.cjs`、`export-slices.py`：可复现排版及精确切分。
- `assets/`、`prompts.json`、`manifest.json`：创作主体、提示词、尺寸与哈希。

历史原生拼版保留在仓库外 `candidates/panorama-native-layout-v1/`，已废弃，不作为本轮交付。更早的独立首图也仅作历史版本。

## 阶段汇报

- 完成：四页连续背景、整组自由创作构图和首图候选；四页均有手机。
- 新增仓库文件：本文。修改：宣传 README、项目状态。候选图片、排版和源素材存仓库外，未提交大文件。
- 未修改：App、Widget、业务、原资源、工程配置、签名、Bundle ID、Team、Version、Build、App Store 后台。
- 验证：排版加载图片/字体检查通过；Pillow 检查母版 4824×2622、四图 1206×2622、RGB 无 Alpha；逐像素验证每张等于母版对应切片，全部通过。已目视检查整组、首图和最终今日卡片；主副标题核对完成。
- Debug：工作区 App 未修改、未重建。中途曾运行仓库外采集工程 Debug 构建成功；最终自由创作版不使用那批原生渲染图。
- Git：保持既有整体未跟踪状态；无新增构建、签名或秘密文件进入仓库。
- 待确认：整组视觉与首图；本阶段无导出阻塞，待用户确认后再深化/本地化，不主动进入上传或发布。

## 用户确认与中文成品导出

2026-11-13 用户明确“可以，没问题”，确认本版中文视觉。四张成品已原样归档至 `docs/marketing/exports/iphone/zh-Hans/20261113/`，并打包 `AppStore-iPhone-zh-Hans-4screenshots.zip`。重新验证四张尺寸、RGB、SHA-256 与 ZIP 完整性通过。仅归档确认稿，不更改设计、App、工程或后台；没有上传/送审，英文版尚未制作。

2026-11-13 按用户要求按设备归档：iPhone 成品位于 `docs/marketing/exports/iphone/zh-Hans/20261113/`；连续母版、底图、主体素材、提示词、字体和排版源文件位于 `docs/marketing/exports/iphone/source/20261113/`。排版字体引用改为随归档的相对路径。iPad、DUO 独立目录仅登记待制作。未改动已确认图片。

2026-11-13 英文 iPhone 四页候选完成，与 DUO/iPad 共12张统一交验。iPhone 单张1206×2622px，标题独立以 Source Serif 4 排版，三张主体用内置 ImageGen 本地化正文，壁纸主体保留无中文原图。候选位于 `/Users/ideabox/.cache/MaoStyleCalendar/store-marketing-20261113/candidates/en-all-devices-v1/iphone/`，统一原尺寸验收入口为 `/Users/ideabox/.cache/MaoStyleCalendar/store-marketing-20261113/candidates/en-all-devices-v1/index.html`。尺寸/RGB/切片/哈希通过，主体及整组已目视检查，中文成品不变；等待视觉确认，未归档打包上传。

2026-11-13 用户确认三设备全部英文稿并授权归档。iPhone英文四张确认成品原样归档至 [exports/iphone/en/20261113/](exports/iphone/en/20261113/)，[英文四图ZIP](exports/iphone/en/20261113/AppStore-iPhone-en-4screenshots.zip)已准备；完整源素材、字体、提示词及排版在 [exports/iphone/source/20261113-en/](exports/iphone/source/20261113-en/)。1206×2622px RGB，无Alpha，成品与候选逐字节一致、切片和哈希及ZIP校验通过，中文成品未变。未上传、未提交，未运行Debug构建；本条替代上方英文待确认状态。
