# 31 套素材接入 Widget 与背景叠字布局

日期：2026-11-06。状态：实现完成，等待用户视觉验收；不扩大清洗范围。

## 目标、边界与决定变更

使用现有 31 套插画及配对语录，替换普通 iPhone Debug Widget 的 Mock 显示。同一天 App 与 Widget 共用内容 ID，日期运行时计算。

用户最新决定替代原图文分区试排：Small、Large、纵向大组件以插画作为整卡背景，再叠加日期和语录；横向条形组件右侧约三分之二容纳插画，左侧显示文字。可以覆盖次要景物，优先保证头部、手部、阅读物件等主体清楚。锁屏 Family 继续遵循系统单色和极小空间限制，矩形显示单色插画及语录，圆形显示日期，单行显示日期与语录；不强行缩入整张彩色日历。

允许改动限于共享资源目录、Widget 渲染／Provider、Debug 预览、必要工程引用与候选资源排除。没有修改扫描原件、31 张 JPG、今日页语录／日期坐标、壁纸、年度册行为、CalendarCore 正式年度算法、字体文件、网络、权限、依赖、签名、Bundle ID、Team、Version／Build。没有开展其他月份清洗及 Duo／iPad／Mac 专项适配。

## 实现

- `Native/Shared/DailyArtworkLibrary.swift`：从 App 原有源码提取内容模型、31 套目录、确定性日期查询、农历格式化，App 与 iOS Widget 分别编译同一实现。未把图片与语录拆开随机分配，未改变正式 365 套分配器。
- `Native/Shared/ArtworkWidgetView.swift`：主屏及锁屏独立布局。整卡背景等比铺满，按素材主体上界约束取景；日期和语录在背景上叠加，语录优先在左侧留白，群像或靠左人物使用顶部右侧叠字，早期靠上人物使用窄左栏。小尺寸限制行数并省略，完整语录保留于辅助功能与打开的日历页。横条插画等比放入右侧三分之二，不拉伸人物。
- ImageIO 按组件尺寸降采样，8 MB／2 张缓存上限；不在时间线里传递大位图。主屏沿用每日本地零点刷新和打开指定日期链接。
- `content-packs.json` 仅追加 31 个 `illustrationRegion`、必要的 `widgetQuotePlacement` 与 Widget 布局修订字段，标注可去除的纸面留白，用于横条完整插画和锁屏图形；不改背景、语录、颜色、原稿换行或 App 日期模板。
- `Native/App/WidgetArtworkQA.swift`：Debug 设置新增“Widget 素材预览”，可切换 31 套并查看各 Family；批量检查通过 `--widget-artwork-qa` 启动，直接用共用 SwiftUI 组件渲染。
- iOS Widget target 引用既有 DailyArtwork 文件夹。App 与 Widget 的 Release 均排除这批待核验候选；仍不表示资源、引文或授权已获发布批准。

## 文件清单

新增：上面两个 Shared 源文件、WidgetArtworkQA.swift、本说明。

修改：App/RootTabView.swift（QA 启动）、App/AppSettingsView.swift（Debug 预览入口）、App/ArtworkPage.swift（模型／农历提取）、App/DailyArtworkCatalog.swift（保留 App 图片缓存）、Widget/CalendarWidgets.swift（共享内容与渲染入口）、DailyArtwork/content-packs.json、project.pbxproj（源码／资源引用及 Widget Release 候选排除）、文档索引、工程结构与项目状态。

## 验收与证据

证据保存在仓库外 `/Users/ideabox/.cache/MaoStyleCalendar/widget-artwork-20261106/`。完整 Debug／Release 日志、CalendarCore 测试日志和各图各尺寸渲染归档于此。离线渲染用于逐图检查，不替代系统桌面和实机验收。

待用户确认：背景裁切是否合适、主体是否清晰、语录遮挡与字号、红底配色、横条插画比例。普通 iPhone 统一验收后再推进下一阶段，不提前制作新月份。

### 本阶段验证结果

- iOS Simulator 无签名 Debug、Release 构建均成功。`swift test --package-path ios-client/Packages/CalendarCore --scratch-path /Users/ideabox/.cache/MaoStyleCalendar/widget-artwork-20261106/CalendarCore`：28 项通过。
- iOS 26.5 共 217 张（31×7）、iOS 27.2 共 248 张（31×8）实际 SwiftUI 渲染生成，逐图检查主屏各尺寸。超宽仅为后续平台参考，不能据此宣称 iPad／Mac 已验收。
- 当前 App 与 Widget 同日映射均为 pack-0024。两个 Debug 产物中的 31 张 JPG 均与源优化资源 SHA-256 一致，JSON 与源文件字节一致；与本轮备份比较，31 条配对仅新增 Widget 元数据。
- iPhone 17 Pro 模拟器实际打开“设置→Widget 素材预览”，检查红底小方形、横条及大方形；最终预览截图为 `review-screen.png`，三个样本的布局对照为 `widget-layout-review.jpg`。这些是 App 内共用视图预览。初版接入曾检查系统桌面 Small／Medium／Large；最终整卡背景微调后，系统桌面逐尺寸复验、锁屏与 StandBy 实际显示仍待用户确认，不以离线渲染替代。
- `plutil -lint ios-client/MaoStyleCalendar.xcodeproj/project.pbxproj` 通过；工程配置与本轮备份逐项比对，唯一 build setting 变化为 iOS Widget Release 的 DailyArtwork 排除，其他变化仅源码／资源引用。Release App／Extension 均未包含 DailyArtwork 或 ArtworkTrials。
- 执行 `git diff --check`、`git status --short`。仓库仍为原有整体未跟踪状态，未写入新的构建产物、扫描母版或异常文件。

尚未完成：最终版系统桌面逐尺寸、真机、实际锁屏／StandBy 验收，以及用户对字号／遮挡的视觉确认。下一阶段建议仅验收和微调现有 31 套，不扩大清洗、不调整其他平台。
