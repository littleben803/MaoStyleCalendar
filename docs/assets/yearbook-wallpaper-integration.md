# 现有素材接入年度册与双模式壁纸

日期：2026-11-06。状态：实现与模拟器自测完成，等待用户统一功能／视觉验收。其他月份清洗暂缓。

## 用户决定与边界

继续使用已清洗的 31 套内容，接入年度册和壁纸；全年其他月份暂时复用这个图片池，不制作新图、不补造语录。壁纸由五种样式简化为“原稿排版／仅插画”，此决定替代 2026-11-02 的五种样式方案，历史记录保留。

本轮允许修改页面取数、布局选择、壁纸合成及必要源码引用。原扫描、31 张背景、配对 JSON、今日页日期／语录坐标、CalendarCore 年度分配算法、Widget、签名、版本、权限、网络和第三方依赖均未改。只推进普通 iPhone；共享模式枚举和既有 Duo 选择入口同步为两项以保持接口一致，不构成 Duo／iPad／Mac 专项验收。

## 已实现

- `AppCatalog` 取代页面中的 MockCatalog 命名。常规 iOS Debug 年度册逐日复用 DailyArtworkCatalog 的 31 套确定性循环，与今日页同日期显示同图／同语录，公历日期、星期和农历按实际年份生成；闰年含 2 月 29 日。该审阅循环允许重复，不代表正式 365 套年内不重复分配已经改成 31 套。
- 壁纸直接浏览 31 套内容，按稳定 ID 配对，独立于日期分配。原稿排版使用工程 JSON 的横竖、分行分列、坐标与配色；仅插画隐藏语录。两者均不显示日号、月份、年份、星期、农历或铜环。
- 标题下方采用两段切换，移除底部五项缩略图；保留内容轮播、首尾循环、切换动画、导出防重入和系统分享。旧样式提示图片保留归档，不再显示，不擅自删除资源。
- 年度册新图缩略卡共用 ArtworkPageSurface。
- 预览使用设备导出画布的实际纵向比例，轮播卡根据可用高度等比缩放；导出调用同一个 WallpaperCompositionCanvas，插画尺寸与位置一致。

## 壁纸安全布局

2026-11-09 移除左右 3% 的留白。插画保持 2:3 比例并贴齐画布左右边缘，纵向中心仍在画布高度的 53% 处。上下留白随设备比例调整，超出画布的部分沿上下边缘裁切。两种模式共用 WallpaperSafeComposition 定义的插画矩形，切换仅影响语录显隐。

上下留白用于给状态栏／锁屏时钟、底部 Dock／手势区域让位；屏幕上的 App 标题、切换器、导出按钮和 Tab 栏不合成进壁纸。系统时钟大小、主屏图标及用户设置的缩放仍需实际设为壁纸后确认，本轮几何检查不冒充系统壁纸最终验收。

空白区域沿用该图纸色及顶部纯纸纹理。2026-11-09 移除预览及导出的候选水印，内部核验状态不变。

导出 JPG 采用设备纵向原生像素，上限宽 1440、长边 3200，质量 0.85。源资源仍为 1024×1536 的压缩 JPG；设备导出尺寸不意味着插画细节升为同等原生分辨率。

## 文件与工程变更

新增：`ios-client/Native/App/ArtworkWallpaperCanvas.swift`（共用安全矩形与无日期壁纸画布），本说明。

修改：`RootTabView.swift`（年度册取数、两项选择、预览比例），`iOSShareAndWallpaperExport.swift`（新图 JPG 导出），`DailyArtworkQA.swift`（跨月／跨页映射及导出验证），`ArtworkTrialGallery.swift`（旧试制调用适配新模式名），`project.pbxproj`（仅新增 iOS App 源码引用），文档索引、项目状态、结构说明及素材清单。

没有新增或修改 JPG／PNG。构建设置逐项与修改前比对完全一致；没有变更签名、Bundle ID、Team、Version／Build 或部署版本。Release 继续隔离 DailyArtwork 和 ArtworkTrials，正式内容状态不变。

## 验证与证据

证据根目录：`/Users/ideabox/.cache/MaoStyleCalendar/yearbook-wallpaper-20261106/`。

- iOS Simulator Debug、Release：`xcodebuild ... -scheme MaoStyleCalendar-iOS -configuration Debug/Release -destination 'generic/platform=iOS Simulator' ... CODE_SIGNING_ALLOWED=NO build` 成功，完整日志分别为 debug-build.log、release-build.log。
- `swift test --package-path ios-client/Packages/CalendarCore`（仓库外 scratch）：28 项通过。
- App 内 QA：2026 年 365 天、2028 年 366 天，12 个月均有内容；每一天的稳定 ID 与今日页查询一致，两年各复用全部 31 个 ID。壁纸池为 31 套、模式恰为两项。
- 使用真实导出函数生成 62 个 JPG，均为当前 iPhone 17 Pro 模拟器的 **1206×2622**，493,548～726,417 字节。此体积属于合成后的壁纸文件，不是 200 KB 的背景资源预算。报告和导出在 `runtime/report.json`、`runtime/pack-xxxx-original.jpg`／`-artworkOnly.jpg`。
- 四种几何比例检查：750×1334、1206×2622、1320×2868、1440×3200，插画矩形均满足顶部 ≥20%、底部 ≥14%、左右 ≥3% 且高度／宽度为 1.5；四个比例是布局检查，本轮没有伪称四台真机运行。
- 已观察模拟器年度册非 1 月页面显示新图、壁纸两段切换和完整预览；点击“导出高清壁纸”成功进入系统 JPG 分享表，未向第三方发送文件或新增照片权限。逐个切换按钮和最终保存／设置系统壁纸仍由用户统一验收。
- 31 张工程背景 SHA-256 与交付记录一致；Release 产物不含两个候选资源目录。`plutil -lint`、`git diff --check` 通过。Git 延续仓库整体未跟踪状态，无构建产物或母版混入。

当前真机不可连接，未做本轮真机安装和系统壁纸设置。下一步只做本轮功能、滚动／轮播手感、两种模式、导出与实际壁纸观感验收及必要微调；在用户统一确认前，不清洗新月份、不扩展其他功能或平台，也不提升内容到 Release approved。
