# 全年扫描清洗与普通 iPhone 接入

日期：2026-11-06。状态：候选资源制作与工程接入，等待用户一次普通 iPhone 实机验收；不代表正式内容获准发布。

## 最新授权与边界

用户要求连续完成剩余 11 个月、归档资源并接入所有现有功能（包括 Widget），最后统一实机验证。这替代此前“暂缓 2 月／先验收 31 套／逐月等待确认”的推进限制。来源月份只用于制作和追溯，不作为成品日期映射。

本轮仅普通 iPhone iOS Debug：今日及翻转详解、年度册、壁纸两模式及导出、主屏／锁屏 Widget 共用全年目录。保留原扫描、1 月已确认数据、稳定 ID、现有字体、正式年度算法和所有签名／工程配置。没有新增依赖、网络请求、权限、StoreKit、账号或其他平台适配。

## 归档与资源

- 只读原扫描：`/Users/ideabox/Desktop/毛选/`，12 个月共 365 PNG。
- 无损母版、逐图提示词、历史候选、来源和校验记录：`/Users/ideabox/Desktop/毛选资源制作/`。
- 分月归档：`batches/source-month-02` 至 `source-month-12`，各自包含有效母版／修订、`sources.json` 和 `metadata/content-packs.json`。复用背景通过 `artwork_reference` 与 `master_path` 指向唯一有效母版；不重复复制无损母版。
- 优化交付：制作根目录 `app-assets/`，以及工程 `ios-client/Native/Resources/DailyArtwork/backgrounds/`＋`content-packs.json`。
- 每套保持独立语录、原分行／分列、配色和稳定 ID；原稿本身存在跨月重复插画，不能把 365 套描述成 365 张不同的新绘图。
- JPG 均为 1024×1536、sRGB、渐进编码，单张不超过 200,000 字节；无损母版和原扫描没有放入仓库。
- `registry/full-year-production.json`、`full-year-export-metrics.json`、`full-year-audit.json` 记录当前有效路径与 SHA-256；`review-inventory/` 保存背景、原扫描配对和实际 SwiftUI 叠字检查图。修订采用新版本，不覆盖旧候选。

## 工程行为

完整 365 套接入 App／Widget 共用的 `DailyArtworkCatalog`，移除旧 31 套循环。直接复用既有 `AnnualContentAllocator` 的版本 1：同一年确定性洗牌，App／Widget／年度册一致，365 套年内各出现一次。

日期、月份、年份、星期和农历仍运行时渲染，背景没有烘焙文本。正文背面明确显示“扫描摘录：篇名、卷次、页码与英文对应尚待核验”，没有新增虚构出处、英译或解读。

2 月 29 日继续使用 `mock-leap-day-001` 专属占位，不挪用基础池内容填补。2028 年可浏览 366 天，但只有 365 套扫描插画；额外闰日正式素材仍未交付。

长语录按逐图版式避开头脸与打孔。少数背景另做留白构图修订，并按原扫描重新核对人物与场景。Widget 每套记录独立插画裁切区和背景窗口参数，避免把高位人物切头或把语录覆盖到脸上；1 月既有参数和画面保留。

## 内容与发布限制

全部保持 `candidate`，Debug App 与 Widget 共用候选，Release 继续排除 `DailyArtwork` 和 `ArtworkTrials`。扫描转录不是底本核验；有打孔遮字、原印疑字的条目保留 notes。中文底本、英文对应、语境和设计师商业授权继续待办，不能据本轮清洗完成将状态升级为 `approved`。

实机验收由用户统一执行；模拟器批量渲染不能代替实际桌面／锁屏／StandBy、系统壁纸设置、Widget 刷新和用户视觉接受。

## 文件变更

新增：334 张优化 JPG、本记录。

修改：`DailyArtwork/content-packs.json`；`Native/Shared/DailyArtworkLibrary.swift`、`ArtworkWidgetView.swift`；`Native/App/TodayView.swift`、`RootTabView.swift`、`DailyArtworkQA.swift`、`WidgetArtworkQA.swift`；文档索引、项目状态、月度清单和仓库结构说明。

未修改：原扫描、1 月 31 张 JPG 和配对／版式、旧试制文件、字体、Core 分配器、App Group、工程配置、签名、Bundle ID、Team、Version、Build、商店配置及其他平台代码。QA 仅通过显式启动参数运行，扩容后逐次让出执行机会，避免长时间阻塞界面。

## 一次实机验收

1. 从 Xcode 运行普通 iPhone 的 Debug：今日左右换日、翻转详解／关闭、长正文滚动；确认日期／语录／插画配对。
2. 年度册浏览不同月份并打开卡片，和今日同日期对照。
3. 壁纸浏览全年，切换“原稿排版／仅插画”，导出后检查分辨率与系统锁屏时间留白。
4. 桌面 Small／Medium／Large／设备支持的纵向大组件，实际锁屏圆形／矩形／单行及 StandBy；检查同日一致、人物裁切、中文长句省略和点击打开对应日期。
5. 设置中的 Debug“Widget 素材预览”可遍历 365 套。日期不再绑定扫描上的 2027 年和旧日期；2 月 29 日占位不计为正式插画验收。

构建与验证结果见下方最终检查记录。


## 最终检查记录

- 365 套齐全：2—12 月新增工程 JPG 334 张；133 个插画场景引用，部分为相同原图的留白构图修订。优化背景共 71,540,569 字节，最大单张 199,947 字节。
- 原扫描 365 张逐文件 SHA-256 与登记基线一致；1 月 31 条完整 JSON 记录和图片保持不变。全部 365 套仍为 candidate。
- 133 个不同有效优化背景完成 Vision OCR，检出文字项 0；这仅辅助检查残留文字，不替代画面复核。跨月复用按原扫描逐对检查，原图误配已纠正。
- 实际 SwiftUI 生成 365 张卡片、730 张壁纸；完成全年卡片总览与问题项细看，四种壁纸安全矩形检查通过。2026 年 365 项、2028 年 366 项，其中 365 个基础 ID 各一次，与既有年度分配器逐日一致。
- iOS 26.5 共 2,555 张 Widget 视图（365×7），iOS 27.2 共 2,920 张（365×8，含纵向大组件）；全量文件生成、配对和几何检查通过，重点复核各尺寸的高位人物、群像、红底与长语录。Extra Large 仅作为既有布局参考，不表示 iPad 或 Mac 已验收。
- 两版 Widget 的当日 ID 均为 `pack-0024`。模拟器和设备无签名 Debug App 及嵌入扩展，共四个 bundle 的 JSON 与 365 张 JPG 均与工程逐文件一致。
- 普通 iPhone 模拟器 Debug、generic iOS 设备 Debug、模拟器 Release 构建通过；Release App／Widget 均无 DailyArtwork／ArtworkTrials 候选文件夹。设备 Debug 构建成功不代表已经签名、安装或在真机运行。
- CalendarCore 28 项测试全部通过。Core 实现未修改。
- 实际渲染与报告已另存制作根目录 `review-runtime/cards-and-wallpapers/`、`widgets-iOS-26.5/`、`widgets-iOS-27.2/`；资源、打包及渲染审计在 `registry/full-year-audit.json`、`final-integration-audit.json`。这些生成物没有进入 Git。

验证命令（从仓库根目录执行）：

```sh
swift test --package-path ios-client/Packages/CalendarCore --scratch-path /Users/ideabox/.cache/MaoStyleCalendar/full-year-artwork-20261106/CalendarCore
xcodebuild -project ios-client/MaoStyleCalendar.xcodeproj -scheme MaoStyleCalendar-iOS -configuration Debug -destination 'generic/platform=iOS Simulator' -derivedDataPath /Users/ideabox/.cache/MaoStyleCalendar/full-year-artwork-20261106/DerivedData CODE_SIGNING_ALLOWED=NO build
xcodebuild -project ios-client/MaoStyleCalendar.xcodeproj -scheme MaoStyleCalendar-iOS -configuration Debug -destination 'generic/platform=iOS' -derivedDataPath /Users/ideabox/.cache/MaoStyleCalendar/full-year-artwork-20261106/DeviceDerivedData CODE_SIGNING_ALLOWED=NO build
xcodebuild -project ios-client/MaoStyleCalendar.xcodeproj -scheme MaoStyleCalendar-iOS -configuration Release -destination 'generic/platform=iOS Simulator' -derivedDataPath /Users/ideabox/.cache/MaoStyleCalendar/full-year-artwork-20261106/ReleaseDerivedData CODE_SIGNING_ALLOWED=NO build
```

批量运行使用 `xcrun simctl launch … com.ideaboxapps.maostylecalendar --daily-artwork-qa` 和 `--widget-artwork-qa`。辅助归档工具在仓库外 `毛选资源制作/tools/`：`audit-full-year.py`、`background-text-audit.swift`、`final-integration-audit.py`；它们验证当前资源，不是产品依赖。最后执行工程／plist 语法检查、`git diff --check` 与 `git status --short`。

本阶段制作与接入完成。未解决项为用户真机视觉与系统行为验收、正式底本／英译／授权、额外闰日内容；不继续新增其他平台或购买能力。建议下一阶段只做本次普通 iPhone 实机统一验收和必要修正。
