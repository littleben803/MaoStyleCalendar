# Firebase Analytics 接入

更新：2026-11-13。

## 范围和配置

用户授权在 iOS 主 App 接入 Firebase；随后明确要求默认开启，不新增提示、开关或设置入口。2026-11-13 追加要求：所有 Debug 相关行为不上传，统一改为仅 Release 启用；Debug 构建不初始化 Firebase，也不调用任何事件 API。仅 `MaoStyleCalendar-iOS` 链接官方 SPM `FirebaseAnalyticsCore` 13.1.1（不含 IDFA 能力）；Widget、Mac 和 CalendarCore 不引入 Firebase。

Firebase Project ID：`maostylecalendar`；iOS Bundle ID：`com.ideaboxapps.maostylecalendar`。从控制台下载的配置与两者匹配，不从之前 PDF App 复用。GA 属性 ID 和关联状态待控制台核验，不以 plist 中的 `IS_ANALYTICS_ENABLED` 单一字段推断是否关联。

本机配置位于 `ios-client/Native/Configuration/GoogleService-Info.plist`，仅 iOS 主 App 打包。它包含 Firebase 客户端 API key，已通过 `.gitignore` 排除，不打印或提交。其他开发机和 CI 需在构建前提供同名匹配配置。配置缺失/项目不匹配时初始化返回，不妨碍日历；正式交付前须核对配置已打包。

## 采集边界

Release 中 `AppAnalytics.start()` 随 App 初始化执行；Debug 中初始化、事件和页面方法均为空实现。Analytics Storage granted，Ad Storage、Ad User Data 和 Ad Personalization denied；IDFV、自动屏幕上报关闭。不请求 ATT，不使用 AdSupport，不设置用户 ID。

自定义事件无参数；屏幕事件只含四个固定 Tab 的名称。不发送具体日期、内容 ID、语录/解读、图片、文件路径、收据或交易明细。SDK 自动事件（首次打开、会话、互动等）以及 SDK 实例/设备/网络相关信息仍受 Firebase 行为和后台配置影响。不是“完全不收集数据”的版本。

| 事件 | 触发和含义 |
| --- | --- |
| `screen_view` | 初次进入根页面或切换 Tab，screen_name 为 today/yearbook/wallpaper/settings |
| `calendar_day_changed` | 今日页选中日期实际变化，不含目标日期 |
| `quote_detail_opened` | 今日页或年度册成功进入打开详解动作 |
| `wallpaper_export_prepared` | 壁纸文件生成成功并准备交给分享面板；不代表用户保存成功 |
| `paywall_viewed` | 永久解锁界面实际展示 |
| `full_access_purchase_started` | 非忙碌状态且商品存在时发起购买流程；不代表成交 |
| `full_access_restore_started` | 发起恢复购买流程；不代表恢复成功 |

2026-11-13 追加自定义购买/恢复结果事件（如下），不调用 `Analytics.logTransaction`，不另发 `purchase` / `in_app_purchase`，避免与 SDK 自动营收统计混为一谈；未使用未被本版 SDK 验证支持的自动购买关闭配置，隐私政策如实说明 SDK 可能采集内购统计。现有 StoreKit 2 权益流程不变。仅统计操作，不更改付费、导出和阅读行为。

## 联调和发布验收

- Debug 构建使用无签名 iOS Simulator；不改签名、Team、Bundle ID、版本、App Store 配置。
- Debug 构建不初始化统计、不发送自动或自定义事件，预览/QA/模拟购买因此不会上报。不要用 Debug 构建验证 Firebase 收数。需要后台联调时使用 Release 测试安装；只有需要 DebugView 时临时传入 `-FIRDebugEnabled`，不加入正式 scheme 默认参数。
- 无测试设备事件出现在 DebugView 前，不宣称后台收数通过。GA 常规报告有延迟，应先验证 DebugView 和实时报告。
- 中英本地隐私政策已同步。发布前须同步线上隐私政策、App Store 隐私问卷，并核对 Google 的数据共享、广告关联、保留期限和适用发行地区的告知/同意要求；本轮未更改后台这些配置。

官方依据：
- https://firebase.google.com/docs/ios/setup
- https://firebase.google.com/docs/analytics/ios/configure-data-collection
- https://firebase.google.com/docs/analytics/ios/measure-in-app-purchases

## 初始接入验证记录（追加 Debug 屏蔽之前）

- `xcodebuild -resolvePackageDependencies -skipPackageUpdates ...`：通过，Firebase 固定为 13.1.1，锁文件已生成。
- `xcodebuild -project ios-client/MaoStyleCalendar.xcodeproj -scheme MaoStyleCalendar-iOS -configuration Debug -destination 'platform=iOS Simulator,id=98A997A6-1924-4163-88D8-BF473932245E' -derivedDataPath /tmp/maostyle-firebase-build -clonedSourcePackagesDirPath /tmp/maostyle-firebase-packages -skipPackageUpdates CODE_SIGNING_ALLOWED=NO build`：通过；最终配置修改后再次增量构建通过，无本次构建 warning/error。
- `plutil -lint`：工程和 App Info.plist 通过。
- 构建产物检查：Firebase 配置 Project ID/Bundle ID 匹配；默认 collection=true；IDFV、自动屏幕及广告默认项为 false；SDK 隐私清单随产物打包；Widget 无 Firebase 配置。
- target 依赖核对：只有 iOS 主 App 新增 FirebaseAnalyticsCore，其他 target 仍只有 CalendarCore；链接列表无 GoogleAppMeasurementIdentitySupport、GoogleAdsOnDeviceConversion、Firestore，动态依赖无 AdSupport/ATT。
- 与修改前快照比对：四 targets 的签名、Team、Bundle ID、Version、Build 全部未变化；设置页没有统计开关或入口。
- 配置文件 `git check-ignore` 通过。仓库本来整体未跟踪，未执行提交；构建缓存、模拟器日志和回滚快照在仓库外。
- 独立 `Mao Firebase QA` iPhone 18 Pro / iOS 27.2 模拟器启动成功，未覆盖已有 QA 安装。仅测试启动传入 `-FIRDebugEnabled`，正式 scheme 未增加调试参数。
- SDK 本机数据库已记录首次打开 `_f`、会话 `_s`、互动 `_e`、屏幕 `_vs`；通过既有 `--review-pack=pack-0001` 路由引发真实选中日期变化，最终安装后以 `pack-0002` 再次验证，`calendar_day_changed` 累计计数为 2。未伪造购买、恢复、导出或详解事件。
- 本机 SDK 状态有非零 `last_successful_upload`，`last_failed_upload=0`，上传队列为空，consent signals 为 `G101`（广告存储拒绝、分析存储允许）。这验证 SDK 的记录与发送链路，不等同于控制台报表验收。
- 浏览器控制再次读取标签列表超时；尚未现场核验 GA 属性 ID、DebugView 的事件展示和完整 UI 操作事件闭环，仍为后续联调项。


## 本轮文件变更

新增：
- `ios-client/Native/App/AppAnalytics.swift`
- `ios-client/MaoStyleCalendar.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved`
- `docs/engineering/firebase-analytics.md`
- 本地配置 `ios-client/Native/Configuration/GoogleService-Info.plist`（Git 忽略）

修改：
- `.gitignore`
- `ios-client/MaoStyleCalendar.xcodeproj/project.pbxproj`
- `ios-client/Native/Configuration/App-Info.plist`
- `ios-client/Native/App/MaoStyleCalendarApp.swift`
- `ios-client/Native/App/RootTabView.swift`
- `ios-client/Native/App/TodayView.swift`
- `ios-client/Native/App/AppSettingsView.swift`（仅事件调用，无统计 UI）
- `ios-client/Native/Resources/Legal/privacy-zh-Hans.html`
- `ios-client/Native/Resources/Legal/privacy-en.html`
- `docs/project-status.md`
- `docs/engineering/repository-structure.md`

未改：语录和插画、排版交互、StoreKit 权益逻辑、Widget 代码、CalendarCore、签名及版本、App Store 后台。Mac target 仅编译空实现以保留共享接口，不链接 Firebase。


## 2026-11-13 Debug 屏蔽修订

- 用户要求所有 Debug 相关行为不上传。`AppAnalytics.swift` 的 Firebase import、初始化及两类上报入口统一使用 `#if os(iOS) && !DEBUG`。
- Debug 版本不配置 Firebase，既不发送本项目事件，也不启动 SDK 自动会话/互动采集。Release 维持默认开启，无提示和入口。
- 初始接入阶段用于验证链路的 Debug 测试事件已发送，屏蔽不会追溯删除服务端历史；当前代码不再采用该调试收数流程。
- 文件修改范围：统计封装、本文、项目状态。业务事件触发点、签名、标识、版本和界面保持不变。
- 构建命令沿用本文件的 xcodebuild，分别指定 `-configuration Debug` / `Release` 和 `-destination generic/platform=iOS Simulator`（arm64、x86_64）；独立 DerivedData：`/tmp/maostyle-firebase-build` 和 `/tmp/maostyle-firebase-release-build`。两者均 `CODE_SIGNING_ALLOWED=NO`、`-skipPackageUpdates`。
- Debug、Release 均 BUILD SUCCEEDED，日志无 warning/error。该验证确认 Debug 空实现与 Release 真实 Firebase 调用分别编译通过。
- Debug 安装到既有独立 QA 模拟器，以 `--review-pack=pack-0003 --review-tab=wallpaper` 启动；自动事件和自定义事件计数与启动前完全一致（首次打开1、会话1、互动1、屏幕5、换日2），QA 操作未新增统计记录，断言通过。未新增 Firebase 初始化或调用路径。
- `git status --short`：仍为原有整体未跟踪状态；未提交；本次未新增仓库文件。


## 2026-11-13 购买与恢复转化结果

用户追加授权记录购买成功/失败/取消及恢复结果，Debug 仍完全不上报。结果均取自既有 StoreKit 流程，不增加交易详情、错误字符串、金额、订单号或收据信息。

| 新事件 | 语义 |
| --- | --- |
| `full_access_purchase_succeeded` | 本次 purchase 返回 success，且既有交易处理确认权益有效 |
| `full_access_purchase_failed` | purchase 抛出非用户取消错误，或返回未知结果 |
| `full_access_purchase_cancelled` | StoreKit 返回 userCancelled 或抛出用户取消错误 |
| `full_access_purchase_pending` | StoreKit 返回待批准，不记为成功或失败 |
| `full_access_purchase_verification_failed` | purchase 返回 success，但既有交易处理未确认有效权益 |
| `full_access_purchase_already_owned` | 发起流程后发现已有权益，未调用实际购买；不计为新成交 |
| `full_access_restore_succeeded` | AppStore.sync 完成后查到有效权益 |
| `full_access_restore_not_found` | 同步成功，但没有找到有效权益 |
| `full_access_restore_failed` | Apple 同步抛出非用户取消错误 |
| `full_access_restore_cancelled` | Apple 同步抛出用户取消错误 |

购买：通过忙碌/商品门禁后记录 started；每次 purchaseFullAccess 调用最多一个结果。未通过门禁不记取消或失败。结果事件不从 View 回调重复发，也不从 transaction updates、启动权益刷新或恢复流程伪造新成交。待批准后的异步权益更新仍由现有 listener 处理，当前购买结果事件不用于统计该后续更新。

恢复：started 移至新 Apple 请求的创建点，复用进行中的同步请求不重复记录 started。终态只在 performRestore 的 Apple 请求实际结束时记录一次，即使界面等待已结束也可记录；30 秒等待超时、UI Task 取消和重复等待不伪报 Apple 请求失败/取消。UI 等待中的 pending 不是恢复终态，因此不新增终态事件。

以上均为不带参数的自定义次数事件，不能把所有“成功”视为不同新用户或不同订单；正式营收仍以 Apple 与 Firebase 标准购买指标为准。


### 本次结果统计验证

- `xcodebuild ... -configuration Debug -destination generic/platform=iOS\ Simulator ... CODE_SIGNING_ALLOWED=NO build` 与相同的 Release 命令均通过（沿用上节两个 DerivedData），本次日志无 warning/error。
- 仓库外临时 Swift harness 从当前源码抽取 purchaseFullAccess、restoreFullAccess、finishRestoreWait 和 performRestore，替换 StoreKit/Firebase 为无网络桩，执行 `xcrun swiftc -swift-version 6 -parse-as-library /tmp/maostyle-conversion-tests.swift -o /tmp/maostyle-conversion-tests` 后运行：19 项分支/事件断言全部通过。
- 覆盖购买成功、验签失败、待批准、返回取消、抛取消、普通失败、已有权益、忙碌/无商品/恢复进行中门禁；恢复成功、无权益、用户取消、失败、忙碌门禁；等待超时后重试复用单一 Apple 请求；UI Task 取消后 Apple 最终成功不伪报取消。
- Firebase 事件名称长度/字符约束通过；四个 `os(iOS) && !DEBUG` 编译门禁保留。
- 这些验证是分支和构建验证，不是 App Store Sandbox 交易或 Firebase 控制台收数验收。本次未发起真实购买或恢复、未提交订单、未在 Debug 发送测试统计。
- 本次无新增仓库文件。修改 AppAnalytics.swift、AppSettingsView.swift、中英隐私政策、本文和 project-status.md，共 6 个文件；工程配置、签名、版本、界面和权益逻辑未改变。
- git status：仍为既有整体未跟踪状态；测试产物在仓库外，无新增异常。
