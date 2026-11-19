# iPhone、iPhone Duo、iPad 与 Mac 适配策略

更新日期：2026-10-30

## 当前执行顺序

2026-10-30 用户决定收敛并行验收负担，以下顺序替代此前多平台同时推进的方式：

1. 普通 iPhone：先完成 App 全部功能、主屏/锁屏 Widget 和视觉验收，以整体里程碑统一验收。
2. iPhone Duo 与 iPad：普通 iPhone 验收通过后，再做展开布局、多窗口及对应 Widget 适配。
3. Mac：最后单独处理原生窗口、菜单、键盘交互、导出及桌面 Widget，并独立验收。

其他平台已有代码、targets 和设计保留；当前不主动增加其专项适配和用户验收任务。共享组件继续复用。下文为后续平台适配目标，不代表本阶段需要同时交付。正式插画与语录待交付时先用 Mock 完成 iPhone 功能和布局验收，正式内容与素材仍需后续发布验收。

## 1. 技术结论

建议使用一个 Xcode 多平台工程：共享 SwiftUI 视图、内容模型、存储、设计 Token 和 Widget 渲染组件；iOS/iPadOS 与 macOS 保留各自 Scene、导航外壳、菜单和窗口行为。目标是高复用，而不是强求所有平台逐像素相同。

不建议只做 iPad App on Mac 或简单 Catalyst 放大版作为最终 Mac 体验。原生 SwiftUI macOS destination 更适合侧栏、多窗口、菜单、键盘和桌面 Widget，同时仍能共享大部分代码。

## 2. 自适应断点思路

布局由可用宽度、Size Class、窗口尺寸和系统 Reserved Regions 决定，不用设备型号字符串判断。

| 环境 | 导航 | 内容布局 |
|---|---|---|
| iPhone 紧凑宽度 | Tab + Stack | 单页 |
| iPhone 横屏 | Stack 或自适应双区 | 插画与文字可并排 |
| iPhone Duo 外屏 | 紧凑单栏 | 与普通 iPhone 一致 |
| iPhone Duo 内屏展开 | Split/Arrangement | 目录与作品双栏，避开折叠区域 |
| iPhone Duo 部分折叠 | 自适应区域 | 重要文字和人物不得跨越中轴 |
| iPad 窗口较窄 | 单栏或两栏 | 随多任务窗口收缩 |
| iPad 全屏 | 两栏/三栏 | 目录、作品、详情 |
| Mac 小窗口 | 两栏 | 侧栏可收起 |
| Mac 大窗口 | 三栏 | 支持 Inspector 和大图预览 |

## 3. iPhone Duo 专项

- 使用标准 `NavigationSplitView` 和自适应布局容器，让外屏折叠为单栏、内屏展开为双栏；
- 避免让人物面部、日期数字、语录正文和主要按钮跨越中轴折叠区域；
- 网格优先使用偶数列，使内容能在两块区域自然分配；
- 设备开合和窗口变化时保持当前日期和阅读位置；
- 支持横屏与书本式摆放，不假设设备永远完全展开；
- iOS 27 SDK 的 Reserved Region/Arrangement 能力在实现阶段以最终 Xcode API 为准。

## 4. iPad 专项

- 支持 Split View、Stage Manager 和任意窗口尺寸；
- 年度册在宽窗口显示月份、日期列表和作品三栏；
- Apple Pencil 不是首版必需能力；
- Extra Large Widget 是首发范围。

## 5. Mac 专项

- 支持菜单命令：今天、上一天、下一天、生成壁纸；
- 支持方向键翻页、Command-F 搜索等键盘路径；
- 支持可调整窗口和恢复上次窗口状态；
- 图片可拖出/分享，但不默认开放原始扫描母版；
- 原生 Mac Widget 支持 Small、Medium、Large、Extra Large；
- 设置使用独立 Settings Scene，避免照搬 iPhone Form 导航。

## 6. 共享代码边界

### 应共享

- `DailyContentPack`、语录来源和语言状态；
- 本地内容仓库与检索；
- 日期/农历格式化策略；
- 颜色、字体、间距、纸张纹理等设计 Token；
- 作品页、来源卡、Widget 内容组件；
- 深链路由和无障碍文本。

### 允许平台差异

- Tab Bar、Sidebar、Toolbar、菜单和窗口 Scene；
- 文件导出、分享面板与壁纸保存入口；
- Hover、右键菜单、键盘快捷键和拖放；
- iPhone Duo Reserved Regions；
- Widget Family 的平台条件声明。

## 7. 官方依据

- [Apple：Designing for iPhone Duo](https://developer.apple.com/design/human-interface-guidelines/designing-for-iphone-duo)
- [Apple：Strike a pose with adaptive layouts on iPhone Duo](https://developer.apple.com/videos/play/tech-talks/111463/)
- [Apple：NavigationSplitView adoption](https://developer.apple.com/documentation/technotes/tn3154-adopting-swiftui-navigation-split-view)
- [Apple：WidgetKit](https://developer.apple.com/documentation/widgetkit/)
