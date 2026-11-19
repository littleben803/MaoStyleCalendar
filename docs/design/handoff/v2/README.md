# 已确认原稿视觉基准 v2

本次用户再次提供的七张附件是唯一视觉基准。v1 的程序合成稿未忠实还原，用户已明确否决；它的“高保真完成”“视觉验收通过”“可按其参数还原”等结论撤回。

本目录无损保存附件，并直接用原稿组成总览，不进行界面重绘、字体替换、插画替换或装饰简化。它是纠偏后的视觉原稿归档，不冒充已完成的可编辑分层稿或经过验证的新切图包。

## 原稿

1. [今日](approved/today.png)：居中标题、大日号、竖排语录、厚纸叠页、铜环、融入纸面的插画、底部操作条。
2. [语录详解](approved/detail.png)：暖色模糊蒙层、同款纸页与铜环、圆形关闭、红色章节标记和细分隔线。
3. [年度册](approved/annual.png)：居中标题、胶囊年份、月份下划线、单张纸页铜环卡、独立插画。
4. [壁纸](approved/wallpaper.png)：侧边露出相邻预览、大面积画面、六个编排缩略图、纸纹朱红导出按钮。
5. [付费墙](approved/paywall.png)：居中图标与标题、黑红文字层级、四组权益图标、红细框购买区、带箭头主按钮。
6. [中文 Widget](approved/widgets-zh.png)：所选第一组精修稿，完整保留原始图文关系。
7. [英文 Widget](approved/widgets-en.png)：原英文字体层级、分行和双页关系。


## 总览

- [品牌资源与启动画面](brand/README.md)包含中英文 Icon、Logo、品牌提示语和开场卡片底图。
- [App 原稿总览](boards/app-approved-originals.png)用于参考材质与字体，当前导航与交互以 [设计规范](../../core-screen-specifications.md) 为准。
- [中文 Widget 原稿](boards/widgets-zh.png)、[英文 Widget 原稿](boards/widgets-en.png)：与本次附件逐字节相同，没有重绘。
- [偏差复核与细节约束](specs/fidelity-review.md)。

## 原稿与此前产品规则的关系

原稿决定视觉；已明确更新的产品规则决定行为与内容。不能因旧稿出现三 Tab 就撤回“四 Tab”；也不能因样例为 2027 就恢复固定年份。

- 底部为今日、年度册、壁纸、设置四 Tab，沿用年度册/壁纸原稿的线性图标气质、非选中棕色与选中朱红，不改变主卡构图。
- 年份跟随系统日期；截图日期只是样例。正式中文与英文语录仍须核验。
- 详情固定 Header 只显示“语录详解”，不显示日期；下面全部正文自然滚动，没有“继续阅读”或向下箭头。此规则以 2026-11-19 的用户验收为准，替代原稿中的日期副标题。
- 2026-11-19 用户验收后的字体方案：中文标题和中文竖排语录使用思源宋体 Bold，中文正文使用 Apple 系统 Regular；英文语录 Source Serif 4 SemiBold；大日期 Libre Bodoni Bold。字体决定不等于批准 v1 的字号或构图；字面大小与行距仍须贴合原稿实测。

## 资源状态

2026-10-30 资源复核：此前 v2 没有跟随定稿更新的独立装饰切图，本次新增 [resources 候选准备包](resources/README.md)：3 类位图的 1x/2x/3x、18 个可编辑 SVG/矢量 PDF 图标、材质/图标检查表和登记清单。阶段 2 已将其中装饰和图标 Asset Catalog 接入 iOS/macOS App targets 作内部今日页还原，Widget 未接入；这不取代原稿，技术或运行检查通过也不等同视觉批准。纹理暂不能无缝平铺，正式每日插画仍待设计师交付。逐屏覆盖、原生效果和缺件详见 [资源审计](../../../assets/v2-resource-readiness.md)。

当前内置字体已独立归档在 [fonts](fonts/) 与 [licenses](licenses/)，准确文件名、版本、PostScript 名称与变量轴见 [font-roles.json](specs/font-roles.json)。其中思源宋体只保留 Bold 静态字重，Source Serif 4 与 Libre Bodoni 为变量字库，分别以 wght=600、700 实例化。Literata 不再属于当前语录/大日期方案，v1 仅作历史保留。

v1 重新生成的铜环、纸纹、占位画、布局参数、切图与 colorset **未通过视觉贴合验收**，不得直接作为最终 SwiftUI 实现基准。

后续分层/切图必须贴合这里的纸张纹理、铜环立体形态、红色印刷质感、插画融合边缘和投影，不得另造一套近似资产。正式设计师插画尚未到位，任何截图切片或生成占位画均不能当正式内容资源。截图中的文字也不能简单烘焙进发布图片。

用户最新明确：不再重新生成高保真，只记录代码要用的字体规范，归档现有原稿并开始工程阶段。因此本包的原稿图片保持不变，最新字体以 font-roles.json 为准，不再把“生成新字体高保真或分层复刻稿”作为开发前置。原稿仍是 SwiftUI 构图、材质与微细节的还原依据，实际运行截图应与原稿对照，技术校验不能代替视觉检查。此决定不意味着此前被否决的 v1 切图重新获得批准。

重现总览与 manifest：

```sh
swift docs/design/handoff/v2/scripts/archive.swift docs/design/handoff/v2
```

仅更新清单、不重新生成任何 PNG：

```sh
swift docs/design/handoff/v2/scripts/archive.swift docs/design/handoff/v2 --manifest-only
```
