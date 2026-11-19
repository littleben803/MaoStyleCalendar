# 仓库结构与维护说明

更新：2026-11-09。本文是当前目录结构的维护入口；工程启动历史和验证记录见 [native-startup.md](native-startup.md)。

## 目录树

```text
MaoStyleCalendar/
├── AGENTS.md                           # 项目规范与协作边界
├── .gitignore                          # 构建缓存、用户态文件忽略规则
├── ios-client/                         # Apple 客户端，包含 iOS/iPadOS/macOS
│   ├── README.md                       # Apple 工程入口
│   ├── Scripts/verify_english_editorial.py # 英文候选覆盖与中文源漂移校验
│   ├── Scripts/verify_release_bundle.py # 实际 Release 包资源、字体与 Debug 标识校验
│   ├── MaoStyleCalendar.xcodeproj/
│   │   ├── project.pbxproj             # 四个 targets、配置与资源引用
│   │   └── xcshareddata/xcschemes/      # iOS、macOS 共享 schemes
│   ├── Native/
│   │   ├── App/
│   │   │   ├── MaoStyleCalendarApp.swift # 两平台共用 SwiftUI App 入口
│   │   │   ├── StartupView.swift       # App 根入口
│   │   │   ├── RootTabView.swift       # 紧凑四 Tab 与宽屏 Sidebar
│   │   │   └── TodayView.swift         # 今日正面、换日与翻转详解里程碑
│   │   ├── App/ArtworkPage.swift       # 365 套插画共用的整页版式
│   │   ├── App/DailyArtworkCatalog.swift # iOS Debug App 图片缓存
│   │   ├── Resources/DailyArtwork/   # 365 张优化 JPG backgrounds/＋content-packs.json；Release 排除
│   │   ├── Resources/Legal/          # 三份协议的中英本地 HTML，仅 App targets 打包
│   │   ├── Shared/
│   │   │   ├── DailyArtworkLibrary.swift # iOS Debug App/Widget 共用 365 套候选及年度分配
│   │   │   ├── ArtworkWidgetView.swift # iOS Debug 各 Widget Family 素材布局
│   │   │   └── CalendarTypography.swift # App/Widget 共用字体注册与角色
│   │   ├── Widget/
│   │   │   └── CalendarWidgets.swift   # 确定性时间线与各主屏/锁屏 Family 独立布局
│   │   └── Configuration/
│   │       ├── App-Info.plist
│   │       ├── Widget-Info.plist
│   │       └── Shared.entitlements     # 四 target 共用 App Group
│   └── Packages/CalendarCore/
│       ├── Package.swift               # 本地 Swift Package，无第三方依赖
│       ├── README.md
│       ├── Sources/CalendarCore/
│       │   ├── CalendarDate.swift      # 公历日期、校验、时区转换
│       │   ├── AnnualContentAllocator.swift # 年度洗牌与闰日规则
│       │   └── Settings/               # 语言与桌面小组件显示偏好
│       └── Tests/CalendarCoreTests/    # 年度、Mock 内容与日期路由 XCTest
├── android-client/
│   └── README.md                       # Android 预留入口，尚无工程
└── docs/                               # 跨平台公共文档与设计交付
    ├── README.md                       # 文档索引
    ├── project-status.md               # 项目决定、状态与风险
    ├── engineering/                    # 工程方案、结构、验证记录
    ├── design/handoff/v2/              # 当前有效设计交付
    │   ├── approved/                   # 已确认高保真原稿
    │   ├── boards/                     # 原稿汇总图
    │   ├── fonts/                      # 五角色真实字库
    │   ├── licenses/                   # 字体 OFL 许可
    │   ├── specs/                      # 字体角色与设计规范
    │   ├── resources/                  # 装饰/图标候选；App targets 内部接入，仍非正式批准资源
    │   ├── scripts/                    # 设计归档、字体核验工具
    │   └── manifest.json               # 归档文件校验清单
    ├── product/                        # 产品形态、分配规则与交互
    ├── research/                       # 竞品、字体和引文核验
    └── assets/                         # 插画交付与授权规范
```

树形图聚焦当前工程及维护入口，不枚举设计历史、全部研究文件和被忽略的构建缓存。v1 设计仍保留作历史记录，不是实现基线。

## 模块职责与依赖

2026-11-12：`Native/Resources/DailyArtwork/english-editorial.json` 随现有 Debug 文件夹资源打包，含 365 套英文卡面及 1,085 个详解 Section，状态为 candidate / project_editorial。Release 沿用整个 DailyArtwork 的排除规则。`Scripts/verify_english_editorial.py` 仅使用 Python 标准库，校验覆盖、段落对应和中文 SHA-256，不负责批准出版引文。

| 模块 / target | 职责及边界 |
| --- | --- |
| MaoStyleCalendar-iOS | iPhone/iPad 主 App，最低 iOS/iPadOS 17 |
| CalendarWidget-iOS | 主屏和锁屏组件，最低 iOS/iPadOS 17 |
| MaoStyleCalendar-macOS | 原生 Mac App，最低 macOS 14，非 Catalyst |
| CalendarWidget-macOS | Mac 桌面组件，最低 macOS 14 |
| Native/Shared | 五角色字体加载及 iOS Debug 素材目录／Widget 渲染；App/Widget 分别编译共享代码 |
| CalendarCore | 不依赖 SwiftUI；负责民用日期、年度确定性分配、Mock 内容与桌面小组件偏好 |
| android-client | 后续 Android App、组件及测试；本阶段仅预留目录 |
| docs | 两平台共享的产品、内容、授权与视觉依据 |

App 与 Widget 分别依赖本地 CalendarCore。iOS 与 Mac 使用独立 targets，共享 SwiftUI 源文件；Widget 独立运行，不依赖主 App 进程。桌面小组件显示偏好通过同设备 App Group 共享；购买状态尚未建立，不能因共享源码推断为已跨进程同步。

CalendarCore 当前是 Swift 实现，Android 不直接依赖该包。后续 Android 必须遵循公共年度分配规范和固定回归样例，保证两平台同日期内容一致；本阶段不引入跨平台框架或新增依赖。

## 路径与资源约定

- Apple 工程、源码、Info.plist、Swift Package 和其测试统一置于 `ios-client/`；Android 实现置于 `android-client/`。
- 公共设计稿、字体许可和内容审核资料保留根目录 `docs/`，避免两平台各自维护一份不同版本。
- `docs/design/handoff/v2/resources/` 为候选准备包；阶段 2 已将装饰和图标 Asset Catalog 接入 iOS/macOS App targets 作内部视觉还原，Widget 未接入。Candidate 不等于视觉批准，完整状态见 `docs/assets/v2-resource-readiness.md`。
- Xcode `SOURCE_ROOT` 为 `ios-client/`，源码和 Info.plist 仍用 `Native/...`，本地包仍用 `Packages/CalendarCore`；公共字体和许可引用改为 `../docs/design/handoff/v2/...`。
- 共享 scheme 的 `ReferencedContainer` 仍指向同目录的 `MaoStyleCalendar.xcodeproj`，无需加 `ios-client/` 前缀。
- 全年 365 套优化资源固定放在 `ios-client/Native/Resources/DailyArtwork/backgrounds/`，配对与版式数据在同目录的 `content-packs.json`。当前均为待内容核验候选，供 iOS Debug 今日页、年度册、壁纸与 Widget 共用；母版和提示词留在仓库外 `/Users/ideabox/Desktop/毛选资源制作/`。不要把优化 JPG、设计母版与发布批准混为一谈。
- 不改变 Bundle ID、Team、部署版本、版本号、target 组成或业务行为；仅迁移目录并修正引用。
- 构建产物与缓存不提交 Git。迁移后可使用仓库外的新 DerivedData / SwiftPM scratch 路径，避免旧绝对路径缓存影响构建。

2026-11-05：新增 iOS Debug 插画试制入口与 `Native/Resources/ArtworkTrials/` 文件夹资源。图片直接保持 JPG 编码，Release 明确排除；未将扫描母版、历史候选或构建证据放入仓库。详细范围与实机证据见 [10 张试制接入记录](../assets/ten-image-trial-integration.md)。

## 常用验证命令

以下命令均从仓库根目录执行：

```sh
xcodebuild -list -project ios-client/MaoStyleCalendar.xcodeproj
swift test --package-path ios-client/Packages/CalendarCore --scratch-path /Users/ideabox/.cache/MaoStyleCalendar/CalendarCore-relocated
xcodebuild -project ios-client/MaoStyleCalendar.xcodeproj -scheme MaoStyleCalendar-iOS -configuration Debug -destination 'generic/platform=iOS Simulator' -derivedDataPath /Users/ideabox/.cache/MaoStyleCalendar/DerivedData-relocated-iOS CODE_SIGNING_ALLOWED=NO build
xcodebuild -project ios-client/MaoStyleCalendar.xcodeproj -scheme MaoStyleCalendar-macOS -configuration Debug -destination 'generic/platform=macOS' -derivedDataPath /Users/ideabox/.cache/MaoStyleCalendar/DerivedData-relocated-macOS CODE_SIGNING_ALLOWED=NO build
plutil -lint ios-client/MaoStyleCalendar.xcodeproj/project.pbxproj ios-client/Native/Configuration/App-Info.plist ios-client/Native/Configuration/Widget-Info.plist ios-client/Native/Configuration/Shared.entitlements
git diff --check
git status --short
```

`/Users/ideabox/.cache/...` 为本机缓存目录，其他开发者应替换为自己的绝对路径；不影响工程可迁移性。日常开发也可直接打开 `ios-client/MaoStyleCalendar.xcodeproj`，选择对应 App scheme。

## 本次迁移验收

2026-10-30：使用仓库外缓存路径，两平台 App 及嵌入 Widget 的无签名 Debug 构建通过；当轮 CalendarCore 测试全部通过；工程列表正确解析四个 targets 和移动后的本地包。四个产物的五字体、三许可证与公共归档逐文件 SHA-256 比对一致，产物最低系统仍为 iOS 17 / macOS 14。工程、Info.plist、entitlements 语法检查及 `git diff --check` 通过。

根目录旧的 Native、Packages 与 Xcode 工程目录已迁走；源码内容未改，资源母版未改。本阶段未重新执行 UI 运行验收，未新增业务能力或 Android 实现。Git 仍处于首次提交前的未跟踪状态，没有生成物进入待跟踪文件列表。

2026-11-06：1 月 31 套已接入常规今日页，旧试制渲染抽为共用页面；Release 继续排除 DailyArtwork 与 ArtworkTrials。现有纸纹／铜环在 DecorCandidates.xcassets，图标在 IconCandidates.xcassets，均仍位于 docs/design/handoff/v2/resources，由工程直接引用，本轮未迁移。年度册、Widget、壁纸工坊未换资源，年度算法未改。详见 [1 月工程接入记录](../assets/january-engineering-integration.md)。

2026-11-06：年度册与壁纸接入现有31套；新增 Native/App/ArtworkWallpaperCanvas.swift，预览／导出共用安全矩形与两种内容模式。RootTabView内的AppCatalog统一页面取数；图片和配对JSON仍在原DailyArtwork目录，未新增位图或移动装饰。细节见 [年度册与壁纸接入](../assets/yearbook-wallpaper-integration.md)。

2026-11-06：31 套目录与模型移至 Shared/DailyArtworkLibrary.swift，App 保留图片缓存；Shared/ArtworkWidgetView.swift 同时供真实扩展和 App/WidgetArtworkQA.swift 预览使用。iOS Widget 加入既有资源引用及 Release 排除，普通 iPhone 先验收，其他平台专项仍后置。详见 [Widget 素材接入](../assets/widget-artwork-integration.md)。

2026-11-06 全年扩容：DailyArtwork 扩至 365 套，复用正式年度分配器版本 1；App 和 iOS Widget 共用候选目录。其余平台、工程配置、原扫描和字体均未修改，母版／提示词／验证产物继续留在仓库外。详见 [全年接入记录](../assets/full-year-artwork-integration.md)。


### 2026-11-13 Firebase Analytics

`Native/App/AppAnalytics.swift` 封装主 App 行为统计。仅 iOS target 链接 SPM `FirebaseAnalyticsCore`；Mac 编译同一封装但为空实现。`Native/Configuration/GoogleService-Info.plist` 仅打包 iOS App，由开发机/CI 本地提供，Git 忽略。未给 Widget 或 CalendarCore 添加 Firebase。事件与验收记录见 [Firebase Analytics](firebase-analytics.md)。

2026-11-13：按用户授权将已验收的 DailyArtwork、OnboardingPreview 及对应 iOS 体验接入 Release；上文 2026-11-12 的整目录排除为历史状态，不再适用。英文编辑分类和源校验记录不变。详见 [Release 接入记录](release-feature-promotion.md)。
