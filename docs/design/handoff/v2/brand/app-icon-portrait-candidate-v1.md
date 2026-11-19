# 无字头像图标候选 v1

日期：2026-11-17。状态：用户真机预览后确认采用当前图标及系统自动深色/着色方案，视觉方案定稿；未发布，商用授权状态未升级。

文件：`app-icon-portrait-candidate-v1.png`。使用内置 ImageGen，根据用户提供的摆件照片中的主席头像与现有 `app-icon-zh.png` 合成重绘。原始生成 PNG 原样归档，实际尺寸以图片属性为准；提示词中的 1024 × 1024 为生成目标，不代表已经导出正式图标规格。

目标：中英文共用无字图标，保留朱红日历页眉、两处米白装订孔和米白纸面，以头像替代文字及引号。保留头像向左的朝向、军帽、红星和版画轮廓，去除摆件、底座、文字和照片背景。

初次候选阶段未修改现有正式图标。随后用户授权部署真机预览，使用 sips 导出 1024 × 1024 不透明 PNG，替换 `Brand.xcassets` 中 `AppIconChinese` 和 `AppIconEnglish` 的 Any/Dark/Tinted 六张图片，保留资源 ID 和 Contents.json。三种外观暂用同一候选，尚未制作专用深色与着色版本。未修改设置入口、业务代码、工程配置或签名。头像为参考图重绘，不是对原画的逐像素提取；原画商用授权仍未确认，AI 重绘不代表权利已获解决。

初次候选检查：大图无文字、水印或摆件；头像与衣领完整，日历结构保留。初次候选阶段未运行 Debug 构建。

## 真机预览验证

2026-11-17：沿用工程现有签名，iPhone 17 Pro Max 的 Debug 构建成功，devicectl 覆盖安装与启动成功；截图确认 App 已进入今日页。随后结束 App 进程返回桌面，截图确认新头像图标已显示，头像和衣领未被系统圆角裁切。当前外观通过；未切换系统深色与着色外观，不代表专用外观验收或最终发布批准。

六张资源均为 1024 × 1024、无 Alpha，SHA-256 相同：`723d1aee9b54cc6520a3a815d3509ace086a8b098d3bdfbd3e39b27b60d6d1fe`。

验证使用 `sips`、`shasum -a 256`、`xcodebuild -project ios-client/MaoStyleCalendar.xcodeproj -scheme MaoStyleCalendar-iOS -configuration Debug -destination 'id=<connected-device>' -derivedDataPath <external-cache> build`、`devicectl device install app`、`device process launch/terminate`、`device capture screenshot`、`git diff --check` 和 `git status --short`。设备标识不作为项目配置写入。

原图标备份、构建日志和截图均位于仓库外 `/Users/ideabox/.cache/MaoStyleCalendar/icon-device-20261117/`，最终桌面截图为 `home-final.png`，App 启动截图为 `app-launched.png`。Debug 构建产物位于 `/Users/ideabox/.cache/MaoStyleCalendar/DerivedData-icon-device/`。无新增仓库文件；修改六张图标和三份品牌/项目记录，业务代码、工程、签名、版本和原始候选不变。Git 保持既有整体未跟踪状态，未提交构建产物。

最新配置（2026-11-17）：用户要求深色与着色由系统自动生成，随后要求删除无用资源。两份 Contents.json 已移除 Dark.png/Tinted.png 的 filename 引用，保留空外观槽位；四张 PNG 已删除，源资源减少 3,872,648 字节（3.69 MiB），不将其等同于安装包节省量。仅保留各自 Any.png；上节六张同图是首次真机预览的历史状态。

最终清理后的真机 Debug 构建通过，无未引用图标资源警告；assetutil 检查编译后的 AppIcon 只有 default 外观。已覆盖安装并启动成功，返回桌面截图确认默认头像图标正常；深色/着色待用户切换主屏幕外观查看。此轮日志及桌面截图归档在仓库外 `/Users/ideabox/.cache/MaoStyleCalendar/icon-auto-device-20261117/`。没有新增仓库文件或业务改动。

## 完整提示词

```text
Use case: compositing / logo-brand.
Create ONE polished square app icon candidate, 1024x1024, opaque edge-to-edge, no rounded outer corners or external margin.
Input image 1: supporting portrait reference. Use ONLY the illustrated portrait of Mao Zedong inside the photographed ornament: same recognizable young face, three-quarter profile facing viewer's left and slightly upward, military cap with red five-point star, cap and high collar. Preserve its likeness and strong woodcut silhouette. Reinterpret the portrait cleanly for an app icon, with broad legible ink shapes and sparse purposeful hatch marks; no photographic artifacts. Keep muted dark olive green cap and collar, warm ochre skin, near-black ink shadows, small vermilion star and collar accents. No white sticker outline.
Input image 2: edit target and layout reference. Keep the existing minimalist calendar icon construction: a flat brand vermilion #B81211 band across the upper quarter, two identical warm ivory vertical pill binding holes in the same positions, and a flat warm ivory paper face occupying the remaining three quarters. Preserve crisp flat shapes and generous margins.
Replace all Chinese typography and BOTH red corner quotation decorations in image 2 with the portrait from image 1. Portrait is the only central graphic on the ivory paper, optically centered within the paper area, roughly 57 percent canvas width and 59 percent canvas height, occupying x 23%-80%, y 32%-91%. Entire cap, face and collar must fit with breathing space. Make the facial identity especially faithful to reference, noble calm expression, no caricature.
No words, letters, numerals, punctuation, slogans, quotation marks, borders, watermarks, photographic pedestal, glass ornament, circular red halo, gradients, rays, shadows, 3D effects, extra objects or texture. This is a restrained flat editorial calendar brand icon. Exactly one icon, not a presentation sheet.
```
