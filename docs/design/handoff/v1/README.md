# SwiftUI 高保真交接包 v1

> 已被用户否决：本包程序合成的视觉与已确认原稿不一致，不再是最终高保真或 SwiftUI 还原依据。旧“检查通过”只证明技术条件，不代表视觉验收。请改看 [v2 原稿视觉基准](../v2/README.md)。字体原件/许可来源仍可沿用，重新生成的装饰与参数不得直接当最终资产。

归档日期：2026-10-29。用途：后续建立原生 SwiftUI 工程时的视觉与资源还原基准。用户已明确取消前端可交互原型；本包只包含设计、参数、字体、切图与可重现的原生静态渲染源，不包含业务工程。

## 先看这些文件

- [历史原稿与样张](screens/)用于核对字体与材质，当前交互见 [设计规范](../../core-screen-specifications.md)。
- Widget 家族：[浅色](boards/widget-family-light.png)、[深色](boards/widget-family-dark.png)、[系统着色参照](boards/widget-family-tinted.png)；每个 Family 的中英文独立稿见 [widgets](widgets/)。
- 宽屏：[iPad](screens/ipad-today.png)、[Mac](screens/mac-today.png)，展示侧栏、日期索引与图文阅读区。
- [六套壁纸编排](boards/wallpaper-templates.png)；每套中英文独立稿在 screens/wallpaper-template-*。
- [设计参数 JSON](specs/design-tokens.json)：字体、字号、颜色、间距、圆角、阴影、各容器参考尺寸和动效约束。
- [SwiftUI 还原说明](specs/swiftui-implementation.md)、[资源用途与切图规范](specs/asset-register.md)。
- [完整文件与 SHA-256 清单](manifest.json)、[检查结果](qa-report.json)。

## 归档层级与使用优先级

1. 本包 specs 的结构化参数和实现说明定义可量化规则；此处不把所有内容固定为某一年。
2. screens/widgets/boards 是使用真实 B 字体与独立图片层合成的实现参照；按逻辑点数还原，不把截图当运行时背景。
3. sources/reference-* 为原来已确认的生成式视觉稿，保留实体纸感、插画构图及气质；其中旧年份、占位语录、模拟字体和比例不覆盖现行规范。
4. 原始设计师插画尚未交付。所有高保真中的人物山水都是 mock-only 概念占位画；后续替换为审定的原画和语录，不把重复占位画当年度资源池。

本包冻结的是界面结构、视觉气质、字体与设计参数；系统着色/透明具体输出仍以 WidgetKit 为准。装饰切图是 AI 辅助制作的候选资源，可供接入与视觉复核；不宣称与设计师手工插画同一来源。正式语录状态和版权审批沿用项目规则，不因出现在高保真中变成 approved。

## 覆盖范围

- App：390×844 pt 的六核心页面浅色与深色稿，长正文详情稿；iPad 1024×768、Mac 1280×800 宽屏参照。
- 桌面 Widget：Small、Medium、Large、Extra Large，中英两种排版 × 浅色/深色/着色三外观，共 24 张独立稿。
- 锁屏：Circular、Rectangular、Inline 各独立稿；另有 StandBy 夜间和透明背景方向。
- 壁纸：六模板中英文独立稿；无日期、无语言选择 UI、无锁屏/主屏选择 UI。
- 额外：中英文家族总览、长句降级样张、原始视觉参考与装饰素材母版。

Widget 尺寸是设计参照，不是设备通用 API 常量。Extra Large 只纳入支持平台，Extra Large Portrait 与 Apple Watch Corner 不属于本项目当前目标。锁屏稿中的深色底仅用于展示白色内容，不是要求绘制自定义底板。

## 已准备的可接入资源

- [fonts](fonts/)：思源宋体 SC Regular/SemiBold 2.003、Literata 3.103 原始完整字库。
- [licenses](licenses/)：对应版权与 OFL 原文；完整字体未子集化、未改名。
- [assets/Decor.xcassets](assets/Decor.xcassets)：纸纹与透明铜环的 1×/2×/3× imageset，可在后续工程中择需导入。
- [assets/Theme.xcassets](assets/Theme.xcassets)：背景、纸面、朱红、正文、次级文字的浅/深动态 colorset。
- [assets/decor](assets/decor/)：独立 PNG 切图；铜环为 24×58 pt，纸纹为 256×256 pt，均含三倍率。
- [assets/mock-only](assets/mock-only/)：仅设计展示用的透明概念画，严禁进入发布资源。该目录不包含在可导入的 Decor.xcassets 内。

字库全量体积较大，这次按用户要求完整归档作为备份，并不等于最终 App 应原样全部打包。最终体积与字重预算在工程接入时确定，修改字体需重新核验命名与许可条件。本轮没有 Git commit，也未修改任何签名/target/工程设置。

## 重现

从仓库根目录运行，三个脚本均只操作本交接包内的设计输出，无第三方依赖：

```sh
swift docs/design/handoff/v1/scripts/export-assets.swift docs/design/handoff/v1
swift docs/design/handoff/v1/scripts/render-hifi.swift docs/design/handoff/v1/fonts docs/design/handoff/v1
swift docs/design/handoff/v1/scripts/package.swift docs/design/handoff/v1
```

输入字体与素材均已在包内，不依赖生成工具的缓存路径。修改本包任何文件后需重跑 package.swift 更新校验清单。

## 已验证与剩余事项

已进行真实字体落位和回退检查、图片解码、透明铜环检查、字号/颜色参数归档、基于纯色纸面的正文/次级字/强调色对比度检查，以及核心页面和各外观的可视检查。具体数量见 qa-report.json。

尚未完成实际 WidgetKit 渲染、SwiftUI 动态字号、VoiceOver、运行时手势与动画、系统分享/IAP 或全体 365 条资源验收。Debug 未构建，因为业务工程尚未建立。后续直接进入 SwiftUI 工程实现与对照截图验收，不再要求先做前端原型。
