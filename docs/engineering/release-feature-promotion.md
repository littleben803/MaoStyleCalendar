# 已验收功能接入 Release

日期：2026-11-13。用户授权：把已验收功能和现有资源接入 Release，调试入口保留 Debug，不改已确认视觉、交互；验证后再继续宣传材料。此前整套资源只用于 Debug 的限制由本次决定替代，不要求重新进行同一轮视觉验收。

## 变更范围

普通 iPhone 是本轮运行验收对象。现有 iPad/Duo 继续共用原实现，不新增专项适配；macOS 的平台分支保留。签名、Team、Bundle ID、版本、依赖、Firebase、StoreKit 交易代码、日期分配、字体与原素材均不改。

| 区域 | 接入 Release 的内容 | 留在 Debug 的内容 |
| --- | --- | --- |
| 每日内容 | DailyArtwork 数据、插画、中英正文及既有详情；同一年度映射 | 逐包审阅、自动 QA 导出 |
| 今日 | 与验收版同一插画表面、尺寸计算、翻页及详情组件 | 审阅日期覆盖与越界权限豁免 |
| 年度册 | 既有内容池、缩略图解码、详情和滚动布局 | QA 启动跳转 |
| 壁纸 | 同一预览、两种排版及 JPG 导出路径 | 模拟解锁与批量 QA |
| Widget | 正常内容供应、主屏插画和锁屏布局 | 模拟权益、语言覆盖、构图诊断和图库入口 |
| 首次引导 | 原四页引导、首次展示持久化、跳过/免费入口及购买页面 | 强制引导、初始页/设备/语言覆盖、自动切换演示 |

工程仅删除 iOS App Release 对 DailyArtwork 和 OnboardingPreview 的排除项，不开启 `DEBUG` 编译标记。11 个 Swift 文件仅调整构建条件、将首次引导正式生命周期与审阅参数分开；布局、字体、颜色和动画值沿用原实现。导出图片的既有质量参数不变。

## 内容记录

本次是用户授权的工程接入，源 JSON 中的 `candidate`、`project_editorial` 及授权登记保持原样；不把工程接入伪装成底本核验、译文身份或商业许可已更新。以后这些历史标签不再成为自动隐藏整套已接入功能的依据，新增内容仍按项目规则处理。

2 月 29 日继续沿用现有独立占位，不新增或重复基础池素材。此点属于既有行为，不宣称本轮补齐了第 366 套正式插画。

## 验证方法

所有备份、独立 QA 模拟器、外置 UI 测试工程、构建和截图均在 `~/.cache/MaoStyleCalendar/release-promotion-20261113/`。没有覆盖用户真机或已有模拟器 App 数据，没有在仓库增加测试 target 或测试用签名配置。

- 修改前 Debug 构建保留作基线；修改后同时验证 Debug 和 Release。
- 普通 iPhone 17 Pro / iOS 26.5，分别走中英四页引导、壁纸排版切换、免费进入、今日详情打开/关闭、年度册、壁纸、设置和付费墙关闭，保存画面。
- 等待动画稳定后对比中英截图。即时截图中的背景透射和过渡帧差异不直接当成版式回归，也不据此修改视觉。
- App 和 Widget 二进制检查 Debug-only 参数、模拟购买与入口标识不得进入正式包。
- `verify_release_bundle.py` 对实际 `.app` 检查全部每日与引导源文件 SHA-256、中英内容 ID 覆盖、字体和 Widget 所在路径；iOS Widget 沿用 `CalendarResources` 访问所属 App 的资源。
- `verify_english_editorial.py` 继续校验英文覆盖及中文源校验值，不修改引文。
- CalendarCore 的 28 项测试覆盖日期、年度分配、语言与权益等已有规则。

命令示例：

```sh
xcodebuild -project ios-client/MaoStyleCalendar.xcodeproj -scheme MaoStyleCalendar-iOS -configuration Debug -destination 'generic/platform=iOS Simulator' CODE_SIGNING_ALLOWED=NO build
xcodebuild -project ios-client/MaoStyleCalendar.xcodeproj -scheme MaoStyleCalendar-iOS -configuration Release -destination 'generic/platform=iOS Simulator' CODE_SIGNING_ALLOWED=NO build
xcodebuild -project ios-client/MaoStyleCalendar.xcodeproj -scheme MaoStyleCalendar-iOS -configuration Release -destination 'generic/platform=iOS' CODE_SIGNING_ALLOWED=NO build
python3 ios-client/Scripts/verify_release_bundle.py /absolute/path/to/Release-iphoneos/MaoStyleCalendar.app
python3 ios-client/Scripts/verify_english_editorial.py
swift test --package-path ios-client/Packages/CalendarCore
git diff --check
git status --short
```

## 验证边界

无签名设备构建证明设备架构编译和打包通过，不是分发签名、上传、TestFlight 或审核通过。没有执行 App Store 发布。

外置 StoreKitTest 的购买注入返回 `StoreKitError.notEntitled`，修改测试 target 和 scheme 关联后仍复现。因此没有把本地自动测试记为真实购买、退款、恢复成功。保留原真实交易路径，未在 Release 加入模拟权益或绕过交易验证。付费墙打开、恢复入口存在与关闭可测试，交易结果另行真机 Sandbox 联调。

Widget 已验证代码分支与包内资源完整性；本轮没有实际在真机系统桌面重新添加并完成全类型截图，不能将 App 截图或资源完整性称为该项运行验收。此前用户已确认的 Widget 视觉沿用。

宣传材料保持暂停；先向用户汇报本轮实际通过项和以上边界，再继续制作。

## 本轮结果

- Debug 模拟器、Release 模拟器、Release iOS 设备架构无签名构建均成功。
- 中英 UI 各两次构建配置运行（Debug 2 项，Release 2 项）均成功；共 22 组截图对照，15 组逐像素一致。一组壁纸差异均值约 0.0001/255，其余差异集中于购买按钮光效、系统玻璃/透射渲染；没有修改对应绘制代码或布局数值。已查看对照总览及购买/设置差异图。该结果不覆盖所有内容包、日期和设备。
- 实际设备 Release 包：137 个每日资源文件、33 个引导资源文件与源码 SHA-256 一致，365 套中英内容覆盖完整，五份字体一致；App/Widget 中未检出六类 Debug-only 标识。原 Native/Resources 全目录与修改前备份相同。
- CalendarCore 28 项测试通过；英文覆盖、1,085 段对应和中文源校验通过。
- StoreKitTest 交易注入失败记录保留，未假称交易通过；没有为绕过该问题调整产品、权益或真实交易代码。

新增：`ios-client/Scripts/verify_release_bundle.py`、本文。修改：`ArtworkPage.swift`、`DailyArtworkCatalog.swift`、`StartupView.swift`、`ArtworkWallpaperCanvas.swift`、`TodayView.swift`、`iOSShareAndWallpaperExport.swift`、`OnboardingView.swift`、`RootTabView.swift`、`CalendarWidgets.swift`、`DailyArtworkLibrary.swift`、`ArtworkWidgetView.swift` 及 `ios-client/MaoStyleCalendar.xcodeproj/project.pbxproj`；同步 AGENTS.md、项目状态、仓库结构和宣传调研的历史状态说明。没有修改 AppSettingsView.swift、AppAnalytics.swift、中文/英文 JSON、图片或字体。

对照证据：`~/.cache/MaoStyleCalendar/release-promotion-20261113/stable-screen-comparison.json`、`release-parity-review.jpg`、`expected-differences.jpg`。UI harness 的改动仅存在于该外置目录，未接入仓库和正式工程。

额外 Release UI 检查通过：带强制引导、审阅跳页及语言覆盖参数启动时，仍进入正常英文今日页；设置中没有调试引导、Widget 图库或模拟购买入口。日志为 `release-no-debug.log`。
