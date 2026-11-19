# 原生工程启动：共享核心层与 App/Widget targets

日期：2026-10-29—30。阶段 4.1—4.2。用户决定：保留现有高保真，不重新生成；最新字体只记录为代码规范，归档后进入原生工程。

## 已开始的实现

`ios-client/Packages/CalendarCore` 是无第三方依赖的原生 Swift Package，未来 App 与 Widget 共用；不是前端原型，也不包含业务 UI 或发行配置。

- `CalendarDate`：公历民用日期、合法性校验、闰年规则、由瞬时时间和显式时区获取本地日期。
- `AnnualContentAllocator`：365 个稳定内容 ID 按年和版本确定性洗牌。先按字典序稳定排序，再使用 SplitMix64 + 无模偏差的 Fisher–Yates；没有 Swift.Hasher、系统随机数或依赖用户访问顺序的可变池。
- 普通年映射 365 天；闰年只有额外提供独立 2 月 29 日内容 ID 才生成 366 天。基础池在闰年仍完整使用一次，缺闰日资源明确抛错，不悄悄重复。
- pool 计数、重复 ID、空/首尾空白 ID、闰日 ID 混入基础池、非法年份和未知算法版本均拒绝。
- 桌面小组件显示偏好通过 App Group 共享；语录 Release 状态门禁与正式资源仍未实现。

算法版本 1 的种子为 `UInt64(year) XOR (UInt64(version) &* 0xD1B54A32D192ED03)`。2026 年、ID `MCP-001`…`MCP-365` 的前五日为 `MCP-298, MCP-334, MCP-038, MCP-014, MCP-218`，作为回归样本锁定。测试 ID 仅为算法夹具，不是正式语录或获准内容。发布前算法仍需整体评审；一旦随正式资源发布，年度映射版本不能任意更换。

## 后续 target 结构

- `CalendarCore`：日期、内容模型/仓库、年度映射和本地状态协议，尽量不依赖 UI 框架。
- 共享 SwiftUI 设计层：最新字体五角色、颜色、纸页、铜环、日期和语录排版，按平台注入可用空间。
- iOS/iPadOS App：今日、年度册、壁纸、设置，详情固定 Header 与翻转；优先从今日页还原开始。
- macOS App：共享内容和组件，独立 Scene、Sidebar、菜单与窗口行为。
- Widget Extension：各 Family 独立布局，共用 CalendarCore 的日期与内容映射。

## 已确认工程配置与边界

用户提供正式 Bundle ID `com.ideaboxapps.maostylecalendar`、最低 iOS 15（2026-10-30 用户明确提升为 iOS/iPadOS 17），以及候选 Team `C2EN8G3ZSM`，授权只读查看钥匙链。macOS 采用建议的最低 14.0，以原生桌面 Widget 为基线。

| Target | Bundle ID | 最低系统 |
| --- | --- | --- |
| MaoStyleCalendar-iOS | com.ideaboxapps.maostylecalendar | iOS/iPadOS 17.0 |
| CalendarWidget-iOS | com.ideaboxapps.maostylecalendar.widgets | iOS/iPadOS 17.0 |
| MaoStyleCalendar-macOS | com.ideaboxapps.maostylecalendar | macOS 14.0 |
| CalendarWidget-macOS | com.ideaboxapps.maostylecalendar.widgets.macOS | macOS 14.0 |

- 主屏 Family：Small、Medium、Large；Extra Large 由支持该 Family 的 iPad/Mac 展示，不承诺 iPhone 支持。
- 2026-10-30 用户将最低版本统一提升到 iOS/iPadOS 17。主屏与锁屏 Widget 均直接注册，移除原 iOS 15/16 分支。
- 统一使用 iOS 17/macOS 14 的 Widget 背景 API，无旧系统背景分支。交互式 Widget 尚未接入；最低版本提升不代表已实现所有新 API。
- 钥匙链中开发证书的公开 Subject OU 与发行证书主体均确认 Team 为 `C2EN8G3ZSM`，主体为 Hangzhou IdeaBox Technology Co., Ltd.；没有读取私钥、导出证书文件或创建 provisioning profile。
- 工程记录该 Team、Automatic 签名；阶段 5 已为四个 targets 增加共享 App Group entitlement，模拟器容器已验证。2026-10-30 用户确认主 App 与两个 Widget App ID 已创建并关联同一 App Group；真实设备 provisioning 与签名仍待验证。后台准确标识、macOS Widget 大小写差异及后续 App Store Connect/IAP 信息统一维护于 [AGENTS.md 第 7.1 节](../../AGENTS.md#71-项目标识与后台配置)。
- 新工程初始 Version/Build 为 1.0/1，仅是工程默认值，不代表上线版本承诺。

允许修改范围：`ios-client/MaoStyleCalendar.xcodeproj/`、`ios-client/Native/`、`ios-client/Packages/CalendarCore/`、`.gitignore` 与相关规范/状态文档。验收是四个 targets 可解析、两平台无签名 Debug 编译、核心测试通过、各 bundle 包含正确字体与许可；不进入正式业务 UI、StoreKit、网络、敏感权限、同步或账号功能。

## 原生骨架内容

- 两个 App 共用自适应根容器：iPhone 紧凑宽度为四 Tab，iPad 扩展宽度与 macOS 为 Sidebar + Detail；四个一级页面共用已有 SwiftUI 内容和状态。
- 两个 Widget 扩展共用日期 Provider、Mock Repository、年度确定性映射，并提交下一本地午夜后的刷新请求；系统调度不保证准点刷新。Small、Medium、Large、Extra Large 与三种锁屏 Family 已独立编排，但当前仍没有正式语录、插画、农历文案或付费状态。
- 五角色字体由 CoreText 按角色首次使用时注册，英文/日期显式设置变量字重；每个 target 独立打包字体与 OFL 许可，不假设主 App 注册可供扩展使用。
- 当前全量字体约 73 MiB，每个 App 及其扩展各含一份；尚未做子集化、内存预算和实际 Widget 宿主压力验收。正式视觉阶段需要测量，不将构建成功等同于资源预算合格。
- 无第三方依赖；直接创建 Xcode 工程，未安装 XcodeGen 或 Ruby 工程库。

## 当前目录与依赖关系

当前目录树、各模块职责、迁移规则与维护命令以 [仓库结构说明](repository-structure.md) 为准。

依赖方向：App 和 Widget 分别依赖本地 CalendarCore；二者都编译 ios-client/Native/Shared 的字体代码，Widget 不依赖主 App 可执行文件。iOS 与 Mac 使用独立 targets、共享 SwiftUI 源码，当前并非 Catalyst。后续按实际 UI 复杂度拆分功能目录，不提前创建空的业务层。

字体暂时直接引用 v2 归档中的真实文件，构建时复制到各 bundle；没有再复制一套字库到源码目录。桌面小组件显示偏好使用本机 App Group；正式插画资源目录、内容仓库和 StoreKit 均未建立。

## 本机工具链

- Xcode 26.6，Build 17F113；Swift 6.3.3。
- 本机 iOS Simulator SDK 26.5、macOS SDK 26.5。
- 有 iPhone 17 Pro、SE 三代等 iPhone 模拟器，以及 iPad Pro/mini/Air 模拟器。
- 当前列表未显示 Duo 专用设备或 iOS 27 SDK；不能把旧设计文档中的相关未来 API 假设当已验证能力，实际以现有 SDK 和可用几何适配为准。

## 验证

```sh
swift test --package-path ios-client/Packages/CalendarCore
swift build --package-path ios-client/Packages/CalendarCore --configuration debug
swift docs/design/handoff/v2/scripts/verify-fonts.swift docs/design/handoff/v2
xcodebuild -list -project ios-client/MaoStyleCalendar.xcodeproj
xcodebuild -project ios-client/MaoStyleCalendar.xcodeproj -scheme MaoStyleCalendar-iOS -configuration Debug -destination 'generic/platform=iOS Simulator' -derivedDataPath /Users/ideabox/.cache/MaoStyleCalendar/DerivedData-iOS CODE_SIGNING_ALLOWED=NO build
xcodebuild -project ios-client/MaoStyleCalendar.xcodeproj -scheme MaoStyleCalendar-macOS -configuration Debug -destination 'generic/platform=macOS' -derivedDataPath /Users/ideabox/.cache/MaoStyleCalendar/DerivedData-macOS CODE_SIGNING_ALLOWED=NO build
plutil -lint ios-client/MaoStyleCalendar.xcodeproj/project.pbxproj ios-client/Native/Configuration/App-Info.plist ios-client/Native/Configuration/Widget-Info.plist ios-client/Native/Configuration/Shared.entitlements
git diff --check
```

CalendarCore 的 XCTest 覆盖年度分配、日期边界与 366 条 Mock Repository。

两平台 App 及嵌入的 Widget 扩展 Debug 构建均通过。余下唯一工具提示是未引入 AppIntents、跳过其元数据抽取，与当前静态 Widget 边界一致。四个产物的五字体与三许可证均逐文件 SHA-256 比对通过；五角色字重/注册/样例字符检查通过。v2 approved/boards 图像与归档 manifest 的 SHA-256 一致，未重绘。

iPhone 17 Pro / iOS 26.5 模拟器的紧凑 Tab 结构已在前序里程碑验证；本阶段新增 iPad Pro 13-inch 模拟器启动与宽屏 Sidebar 截图核对，证据位于仓库外 `/tmp/maostyle-ipad-adaptive-app.png`。macOS App 已启动，并通过窗口可访问性树确认 Sidebar、四个入口和今日详情内容；Widget 桌面宿主截图仍未验收。本机没有 iOS 17 运行时，部署版本编译通过不等同于 iOS 17 实际运行验收。

本阶段增加 `.gitignore` 以忽略 `.DS_Store`、SwiftPM `.build/.swiftpm`、DerivedData 和用户态 Xcode 文件；不忽略源码、设计稿和字体。没有删除旧文件或提交 Git。

视觉与字体依据：[v2 原稿归档](../design/handoff/v2/README.md)、[当前字体五角色](../design/handoff/v2/specs/font-roles.json)。PNG 不在本阶段重绘或重生成。
