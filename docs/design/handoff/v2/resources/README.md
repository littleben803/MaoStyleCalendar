# v2 实现资源准备包

日期：2026-10-30。基准为上级 `approved/` 的原稿；**不是重新定稿的界面，不替换原稿，也不恢复 v1 切图的使用资格**。

已按用户要求归档为 **v2-resources-r1**，当前停止调整，后续有需要再修订；见 [归档记录](ARCHIVE.md)。候选状态及使用限制保留，但进一步打磨不作为新增的开发前置条件。

审计结论：此前没有跟随 v2 更新的可用切图包，只有已归档原稿、字体和被否决的 v1 素材。本次补齐基础装饰与图标的候选导出，正式插画和逐屏视觉贴合尚未齐备，不能宣称全部资源已最终验收。

## 现在有什么

| 目录 / 文件 | 内容 |
| --- | --- |
| `masters/` | 依定稿原图由内置 imagegen 补制的五个候选母图（含保留的铜环 V1/V2 与收敛后的 V3）；保持生成原件不变 |
| `DecorCandidates.xcassets/` | 铜环 V1/V2/V3、米白纸纹、朱红纹理；每项 1x/2x/3x，共 15 张 PNG |
| `vectors/` | 18 个项目自绘 SVG 图标候选，无第三方图标包 |
| `IconCandidates.xcassets/` | 同源 18 个单页矢量 PDF，保留矢量，Template 渲染 |
| `vector-spec.json` | 图标的可编辑 24pt 路径、1.5pt 线宽及状态 |
| `previews/material-check.png` | 铜环浅/深/棋盘底、实际尺寸及材质重复铺排检查 |
| `previews/icon-check.png` | 图标大图与实际尺寸检查 |
| `export-report.json` | 位图导出尺寸、透明范围、候选状态 |
| `asset-inventory.json` | 位图、字体、原生效果、待交付插画的统一登记 |
| `qa-report.json` / `resource-manifest.json` | 技术核验与文件散列；不代表视觉批准 |
| `generation-prompts.md` | 图像工具、输入、提示词与生成来源 |
| `scripts/` | 资源导出和核验工具，不是业务代码 |

字体继续使用上级 `fonts/`、`licenses/` 和 `specs/font-roles.json`，不复制第二套字体。

## 资源使用方式

- 铜环 V1/V2/V3 逻辑画布均为 24×64pt，分别提供 24×64、48×128、72×192 PNG。V2 延长后侧扣脚但运行中压边过深；V3 将长度收敛到 V1/V2 之间，并配合 2pt 组内纵向校正，使正面与详解页只保留轻微压边且不出现空气缝。三版均保持 Candidate 状态。导出时按 alpha>8/255 的可见范围做矩形裁边，再等比缩小，并留透明边距；保留范围内的 RGBA 不重新抠图。母图中有极低透明度散点，不能直接按整张母图尺寸摆放。三版铜环都是 AI 辅助重建候选，不是设计师的分层原件。
- 原稿的纸孔与铜环暗面不能合并成一个不透明贴片。孔、接触阴影、铜环和纸页遮挡关系分层处理；翻页时铜环可保持固定，纸页独立变换，不需要预生成动画帧。
- 米白和朱红材质逻辑参考边长 256pt，提供 256、512、768px 方图。原件均为 1254px 方图；导出不放大原图。使用时按比例填充并裁切，不能拉伸纹理。
- **无缝平铺未通过**：2×2 检查仍可见重复分块，朱红较明显。当前按单块材质局部裁切/填充使用，不直接重复铺排；大面积背景需要最终环境中的低对比度材质叠加或再处理，不能宣称 seamless。
- 图标使用 PDF Template，由运行时设置朱红/棕色；SVG 供设计及未来 Android 复用。24pt 是图标参考画布，触控区域独立保证，不把图标放大至命中区大小。
- `calendar` 图标不含固定日号；“今日”的日号必须动态绘制。`calendar-grid` 用于付费墙顶部。设置 Tab 使用齿轮图标。
- 详情关闭框由原生圆形描边和 `close` 组合，可分别调颜色；`close-circle` 仅作完整图标备用。
- 18 个图标是依据原稿气质统一重建的候选，不是逐像素描摹；尤其齿轮、圆角和微线宽还需运行截图贴合。`check`、`trash` 为辅助状态/菜单备用，不在付费墙权益区新增打勾样式。

## 不需要整张切图的效果

| 效果 | 实现交付规则 |
| --- | --- |
| 今日厚纸与背面 | 原生多层纸页、细边、可变暖投影 + 纸纹；纸页层和内容层独立。禁止整屏截图作背景 |
| 年度册卡片 | 原生单页、轻阴影、铜环；不能复用今日厚叠页作为缩略卡 |
| 详情背景 | 对真实底层页面做模糊与暖色半透明蒙层；不能使用截图里烘焙的底层文字 |
| 详情文字与章节 | 固定“语录详解”标题（不显示日期）+ 滚动正文，原生短竖条和细线；语录详解不切成位图 |
| 红日号 / CTA | 字体或圆角形状作为 mask，叠加朱红材质；文字、金额、箭头独立，禁止烘焙 |
| 月份下划线 / 胶囊 / 今日标 | 原生线条与形状，随日期和选中态变化 |
| 壁纸预览与六缩略图 | 使用同一插画/语录按六模板渲染缩略图，无固定日期；不预切 365×6 套成品 |
| Widget Small / Medium / Large | 系统容器内独立文字与插画布局；圆角和裁切由系统容器及视图共同约束 |
| Extra Large 双页 | 原生两页构图和中缝渐变，与插画层分离；中缝不是一张横向整屏贴图 |
| 锁屏 / 系统着色 | 原生可读文字、单色图形和系统渲染；不把米白底、投影或彩色铜环强塞进锁屏 |
| 左右翻日 / 卡片翻转 | 程序变换、透视、遮挡与动态阴影；无需 GIF、视频或逐帧切图 |

详细页面覆盖和缺件见 [资源审计](../../../../assets/v2-resource-readiness.md)。阶段 2 已将两个 Asset Catalog 加入 `ios-client` 的 iOS/macOS App targets，用于今日页内部实现；Widget targets 未加入。文件名继续保留 Candidate，避免误认为正式定稿。

## 重现

从仓库根目录执行：

```sh
swift docs/design/handoff/v2/resources/scripts/export.swift
swift docs/design/handoff/v2/resources/scripts/export-vectors.swift
swift docs/design/handoff/v2/resources/scripts/verify.swift
swift docs/design/handoff/v2/scripts/archive.swift docs/design/handoff/v2 --manifest-only
```

资源预览只是检查表；不生成或替换 App/Widget 高保真。正式插画、深色/系统着色效果仍沿用设计师后续交付与实机验证流程。

## 本轮技术核验

- 15 张倍率 PNG 的像素尺寸、米白/朱红不透明性、三版铜环透明角点和有效画面占比检查通过。
- 18 个单页 24×24pt PDF、对应 SVG 路径及 Template/矢量保留配置检查通过。
- iOS 17 模拟器平台与 macOS 14 的 `actool` 独立资源编译均通过；阶段 2 又验证了资源随 iOS/macOS App targets 编译，产物保存在仓库外缓存。
- 11 张 approved/boards 原稿与既有 manifest 哈希一致。本轮未重跑 App Debug 或 UI 运行验收，因为没有修改 App/Widget 源码和工程配置。
- 技术与运行通过不改变候选状态；重复接缝、局部形态与运行中的纹理强度仍按上述限制处理。

独立编译命令示例（先创建自己的仓库外输出目录）：

```sh
xcrun actool docs/design/handoff/v2/resources/DecorCandidates.xcassets docs/design/handoff/v2/resources/IconCandidates.xcassets --compile /Users/ideabox/.cache/MaoStyleCalendar/resource-audit/iOS --platform iphonesimulator --minimum-deployment-target 17.0 --output-format human-readable-text
xcrun actool docs/design/handoff/v2/resources/DecorCandidates.xcassets docs/design/handoff/v2/resources/IconCandidates.xcassets --compile /Users/ideabox/.cache/MaoStyleCalendar/resource-audit/macOS --platform macosx --minimum-deployment-target 14.0 --output-format human-readable-text
```
