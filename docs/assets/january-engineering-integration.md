# 1 月 31 套素材接入今日页

日期：2026-11-06。阶段：工程接入完成，等待用户统一视觉验收；不推进 2 月。

## 目标、方案与边界

用户确认 1 月离线制作结果，要求先接入工程和常规今日页，再统一微调。将 31 套压缩 JPG 和语录版式导入 Apple 客户端，抽出共用页面渲染器；今日卡片直接使用完整插画、原分行／分列、各图配色及最新版日期排版。保留铜环、翻页和翻转详情。

当前仅有 31 套、语录底本与授权仍待核验，因此 **常规 iOS Debug 今日页默认使用这批素材，Release 继续排除候选内容**。本轮是工程接入，不是发布批准。Debug 按公历民用日期相对 2001-01-01 的天数对 31 取模，连续 31 天可看完一轮；重启、时区变化后的同一民用日期映射稳定。原扫描月份、页上日期不参与分配。此循环仅供当前素材审阅，未更改 CalendarCore 的 365 套年度确定性洗牌及闰日规则，也不声称年内不重复。

年度册、Widget、壁纸工坊暂不替换。旧 10 张试制入口和文件保留。

## 资源放在哪里

| 用途 | 当前真实位置 | 管理方式 |
| --- | --- | --- |
| 本批 App 优化背景 | `ios-client/Native/Resources/DailyArtwork/backgrounds/` | 31 张原编码 JPG，共 6,087,909 字节；通过文件夹资源打包，按 URL 读取，不重新转成 PNG |
| 背景、语录、版式配对 | `ios-client/Native/Resources/DailyArtwork/content-packs.json` | 稳定 ID、图片名、分行／分列、归一化坐标、字号、配色、修订、来源及输出哈希；无固定日期 |
| 旧 10 张试制 | `ios-client/Native/Resources/ArtworkTrials/` | 保留历史对照，仍只在 iOS Debug 打包；与新资源间有 4 张历史重复，未擅自删除 |
| 纸纹、朱红印刷纹理、铜环等装饰 | `docs/design/handoff/v2/resources/DecorCandidates.xcassets` | 工程已有 Asset Catalog 引用；本轮不搬动 |
| Tab 和功能图标、壁纸排版图标 | `docs/design/handoff/v2/resources/IconCandidates.xcassets` | 工程已有 Asset Catalog 引用；本轮不搬动 |
| 字体与许可证 | `docs/design/handoff/v2/fonts/`、`licenses/` | 工程直接引用既有文件，本轮不换字体 |
| 设计原稿／设计资源母版 | `docs/design/handoff/v2/approved/`、`resources/masters/` | 设计与来源归档，不能把全部文件视为已打包资源 |
| 扫描原件 | `/Users/ideabox/Desktop/毛选/` | 不可变输入，不进工程 |
| 清洗无损母版、提示词及离线对照 | `/Users/ideabox/Desktop/毛选资源制作/batches/source-month-01/` | 仓库外制作归档；App 仅接收压缩 JPG 和精简结构数据 |

现阶段无需移动既有装饰目录。后续若统一收拢 Apple 专用装饰到 Native/Resources，可单独迁移并核对引用，避免将路径整理和本轮视觉微调混做。

## 今日卡片行为

- `ArtworkPage` 同时描述新批次和旧试制；`ArtworkPageSurface` 统一渲染 360×540 设计坐标，完整缩放到 2:3 插画区域，不拉伸、不裁人物。
- 卡片使用完整 2:3 插画；普通 iPhone 依据实际可用宽高约束卡片宽度，短屏优先完整显示插画。
- 月份增大两号；年份＋星期和干支年农历同字号，顶部三行右对齐、底部三行左对齐。日期来自选中公历日，农历按该日本地正午计算，支持春节换干支和闰月。
- 横排保持逐行文本；竖排保持从右向左列顺序和逐字步长。语录、日号、月份、年份、星期、农历均为 SwiftUI 文字，JPG 没有日期或语录。
- App 内复核发现 pack-0014 原字号靠近人物面部，在工程 JSON 中将字号比例由 0.046 调为 0.039、内容修订为 2；分行、图片和原扫描不变。该工程微调不覆盖仓库外原制作预览，工程 JSON 为本轮 App 呈现依据。
- 今日页显示简短“素材预览／31 套·出处待核验”；分享文本继续说明来源待审，未补造中文篇名或英译。

## 新增与修改文件

新增：`Native/App/ArtworkPage.swift`、`DailyArtworkCatalog.swift`、`DailyArtworkQA.swift`，`Native/Resources/DailyArtwork/content-packs.json` 及 31 张 JPG，本接入说明。

修改：`TodayView.swift`、`RootTabView.swift`、`ArtworkTrialGallery.swift`、`MaoStyleCalendar.xcodeproj/project.pbxproj`，结构文档、素材清单、文档索引与项目状态。工程变更只增加 iOS App 源码／资源引用和 Release 候选资源排除；构建设置比对确认除此之外无变化。

明确未改：CalendarCore 源码、年度算法、Widget 源码及资源目标、其他平台专项适配、壁纸工坊与导出逻辑、字体／装饰资源、签名、Bundle ID、Team、Version／Build、部署版本、依赖、网络权限及扫描原件。

## 验证结果

证据目录：`/Users/ideabox/.cache/MaoStyleCalendar/january-integration-20261106/`。

- `swift test --package-path ios-client/Packages/CalendarCore`（仓库外 scratch）：28 项通过。
- `xcodebuild`：iOS Simulator Debug、Release 均成功；Debug 的 App 包含 31 新图和 10 旧试制图，Release 两个候选目录均不存在。
- `DailyArtworkQA`：在 App 进程内解码 31 套，逐图核对 SHA-256、200 KB 预算、1024×1536 尺寸、稳定配对与 candidate 状态；实际 SwiftUI 今日卡片渲染 31 张，验证连续 31 日覆盖全部 ID，以及 2026-11-06 农历和 2027 春节前后干支换年。
- 已观察 iPhone 17 Pro 模拟器常规今日页、红底卡片、详情翻转；31 张渲染文件为独立组件证据，不冒充全部页面截图或真机验收。
- 31 张工程 JPG 的哈希与交付成品一致；365 张原扫描再次复核哈希未变。资源路径、Release 排除和工程 plist 检查通过。
- `git diff --check`、`git status --short`：延续仓库整体未跟踪状态，无构建产物或扫描母版进入工程目录。

完整命令、构建日志及 App 内报告保留在证据目录。`--daily-artwork-qa` 与 `--review-pack=pack-xxxx` 仅为 Debug 验证启动参数，正常启动不导出文件或强制跳转选定图片。

当前真机不可连接，未将本次模拟器检查记为真机通过。仍待用户统一检查画面、字号、对齐、农历和短屏观感；语录底本、英文对应和授权审核独立保留。建议先完成本轮今日页微调，再扩展其他页面与月份。

## 2026-11-06 日期信息区微调

用户指出：左上日号模板的右侧三行信息过于靠上，两种顶部模板的字号也不一致。原实现确实分别使用不同字号，不是截图缩放造成。现统一两种顶部模板的月份为 `360×0.048+2 = 19.28` 设计点，年份／星期与农历为 `360×0.023+2 = 10.28` 设计点，保持三行右对齐。左上日号模板的信息区起点由画布高度 0.018 改为 0.04，整体下移 11.88 设计点（在 360×540 坐标系下），右上日号模板的位置不变。

只修改 ArtworkPage.swift 与本记录／项目状态。日号、语录、背景 JPG、配对数据、底部模板及工程配置不变；此新决定替代此前两个顶部模板采用不同字号的规则，历史记录保留。运行 iOS Simulator Debug 构建及实际 SwiftUI 叠字复核；本次不改业务逻辑，不重复核心层测试。证据归档于 `/Users/ideabox/.cache/MaoStyleCalendar/date-information-adjustment-20261106/`。

本次验证完成：Debug 构建成功，App 内重新生成 31 张卡片，农历检查通过；抽看 pack-0022（左上日号）和 pack-0033（右上日号）确认月份与辅助行同字号，位移生效，无日期区遮住人物。模拟器已更新至此构建，恢复正常启动，不携带 QA 参数。Git 状态仍为原有整体未跟踪，无新增异常文件；无新增源码或资源文件，背景和工程配置未改。

## 2026-11-06 顶部留白卡片的日期模板纠正

用户要求共同调查画面采用左上大日号、右上月份／年份星期／农历的版式。检查本月只有 pack-0009（青年共读）和 pack-0010（共同调查）还在用底部紧凑模板，两者顶部均有足够留白，因此将工程 JSON 中这两套的 datePosition 从 bottomLeftCompact 改为 topLeft，修订升为 2；采用刚确认的顶部字号、信息区下移与右对齐规则。

仅修改本批 content-packs.json、本文档和项目状态。背景 JPG、语录坐标／分行、日期渲染代码、字号、工程配置及原扫描未改。旧 10 张试制入口仍保留历史数据，本轮修改常规今日页使用的 DailyArtwork 数据。后续制作优先使用顶部空白摆放日期，不因原扫描的底部日期条而沿用底部模板。

本次模板纠正验证完成：iOS Simulator Debug 构建成功，App 内 31 套重新渲染通过；已查看 pack-0009、pack-0010 的当前渲染，顶部日号／三行日期与语录之间留有间距，不覆盖人物。31 张 JPG 哈希不变，对比修改前后 JSON 仅两套 datePosition、revision、notes 有变化。git diff --check 通过，Git 延续原有整体未跟踪状态，无异常产物；未新增文件、未重复核心业务测试。模拟器已更新，恢复正常启动并定位到共同调查卡片，等待用户看效果。

后续范围变更：用户于同日授权接入年度册／壁纸并将壁纸改为两种模式；见 [年度册与壁纸接入记录](yearbook-wallpaper-integration.md)。本文此前“年度册与壁纸不替换”是当时阶段边界，已由该后续请求覆盖，其他月份制作继续暂停。
