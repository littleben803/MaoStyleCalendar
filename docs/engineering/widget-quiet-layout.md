# 桌面 Widget 留白排版

## 2026-11-19 日期完整显示

iPhone 桌面小号、中号和大号曾将“11月 · 星期四”压成“11月 · 星期…”。日期区现按完整月与星期预留宽度，文本在系统字号变化时优先缩放完整显示；语录候选区域随日期区重新排布。补充 292×302pt 的窄版大号样张检查。iOS 26.5 Debug 构建通过；重点组合 840 张、365 套内容 × 12 种尺寸共 4,380 张样张完成渲染。模拟器主屏的小号、中号、大号均已核对星期完整显示，语录无截断。其他平台尚未做本轮桌面实机验收。

## 横向超大同步主体取景

2026-11-11：systemExtraLarge 与 systemMedium 共用右侧三分之二图片区、主体/人脸取景、渐隐边缘及密度图投影。仅扩展适用 family，不改变中号既有参数；横向超大保留目标 42pt / 最低 36pt、原日期字号与间距。其他 family 使用原布局。语录可利用窄宽度留白候选，依旧优先完整显示、保护日期区，最低字号容纳不下时尾部省略。

全背景验证入口：--widget-artwork-qa --widget-quiet-layout-qa --widget-extra-large-artwork-qa，输出 WidgetExtraLargeArtworkQA。133 张背景共 266 张正常/探针图通过区域、对齐、人脸边界与字号检查，133 组文字/日期检查通过；pack-0282 为人脸保护缩小的唯一例外。常规跨平台样张 1,080 组边界检查通过，其他类型 1,920 张前后 PNG 一致，Debug 构建通过。归档于 `~/.cache/MaoStyleCalendar/widget-extra-large-artwork-20261111/`。仅为此类型布局修正，仍需真实桌面观感验收。

## 当前中号右侧三分之二规则

2026-11-11 用户进一步要求中号图片区占整个宽度三分之二并靠右，替代后文历史阶段的 62% 完整主体适配。主体通常按该宽度等比缩放，纵向优先从主体上沿取景，再约束到容纳已标注人脸的窗口；允许裁切部分上下场景。人脸跨度过大时缩小图片，固定画布区域不变，本批仅 pack-0282 使用此回退。左侧三分之一为纸面，渐隐和密度图同步限制于右侧；其他 family 保留原背景分支。

中号日期区与下方语录最小间距为 6pt，底部 18pt、目标 17pt / 最低 13pt 不变。Debug 构建通过；2,280 张组合样张、1,080 组边界检查通过，其他类型 1,430 张前后 PNG 一致。全 133 张背景两种中号尺寸共 532 张图通过比例、对齐、人脸边界和字号检查，另有 266 组文字/日期边界检查通过。归档：`~/.cache/MaoStyleCalendar/widget-medium-two-thirds-20261111/`。

2026-11-11：按用户确认替代固定底部对齐；随后用户明确可读性优先，允许适当遮挡插画。仅调整已有候选插画 Widget，Duo 超大竖版和锁屏不变。

## 区域资源

`Native/Resources/DailyArtwork/widget-composition.json` 使用版本 1；以 JPG 相对路径索引 133 张独立插画，365 套内容复用对应记录。

- `columns` / `rows`：24×36 网格。
- `ink`：逐行 UInt8 权重，十六进制编码；低值代表纸面留白，高值代表较多色彩或边缘。
- `protectedRegions`：原图左上为原点的归一化人脸矩形。
- `sourceChecksum`：对应 JPG 的 SHA-256，与内容清单 `assetChecksum` 相符才启用。

离线生产：取原图顶部纸面参考区域中位 RGB，计算偏离纸色的连续强度；与灰度边缘强度按 82:18 混合，再按面积缩至网格。使用 macOS Vision 全图与底部重叠分块检测人脸，去重后加外边距；对骑马队伍、背向读书人物补充人工保护框。本批共 323 个检测或补充框，允许重复保护。原图像素不变。

本轮生成脚本及记录归档在 `~/.cache/MaoStyleCalendar/widget-quiet-layout-20261111/`（make-atlas.py、detect-faces-tiled.swift、faces.json、manual-protection.json、atlas-production.json）。后续插画更新应重新生成对应数据及清单 checksum；不得直接沿用旧图区域。

## 排版

日期、星期、农历组成固定左上矩形，语录候选区域位于其下方或右侧。按实际背景裁切投影密度图与人脸框。固定宽度和实际字号分别测量完整文字高度，在可用区域内比较候选位置，保护日期块，优先避开已标注人脸，再兼顾低密度、字号和留白。保持底部 padding，字号下限为小号 11pt、中号 13pt、大号 16pt、横向超大 36pt；横向超大目标字号为 42pt，并按目标 family 统一采用 iPad 布局，避免 iPhone 调试预览误用较小字号。达到下限后允许覆盖插画；先使用完整语录，若在所有候选区域都放不下，则按最低字号和完整剩余宽度尾部省略，VoiceOver 仍保留全文。中号按主体范围适配右侧区域（见后文），其他尺寸裁切与全部插画透明度保持原规则。

运行时不执行 Vision 或逐像素图像分析，只读取已生成的小型网格。资源缺失或 checksum 不匹配时退回既有 illustrationRegion 粗略分区。密度图不等于完整语义分割：衣物、建筑、器物只能通过图案密度避让，人脸检测也可能漏检；极密构图不能保证完全空白背景，超长语录可能尾部省略，需要继续实机视觉验收。

## 本阶段验证

`xcodebuild -project ios-client/MaoStyleCalendar.xcodeproj -scheme MaoStyleCalendar-iOS -configuration Debug -destination 'generic/platform=iOS Simulator' ... CODE_SIGNING_ALLOWED=NO build` 通过。

显式 `--widget-artwork-qa --widget-quiet-layout-qa` 模式生成样张，不影响正常启动。iOS 26.5、27.2 及现有 iPad 路径合计 1,520 张正常/探针图；720 组非 Duo 探针检查通过日期区隔离、文字可见性与边界，已标注人脸框零相交。覆盖 8 张不同构图、短/普通/最长语录、普通/紧凑小中号、大号、横向超大和五种显示开关组合。Duo 竖版 40 张前后 PNG 完全相同；133 张 JPG 与已批准批次哈希相同。样张验证基于 ImageRenderer，尚未作为真实桌面 Widget 安装验收，也不代表所有 365 天视觉均已人工通过。

## 最低字号修订验证

2026-11-11：新增用户反馈的 pack-0104 样张与所选字号诊断，诊断只在显式 --widget-quiet-layout-qa 参数下记录，锁保护数据，不影响正式绘制。共 1,710 张样张，1,296 次字号下限检查通过，810 组显示状态/边界/日期区隔离检查通过；不再以零人脸框相交作为硬性验收。Duo 40 张前后 PNG 完全一致，Debug 构建通过。最低字号阶段样张与报告见仓库外 `~/.cache/MaoStyleCalendar/widget-min-font-20261111/`。

## 横向超大字号修订验证

2026-11-11：增加用户截图 pack-0078，横向超大目标 42pt / 最低 36pt，宿主 iPhone 预览与 iPad 渲染统一。共 1,900 张样张，900 组边界与日期区检查通过，240 次横向超大字号检查通过；100 张横向超大跨设备 PNG 完全一致，其余类型 1,440 张修改前后 PNG 完全一致。Debug 构建通过。日志与样张归档于仓库外 `~/.cache/MaoStyleCalendar/widget-extra-large-font-20261111/`。此前阶段的 +9pt 增量记录为历史方案，横向超大现按此独立字号执行，不再叠加该增量。

## 中号主体适配

2026-11-11：systemMedium 不再将整张竖版图放大铺满横向画布。将 illustrationRegion 与已标注人脸框合并，并与源图边界求交，按右侧最多 62% 宽度与完整卡片高度等比容纳，右/底对齐。源图左侧 6% 渐隐以接入纸面；图像外区域是纸色，不应把原图边缘网格延伸至文字区。WidgetArtworkCrop 的 fittingIllustration 参数仅中号为 true，sourceRect 此时可以超出原图归一化范围，表示整个画布在原图坐标系中的投影。密度图与保护框必须复用该变换，不得仍按铺满裁切计算。

中号增加约 28% 可用宽度的语录候选（仍至少 88pt），便于利用左侧留白。最低字号、日期区隔离与极长语录省略规则不变。适配区域来自已有数据，并非重新分割或重新生成插画；完整语义构图仍需人工验收。

显式 --widget-artwork-qa --widget-quiet-layout-qa --widget-medium-artwork-qa 可生成全背景中号检查，输出 WidgetMediumArtworkQA。133 张独立背景、两种中号尺寸共 532 张正常/探针图，主体及人脸框均在边界内，266 组文字/日期/边界检查通过；现有跨平台样张检查 990 组通过，其他类型 1,300 张前后 PNG 完全一致，Debug 构建通过。归档：`~/.cache/MaoStyleCalendar/widget-medium-artwork-20261111/`。
