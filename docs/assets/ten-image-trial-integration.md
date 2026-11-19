# 10 张压缩插画真机试制

日期：2026-11-05；确认更新：2026-11-06。状态：用户已确认试制方向、压缩观感及日期排版；月度推进清单待确认。

## 用户确认与后续归档（2026-11-06）

用户在最新日期排版真机结果后确认“没什么问题，就按照这个方案推进”，要求先将方案归档到 docs，列出按扫描来源月份推进的清单，等待确认后执行。该确认覆盖试制的视觉／制作方向，不代表正式语录、授权或 Release 审核完成，也不将手动保存／设为系统壁纸等未单独验证的步骤记为完成。

后续制作规范见[清洗与内容制作方案](scan-cleanup-production-plan.md)，执行状态统一维护在[按月推进清单](scan-cleanup-monthly-checklist.md)。来源月份仅作制作批次，最终内容包与日期解绑。本轮归档没有开始新的清洗或扩大 Debug 资源池。

## 目标与边界

使用本轮 10 张压缩候选，在真实 iPhone 中检查图片清晰度、纸面、横竖排语录、红底配色及壁纸输出。新增独立的 Debug 试制入口，复用今日卡片容器；不替换年度 365 套 Mock 数据，不改年度分配、Widget 或正式默认路径。

用户已允许依据扫描稿重绘、延展和二次创作，重点是水墨风格统一、人物与景物完整；不要求精确恢复被文字或日期色条遮挡的原画。此授权只适用于这批资源制作，不等于引文核验、插画商业授权或 Release 批准。

## 入口与使用

Debug App：今日 → 设置 → 调试 → **10 张插画试制**。

- 左右滑动或点箭头浏览 10 张；日期来自当前系统日期，与图片不建立固定日期关系。
- 点击卡片查看摘录与待核验说明。
- “壁纸预览与导出”提供原稿语录排版与仅插画两种试制模式，不显示日期；通过系统分享表交付 JPG。
- 完成后返回原 App；此入口没有更换正式今日页、年度册或壁纸工坊的数据源。

## 资源与排版

资源目录：`ios-client/Native/Resources/ArtworkTrials/`，10 张 `pack-0001.jpg` 至 `pack-0010.jpg`，以及 `samples.json`。

图片直接复制自用户已选择的压缩候选，均为 1024×1536、sRGB、渐进式 JPEG；单张 183,943～198,795 字节，合计 1,941,753 字节。使用文件夹资源引用，避免 Asset Catalog 重新编码 JPEG。原扫描、无损母版及制作历史继续保留在仓库外，没有复制到工程。

`samples.json` 记录稳定内容 ID、文件名、原图与成品校验值、候选状态、逐行／逐列内容、阅读顺序、位置、间距、日期位置、文字颜色及纸面取色。试制 `DailyContentPack` 使用独立的 `trial-` ID，`reviewStatus` 与插画状态始终为 `candidate`；不加入年度分配器或正式 Repository。

纸面取色来自每张背景顶部无字区域，仅用于容器边缘及壁纸纸面延展。卡片中图片区域保持完整 2:3，文字使用项目真实字体独立渲染。完整插画中不增加用于文字留白的抹除／淡化区。

04 号使用完整重绘修订版；09、10 号使用去除底部红／黑日期条后的延展重绘版。04 号“定要将”照录原稿；08 号首字“为”属于打孔遮挡后的暂补，均保留待核验说明。

## 壁纸输出

只针对试制内容增加 JPG 导出分支。普通 Mock 壁纸的既有 PNG 输出保持原样。

试制输出按当前设备原生纵向像素与比例合成，宽度不超过 1440、长边不超过 3200。完整 2:3 画面按宽度放在底部，上方延展同色纸面；淡入仅作用于画面顶部 6% 的空纸区域，不淡化人物。日期不进入壁纸，语录保持源稿分行分列，附“试制 · 出处待核验”标记。JPG 编码质量 0.85，不新增照片权限或直接写入照片图库。

## Release 隔离

试制类型、入口、启动参数与导出分支均受 `DEBUG && os(iOS)` 或所属 iOS 文件的 `DEBUG` 限定。工程仅向 iOS App 增加一份 Swift 源码和一个资源文件夹引用，并在 iOS App Release 配置排除 `ArtworkTrials`。没有修改签名、Team、Bundle ID、Version、Build、部署版本、target 组成、依赖或 App Store 配置。

Release Simulator 实际构建后已检查 `.app`：没有 `ArtworkTrials` 文件夹或 `pack-*.jpg`。此检查只证明本轮试制资源被排除，不代表项目原有 Mock Release 内容已完成发布准入审核。

## 验证结果

- iPhone 17 Pro Max，iOS 26.5.2：使用既有签名配置构建、安装并启动成功。
- 全部 10 张已在真机启动对应页面并捕获 1320×2868 屏幕截图。检查总览及横排、长竖排、红底等完整截图；没有把离线合成图当作实机截图。
- 真机通过同一 `WallpaperExporter` 实际生成 10 张 JPG，逐文件检查均为 1320×2868，574,670～775,853 字节。该验证证明设备上的渲染与文件生成；通过系统分享表手动保存、设为系统壁纸的最终操作留给用户体验确认。
- 核心 Swift Package：28 项测试通过，0 失败；没有修改其代码或测试。
- iOS Simulator Debug、真机签名 Debug、Simulator Release 构建通过；Release 中未发现试制资源。
- Debug bundle 中的 10 张 JPG 与压缩源逐文件 SHA-256 一致。全部 365 张原 PNG 与清洗前记录的校验值一致。
- 工程各配置的签名、Team、Bundle ID、版本字段与修改前逐项比较一致。
- `plutil -lint`、`git diff --check`、资源数量与尺寸检查通过；仓库仍处于原有整体未跟踪状态，没有新增异常构建产物。

验证命令包括：

```sh
swift test --package-path ios-client/Packages/CalendarCore --scratch-path /Users/ideabox/.cache/MaoStyleCalendar/artwork-trial-20261105/CoreTests
xcodebuild -project ios-client/MaoStyleCalendar.xcodeproj -scheme MaoStyleCalendar-iOS -configuration Debug -destination 'generic/platform=iOS Simulator' -derivedDataPath /Users/ideabox/.cache/MaoStyleCalendar/artwork-trial-20261105/DebugSimulator CODE_SIGNING_ALLOWED=NO build
xcodebuild -project ios-client/MaoStyleCalendar.xcodeproj -scheme MaoStyleCalendar-iOS -configuration Release -destination 'generic/platform=iOS Simulator' -derivedDataPath /Users/ideabox/.cache/MaoStyleCalendar/artwork-trial-20261105/ReleaseSimulator CODE_SIGNING_ALLOWED=NO build
plutil -lint ios-client/MaoStyleCalendar.xcodeproj/project.pbxproj
git diff --check
git status --short
```

真机使用 `xcodebuild -destination` 选择已连接设备，再通过 `devicectl device install app`、`device process launch`、`device capture screenshot` 和 `device copy from` 验证。没有使用允许在线 provisioning 更新的构建参数，没有读取或导出签名资产。

证据保存在仓库外 `/Users/ideabox/.cache/MaoStyleCalendar/artwork-trial-20261105/`：`device-card-01.png` 至 `device-card-10.png`、`device-overview.jpg`、`device-wallpapers-final/`、`validation.json` 与构建日志。

## 日期信息迭代（2026-11-05）

用户确认试制后，要求月份、年份和星期增大两号，月份与“年份＋星期”统一左／右对齐，并在下一行增加同字号干支年农历。仅修改试制页日期模板：月份在原模板基准字号上增加 2pt；年份／星期合为一行并使用统一增大字号；农历与该行同字号。顶部模板三行右对齐，底部模板三行左对齐。底部紧凑模板将文字块与大日号拉开；日号字号、语录、背景及壁纸输出保持原样。

农历根据卡片公历年月日、当前时区的本地正午计算，显示如“丙午年 九月廿七”，包含闰月。干支年按农历春节换年；“丁未”的“未”不写为“末”。没有将示例农历写死，也未使用机器翻译或网络请求。

本轮无新增仓库文件；修改 `ArtworkTrialGallery.swift` 与两份记录文档。直接提取生产 formatter，6 个日期 × 上海／洛杉矶／檀香山 3 个时区的 18 项核验通过，覆盖春节前后、干支年变化与闰二月。真机签名 Debug 构建、安装与 10 张截图检查完成；图片 SHA-256 未变。构建、核验脚本与截图位于仓库外 `/Users/ideabox/.cache/MaoStyleCalendar/trial-date-20261105/`。大字号与其他平台未扩展专项验收，待用户确认本轮日期视觉。

## 文件改动与下一阶段

新增：`ArtworkTrialGallery.swift`、10 张压缩 JPG、`samples.json`、本文档。

修改：`TodayView.swift`（抽出原卡片并增加显式试制 ID 分支）、`AppSettingsView.swift`（Debug 入口）、`StartupView.swift`（只供调试启动的试制页参数）、`iOSShareAndWallpaperExport.swift`（试制 JPG 分支）、工程引用与 Release 排除规则，以及结构／状态文档。

未修改：`CalendarCore`、年度算法、普通内容 Repository、Widget、原有默认 App 页面行为、原扫描与字体、签名和版本字段、Duo/iPad/Mac 专项布局。

当前待办：用户确认按月推进清单，以及后续的系统壁纸实际使用、正式引文和授权审核；辅助功能大字号与其他平台未作本轮专项验收。10 张试制方向与日期排版已于 2026-11-06 获用户确认，不再重复列为待确认；不据此直接替换正式默认路径。
