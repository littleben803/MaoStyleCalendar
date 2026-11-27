# 项目状态

2026-11-26 桌面 Widget 插画颜色与今日卡片一致：用户对照 11 月 25 日桌面大 Widget 和 App 今日卡片，指出前者整体发浅。两处使用同一插画资源；原因是 `ArtworkWidgetView` 在显示语录时给整张插画施加 0.78 不透明度，露出下方米白纸色。移除全图淡化，保留现有语录留白选位与文字光晕，不改图片、日期、语录或 Widget 裁切规则。iOS 模拟器无签名 Debug 构建通过；现有 Widget QA 生成 280 份布局渲染，抽查大卡文字可读；同一样张有语录/无语录时插画区域像素完全一致。未修改 Mac Widget、资源、工程、签名或购买逻辑。

2026-11-20 App/Widget 版本对齐：用户要求修复 iOS 构建的扩展版本不一致警告。核对四个 target 后，以原 iOS 主 App `1.0.1 (1)` 为准，把 iOS Widget、macOS App 和 macOS Widget 的 Debug/Release `MARKETING_VERSION` 从 `1.0.0` 调为 `1.0.1`；`CURRENT_PROJECT_VERSION` 均保留 `1`。iOS 设备 Release/模拟器 Debug 与 macOS Debug 无签名构建通过，iOS Release/macOS Debug 产物内四个主 App/Widget 的 Info.plist 均读回 `1.0.1 (1)`，先前扩展版本不一致警告消失。仅修改 Xcode 工程版本号与本文；未修改 Bundle ID、Team、签名、Info.plist 内容或功能代码。

2026-11-20 App 加密出口合规选项核对：按当前代码、Swift Package 依赖与 iOS 设备 Release 产物检查，主 App 使用 StoreKit、WebKit 与系统 Security/CommonCrypto 能力；链接的 Firebase Analytics Core 未见随包附带的 OpenSSL/BoringSSL 或 gRPC 加密框架。对照 Apple 现行出口合规说明，当前 App Store Connect 弹窗中选择“不属于上述的任意一种算法”与仅使用 Apple 系统加密的实现相符。用户明确要求免除后续重复问卷，已在 iOS/macOS 共用的 `Native/Configuration/App-Info.plist` 加入布尔值 `ITSAppUsesNonExemptEncryption = NO`，不表示 App 完全不用加密。`plutil -lint`、iOS 无签名设备 Release/模拟器 Debug 构建、macOS Debug 构建及 iOS Release/macOS Debug 产物的 Info.plist 读回均通过；未修改 Widget plist、工程、签名或 App Store Connect 后台。iOS 构建仍有既有警告：Widget 扩展版本 1.0.0 与主 App 1.0.1 不一致，本阶段未改版本配置。

2026-11-20 桌面 Widget「每日换插画」购买后自动开启：该开关默认关闭，未解锁时尝试开启会进入付费墙。用户要求无论从哪个付费墙入口完成购买，只要永久解锁权益由未确认/未拥有切为已确认拥有，就自动把此开关写为开启并刷新 Widget 时间线。实现集中于 `AppSettingsLibrary.refreshFullAccess()` 的统一 StoreKit 权益刷新处，涵盖直接购买、恢复购买、交易更新与外部兑换后的权益同步；Debug 模拟购买从关闭切为开启也同样处理。读取 App Group 中已保存的权益状态，已购用户后续手动关闭开关时，重启 App 不会再次强制开启。iOS 模拟器与 macOS 无签名 Debug 构建均通过。仅修改设置/权益联动代码；未改付费墙界面、商品标识、Widget 排版、签名或工程配置。真机 Sandbox 交易仍待联调。

2026-11-20 年度册英文缩略卡字号统一：用户以 11 月 13 日红字卡为基准，要求所有英文缩略卡语录同样大。缩略卡改为固定 360pt 设计画布上的 23pt Source Serif 4 字号；长句按可用留白区生成带省略号的短摘录，详情及其他完整卡面保留全文。缩略卡不再套用今日页铜环顶部的避让区，但仍避开日期与人物保护区。iPhone 17 Pro 模拟器 Debug 构建通过，运行检查覆盖 365 张卡，均以 23pt 排入安全区域且无文本越界；其中 243 张需要短摘录。11、13、14 日卡片渲染图已目检，均为相同字号。仅修改英文缩略卡排版及专用 Debug 检查入口，未改 Widget、中文排版、资源、工程及签名；渲染图位于模拟器缓存 `YearbookThumbnailQA/`，不进入仓库。

2026-11-19 v2 资源检查脚本图标数量修正：当前 `vector-spec.json`、资源说明和实际 SVG/PDF 均为 18 个候选界面图标，旧脚本却断言 20 且成功文案写死 20。将断言改为 18、成功文案改为输出实际数量后，完整资源检查通过（15 张装饰 PNG 导出、18 对矢量图标、10 张原稿/看板未变）；同步生成 `qa-report.json`、资源子清单与 v2 总清单。未修改图标本体、App/Widget 代码、工程配置或宣传图；仅资源核验工具和清单状态变化。

2026-11-19 字体减量验收完成：用户确认先前映射效果后，删除活动 v2 字体目录中的思源宋体 SC SemiBold 与 Regular 两份 OTF，并移除 iOS App、macOS App 与 macOS Widget 的 Xcode 资源引用；iOS Widget 继续通过容器 App 读取保留字体。运行时字体映射未改：中文标题与语录使用思源宋体 Bold，中文正文使用 Apple 系统 Regular。更新当前字体规范、资源清单、Release 包校验脚本与相关 manifest，历史设计研究和宣传图源包不改。相同源码状态、相同无签名设备 Release 构建口径下，删除前 `.app` 文件合计 137,078,849 字节（130.73 MiB），删除后 87,834,769 字节（83.77 MiB），减少 49,244,080 字节（46.96 MiB、35.9%）；相同 Payload 结构的 DEFLATE level 6 参考压缩包从 113,673,686 字节（108.41 MiB）降至 73,272,613 字节（69.88 MiB），减少 40,401,073 字节（38.53 MiB、35.5%）。参考压缩包不是签名 IPA、App Store 下载量或设备实际磁盘占用。iOS Release、iOS Debug 与 macOS Debug 无签名构建成功；Release 包完整性和三份保留字体的哈希、注册、字重及样本字符检查通过，macOS App/Widget 也只含思源宋体 Bold。原字体与工程文件备份、构建日志、压缩参考包均在仓库外 `~/.cache/MaoStyleCalendar/font-prune-20261119/`。v2 资源脚本 `resources/scripts/verify.swift` 因既有图标数量断言 20 与实际 18 不符而失败；改用逐条哈希核对，v2 与资源子清单均零失配，未扩大范围修改该旧断言。未改 App/Widget 业务代码、宣传图、签名、Bundle ID、版本或 App Store 配置。

2026-11-19 App 图标头像更新：按用户提供的 292 × 236 红底参考图，用内置 ImageGen 抠出并高清重绘黑白版画头像，再放入现有朱红页眉、双装订孔、米白纸面的日历图标。用户随后要求头像再放大，并在米白纸面内水平、垂直居中，已修订完整 v2 候选。透明人物层及完整候选归档于 `docs/design/handoff/v2/brand/`；两份中英文 AppIcon 的 `Any.png` 替换为同一 1024 × 1024 不透明导出，Dark/Tinted 仍由系统处理。原图副本和旧图标备份仅在仓库外缓存；官网 Logo、宣传图、业务代码、Widget、工程配置与签名未改。尺寸、Alpha、哈希及 96 px 缩图已核对，无签名 iOS 模拟器 Debug 构建通过；真机主屏幕尚未验收，商用授权未因此升级。详见[制作记录](design/handoff/v2/brand/app-icon-portrait-red-candidate-v2.md)。

2026-11-19 App 与 Widget 三设备布局验收规则更新：用户明确确认今日卡片背面的固定 Header 只显示“语录详解”，不显示日期；此前“标题和日期固定”的规则由此替代。用户同时确认 App 内 Widget“原尺寸”预览通过，不将预览弹窗内的可见范围记为布局缺陷。仅同步当前规则与验收结论，未修改 App/Widget 代码、资源、宣传图或工程配置。

2026-11-19 新手引导触控复核：用户报告上轮改动后欢迎页仍不能点击。复核确认 App 主线程运行、Xcode 未停在断点，辅助功能动作可调用页面处理；真正失效的是 Device Hub 紧凑设备窗口的坐标输入，工具返回 `noWindowsAvailable` / `windowNotFoundAtPosition`。已撤回上一轮 `StartupView.swift` 的试探性命中测试改动；重启 Device Hub 后在完整设备视图以实际屏幕坐标验证欢迎页点击进入引导、继续按钮翻页、横向拖动翻页、跳过按钮进入今日页，均成功；重新切回紧凑窗口时坐标输入仍报错，切回完整视图后再次成功。当前将 Device Hub 保持在完整视图、引导第 1 页供用户复验。Apple Xcode 27.2 版本记录记载过 Device Hub 停止转发触摸输入的修复项，但本机紧凑窗口的具体触发机制未确定。本阶段无 App 代码净变更，仅更新本文；撤回后无签名 iOS 模拟器 Debug 构建成功，字体文件、业务、工程配置和签名未改。

2026-11-19 收到 iPhone 17 Pro 模拟器新手引导“继续、滑动、跳过均无反应”的反馈。检查发现 `StartupView` 在全屏引导的呈现宿主上设置了根视图 `.allowsHitTesting(!presentsOpening)`，可能连带影响弹层的指针命中；移除此限制，保留开屏覆盖层的点击关闭逻辑。仅修改 `ios-client/Native/App/StartupView.swift` 和本文，未改引导页面、字体、内容、购买、工程配置或签名。无签名 iOS 模拟器 Debug 构建成功，修复版已安装到 iPhone 17 Pro / iOS 26.5；设备辅助功能操作验证“下一页”从第 1 页进入第 2 页、“继续”进入第 3 页、“跳过”关闭引导并进入今日页。设备窗口的坐标点击及拖动自动化接口返回 `noWindowsAvailable`，因此真实触摸和左右滑动尚待用户手动复核，当前不将故障标记为完全验证解决。构建日志与采样文件位于仓库外缓存，无新增仓库文件；Git 仍为既有整体未跟踪状态。

2026-11-19 字体减量试用阶段按用户指示完成代码映射：`CalendarTypography` 的中文语录角色改用现有思源宋体 SC Bold，中文正文角色改用 Apple 系统 Regular；中文标题、英文字体与日期数字角色未改。SemiBold 和 Regular 字体文件、工程资源引用仍保留，待用户视觉验收后另行删除，因此本阶段不产生安装包体积收益。iOS 模拟器无签名 Debug 构建成功，iPhone 17 Pro 今日页改动前后截图已保存于仓库外 `~/.cache/MaoStyleCalendar/font-role-switch-20261119/`；中文语录加粗且画面无明显截断。尚未完成正文及 Widget 的运行画面对照，也未验证真机、iOS 17 或 Mac 运行。未改业务、内容、布局、工程配置、签名、版本或发布设置。仅修改 `ios-client/Native/Shared/CalendarTypography.swift` 和本文，无新增仓库文件；等待用户验收后再处理字体文件。

2026-11-19 安装包优化第一阶段按用户指示完成：仅从新手引导删除 iPad/Duo 的 18 张专用图、仅供 Duo 横向详情卡使用的 2 张图，以及 `OnboardingView.swift` 中对应设备识别、横向布局和分支；iPad/Duo 若运行引导将使用普通单栏 iPhone 布局，其他平台页面、Widget 与 targets 不变。保留的 12 张 iPhone 引导 PNG 用 macOS `sips -s format heic -s formatOptions best` 转为 HEIC，更新读取扩展名、manifest 文件名/哈希和资源状态记录。12 张源 PNG 共 24.13 MiB，HEIC 共 15.17 MiB；32 张旧 PNG 与旧清单备份在仓库外 `~/.cache/MaoStyleCalendar/onboarding-size-20261119/original-OnboardingPreview/`，仓库内删除旧 PNG。无签名 iOS 模拟器 Debug 与设备 Release 构建成功，Release bundle 完整性脚本通过；当前 Release `.app` 文件合计 137,012,405 字节（130.67 MiB），相对本轮修改前同口径 189,180,232 字节（180.42 MiB）减少 52,167,827 字节（49.75 MiB、27.6%）。逐文件 DEFLATE level 6 参考值由 154.85 MiB 降至 108.31 MiB，均非 App Store 实际下载或安装体积。iPhone 17 Pro / iOS 26.5 模拟器实际启动并核对中文小组件页、英文今日页和英文壁纸页，HEIC 图层、文字与透明边缘正常；未覆盖 iOS 17 运行时或真机。未修改字体、内容库、购买业务、工程配置、签名、Bundle ID、版本及其他页面。未新增仓库文件；下一阶段待确认后评估字体子集，不在本阶段实施。

2026-11-17 用户确认采用当前无字头像图标及系统自动深色/着色处理方案，图标视觉方案定稿；该确认不升级参考头像的商用授权状态。本轮仅测量包体并记录决定，未进一步修改图标、业务或工程。当前真机 Debug .app 文件合计 194,466,476 字节（185.46 MiB）；现有源码无签名设备 Release 构建成功，.app 文件合计 189,180,880 字节（180.42 MiB）。使用 Python zipfile、DEFLATE level 6 生成仓库外 Payload 结构压缩参考包：Debug 162,246,027 字节（154.73 MiB），Release 162,416,048 字节（154.89 MiB）。此压缩参考包不是正式导出/签名分发 IPA，也不是 App Store 下载量或设备实际磁盘占用。资源大头为三款中文字体 71.30 MiB、32 张 OnboardingPreview PNG 及清单 64.62 MiB、DailyArtwork 27.63 MiB。源码确认引导图有按设备/语言动态引用，不能按字符串未命中认定无用；Duo/iPad 资源在普通文件夹内，不能假设会被 App Store 自动裁剪。优化建议先评估引导图的显示分辨率/编码与视觉对照，再评估字体子集化的完整字符覆盖、授权与字体身份保留；本轮未实施优化，不承诺节省量。执行本地文件统计、源码引用检索、xcodebuild Release（CODE_SIGNING_ALLOWED=NO）、zipfile、git diff --check、git status；沿用上一阶段真机 Debug 构建/安装成功结果，未重装 Release。所有测量包与日志均位于仓库外 ~/.cache/MaoStyleCalendar/icon-auto-device-20261117/。仅修改状态及候选记录，无新增仓库文件，Git 维持既有整体未跟踪状态。

2026-11-17 图标外观改为系统自动处理并清理无用资源：按用户要求移除 AppIconChinese/AppIconEnglish 两份 Contents.json 的 Dark/Tinted 文件引用，保留空外观槽位；随后按用户补充要求删除四张对应 PNG，仅保留 Any.png。源资源减少 3,872,648 字节（3.69 MiB），不等同于安装包节省量。最终 Debug 真机签名构建通过，未再出现未引用图标资源警告；assetutil 检查编译后的 AppIcon 仅含 default 外观。已覆盖安装到 iPhone 17 Pro Max，启动成功，返回桌面截图确认默认头像图标正常。系统自动深色/着色效果待用户在主屏幕自定外观中查看，未记为已专项验收。删除四张 PNG、修改两份 Contents.json 及品牌 README/候选记录/本文，无新增仓库文件；Any.png、业务、工程、签名和版本不变。执行 JSON/文件检查、xcodebuild、assetutil、devicectl、git diff --check、git status。证据在仓库外 ~/.cache/MaoStyleCalendar/icon-auto-device-20261117/；Git 仍为既有整体未跟踪，无新增异常产物。本阶段完成，等待用户真机外观确认。

2026-11-17 无字头像图标真机预览完成：用户确认候选 v1 并授权部署后，将候选等比导出为 1024×1024 不透明 PNG，替换 Brand.xcassets 中 AppIconChinese/AppIconEnglish 的 Any、Dark、Tinted 六张图，保留资源 ID 与 Contents.json，各外观暂用同一候选。沿用现有工程签名在 iPhone 17 Pro Max 上 Debug 构建、覆盖安装、启动成功；实际截图确认今日页正常显示，返回桌面后新版头像图标完整显示。未修改业务、工程、签名、版本、官网 Logo 或历史原稿；未切换验证深色/着色外观，用户真机视觉验收与商用授权仍待确认，不代表上架批准。修改六张图标及品牌 README、候选记录、本文，无新增仓库文件。执行 sips、哈希、xcodebuild、devicectl、git diff --check 和 git status；Git 保持既有整体未跟踪，无新增异常产物。证据和旧图备份均在仓库外缓存，详见[候选及真机记录](design/handoff/v2/brand/app-icon-portrait-candidate-v1.md)。本阶段完成，等待用户确认实际桌面效果。

2026-11-16 用户确认 Android 包名固定为 `com.ideaboxapps.maostylecalendar.android`，后续工程 applicationId、备案和正式打包保持一致；公开标识同步记录于 AGENTS.md 第 7.1 节。当前 android-client 仅有预留说明，尚未创建工程或配置包名；本次仅记录决定，未修改业务、Apple 工程、签名或后台，未运行 Debug 构建。

2026-11-13 用户要求完成En标题及搜索图后直接归档。英文两张已完成并归档：header/en/20261113/AppStore-header-en-3840x1646.png（8种Widget层叠、无外部标题），search-results/en/20261113/AppStore-search-en-3840x2560.png（左文案“Good words, at a glance.”及“Daily quotes meet hand-drawn art.”、右桌面Widget手机）。两张分别位于 docs/marketing/exports/ 下；源素材、提示词、字体/排版、缩略及离线安全区裁切位于各自 source/20261113-en-v1/。内置ImageGen本地化主体，保留13/Nov/Fri和18/Nov/Wed完整日期；语录仍为项目编辑译文/短摘句，不记为出版底本核验升级。英文拼写、布局、离线安全区主内容、尺寸/RGB无Alpha/星期/哈希、归档字节一致和源清单读回通过，既有26张成品哈希不变。本次为按用户授权直接归档，不伪记为另行用户逐图视觉验收；未后台实际预览或上传。只新增两套归档及汇总清单、修改宣传README和本文，App/Widget、工程、签名、版本与后台未改，未运行Debug构建、未提交；Git保持既有整体未跟踪状态，无新增异常构建文件。

2026-11-13 用户确认中文搜索结果v1并要求“可以，归档吧”。原样PNG归档至 docs/marketing/exports/search-results/zh-Hans/20261113/AppStore-search-zh-Hans-3840x2560.png，3840×2560px RGB无Alpha；源素材、提示词、字体、排版、缩略和离线安全区截取位于 search-results/source/20261113-zh-Hans-v1/。候选与成品逐字节相同，尺寸/模式/哈希读回和源清单复核通过；重建排版输出独立目录，不覆盖确认成品。单图直接供上传，无ZIP，未上传或后台跨设备预览，英文搜索未制作。只新增搜索归档和更新宣传README及本文；App/Widget、工程、签名、版本、标题成品与既有24张截图未改，未运行Debug构建、未提交；Git保持既有整体未跟踪状态，无新增异常构建文件。

2026-11-13 用户授权开始搜索结果材料，并补充Apple官方示例说明可加标题和宣传语。中文搜索v1候选完成，待视觉确认：左侧“好句子，就在桌面”及“每日语录，遇见手绘之美”，右侧正面iPhone桌面和大小Widget浮层，无外层App Store界面。内置ImageGen独立生成主体，日期13/11月/星期五完整；项目字体单独排版。候选与提示词位于仓库外 candidates/search-widget-zh-v1/。规格3840×2560px RGB无Alpha；图片/字体加载、文字溢出、标题安全边界、尺寸/星期/哈希通过，已目视核对整图和官方安全区x836/y765/w2168/h1030截取中的关键日期/语录/面部；未后台实际预览，不宣称整个设备或所有辅助画面跨设备完整可见。只改宣传README及本文，标题确认稿、24张既有宣传图、App/Widget、工程、签名、版本及后台未改；未运行Debug构建，未归档打包提交上传。

2026-11-13 用户确认中文Widget-only标题v2并要求“归档吧，然后我上传”。确认PNG原样归档至 docs/marketing/exports/header/zh-Hans/20261113/AppStore-header-zh-Hans-3840x1646.png，3840×1646px RGB无Alpha；生成母图、初始及修正提示词、规格、缩略与离线安全区截取归档至 header/source/20261113-zh-Hans-v2/。成品与候选逐字节相同，尺寸/模式/哈希读回、源清单复核通过。单图直接供用户上传，无ZIP；尚未后台上传或跨设备预览，搜索图和英文标题未制作。仅新增标题归档并更新宣传README及本文，既有24张宣传成品、App/Widget、工程、签名、版本和后台未改；未运行Debug构建、未提交，Git保持既有整体未跟踪状态，无新增异常构建文件。

2026-11-13 标题图Widget-only中文v2候选完成，待视觉确认。用户否决v1外部文字，要求只排小中大Widget并可层叠；进一步要求日数字下补月份/星期。内置ImageGen生成8卡错落层叠朱红场景，无品牌名、标语、手机，保留Widget内日期与语录；13/11月/星期五、18/11月/星期三已按2026年11月核对。中央主卡向下调整使核心日期/语录/人物面部位于安全区，外围卡片按辅助艺术可裁切，不声称全部卡片跨设备完整可见。仓库外候选 candidates/header-widget-zh-v2/ 保存母图、提示词、规格与预览；精确导出3840×1646px RGB无Alpha，尺寸/星期/哈希通过，已目视检查整图和安全区截取；尚未后台实际预览。仅修改宣传README及本文，既有成品、App/Widget、工程、签名、版本、后台未改，未运行Debug构建，未归档打包上传。

2026-11-13 产品页标题中文Widget主视觉v1候选完成，待视觉确认。用户要求先研究官方示例后授权先做标题，并明确核心卖点是桌面小组件；据此采用主语录Widget+小方形插画Widget，品牌名与“把好句子放在桌面上”独立排版，保持单一主题，未采用阅读场景或手机拼版。内置ImageGen生成新主体，既有朱红底图延续；候选及提示词在仓库外 candidates/header-widget-zh-v1/，正式规格3840×1646px RGB无Alpha，品牌与卡片边界在官方x1097/y493/w1646/h661安全区内。图片/字体加载、文字溢出、尺寸/模式、安全区元素边界/哈希通过，已目视检查整图及离线安全区截取；尚未后台跨设备预览。仅改宣传README及本文，未改既有24张中英成品、App/Widget、工程、签名、版本或后台；未运行Debug构建，未归档打包、提交或上传，搜索与英文未制作。

2026-11-13 用户确认英文三设备全部12张并授权“可以，归档吧”。四图分别归档至 docs/marketing/exports/{iphone,DUO,ipad}/en/20261113/，每设备提供仅含四张PNG的上传ZIP；源素材、提示词、字体和排版分别在各设备 source/20261113-en/，另新增英文归档汇总清单。单张尺寸依次为1206×2622、2007×2853、2064×2752px RGB无Alpha；成品与候选逐字节相同，尺寸/精确切片/哈希、ZIP完整性与解压哈希、源清单读回通过。中文12张成品哈希不变。更新宣传索引、iPhone记录、DUO/iPad说明和本文；App/Widget、工程、签名、版本、后台未改，未运行Debug构建，未提交或上传。Git保持既有整体未跟踪状态，无新增异常构建文件；视觉确认与归档不升级出版底本核验、商业授权或实际运行验收状态。

2026-11-13 按用户要求一次完成全部已制作设备英文宣传：iPhone、DUO、iPad 各四张共12张候选，等待统一视觉验收。单张分别1206×2622、2007×2853、2064×2752px RGB竖版，独立沿用各设备中文确认构图和连续背景；内置 ImageGen 本地化九张主体，三张无中文壁纸主体原样复用。标题以项目 Source Serif 4 独立排版；英文卡片采用项目编辑译文及短摘句、详情说明为宣传释义，不升级出版底本核验或商业授权。候选、提示词、字体与原尺寸验收入口在仓库外 candidates/en-all-devices-v1/index.html。图片/字体加载、标题溢出及间距、12图尺寸/RGB/精确切片/哈希通过，九张主体和三组预览已目视核对；已确认中文12图哈希不变。未正式归档、打包或上传，Mac不在本次已确认设备范围。仅更新宣传README、iPhone记录、DUO/iPad说明及本文；App/Widget、工程、签名、版本及后台未改，未运行Debug构建；Git保持既有整体未跟踪状态。

2026-11-13 用户确认 iPad 中文 v1 并明确“可以，归档吧，然后我上传”。四张确认成品原样归档至 docs/marketing/exports/ipad/zh-Hans/20261113/，上传 ZIP 仅含四张 PNG；母版、底图、主体、字体、提示词及排版归档至 ipad/source/20261113/。每张 2064×2752px 竖版 RGB 无 Alpha；候选与成品逐字节一致，尺寸、母版精确切片、SHA-256、ZIP 完整性与解压哈希、源清单读回全部通过。仅新增 iPad 归档并更新 iPad README、宣传索引及本文；App/Widget、iPhone/DUO 成品、工程、签名、版本与后台未改，未运行 Debug 构建，未提交或上传；待用户自行上传。不升级实际运行验收或商业授权状态。

2026-11-13 用户提供 App Store Connect iPad 13 英寸截图要求并授权制作。中文四页 iPad 宣传 v1 预览完成，待视觉确认；选择单张 2064×2752px 竖版 RGB 无 Alpha、母版 8256×2752。内置 ImageGen 独立制作正面竖向 iPad 主体，延续连续红底及文案，首图浮层 Widget、今日大设备与竖长双卡、年度册三列、壁纸及图库四页；不是放大 iPhone/DUO 成品。候选、提示词、字体与排版保存于仓库外 candidates/ipad-preview-v1/，没有 ZIP、正式成品归档或上传。图片/字体加载、尺寸/模式、精确切片、哈希通过，已目视检查主体和整组。仅改 iPad README、宣传索引及本文；App/Widget、iPhone/DUO 成品、工程及后台未改，未运行 Debug 构建，未提交；Git 保持既有整体未跟踪状态。宣传创作不升级 iPad 运行验收、内容核验或商业授权状态。

2026-11-13 用户确认 DUO v4 并要求“归档吧，然后我上传”。四张中文成品原样归档至 docs/marketing/exports/DUO/zh-Hans/20261113/，上传 ZIP 仅含四张 PNG；完整源素材、字体、提示词、母版、底图与排版归档至 DUO/source/20261113/。每张 2007×2853px 竖版 RGB 无 Alpha；确认候选与归档逐字节一致，尺寸、精确母版切片、SHA-256、ZIP 完整性与解压哈希通过。更新 DUO README、宣传索引及本文。App/Widget、iPhone 成品、工程、签名、版本及后台未改；未运行 Debug 构建，未提交或上传，待用户自行上传。归档不升级实际运行验证或素材商业授权状态。

2026-11-13 DUO 今日宣传 v4 完成候选：用户指出手机应更大居中，双卡不应方化变形。仅用内置 ImageGen 重做今日主体，放大居中手机并在排版中与小组件页机身高度对齐，双卡恢复竖长比例、减小旋转和透视，保留超出屏幕的前景叠放。四张均为 2007×2853px RGB PNG，尺寸/精确切片/哈希通过；其他三张 PNG 与 v3 字节一致，已目视核对今日整图。候选与提示词在仓库外 candidates/DUO-simulator-preview-v4/，未正式归档、打包或上传；等待视觉确认。仅改 DUO README 与本文，App/Widget、iPhone 成品、工程及后台未改；未运行 Debug 构建，Git 保持原整体未跟踪状态。

2026-11-13 DUO 宣传 v3 中文四页预览完成，待视觉确认。用户指出 v2 竖屏机身错误；经只读查看当前模拟器，改用最外层真实设备外形参考（左侧近直角/折叠边，右侧大圆角，右上圆形前摄与右侧纵向状态区），不再误用引导插画中的居中前摄手机。进一步依用户指示放大首图两张辅助 Widget 并超出屏幕；今日前卡与详情卡舒展、向两侧延伸，叠放在手机前景，以功能宣传示意呈现。文案及连续红底保持。内置 ImageGen 新生成候选与提示词、可编辑排版位于仓库外 candidates/DUO-simulator-preview-v3/；母版 8028×2853，四张独立竖图严格 2007×2853px、RGB。图片/字体加载、尺寸/模式、精确切片与哈希通过，已目视核对整组及主体。没有 ZIP、正式归档或上传；v2 被本轮纠正替代。仅修改 DUO README 和本文，App/Widget、iPhone 成品、原资源、工程及后台未改；未运行 Debug 构建，Git 保持既有整体未跟踪状态。宣传创作不记为实际运行截图、用户视觉批准或素材商业授权升级。

2026-11-13 用户指出本组 DUO 竖版宣传应展示合拢外屏，而不是展开横向内屏。已按该明确设计要求重做四页设备与卡片：竖向合拢机身、圆形前摄、折叠侧边，今日叠层双卡、年度册外屏两列浏览。标题及单一连续底图不变；8028×2853 母版等分四张 2007×2853 RGB PNG。工作候选位于 candidates/DUO-cover-preview-v2，v1 展开内屏版弃用。图片/字体加载、尺寸/模式、逐像素切片及哈希通过，已目视核对形态与文字。依用户要求只交预览，没有 ZIP 或正式归档，待确认；仅更新状态说明和本文，iPhone 成品、App/Widget、工程及后台未改，未运行 Debug 构建，未上传。

2026-11-13 用户进一步明确 DUO 先只交付预览，确认后再准备下载包和正式归档。本轮刚准备的 DUO ZIP 已撤回删除；未确认素材及源文件从 docs 正式归档目录移回仓库外 candidates/DUO-preview-v1，iPhone 已确认成品不变。DUO 目录现只保留预览状态说明与索引；后续等待用户视觉确认。此条覆盖此前 DUO 已归档打包的状态。

2026-11-13 用户报告 iPhone 中文宣传图已上传，并授权开始 DUO。依据用户 App Store Connect 截图，本轮选用 2007×2853 竖版，母版 8028×2853，四页连续背景与主副标题沿用已确认视觉；独立生成展开态 DUO 小组件、今日双栏、年度册与宽幅壁纸宣传主体。中文四页候选、ZIP、提示词、主体素材、字体与可编辑排版已归档 docs/marketing/exports/DUO/，待用户视觉确认，未上传 DUO。字体/图片加载、尺寸/RGB/Alpha、精确切片、哈希和 ZIP 校验通过，已目视检查整组。仅宣传素材和索引变更，App/Widget、工程、签名、版本及后台未改；无代码修改，未运行 Debug 构建，未提交。iPad、英文及运行适配验收未因此升级。

2026-11-13 用户确认中文四页宣传视觉，并要求按设备归档。四张 iPhone 中文成品与 ZIP 下载包已归档至 docs/marketing/exports/iphone/zh-Hans/20261113/，连续母版、底图、创作主体、提示词、字体与可编辑排版归档至 iphone/source/20261113/。exports/ipad 与 exports/DUO 独立保留为待制作目录；英文尚未完成。图片哈希、尺寸、ZIP 完整性及源文件字体引用已核对。仅归档宣传文件和更新索引，App/Widget、工程、签名、版本及后台未改；归档不涉及 Debug 构建，未提交或上传送审。

2026-11-13 中文 iPhone 四页连续宣传预览完成，待视觉确认。依用户最新要求，最终采用自由创作宣传视觉，替代原生渲染拼版；四页（小组件、今日、年度册、壁纸工坊）均有正面手机，参考新手引导纸张/插画/卡片层次。4824×2622 单一连续朱红底图，准确等分为四张 1206×2622 RGB PNG；每页独立主副标题，没有品牌行、页码、付费说明或免费承诺。内置 ImageGen 生成主体，标题独立排版；本轮没有修改产品内 UI。候选、提示词、可编辑排版、哈希和导出存仓库外 candidates/panorama-creative-v1；详见 docs/marketing/iphone-panorama-preview-20261113.md。

完成图片/字体加载、尺寸/RGB/Alpha、逐像素切片与整体/首图/今日卡片目视核对。仅新增上述说明并更新宣传索引与本文，App/Widget、资源、工程、签名、版本及后台未改；工作区 App 未重建，中途仓库外采集工程 Debug 构建通过，但最终版本未使用该批采集图。Git 仍为既有整体未跟踪状态，未提交大文件、未上传或送审；等待本批视觉确认后再继续英文版。

2026-11-13 用户否决六卡铺满屏幕的 v2，要求按照附件中内层 Duo 展开手机的真实桌面观感，减少卡片并保留常见应用。新增 iap-promotion-20261113/full-access-promo-duo-home-zh-1024-v3.png、prompt-duo-home-v3.txt、manifest-duo-home-v3.json。以现有 Duo 内屏引导图为主要参考，内置 ImageGen 生成三张代表性 Widget（日期读书、书房、乡间共读）和常见应用图标/状态栏/底部 Dock；不包含附件外层引导设备、标语或按钮。仍为 AI 设备效果图，不记为真实硬件照片、实际运行截图或独立选内容功能验收。v1/v2 保留为已否决历史版本。

导出并验证 1024×1024、RGB PNG、无 Alpha、72 dpi，记录 SHA-256，核对三张卡片语录及整体桌面构图。仅新增三份候选资源并更新本文；App、Widget、业务、工程配置与后台均未修改。执行 sips、Pillow 尺寸/模式/DPI 校验、git diff --check 和 git status；资源阶段未运行 Debug 构建，无新增异常构建文件，未上传送审，待用户视觉确认。


2026-11-13 用户否决纸页展开版内购推广图，要求采用展开 Duo 手机内展示多种 Widget 的方案。新增 iap-promotion-20261113/full-access-promo-duo-zh-1024-v2.png、prompt-duo-v2.txt 和 manifest-duo-v2.json；内置 ImageGen 参考现有 Duo 引导、Widget 卡片与骑马插画，制作六卡大小混排、不同背景/语录/文字布局的中文候选图。v1 保留为已否决历史候选。导出 1024×1024 RGB PNG、无 Alpha、72 dpi，已核对生成画面及六条文字，记录 SHA-256；未将概念图作为实际主屏截图、Widget 独立选内容已实现或商业授权升级的证据。顶部推广图全球共用一个槽，本版包含中文；左下系统图标可能覆盖部分边框/乡间插画，上线前需核对后台预览。

仅新增三份候选资源并更新本文；App、实际 Widget 布局、资源池、业务、工程配置及后台均未改。执行 sips、Pillow 尺寸/模式/DPI 核验、SHA-256、git diff --check 与 git status；资源阶段未运行 Debug 构建。无新增异常构建文件，待用户确认本版视觉，未上传或送审。


2026-11-13 内购顶部推广图候选完成。新增 docs/marketing/iap-promotion-20261113/ 下 full-access-promo-1024-v1.png、prompt.txt 和 manifest.json；内置 ImageGen 参考现有 pack-0077 插画及 v2 今日卡片材质，生成铜环/纸页展开构图，无文字、中英文共用，不使用付费墙截图或完整 App 图标。原生成图保留在 ~/.codex/generated_images/，仅将 1254×1254 输出缩放至 1024×1024，PNG、RGB、无 Alpha、72 dpi，记录 SHA-256 与完整提示词。整体和最终尺寸画面已查看；重要骑马人物位于中右，左下无文字或核心人物，预留系统图标叠加空间。候选未上传、未送审；生成不升级既有参考插画商业授权审计状态。

未修改 App、业务逻辑、工程配置、签名、版本或后台。执行 Apple 推广图要求核对、sips 导出、Pillow 尺寸/模式/DPI 校验、SHA-256、git diff --check 与 git status；资源制作未重新运行 Debug 构建。Git 保持既有整体未跟踪状态，无新增异常构建文件。待用户确认视觉后再使用，不主动进入上传或启用内购推广阶段。


2026-11-13 按用户要求精简内购审核备注，仅保留非消耗型一次买断、购买入口、核心权益和恢复购买/无需应用账户四项重点；更新 iap-review-20261113 下三份审核备注 TXT 和使用说明，双语合计 437 字符。截图、商品描述和 App 均未改，无新增文件；执行字符长度检查、git diff --check 与 git status，通过。纯文案调整未重新运行 Debug 构建，无新增未解决问题，待用户确认精简版。


2026-11-13 中文 iPhone 小组件宣传首图候选完成，待用户视觉确认。按用户要求整组顺序调整为小组件、今日、年度册、壁纸工坊；先只做首图，确认后再完成整组中英。宣传按完整功能展示，不出现付费、解锁或价格说明。首图为 1206×2622 RGB PNG，采用既有纸张、铜环、朱红和思源宋体，标题“把好句子／放在桌面上”。当前真实 Widget 绘制代码在仓库外独立 Debug 工程中以 3x 采集 pack-0018、pack-0029（2026-11-13，中文农历）；图中文字和手绘未由模型重绘。内置 ImageGen 仅生成装饰性灵动岛设备外框，不把宣传组合冒充完整 SpringBoard 实拍。

新增 docs/marketing/iphone-widget-first-shot.md，更新营销 README 和本文。采集 Debug 构建、字体图片加载、尺寸/RGB/无 Alpha、来源 SHA-256 和绘制源码一致性检查通过；已查看最终候选。App/Widget 源码、原资源、工程配置、签名、版本和后台未改。输出、可编辑排版、外框、采集工程及检查清单均在仓库外 ~/.cache/MaoStyleCalendar/store-marketing-20261113/，未进入 Git。执行 xcodebuild、simctl、布局渲染、图片与哈希检查、git diff --check 和 git status；仓库仍为既有整体未跟踪状态，无新增异常构建产物。未上传或送审；下一阶段等待首图确认。

2026-11-13 内购审核材料已准备，待用户确认。新增 docs/marketing/iap-review-20261113/：当前 App 首次引导第四屏中英真实 PNG 截图各一张、审核备注中英单独及合并 TXT、可选本地化商品描述 TXT、使用说明及 manifest，共 8 个文件。截图为 iPhone 17 Pro / iOS 26.5、当前 Debug 构建，1206×2622 RGB；仅移除完全不透明 Alpha，RGB 像素保持一致，未拼接/修改界面或价格。$4.99 来自 StoreKit 返回值，不将其记为生产各地区定价核验或真实交易通过。中英备注合计 1990 字符；商品描述分别不超过 45 字符。核对 Apple 官方内购信息要求；此审核截图与顶部 1024×1024 推广图用途不同。

执行 simctl 安装/启动/截图、两张全图视觉核对、Pillow 尺寸/Alpha/像素核验、SHA-256、字符长度检查、git diff --check 与 git status。复用上一阶段已通过 Debug 构建的 App，本轮未重新构建；未改 App、工程配置、交易、签名或后台，未上传/送审。Git 保持既有整体未跟踪状态，无新增异常构建产物；原始截图位于仓库外 ~/.cache/MaoStyleCalendar/iap-review-20261113/。建议用户确认后选英文截图及双语备注填写审核区。


2026-11-13 按用户确认统一 App 内商品名称：中文「永久解锁」、英文 `Full Access`，与用户提供的后台本地化截图一致。首次引导价格上方改为按应用语言显示，中文沿用项目中文正文字体、字号仍为 14；设置未解锁入口同步中文名称，付费按钮商品就绪时按应用语言显示固定名称，不再受 StoreKit displayName 语言影响。保留英文操作文案、全部状态分支、价格来源和交易代码；三份中文本地协议同步商品称呼，条款范围不变。此决定替代设置入口此前的「解锁完整日历」文案，并同步 iap-strategy.md。

本阶段完成，无新增仓库文件；修改 OnboardingView.swift、AppSettingsView.swift、Legal 下 purchase/privacy/terms-zh-Hans.html、iap-strategy.md 和本文。未改布局容器、间距、字号、购买/恢复/权益逻辑、英文协议、图片、工程配置、签名、版本或后台配置。执行 rg 文案检索、与仓库外备份逐项差异断言、git diff --check、git status，以及 generic iOS Simulator 无签名 Debug 构建，BUILD SUCCEEDED。未运行真实交易或 UI 视觉验收。Git 仍为既有整体未跟踪状态，无本轮新增异常文件；备份、构建与日志位于仓库外 ~/.cache/MaoStyleCalendar/iap-name-20261113/。建议用户确认本轮文案，不扩展下一阶段。


2026-11-13 用户明确要求先将已验收功能和资源接入 Release，调试入口保留 Debug，冻结已确认视觉与交互，验证后再继续宣传。已取消 iOS App Release 的 DailyArtwork / OnboardingPreview 整目录排除，将 11 个 Swift 文件内的正常内容、今日、年度册、壁纸、Widget 和首次引导分支接入 Release；模拟购买、语言覆盖、图库、审阅参数和 QA 诊断仍仅 Debug。没有打开 Release 的 DEBUG 标记，没有修改真实交易、Firebase、签名、Team、Bundle ID、版本、第三方依赖、字体、插画或中英正文；Native/Resources 全目录与修改前备份一致。AGENTS.md 已记录该明确授权替代历史整套隔离，资源审计状态与编辑译文分类不因工程接入升级。

本阶段接入完成。Debug Simulator、Release Simulator 及 generic iOS Release 无签名构建成功；CalendarCore 28 项测试通过，英文 365 套与 1,085 段源校验通过。独立 iPhone 17 Pro / iOS 26.5 的 Debug/Release 中英 UI 共 4 项通过，覆盖首次引导与切换、免费进入、今日/详解、年度册、壁纸、设置、付费墙与关闭；22 组稳定截图中 15 组逐像素一致，壁纸一组差异均值约 0.0001/255，其余按钮光效与系统玻璃差异已人工查看。额外 Release 审阅参数忽略/调试入口缺席 UI 测试 1 项通过。新脚本 verify_release_bundle.py 对实际设备架构 Release 包验证 137 个每日文件、33 个引导文件、365 套中英覆盖、五份字体及 App/Widget 无 Debug-only 标识，全部通过。首次即时截图有过渡帧差异，未当作最终结果，稳定截图作为对照证据。

验证边界：外置 StoreKitTest 购买注入在关联 target/scheme 后仍返回 notEntitled，不能宣称真实购买、退款或恢复交易通过；保持既有交易代码，真机 Sandbox 仍待联调。Widget 本轮为包和分支验证，未重新添加真机全类型组件；不重新否定用户既有视觉验收。设备 Release 是无签名编译打包，不是分发签名、上传或发布。本阶段新增 verify_release_bundle.py 和 docs/engineering/release-feature-promotion.md，同步仓库结构、宣传调研、本文及 AGENTS.md。执行 xcodebuild、外置 XCTest、swift test、英文/包校验、SHA-256/截图比较、git diff --check 与 git status；构建、UI 测试 target、日志、备份和图片均在仓库外 ~/.cache/MaoStyleCalendar/release-promotion-20261113/。Git 仍为既有整体未跟踪状态，无新增异常构建产物。宣传材料暂缓，待本阶段结果确认后继续。

2026-11-13 App Store 宣传材料第一阶段调研与资源盘点完成，待用户确认后逐批制作。核对 Apple 创意素材、Asset Library、产品页预览、CPP 关键词关联、PPO、内购推广与 Offer Codes，记录顶部/搜索图、安全区、截图和两类视频的不同规格。新增 docs/marketing/README.md、app-store-research-20261113.md、asset-inventory-20261113.json。仓库每日内容 365 套引用 133 个背景文件，资源登记仍全部 candidate / pending_designers_commercial_license；Release 配置继续排除 DailyArtwork 和 OnboardingPreview，不将内部完整体验当正式可发布内容。六组已知 QA 素材已做尺寸/格式及抽样哈希盘点，已查看英文今日页样张；本轮未生成宣传图片/视频，未改原素材、App、Widget、业务、依赖、工程配置、签名或后台数据，未上传/送审/发布。只读核验当前版本页，记录顶部素材 0/1、版本文案等缺项；次要类别仍为图书，先前参考资料只作建议，未自动应用。建议下一批先做普通 iPhone 中英各六张截图候选，再做顶部/搜索创意图；iPad/Duo 按专项验收补齐，Mac 暂缓。验证：官方页面核对、浏览器只读、Pillow 图片元数据、SHA-256、JSON 读回、git diff --check、git status。文档阶段未运行 Debug 构建。Git 仍为既有整体未跟踪状态。

2026-11-12 用户取消译文审计信息的界面展示。用户要求卡面“Project editorial translation”和详解“About This Translation”整段只在内部文档审计中记录，不向用户显示；此决定替代同日此前“界面明确标注”的呈现要求，内容分类和核验规则不变。App 卡面、年度册、壁纸预览/导出、Widget 及无障碍朗读中的同类标注一并移除；详解不渲染 translationNote Section，也不残留空标题或分隔线。英文资源的 candidate / project_editorial、QuoteText 的 editorialTranslation / projectEditorial、中文源 SHA-256、隐藏审计说明及 5 套归属未核实记录继续保留，不升级为出版英译或正式批准。

本阶段无新增文件。仅修改 ArtworkPage.swift、TodayView.swift、Shared/ArtworkWidgetView.swift、Shared/DailyArtworkLibrary.swift、本文及详解进度文档。未修改译文/中文正文、出处、资源 JSON、图片、字体、英文拟合规则、年度分配、购买逻辑、工程配置、签名或版本。执行英文资源覆盖及源校验脚本、iOS 模拟器无签名 Debug 构建、源码差异及界面标注检索、git diff --check、git status；覆盖/源校验与 Debug 构建通过。Git 仍为既有整体未跟踪状态，无新增异常文件。无本次展示修改的遗留阻断，建议用户继续验收；正式内容核验状态保持原状。

2026-11-12 英文覆盖补齐完成，交付普通 iPhone Debug 候选验收。用户已明确允许补齐英文并标注“项目编辑译文”。新增 DailyArtwork/english-editorial.json，覆盖 365 套英文标题与卡面、360 段原文出处、360 段历史背景、365 段当下解读（共 1,085 个详解 Section）。全部保持 candidate / project_editorial。365 条卡面及 174 段不重复历史背景逐条修订，部分原文、阅读段落及术语同步修订；其余阅读正文为离线翻译辅助候选稿，不宣称完整人工逐句出版核验。原 content-packs.json、editorial-details.json 逐字节不变；每套英文保存对应完整中文输入的 SHA-256。

共享目录将英文 QuoteText 标为 editorialTranslation / projectEditorial，详解按 languageTag 筛选。CalendarCore 提供语言匹配；英文缺失不静默显示中文。闰日与 Release Mock 均有英文占位和详解。卡面、年度册、壁纸预览/导出共用英文横排，使用已有 Source Serif 4 角色，拟合全文并避让日期、铜环孔位及图集检测到的人脸。中文坐标、版式、插画与年度映射不变。英文卡面、导出、详解、Widget 和 VoiceOver 均带项目编辑译文说明；小 Widget 长文可截句，但保留译文标注。5 套无可靠出处的内容仍仅提供当下解读，App 卡面和详解明确提示归属未核实，不补造出处或升级状态。

新增文件（含前一界面阶段）：CalendarCore/CalendarLocalization.swift、CalendarLocalizationTests.swift、Native/Resources/DailyArtwork/english-editorial.json、Scripts/verify_english_editorial.py。修改 Native/App 的 AppSettingsView.swift、ArtworkPage.swift、ArtworkWallpaperCanvas.swift、RootTabView.swift、TodayView.swift、iOSShareAndWallpaperExport.swift、DailyArtworkQA.swift，Native/Shared 的 DailyArtworkLibrary.swift、ArtworkWidgetView.swift，Native/Widget/CalendarWidgets.swift，CalendarCore/Content/MockDailyContentRepository.swift，以及本文、详解进度、仓库结构文档。未修改 Xcode 工程、Info.plist、签名、Bundle ID、Team、版本、StoreKit/购买权益、年度分配器、中文底稿、图片或字体；未接入 App 网络请求、第三方依赖、在线翻译或运行时模型。

验证命令：python3 ios-client/Scripts/verify_english_editorial.py；swift test --package-path ios-client/Packages/CalendarCore --scratch-path ~/.cache/MaoStyleCalendar/CalendarCore-localization；xcodebuild -project ios-client/MaoStyleCalendar.xcodeproj -scheme MaoStyleCalendar-iOS -configuration Debug/Release -destination 'generic/platform=iOS Simulator' -derivedDataPath ~/.cache/MaoStyleCalendar/DerivedData-localization CODE_SIGNING_ALLOWED=NO build；simctl install/launch/terminate/get_app_container；修改前副本差异、git diff --check、git status。覆盖校验通过，28 项核心测试通过，Debug/Release 均 BUILD SUCCEEDED。Debug 英文 atlas 与源文件一致；Release 未含 DailyArtwork 或 english-editorial.json。

QA iPhone 渲染全部 365 张英文卡面，生成代表性中英壁纸、18 张桌面/锁屏英文 Widget 图及 320/393pt 原生托管的详解首尾截图；通过 UIScrollView 偏移检查正文滚动与固定 Header，未冒充真实手势或 VoiceOver 验收。ImageRenderer 无法正确渲染滚动详解，已改用 UIHostingController；最初空白截图不作为通过证据。补充核对：UIView 页面快照在部分滚动末帧遗漏 Header，实际模拟器屏幕（detail-actual-screen.png）确认 Quote Details 与关闭按钮仍固定，正文已到末段；不将快照合成差异记为产品故障。正文显式 clipped 保护固定标题区域。8 张全年总览仅作排版检查，不代替用户艺术与逐字内容验收。证据在仓库外 ~/.cache/MaoStyleCalendar/localization-20261112/review/。

本阶段完成，建议进入用户统一英文验收；无覆盖或构建阻断。正式底本核验、原有归属问题、候选译文语言润色和用户视觉确认仍是转正式前的工作。未执行真实交易、真机 Widget Gallery 添加、VoiceOver 实际朗读或其他平台专项验收。Git 维持任务开始时整体未跟踪状态，无新增异常产物，不自动提交。下方同日“等待译文方式确认”的记录为用户确认前的阶段记录。

2026-11-12 英文覆盖梳理与界面补齐（整体多语言任务尚未完成）：本轮按用户“一次完成后统一验收”的要求，补齐四 Tab、今日/详解标题、年度册年份/月名、壁纸布局/导出提示/错误、VoiceOver 文案、小组件添加教程、Debug Widget 全类型预览及桌面/锁屏 Widget 日期与组件介绍。沿用现有系统语言与 Debug 进程内覆盖；Widget timeline 携带已解析语言，视图显式注入 Locale；离屏壁纸导出接收与预览一致的 Locale。中文卡片保留“月.星期”排法，英文使用英文月份/星期；英文不显示中文农历。未改资源 ID、年度分配、购买权益、交易、工程配置、签名、字体、图片或内容审核状态。

正文缺口单独记录：365 套卡面当前只含中文；editorial-details.json 只含中文正文。研究档案有 50 套较早的英文历史背景/解读草稿；出版英文来源统计为 62 套定位具体段落、159 套仅定位篇章、144 套尚未定位，不能把来源线索或既有短草稿视为 365 套现行中文详解的完整英文。已向用户请求选择“明确标为项目编辑译文的候选翻译”或“只接入可核验出版英译，其他提示待核验”，尚未收到答复，未擅自改写或批准引文。此状态不代表全 App 英文化完成，不建议现在做整体多语言最终验收。

新增 CalendarCore/CalendarLocalization.swift 及 CalendarLocalizationTests.swift；修改 AppSettingsView.swift、ArtworkPage.swift、ArtworkWallpaperCanvas.swift、RootTabView.swift、TodayView.swift、iOSShareAndWallpaperExport.swift、Shared/ArtworkWidgetView.swift、Widget/CalendarWidgets.swift 和本文。验证命令：xcodebuild（MaoStyleCalendar-iOS，Debug/Release，generic iOS Simulator，CODE_SIGNING_ALLOWED=NO）、swift test（CalendarCore，27 项通过）、simctl install/launch/terminate/spawn defaults/io screenshot、修改前副本差异、git diff --check 与 git status。英文年度册和壁纸在独立 QA iPhone 模拟器已截图核对；卡面仍显示中文，明确留作待处理项。未执行真机、小屏/大字号、实际 Widget Gallery/锁屏添加或完整交互验收；未执行真实交易。Git 保持任务开始时的整体未跟踪状态，产物保存在仓库外。待正文译文路径确认后继续，不宣称正式内容可发布。

2026-11-12 iPad 首次引导专项适配完成，待用户视觉确认。OnboardingDevice 新增 tablet，先按 .pad 识别，避免复用 iPhone 硬件切图；横向沿用已确认的大标题、主体图、底部分离导航构图，竖向使用标题在上/主体居中/操作在下，内容最大宽度 840pt、主体高度按可用空间计算。新增 ipad-widget、ipad-lock、ipad-home 三组中英透明 PNG，共 6 张（1448×1086），使用 iPad 外形，无灵动岛或折叠接缝，保留现有阅读人物和插画主题。manifest 补齐尺寸/哈希/候选状态与生成说明；所有文字与插画仍为 Debug 候选，英文编辑文案不声明为权威逐字英译，未获正式内容或 Release 素材批准。

模拟器旋转问题：iPad Pro 13-inch (M5) / iPadOS 26.5 在 SpringBoard 和 App 都曾出现机身旋转而逻辑画布不变，控制中心添加控件目录空白，不能据此确认是旋转锁定；此前让用户搜索旋转锁定的判断不充分。仅正常关闭并重新启动该模拟器（未 erase、未清除 App 数据）后，系统桌面和引导均恢复逻辑横竖屏切换，自动触控也恢复。本阶段未修改方向声明或工程配置；运行验证证明恢复，未将具体系统故障根因写成已查明。

本阶段新增 6 张 ipad-*.png；修改 OnboardingView.swift、OnboardingPreview/manifest.json、本文。未修改 StartupView.swift、本轮以前的 26 张素材、购买实现、工程/签名/Bundle ID/版本与 Mac。iPad 中英文竖向、小组件/今日/壁纸/解锁四屏横向截图完成；实际点按返回、壁纸仅插画/原稿恢复、今日详情卡片层级切换，并实际从壁纸竖向切换至横向，页面布局随方向变化。无签名模拟器 Debug 与 Release 构建均 BUILD SUCCEEDED；32 张 manifest 资源尺寸/哈希匹配，Release bundle 未含 OnboardingPreview 或新增 iPad 素材。执行 xcodebuild、simctl install/launch/terminate/io screenshot/shutdown/boot/bootstatus、原实现比对、资源校验、git diff --check 和 git status；未执行购买交易。证据位于仓库外 ~/.cache/MaoStyleCalendar/onboarding-ipad-adaptation-20261112/。Git 仍为既有整体未跟踪状态，未发现新增异常构建产物。建议由用户确认本版 iPad 视觉，Mac 继续按最新指示暂缓。



2026-11-12 修复 iPad Mock 开启后仍无首次引导：StartupView 原 requestsOnboarding 前置 userInterfaceIdiom == .phone，导致 iPad 在读取首次标记/调试开关前被拦住。用户进一步要求取消设备限制，最终直接删除 idiom 白名单，所有当前 iOS/iPadOS target 支持的设备统一按未展示过、alwaysShowsOnboarding 或显式审阅入口判断。原品牌开场、首次标记写入、关闭与购买逻辑不变；引导仍限 Debug 候选，不放开 Release。

本轮确认的范围变更：用户先表示包含 Mac，经只读检查发现 Mac target 未打包引导资源，且当前引导依赖 UIKit、Mac 尚未接入同套入口；询问是否允许必要的资源引用/Release 排除配置后，用户明确选择「暂不改工程，先完成 iPhone 和 iPad」。故本阶段按最新指示仅完成 iPhone/Duo/iPad 入口统一，Mac 接入暂缓，未修改工程或宣称 Mac 已支持。

本阶段完成，无新增文件，仅修改 StartupView.swift 与本文。实际读取 iPad Pro 13-inch (M5) / iOS 26.5 的既有 debug.onboarding.always=true，初始未有首次展示记录；安装修复版后无任何 review 参数连续两次正常启动均显示首屏，hasPresented 已为 true 时仍因 Mock 开关正常展示。最终删除设备白名单版本已再次无参数启动 iPad 核对；iPhone 17 Pro 审阅入口回归正常。两设备的既有调试开关均保留，不清除应用数据。iOS 模拟器无签名 Debug 构建 BUILD SUCCEEDED。执行 xcodebuild、simctl install/terminate/launch/io screenshot/get_app_container、仅指定布尔偏好只读核对、修改前差异、git diff --check、git status。引导布局、资源、交易、签名/版本/工程配置和 Mac 均未改；本次为入口验证，不代表 iPad 所有布局/交互或 Mac 验收通过，未新增测试或执行交易。Git 保持原有整体未跟踪状态，无新增异常产物。证据位于仓库外 ~/.cache/MaoStyleCalendar/onboarding-ipad-entry-20261112/。开关在重新启动 App 时生效，仅切回前台不触发新一轮入口评估。建议先确认 iPad 实际引导入口。


2026-11-12 修正 Duo 内屏竖向首次引导误用旧分栏。根因是 wide 仅判断宽度至少 640pt/高度至少 380pt，未排除竖屏，且 introduction 留有旧宽屏侧栏分支。wide 现要求宽大于高，前三屏删除旧左右分栏分支，竖向统一复用 iPhone 的 portraitIntroduction（标题在上、示意图居中、操作在下），保留 Duo 专属切片。第四屏竖向同样以 isWide=false 进入单栏，compactPortrait 只留给 Duo 外屏，内屏竖向沿用普通单栏字号，不再用外屏紧凑字号。横屏布局/交互与购买区实现逐字未变，半展开和全展开使用相同判断。

本阶段完成，无新增文件，仅修改 OnboardingView.swift 与本文。iOS 模拟器无签名 Debug 构建 BUILD SUCCEEDED；全展开竖屏中文四页截图核对，半展开竖屏英文壁纸页、半展开旋至横屏、全展开切回竖屏均核对，当前页和原稿模式保持，竖排/横向布局切换正确。首次今日页截图落在品牌开场，已重新等待并补拍实际今日页，不以开场截图代替验收。执行 xcodebuild、simctl install/terminate/launch/io screenshot、Device Hub 半展开/全展开及旋转、修改前差异、横屏实现与第四屏代码逐字比对、git diff --check、git status。素材、购买逻辑、工程/签名/版本及其他页面未改；未新增测试或重新做真实购买/手势/辅助功能验收。Git 保持原有整体未跟踪状态，无新增异常产物。证据位于仓库外 ~/.cache/MaoStyleCalendar/onboarding-duo-portrait-routing-20261112/，portrait-sheet.jpg 为四屏概览。建议先确认本版竖向布局。


2026-11-12 Duo 横向首次引导第四屏重排及连续反馈收尾：六项权益从左栏移至右栏上部，整组水平居中、各行左对齐，购买区继续独立固定靠下。左栏仅保留日历图标/解锁标题/一次买断说明并整体居中，图标 26→48pt、标题倍率 1.55、说明 17→21pt。权益按后续要求仅该入口放大：文字 15→18pt、图标 25→30pt、行距 10→12pt、图文间距 14→16pt。权益区域可独立滚动，英文换行仍显示完整六项；双栏固定为几何容器可用高度，避免其自然高度挤压顶栏。仅 isWide 且宽大于高入口启用，Duo 内屏半展开与全展开共用判断；竖向、外屏和普通 iPhone 的内容字号及布局参数保持原值。

用户同时要求引导的返回与跳过下移：共用 navigation 增加顶部 12pt 内边距，保留自然高度并提高布局优先级，防止大内容将按钮压出顶部；所有引导页两个按钮保持同行。正文随顶栏高度避让。复用抽取的 introductionHeader/benefitList，文案不变。purchaseArea 及其后的价格/购买/恢复函数逐字比对未变。

本阶段完成，无新增仓库文件，仅修改 OnboardingView.swift 与本文。iOS 模拟器无签名 Debug 最终构建 BUILD SUCCEEDED。一次构建进程以 137 中止且无编译诊断，使用 -jobs 2 重试及最终构建通过，未改工程设置。Duo 横向中英文最终截图核对：左栏放大居中、右栏六项放大且完整、购买区靠下、返回/跳过正常下移无裁切；普通 iPhone 中文第四屏已核对内容布局保留、顶栏下移。最终版仅再次加强顶栏自然高度保护，其他设备及辅助功能未专项复验。执行 xcodebuild、simctl install/terminate/launch/io screenshot、修改前差异、交易代码逐字比对、git diff --check、git status。素材、前三屏主体、购买业务、工程/签名/版本未改，未执行真实交易或新增测试。实际点击、辅助功能及用户视觉验收仍待确认。Git 保持原有整体未跟踪状态，无新增异常产物。证据位于仓库外 ~/.cache/MaoStyleCalendar/onboarding-paywall-columns-20261112/，zh-current.png、en-current.png 为本轮最终截图；建议先确认本版字号与布局。


2026-11-12 首次壁纸引导样式切换动效统一：选择仅插画时左侧锁屏图透明度降至 50%，右侧主屏图增强前景阴影/层级，并按原 iPhone/外屏尺寸变化放大；Duo 内屏额外采用 1.08 倍缩放，横向及竖向入口共用。切回原稿排版恢复大小、透明度和阴影。原 0.3 秒 easeInOut 改为 response=0.48、dampingFraction=0.86 的弹簧动画，重复选择同一模式不重播；reduceMotion 沿用 nil animation，无弹簧过渡。模式状态初始化固定 false，删除旧 --review-onboarding-artwork-only 初始覆盖；move(to:2) 在页面转场前以无动画事务重置为原稿排版，避免再次进入沿用上次状态。新增仅显式启用的 Debug 演示参数 --review-onboarding-wallpaper-switch，经与按钮共用的 selectWallpaperMode 函数演示往返，不改变正常入口。

本阶段完成，无新增文件，仅修改 OnboardingView.swift 与本文。iOS 模拟器无签名 Debug 构建 BUILD SUCCEEDED；iPhone 17 Pro 与 Duo 横向分别核对默认、仅插画、恢复原稿三种运行截图，并录制两平台的切换过程，确认左图淡化、右图放大且无边缘/按钮遮挡。默认验证即便传入旧 artwork-only 参数也仍选原稿。末次 move 重置时机微调后已再次构建并安装两设备；再次进入重置依据导航代码比对，本次未做实际跨页返回点按。26 张资源哈希匹配，TodayCards/第四屏及之后代码逐字未变。执行 xcodebuild、simctl install/terminate/launch/io screenshot/recordVideo、资源校验、修改前差异、git diff --check、git status。素材、真实壁纸排版/导出业务、其他页面、工程/签名/版本未改。实际点按命中与系统减少动态效果开关未专项运行验证；模拟器 ui 命令不提供 reduceMotion 设置，本轮只核对原无动画分支。证据位于仓库外 ~/.cache/MaoStyleCalendar/onboarding-wallpaper-motion-20261112/，states.jpg 为三态对照，duo-switch.mp4 / iphone-switch.mp4 为运行录屏。Git 保持原有整体未跟踪状态，无新增异常产物。建议先确认本版动效观感。


2026-11-12 按用户标注将 Duo 横向壁纸引导的原稿排版/仅插画切换从页脚移至右侧手机正上方。控件在图文画布内按宽度 29%、中心 x=73%、y=14% 定位，与右侧手机水平中心一致；页脚仅保留进度点与继续。控件字号、宽度比例、原绑定与模式逻辑不变，手机图与标题布局不改。

本阶段完成，无新增文件，仅修改 OnboardingView.swift 与本文。iOS 模拟器无签名 Debug 构建 BUILD SUCCEEDED，Duo 横向中文原稿排版、英文仅插画运行截图已核对，切换控件位于右侧手机上方，无标题/状态栏遮挡。执行 xcodebuild、simctl install/terminate/launch/io screenshot、修改前差异、git diff --check、git status；逐字比较 portraitIntroduction 及之后代码未变。其他引导页、竖向/外屏、素材、切换逻辑、购买业务和工程/签名/版本未改；未新增测试，本次未执行真实点击。Git 保持原有整体未跟踪状态，无新增异常产物。证据位于仓库外 ~/.cache/MaoStyleCalendar/onboarding-wallpaper-toggle-top-20261112/。建议先确认本版控件位置。


2026-11-12 Duo 横向今日引导独立日历与详情换层：日历倍率由基础 1.30 收至 1.22（比上一版约小 6%），局部中心 x 从 0.20 左移至 0.14，y 保持 0.545；日历与详情卡不再重叠，与标题及进度点留有间距。该入口的日历不参与前后层级切换，旋转/缩放/位置在详情换层期间固定。两张详情均改为 Button，左卡调用原 bringForward(true)，右卡在 landscapeSpread 下调用 bringForward(false)，分别把自己带到前景；前景纸页使用更深阴影与相应旋转。沿用先分离、交换 zIndex、弹簧回落、动画忙碌屏蔽及 reduceMotion 直接切换；左卡增加双语辅助标签、当前层级状态与稳定标识 onboarding.today.secondaryDetail。其他入口沿用原日历/详情切换规则。

本阶段完成，无新增文件，仅修改 OnboardingView.swift 与本文。iOS 模拟器无签名 Debug 构建 BUILD SUCCEEDED；中文左右前置、英文左前置截图核对，无日历/详情重叠、标题/进度点遮挡或卡片裁切。通过现有 --review-onboarding-card-switch 调用与按钮相同函数，录制运行往返；抽帧确认右前景转至左前景，后续 settled.png 确认回到右前景。Device Hub 实际坐标点按返回 noWindowsAvailable，因此真实触点命中仍待用户确认，不以调试演示替代。26 张资源哈希与第四屏逐字比对未变，执行 xcodebuild、simctl install/terminate/launch/io screenshot/recordVideo、录屏抽帧、修改前差异、git diff --check、git status。资源、其他页面、购买业务、工程/签名/版本未改；未新增测试，辅助功能与其他平台未专项运行复验。Git 保持整体未跟踪状态，无新增异常产物。证据位于仓库外 ~/.cache/MaoStyleCalendar/onboarding-detail-swap-20261112/。建议先确认日历间距及左右详情真实点按效果。


2026-11-12 Duo 横向今日引导三卡组合：日历由基础倍率 1.18 放大至 1.30（比上一版约再大 10%），中心移至局部 (0.20,0.545)，为标题和底部进度点留出间隔。新增详情卡在 (0.51,0.49) 以现有详情 94% 尺寸和 -3 度倾斜放在后层，原详情保持右侧，填补中部空白。新卡不拦截点击，既有两卡切换函数不改。

新增 today-detail-investigation-zh.png、today-detail-investigation-en.png；修改 OnboardingView.swift、OnboardingPreview/manifest.json 与本文。新图由内置 ImageGen 生成，采用青绿柳岸石桥背景，文案基于现有 pack-0010《反对本本主义》候选资料。中文摘句为「注重调查！反对瞎说！」，解读为编辑摘要；英文明确标注 Project editorial summary，不作为权威英译。来源、生成要求、尺寸及 SHA-256 已记入 manifest，仍仅作 Debug 候选，正式内容核验状态不变，原图未覆盖。

本阶段完成。iOS 模拟器无签名 Debug、Release 构建均 BUILD SUCCEEDED；最终 Debug 中文三卡及英文原/详情前置截图已核对，无标题/按钮交叠或边缘裁切。26 张资源哈希匹配，新图为 RGBA 且含全透明像素；Release 包确认无 OnboardingPreview 和新图。执行 xcodebuild、simctl install/terminate/launch/io screenshot、Alpha/哈希校验、第四屏逐字比对、git diff --check、git status。购买业务、正式内容库、工程/签名/版本和其他页面未改。状态截图不替代实际点按、手势与辅助功能验收，本次未专项复验这些交互。Git 保持原有整体未跟踪状态，无新增异常构建产物。证据与备份位于仓库外 ~/.cache/MaoStyleCalendar/onboarding-today-stack-20261112/。建议先确认新增卡片及三卡层次。


2026-11-12 按用户标注优化 Duo 横向今日引导双卡：仅 landscapeSpread 入口启用新参数，日历卡相对原尺寸放大 18%、中心由局部 (0.28,0.39) 移至 (0.17,0.53)，向左下补足留白；详情卡放大 6%、中心由 (0.63,0.48) 移至 (0.78,0.37)，向右上补足留白。双卡切换后保留左右位置，仍复用前后层级、旋转、缩放、阴影及原切换函数；该入口的临时分离距离由 25% 局部宽度收至 4%，避免边缘越界。其他入口默认 landscapeSpread=false，沿用原尺寸/位置/切换位移公式。

本阶段完成，无新增文件，仅修改 OnboardingView.swift 与本文。iOS 模拟器无签名 Debug 构建 BUILD SUCCEEDED，Duo 横向中英文两种前后状态共四张截图核对，卡片与标题/底部按钮无交叠、无裁切；状态由原 Debug 参数进入，不替代实际点按或动画逐帧验收。执行 xcodebuild、simctl install/terminate/launch/io screenshot、修改前差异、git diff --check、git status。标题、底部操作、其他引导页、资源、购买业务与工程/签名/版本未改；未新增测试，其他设备与辅助功能未专项复验。证据位于仓库外 `~/.cache/MaoStyleCalendar/onboarding-today-balance-20261112/`。Git 保持原有整体未跟踪状态，无新增异常产物；建议先确认本版双卡位置与大小。


2026-11-12 按用户截图将 Duo 横向小组件引导页的展开手机图单独下移 20pt，position.y 从 h*0.595 改为 h*0.595+20，增加与上方标题的距离。标题、右侧卡片、手机图尺寸与横坐标、底部操作、其他页面及业务均不改，半展开/全展开共用。

本阶段完成，无新增文件，仅修改 OnboardingView.swift 与本文。iOS 模拟器无签名 Debug 构建 BUILD SUCCEEDED，安装后核对 Duo 横向内屏中文截图，手机与标题间距增大、底部无裁切。执行 xcodebuild、simctl install/terminate/launch/io screenshot、修改前单行差异、git diff --check、git status；未新增测试或复验其他状态。资源、工程/签名/版本及购买逻辑未改，Git 保持整体未跟踪状态，无新增异常文件。证据位于仓库外 `~/.cache/MaoStyleCalendar/onboarding-phone-lower-20261112/`。建议先确认本版间距。


2026-11-12 用户重新提供截图，明确此前目标应为左上大标题、中部大幅设备图、右侧上下卡片、左下进度点及右下继续按钮。此前把设计稿对应为左图右文案有误，前一条记录中的视觉源不再作为实现目标；本次以用户新附截图一为准（同原生成图 exec-b9f7ef57-6e89-493e-a6e7-0bb442c27dd7.png）。已移除 Duo 横向前三屏的左右文案分栏，改为共享上方图文画布与底部操作行；标题按原 1.6 倍角色字号、紧凑行距左上排列，小组件设备图放大居中偏左，两张原切片卡片置于右后方，进度点固定左下、继续按钮固定右下。今日双卡和壁纸同样采用这套画布/页脚结构，壁纸模式开关保留在页脚中部。主体释放 trailing/bottom 安全区以利用完整内屏画幅，顶栏仍独立保留相机与状态栏避让。半展开、全展开共用；竖向、外屏、普通 iPhone 沿用原入口。

本阶段完成，无新增仓库文件；仅修改 OnboardingView.swift 与本文。iOS 模拟器无签名 Debug 构建 BUILD SUCCEEDED。半展开中英文前三屏截图核对；最后微调今日卡片下移后在全展开核对中文今日和小组件，reference-vs-actual.jpg 将用户目标与最终模拟器画面同尺寸并排检查，确认构图位置/层次及底部操作对齐。设计稿局部绘画及卡片文字比例与现有切片不完全相同，本次保留原切片内容，不重绘资源。24 张资源哈希保持匹配，第四屏代码逐字未变。执行 xcodebuild、simctl install/terminate/launch/io screenshot、资源哈希校验、修改前差异、git diff --check、git status。购买逻辑、工程/签名/版本、资源文件与其他页面未改；Git 仍整体未跟踪，无新增异常产物。实际点按、滑动与辅助功能仍待运行验收，不以截图替代；建议用户先核对本版与设计稿的并排图。证据位于仓库外 `~/.cache/MaoStyleCalendar/onboarding-duo-correct-layout-20261112/`。


2026-11-12 用户选择 Duo 横向引导设计第 1 张（按会话实际展示顺序，为左侧大示意图、右侧集中标题/进度点/继续；视觉源 `~/.codex/generated_images/01a1cedb-7f01-7463-93bd-2378481a77fd/exec-3ea91c62-1953-4f18-a6f6-ffacfbad5a12.png`），随后要求今日和壁纸页采用相同样式。本轮前三屏共用 duoLandscapeIntroduction，左侧约 67% 示意区、右侧约 33% 文案区，分区间距 28pt；标题、进度与按钮在右侧成组居中，壁纸模式入口置于标题下方。仅 Duo 内屏横向且空间/字号满足原 wide 条件时启用；半展开和全展开一致，竖向和空间不足回退沿用原路径，普通 iPhone/外屏不受影响。

小组件页使用原 duo-inner-widget 及 widget-cards 中英 PNG，后者在显示时按归一化源矩形拆为上下卡片独立排布，源文件不修改、不新增图片；展开设备图置于右前方，卡片置于左后方。生成概念稿与原切片局部绘画/文字位置有差别，代码保留原资源内容，不将生成稿整图接入 App。今日双卡前后切换/动画/辅助标签及壁纸两种模式状态继续复用原实现。第四屏购买区、价格、购买及恢复函数逐字比对未变。

本阶段完成，无新增仓库文件；仅修改 OnboardingView.swift 与本文。iOS 模拟器无签名 Debug 构建 BUILD SUCCEEDED。半展开中文三屏、全展开英文三屏截图核对无文字/按钮裁切；最终版半展开中文小组件、详情前置和仅插画状态另行核对；普通 iPhone 17 Pro 中文首屏截图回归正常。调试参数展示备选状态，不代替实际点按切换/手势验收。24 张资源 SHA-256 与清单一致。执行 xcodebuild、simctl install/terminate/launch/io screenshot、修改前差异及第四屏/今日交互代码逐字比对、git diff --check、git status。工程/签名/版本、资源文件、购买业务及其他页面未改；Git 仍为原有整体未跟踪状态，无新增异常产物。本次未做真实点击/滑动、VoiceOver/减少动态效果和大字号运行专项，仍为 Debug 候选，正式内容批准状态不变。备份、构建日志与截图位于仓库外 `~/.cache/MaoStyleCalendar/onboarding-duo-widget-editorial-20261112/`，en-sheet.jpg 与 regression-sheet.jpg 为概览。建议用户统一确认三屏视觉和交互后再进入后续阶段。


2026-11-12 按用户要求将首次引导第四屏完整购买区移出 ScrollView：单栏使用上方可伸缩的权益 ScrollView + 下方自然高度 purchaseArea，购买区固定靠下；移除 Duo 原整页滚动回退。内屏双栏右侧 purchaseArea 同样取消 ScrollView，改为底部对齐，左侧权益继续独立滚动。辅助功能字号单栏也使用固定购买区。价格、购买按钮、免费使用、恢复购买及法律链接作为完整一组保留，内容和交易函数未改。

本阶段完成，无新增文件，仅修改 OnboardingView.swift 与本文。iOS 模拟器无签名 Debug 构建 BUILD SUCCEEDED，安装并核对 Duo 外屏中文第四屏截图；六项权益完整、购买区靠下。执行 xcodebuild、simctl install/terminate/launch/io screenshot、修改前差异及 content/purchaseArea/交易代码逐字比对、git diff --check、git status。前三屏、字体、资源、工程/签名/版本未改；本次未复验内屏/英文/辅助功能大字号的运行画面或实际滚动手势，未执行交易。证据位于仓库外 `~/.cache/MaoStyleCalendar/onboarding-fixed-footer-20261112/`。Git 保持原有整体未跟踪状态，无新增异常文件。建议用户确认固定底部交互后再进入后续阶段。


2026-11-12 按用户截图继续下移 Duo 第四屏单栏内容。完整内容组及其容器改为底部对齐；修正底部 padding 与 ignoresSafeArea 的修饰顺序，确保 16pt 边距作用于释放后的屏幕底部，而非继续叠加系统安全区。六项权益、字号、购买按钮及 44pt 法律链接触控区域保留。Duo 外屏中文实际截图确认整组内容下移、底部空白减少且六项权益完整。普通 iPhone 与前三屏不适用本次修改。

本阶段完成，无新增文件，仅修改 OnboardingView.swift 与本文。iOS 模拟器无签名 Debug 构建通过；执行 xcodebuild、simctl install/terminate/launch/io screenshot、修改前差异、git diff --check、git status。购买业务、资源、工程/签名/版本未改；未执行交易或新增测试，本次未复验所有展开状态及辅助功能。证据位于仓库外 `~/.cache/MaoStyleCalendar/onboarding-bottom-20261112/`。Git 仍整体未跟踪，无新增异常产物。建议用户先确认本版位置。


2026-11-12 首次引导第四屏节省空间：移除所有设备 Full Access 页价格下方的进度点，前三屏保留。Duo 单栏（外屏及空间不足的内屏回退）收紧标题至原 87%、分区间距 12→7pt、权益间距 10→6pt、上下内边距，改为 ViewThatFits 优先显示完整权益与购买区；容纳不足时整页滚动，避免固定购买区截断最后两项权益。Duo 第四屏释放底部系统安全区并改留 16pt 外边距，保留顶部/侧面状态栏及相机避让；普通 iPhone 仅移除指示点，其他排版规则不变。辅助功能字号继续沿用整页滚动。

本阶段完成，无新增文件，仅修改 OnboardingView.swift 与本文。iOS 模拟器无签名 Debug 构建 BUILD SUCCEEDED；实际 Duo 外屏中英文截图均显示六项权益、价格、购买/免费按钮及法律链接，无需滚动；半展开内屏横竖向、全展开竖向与切换后截图正常，普通 iPhone 17 Pro 中文截图确认进度点移除且权益完整。执行 xcodebuild、simctl install/terminate/launch/io screenshot、修改前差异、交易代码逐字比对、git diff --check 与 git status。价格/购买/恢复实现、前三屏、素材、工程/签名/版本未改。未新增测试或执行真实交易，VoiceOver/大字号交互及用户视觉验收仍待确认，未以截图替代。Git 仍为原有整体未跟踪状态，无新增异常文件。证据与备份位于仓库外 `~/.cache/MaoStyleCalendar/onboarding-duo-portrait-20261112/`；建议先确认本版视觉，不扩展下一功能阶段。


2026-11-12 续接首次引导 Duo 适配：接手时 OnboardingView 已包含 phone/duoCover/duoInner 分型、公开 UIHingeInteraction 观察器、外屏竖排、内屏左右布局、Full Access 双栏，以及 12 张 Duo 中英文专用候选 PNG；尚未写入本状态文档，已有验证主要为外屏。本轮保留这些实现，补齐运行检查与收尾。partiallyOpen 和 fullyOpen 共用同一内屏状态及宽度/高度判断；辅助功能字号或空间不足沿用滚动回退，折叠不重置当前页。补齐第四屏恢复购买及两份协议的 44pt 最低触控高度，交易实现未改。

本阶段实现及构建收尾完成，无新增仓库文件；本轮只修改 OnboardingView.swift 与本文，前次已生成的 Duo 资源及 manifest 未再修改。实际 Duo 半展开冷启动未传设备覆盖参数，四屏中英文截图均核对；第四屏实测全展开、合上外屏、重新展开及旋转，页面保持、单双栏切换正常。旋转后英文法律链接自动纵排。iOS 模拟器 Debug、Release 无签名构建均 BUILD SUCCEEDED；24 张 PNG 清单 SHA-256 全匹配，Release bundle 未发现 OnboardingPreview 或 Duo 候选资源。执行 xcodebuild、simctl install/terminate/launch/io screenshot、资源哈希脚本、修改前差异、git diff --check 与 git status。购买业务、首次显示规则、正式资源、其他页面、工程/签名/版本未改；Git 保持原有整体未跟踪状态，无新增异常构建产物。

证据与备份位于仓库外 `~/.cache/MaoStyleCalendar/onboarding-duo-resume-20261112/`，partial-sheet.jpg 为四屏双语概览。运行截图证明布局呈现，不替代真实点按、滑动、VoiceOver、减少动态效果、辅助功能大字号以及真实交易验收；本轮未进行购买或恢复交易，未覆盖每个展开状态下全部页面的全部交互。Duo 引导仍为 Debug 候选，正式内容与视觉批准、Release 放开继续独立等待确认。建议下一阶段由用户统一确认引导视觉与上述手势/辅助功能，不扩展其他页面。

2026-11-12 按用户截图将设置页未解锁入口的中文“解锁完整功能”改为“解锁完整日历”；英文、已解锁状态、样式及点击行为不变。本阶段完成，无新增文件，仅修改 AppSettingsView.swift 一处文案和本文。已执行 rg 定位/核对、git diff --check 与 git status；纯文案替换未运行 Debug 构建，无业务或工程配置变更，无新增未解决问题，仓库沿用整体未跟踪状态且无异常新增文件。可直接进入文案验收。

2026-11-12 按用户提供的引导页底部截图调整现有付费墙的 purchaseLinks：恢复购买、购买协议、隐私政策改为同一 HStack，统一 12pt 次级墨色，移除所有下划线与中间分隔点；保持原有已购时隐藏恢复购买、忙碌时禁用恢复、协议导航和 Debug 模拟购买按钮。链接标签保留 44pt 最低触控高度，单行排版，小宽度允许最多缩小 20%，英文按现有英文引文字体显示。

本阶段完成，无新增仓库文件，仅修改 AppSettingsView.swift 与本文。xcodebuild iOS 模拟器 Debug 构建通过；真实内置字体测量显示中文整行约 172pt、英文约 317.7pt（含两处 14pt 间距），均可放入 SE 的 335pt 内容宽度。修改前精确比对确认只改 purchaseLinks 呈现，购买/恢复/价格/权益逻辑、协议内容、按钮动效、引导页和工程/签名/版本未改。执行字体宽度检查、修改前差异、git diff --check 和 git status，仓库仍为原有整体未跟踪状态，无异常文件。未新增测试，本次未操作真实点击或交易，运行观感待用户确认。备份和构建日志位于仓库外 `~/.cache/MaoStyleCalendar/paywall-footer-20261112/`。建议先确认本版底部排版。

2026-11-12 修复首次引导第四屏无法手势返回，并统一购买按钮效果。原因是 DragGesture 只挂在前三屏的示意图上，第四屏独立的 Full Access 页面未接手势；现给第四屏整体补充 contentShape 与 simultaneousGesture，水平右拖超过 35pt 且水平位移大于纵向的 1.4 倍时返回壁纸页，仍经原 move/canLeave 判断购买忙碌状态，纵向滚动和普通按钮点击沿用原规则。引导购买按钮与现有付费墙共用 PaywallPurchaseButtonLabel、PaywallPurchaseButtonStyle：相同 7pt 圆角、58pt 最低高度、红色纸纹、扫光、呼吸阴影、缩放与箭头动效；原有付费墙只提取外观代码，购买/恢复/价格/权益函数和动效引擎逐字对照未变，处理中保留引导原有进度提示。

本阶段完成，无新增仓库文件；修改 OnboardingView.swift、AppSettingsView.swift 和本文。xcodebuild iOS 模拟器 Debug、Release 与 macOS Debug（arm64及通用架构）均通过。首次 Mac 通用尝试遇到 CalendarCore.o 仅 arm64 的缓存/架构组合链接错误，显式命令指定 ONLY_ACTIVE_ARCH=NO、ARCHS=arm64 x86_64 后通用构建通过，未改工程配置。simctl 安装/启动后已核对第四屏实际截图并录制购买按钮动效；CUA Device Hub 可截屏，但 drag 仍返回 noWindowsAvailable，右滑与纵向滚动的实际手势验收待用户确认，不能以代码接入或编译代替。未执行购买、恢复或其他交易。其余引导画面、内容资源、首次显示规则、StoreKit 业务、签名/版本/工程配置未改。执行修改前差异与业务/动效引擎逐字比对、git diff --check、git status，仓库仍为整体未跟踪状态，无异常文件。备份、构建日志、截图与录屏位于仓库外 `~/.cache/MaoStyleCalendar/onboarding-purchase-swipe-20261112/`。建议先确认按钮效果并手动验收第四屏右滑。

2026-11-12 按用户反馈统一首次引导前三屏的底部按钮为中文“继续”/英文“Next”，移除壁纸屏特例“看看完整功能”/“Explore Full Access”及此前英文 Continue。壁纸引导两部手机的宽高约放大 16%（锁屏高度容纳范围略多），原稿排版和仅插画两种状态同步调整，并微调水平中心减少左右留白。原图、标题、模式切换方式、今日双卡、Widget 屏布局和第四屏付费逻辑不变。

本阶段完成，无新增文件，仅修改 OnboardingView.swift 与本文。xcodebuild iOS 模拟器 Debug 构建通过；simctl 安装/启动后检查 iPhone 17 Pro 中英壁纸页与 SE 中文小屏截图，底部文案、手机边缘及模式入口完整；未新增测试，既有真实点击待验收项保持原状态。执行修改前差异、git diff --check 和 git status；工程/签名/版本及业务未改，仓库仍为原先整体未跟踪状态，无异常产物。备份、截图与日志位于仓库外 `~/.cache/MaoStyleCalendar/onboarding-wallpaper-scale-20261112/`。建议先确认本版手机占比。

2026-11-12 按用户连续两次反馈拉开今日引导页双卡的默认横向距离：日历中心从宽度 40% 调至 28%，详情卡中心从 54% 调至 63%，减少左右外侧留白及相互遮挡。两张卡的尺寸、纵向位置、图像、纸边阴影、详情在前时的布局、切换动画和按钮逻辑不变，其余三屏及业务/工程配置不改。

本阶段完成，无新增文件，仅修改 OnboardingView.swift 和本文。xcodebuild iOS 模拟器 Debug 通过；simctl 安装/启动并保存普通 iPhone 实际截图；修改前精确比对确认仅两项默认横坐标变化。执行 git diff --check 与 git status，仓库沿用整体未跟踪状态，无异常文件；未新增测试，既有真实点击待验收项不因此视为通过。备份与日志在仓库外 `~/.cache/MaoStyleCalendar/onboarding-card-spacing-20261112/`。建议先确认本版间距后再继续。

2026-11-12 按用户后续要求重做今日引导页的双卡层叠：中英文详情图恢复正常整页排版（等距页边、居中标题、全宽分节正文与底部彩色水墨山景），取消专为遮挡保留的空白左列。详情卡实际尺寸大于日历，默认位于后层，上方略露、下方露出更多；点击露出的详情卡将其带到前景，日历向右后退并保留可点击露出，点击日历可切回。切换先错开纸页，再交换层级并弹簧回落，进行中屏蔽重复点按但保持画面原色；开启减少动态效果时直接切换层级。图片保存在本页视图内，避免状态切换时重复读取文件；卡片按钮提供双语辅助标签与前后状态。详情卡边缘经重绘清理，原生接触阴影叠加柔和投影，前景状态阴影更深；为底部阴影预留空间，避免被底栏裁切。

本阶段完成，无新增仓库文件；修改 OnboardingView.swift、today-detail-zh.png、today-detail-en.png、manifest.json 和本文。仅今日引导页调整，其他三屏、日历原图、启动显示规则、付费业务、工程/签名/版本和其他平台未改，仍限普通 iPhone Debug 候选。xcodebuild iOS 模拟器 Debug 通过；simctl 安装/运行后保存 iPhone 17 Pro 中文与 SE 英文两种前后状态截图、中文运行录屏；调试参数 --review-onboarding-card-switch 调用与按钮相同的切换函数完成往返，已确认状态/层级呈现。Device Hub 截图正常，但 CUA 真实点击返回 noWindowsAvailable，故本轮不能宣称物理点按命中已通过；手动点按与 VoiceOver/减少动态效果运行验收仍待确认，自动演示不替代交互验收。已检查两张 PNG 透明通道、尺寸、哈希，刷新资源清单；执行修改前差异、git diff --check 与 git status，仓库仍为原有整体未跟踪状态，无异常构建产物。备份、绘图要求、截图、录屏与构建日志位于仓库外 `~/.cache/MaoStyleCalendar/onboarding-layer-switch-20261112/`。建议用户先确认本版双卡层次、阴影和动画，再进入下一阶段。

2026-11-12 按用户截图优化今日引导页的右侧详情卡：重绘中英双语透明资源为平整厚纸、轻微圆角与细纸边，移除不自然卷曲和粗灰轮廓；文字列由原先靠右收窄改为从卡片约 45% 宽处开始，内容沿用现有候选。详情卡宽度参数由 0.62 改为 0.60、中心横坐标由 0.78 改为 0.70，缩短日历与详情文字之间的空白并让卡片右缘回到可视范围。左侧日历、其余三屏、交互动画与购买业务保持不变。

本阶段完成；无新增仓库文件，仅修改 OnboardingView.swift、today-detail-zh.png、today-detail-en.png、manifest.json 和本文。已执行 xcodebuild iOS 模拟器 Debug（BUILD SUCCEEDED）、simctl 安装/启动/中英截图、PNG Alpha/尺寸/哈希检查、修改前差异与 git diff --check、git status。签名/工程配置、正式 App 业务、Release 隔离与其他平台未改；资源仍为 Debug 候选，正式内容审核状态不变。未新增测试；本次仅位图与摆放参数调整，既有交互待验收项仍保留。备份与日志在仓库外 `~/.cache/MaoStyleCalendar/onboarding-detail-refine-20261112/`；仓库仍为原有整体未跟踪状态，无异常构建文件。建议用户先确认本版详情卡观感。

2026-11-12 完成普通 iPhone 首次引导的首版 Debug 实现，四屏依次为桌面小组件、今日卡片、壁纸、Full Access。首次展示即记录，后续正常启动跳过；设置调试区新增“始终显示首次引导”。原启动品牌动画保留。原生标题、按钮、进度点与权限文案支持中英切换，示例手机/卡片使用中英文透明图层，按层淡入、上移和缩放，支持减少动态效果回退；壁纸保留原稿排版/仅插画切换。第四屏复用现有 StoreKit 产品、本地化价格、购买/恢复流程及法律文档，六项权益与设置付费墙共用同一文案表。

本阶段新增 OnboardingView.swift、Native/Resources/OnboardingPreview/ 下 12 张 PNG 与 manifest.json；修改 StartupView.swift、AppSettingsView.swift、project.pbxproj 和本文。图层为基于已确认设计的重新生成素材，局部绘画与整图不完全相同；英文示例包含候选引文和项目编辑文案，尚未取得 bilingual_verified/正式内容批准。因此入口、调试项与图层资源仅用于 iOS Debug，Release 不含此引导资源，待视觉和内容审核后另行放开。iPad/Duo/Mac 引导适配、正式内容库、Widget 布局、签名、Bundle ID、版本及已有 StoreKit 业务实现均未修改；工程仅增加源码/资源引用和 Release 排除规则。

验证：xcodebuild 普通 iPhone 模拟器 Debug、iOS Release、macOS Debug 均 BUILD SUCCEEDED；swift test --package-path ios-client/Packages/CalendarCore 共 25 项通过。iPhone 17 Pro 四屏中英运行截图已核对，SE 小屏显示可滚动权益区，大字体运行截图已保存；正常第二次启动跳过、强制显示偏好读取均以实际启动截图验证。12 张透明资源的尺寸/Alpha/校验值已检查并写入清单，Release bundle 确认无 OnboardingPreview；工程原有 buildSettings 比对只有资源排除项变化。原生模拟器控制工具未返回现有页面及引导页的可操作控件，故本轮未完成真实点击、左右滑动、切换按钮、协议导航、购买/恢复、VoiceOver 与减少动态效果的交互验收，不能以截图或编译通过替代。已有购买验收记录仍独立有效，不代表新入口已验收。执行 git status、git diff --check 及修改前备份差异核对；仓库沿用整体未跟踪状态，无本轮构建/日志/签名资产写入仓库。所有备份、构建、截图与入场录屏保存于仓库外 `~/.cache/MaoStyleCalendar/onboarding-implementation-20261112/`。建议先由用户审阅普通 iPhone 效果，再进入下一阶段。

2026-11-12 修复英文设置页缺少桌面/锁屏小组件教程入口的问题。原因是原“先做中文、英文正文后续翻译”的要求被实现为整个入口仅 zh-Hans 可见；现移除入口语言限制，中文显示原名称，英文显示 Home Screen Widgets / Lock Screen Widgets，二级页面导航标题同步切换。教程正文与步骤仍保留中文，按原计划后续统一翻译；农历开关等原语言规则、显示偏好、付费及 Widget 布局未改。

本阶段完成，无新增文件，仅修改 AppSettingsView.swift 和本文记录。源码差异确认两个入口不再受语言条件限制，中文教程内容及显示设置代码保持一致；真机 Debug 构建和 codesign 校验通过，已沿用现有签名覆盖安装到 iPhone 17 Pro Max，devicectl 安装及正常启动均返回 success，版本仍为 1.0.0（1）。未修改工程/签名、资源或业务逻辑；双语点击观感待用户在手机确认。执行 xcodebuild、codesign、devicectl install/launch、备份差异核对、git diff --check 与 git status；仓库仍为整体未跟踪状态，无异常新增文件。日志及备份位于仓库外 `~/.cache/MaoStyleCalendar/widget-guide-language-20261112/`。建议继续在英文设置中验收入口。

2026-11-11 用户确认当前 Widget 预览布局后，要求安装真机 Debug 包。已沿用工程现有自动签名与 Team 配置，为连接的 iPhone 17 Pro Max 构建 Debug 1.0.0（1），包含最新 App 与 CalendarWidget 扩展；codesign 深度/严格校验通过，devicectl 覆盖安装及正常启动均返回 success，未使用 QA 启动参数。未卸载应用，不清理原有数据；真机桌面观感与手势体验由用户继续确认。

本阶段完成，无新增仓库文件，仅更新本文安装记录；源码、资源、版本号、业务、工程及签名配置未改。执行 xcodebuild 真机 Debug 构建、codesign 校验、devicectl install/launch、git diff --check 与 git status。仓库仍为原先整体未跟踪状态，无新增异常文件。构建产物及日志保存在仓库外 `~/.cache/MaoStyleCalendar/DerivedData-device-debug-20261111/` 与 `~/.cache/MaoStyleCalendar/device-debug-widget-20261111/`，未提交构建产物或签名资产。建议用户直接在真机桌面添加 Widget 验收。

2026-11-11 按用户要求，横向超大 systemExtraLarge 沿用中号右侧三分之二图片区方案，修复竖版插画铺满横向画布导致只露出头顶的问题。背景绘制、取景坐标、密度图及人脸保护框同步使用既有横向主体变换，语录增加同样的窄宽度候选以利用留白。保留横向超大目标 42pt / 最低 36pt、日期字号、间距与留白；人脸跨度过大的 pack-0282 仍优先保留人脸而略缩小。中号、小号、大号、Duo、锁屏及原图不改。

本阶段完成，仅修改 ArtworkWidgetView.swift、WidgetArtworkQA.swift（新增 --widget-extra-large-artwork-qa 全背景验证分支）、widget-quiet-layout.md 及本文档，无新增文件。iOS Simulator Debug 构建通过（含 Widget Extension）。iOS 26.5 / 27.2 及既有 iPad 路径共 2,280 张组合样张、1,080 组显示/文字边界检查通过，288 次横向超大字号检查均在 36–42pt；其他类型 1,920 张前后 PNG 完全一致，Duo 40 张旧基线一致。全 133 张背景的 266 张横向超大正常/探针图通过右侧区域比例、对齐、人脸边界与字号核验，133 组文字/日期边界检查通过。已查看 pack-0080 最终样张，主要人物及举手动作可见；真实桌面观感待用户确认，建议验收。

执行 xcodebuild、simctl、区域/字号/像素边界检查、PNG 与源码备份比对、资源 checksum 核验、git diff --check 和 git status。原图、内容、其他页面、工程/签名未改，未安装真机，不代表整体 iPad 适配验收。仓库保持整体未跟踪状态，无异常新增顶层文件。日志、备份和样张在仓库外 `~/.cache/MaoStyleCalendar/widget-extra-large-artwork-20261111/`。

2026-11-11 中号图片区按用户要求改为卡片右侧三分之二，替代上一阶段最多 62% 宽的完整主体适配。保持原比例并靠右；纵向优先主体上沿，再约束到容纳已标注人脸的窗口，允许裁切上下场景。人脸跨度过大时略缩小，全 133 张背景中仅 pack-0282 使用此回退，画布图片区仍为三分之二。左侧三分之一为纸面，渐隐及密度图投影同步限制在右侧。中号日期区与下方语录最小间距由 8pt 调为 6pt，便于短语录利用左侧留白；底部 18pt 和最低字号 13pt 不变。

本阶段完成，修改 ArtworkWidgetView.swift、WidgetArtworkQA.swift（新增 pack-0079 样张）、widget-quiet-layout.md 及本文档，无新增文件。中号采用独立背景分支，已修复回归检查发现的遮罩连带影响。Debug 构建通过（含 Widget Extension）；2,280 张组合样张的 1,080 组边界/日期区检查通过，其他类型 1,430 张前后 PNG 完全一致，Duo 40 张旧基线一致。全背景两种中号尺寸 532 张图通过右侧区域、对齐、人脸边界与字号核验，266 组文字/日期边界检查通过。已查看用户反馈多人读书图，语录位于左侧留白；真实桌面观感仍待确认，建议用户验收。

执行 xcodebuild、simctl、区域/字号/文字检查、PNG 与源码备份比对、资源 checksum 核验、git diff --check 和 git status。原图、内容、其他页面、工程/签名未改，未安装真机。仓库仍为整体未跟踪状态，无异常新增顶层文件。日志、备份、样张与报告位于仓库外 `~/.cache/MaoStyleCalendar/widget-medium-two-thirds-20261111/`。

2026-11-11 修正中号 Widget 竖版插画被横向铺满裁切、只能露出人物头顶的问题。仅 systemMedium 改为主体适配：将既有 illustrationRegion 与已标注人脸框合并，按卡片右侧最多 62% 宽度及完整高度等比容纳，右/底对齐；左边缘用 6% 渐隐衔接同一纸色，原 JPG 不变。背景绘制、密度图与人脸区域投影复用同一变换，卡片左侧图像外区域按空白处理。中号增加约 28% 宽的语录候选，便于利用日期右侧、插画左侧的狭长留白；保留 17pt 目标 / 13pt 下限及既有完整优先、最低字号尾部省略和日期区保护。小号、大号、横向超大、Duo 与锁屏不改。

本阶段完成，仅修改 ArtworkWidgetView.swift、WidgetArtworkQA.swift、widget-quiet-layout.md 与本文档，无新增仓库文件。iOS Simulator Debug 构建通过（含 Widget Extension）。现有 11 种构图/显示开关组合在 iOS 26.5 / 27.2 / 既有 iPad 路径生成 2,090 张样张，990 组文字边界与日期区检查通过；与修改前相比，其他类型 1,300 张 PNG 字节完全一致，Duo 40 张旧基线亦一致。新增显式 --widget-medium-artwork-qa 模式，对 133 张独立背景、常规/紧凑中号、日期及农历打开状态生成 532 张正常/探针图：全部主体区域与已标注人脸框位于卡片边界内，532 次所选字号不低于 13pt，266 组文字/日期/边界检查通过。几何检查不代表所有语义主体均已人工审美验收；已查看用户截图 pack-0080，以及骑马、读书、红底和多人场景样张。允许部分语录遮挡插画规则继续保留。

执行 xcodebuild、simctl 安装/显式 QA 启动、全背景主体投影和文字边界检查、字号及区域资源 checksum 核验、备份差异与 PNG 字节比对、git diff --check 和 git status。原图、内容、其他 App 页面、付费业务、字体、签名及工程配置未改，未安装真机。仓库保持原先整体未跟踪状态，无异常新增顶层文件。备份、日志、样张及报告位于仓库外 `~/.cache/MaoStyleCalendar/widget-medium-artwork-20261111/`。建议用户验收中号主体完整性与图文比例。

2026-11-11 修正横向超大 Widget 语录偏小及 iPhone 调试预览未采用 iPad 布局的问题。此前 iPadWide 同时依赖 systemExtraLarge 和宿主设备 idiom，导致 iPhone 预览使用 21pt / 最低 16pt；现按目标 family 决定 iPad 横向超大布局，在预览与 iPad 上统一。横向超大语录目标字号 42pt、硬性下限 36pt，替代此前真实 iPad 的 30pt / 最低 25pt；其余字号策略、内容完整优先/最低字号尾部省略、日期区保护及允许覆盖插画规则不变。预览尺寸说明增加「iPad 布局」。iOS supportedFamilies 仍仅向非 iPhone 设备提供 systemExtraLarge；未修改平台支持或工程配置。

本阶段完成：修改 ArtworkWidgetView.swift（横向超大判定与语录字号）、AppSettingsView.swift（预览说明）、WidgetArtworkQA.swift（增加用户截图 pack-0078 样张）、widget-quiet-layout.md 和本文档，无新增仓库文件。iOS Simulator Debug 构建通过（含 Widget Extension）；iOS 26.5 / 27.2 与既有 iPad 路径共 1,900 张样张，900 组显示/边界/日期区隔离检查通过，240 次横向超大实际字号检查均为 36–42pt。同一可用预览宽度下 36/720 > 17/364，横向超大最低字号的显示比例仍大于中号最大字号。iPhone 与 iPad 的 100 张横向超大 PNG 字节完全一致，其余类型与修改前 1,440 张 PNG 字节完全一致，Duo 40 张旧基线亦一致。原 Duo 竖版及后续共享绘制/锁屏函数逐字未改；133 张插画 checksum 与 365 套数据检查通过。

执行 xcodebuild、simctl 安装/显式 QA 启动、实际字号/像素边界检查、跨设备与修改前 PNG 字节比对、源码备份差异核对、git diff --check 与 git status。未改图片、语录、业务、字体资源、签名及工程配置；未安装真机，不代表完整 iPad 适配验收。仓库保持原先整体未跟踪状态，无异常新增顶层文件。日志、备份及样张在仓库外 `~/.cache/MaoStyleCalendar/widget-extra-large-font-20261111/`，建议用户验收横向超大的新字号。

2026-11-11 按用户反馈提高普通桌面 Widget 语录可读性：设置硬性最低字号，小号 11pt、中号 13pt、大号/横向超大 16pt（保留现有 iPad 横向超大 +9pt 字号增量）。候选不再降至 5pt；在日期区外优先寻找留白和低图案区域，达到字号下限后允许适当覆盖插画。先选择能完整显示的候选；极长语录在紧凑尺寸下若最低字号仍放不下，保持最低字号、利用完整剩余宽度并以尾部省略号呈现，VoiceOver 仍提供完整语录。不缩日期/星期/农历，不将语录挤入日期块。Duo 超大竖版、锁屏绘制及已有预览入口保持不变。

本阶段完成，修改 ArtworkWidgetView.swift、WidgetArtworkQA.swift（增加截图中 pack-0104 及选中字大小/截断状态记录）、widget-quiet-layout.md 与本文档，无新增仓库文件。iOS Simulator Debug 构建通过（含 Widget Extension）；iOS 26.5 / 27.2 及既有 iPad 字号路径共 1,710 张正常/探针样张，1,296 次最低字号检查通过，810 组显示状态/留白/日期区不重叠检查通过。允许插画遮挡后，不再要求人脸框零相交；部分拥挤构图存在图案或保护框覆盖。Duo 40 张前后 PNG 完全一致，原 topAlignedForeground 及后续共享绘制/锁屏代码逐字一致。133 张插画与 365 套区域数据 checksum 检查通过。检查并查看了用户反馈插画、长语录紧凑尺寸的实际样张；真实桌面观感仍待用户确认。

执行 xcodebuild、simctl 安装/QA 启动、排版像素检查、最低字号记录核验、备份差异核对、git diff --check 与 git status。原图、语录、App 页面、业务、工程/签名配置未改；仓库仍为原先整体未跟踪状态，无异常新增顶层文件。日志、备份、样张与报告位于仓库外 `~/.cache/MaoStyleCalendar/widget-min-font-20261111/`。建议用户验收新版字号与允许遮挡后的观感。

2026-11-11 恢复设置 → 调试 →「Widget 全类型预览」入口，并完善 Debug 专用预览页。按 filename 去重覆盖全部 133 张独立插画，支持背景缩略图选择、前后切换、预览日期、日期/星期/农历/语录本地开关、小/中号紧凑尺寸及原尺寸双向滚动查看。桌面小/中/大/横向超大、锁屏圆形/矩形/行内及待机小号集中展示；iOS 27 增加真实 Duo 竖向超大，旧系统仅提示版本要求，不以大号冒充。直接复用 ArtworkWidgetView / ArtworkLockWidgetView，显示开关不写 App Group，背景选图使用 200px 缩略图、后台 actor 立即解码及 4 MiB 缓存，离屏释放。跨设备尺寸与系统着色/圆角以实机为准，未扩展 Duo/iPad 产品适配。

本阶段实现与渲染验证完成。只修改 AppSettingsView.swift（调试入口、预览及样张辅助）、WidgetArtworkQA.swift（新增显式 --widget-gallery-qa 分支）及本文档，无新增仓库文件。正常启动及既有 QA 路径保持不变；桌面/锁屏正式绘制、原图、内容、业务、付费、工程与签名未改。iOS Simulator Debug 构建通过，全部背景在 iOS 26.5 的 8 种和 iOS 27.2 的 9 种样式完成 2,261 次渲染与尺寸核验。UIHostingController 承载完整预览页并确认首屏真实渲染；Device Hub 点击接口持续返回 noWindowsAvailable，完整点击/选图/原尺寸交互尚未自动验收，不能将渲染检查视为交互通过。未安装真机，建议用户在调试入口手动验收。

执行 xcodebuild、simctl 安装/显式 QA 启动、全背景渲染报告核验、源码备份差异核对、git diff --check 与 git status。仓库保持原先整体未跟踪状态，无新增异常顶层文件；备份、日志、样张与报告在仓库外 `~/.cache/MaoStyleCalendar/widget-preview-20261111/`。

2026-11-11 用户确认桌面 Widget 改为语录优先布局在留白或图案较少的区域，替代下方固定底部对齐方案。普通小/中/大及横向超大在顶部日期块下方、日期块右侧寻找合适区域，日期、星期、农历保持原字号和位置；语录按实际字体与固定宽度测量，完整容纳后再绘制。评分综合图案密度、已标注人脸区域和字号，保留底部 padding 与日期块间距；空间紧张时缩小语录，极长语录在小尺寸下字号仍偏小，等待用户观感验收。Duo systemExtraLargePortrait 保留原布局；锁屏、原图、语录内容、显示偏好、其他页面及工程/签名配置未改。

新增 `ios-client/Native/Resources/DailyArtwork/widget-composition.json`（285,764 字节），覆盖 133 张独立 JPG / 365 套内容：24×36 密度图、离线 Vision 全图与分块检测及人工补充的 323 个人脸保护框、原图 SHA-256。Widget 只读取轻量区域数据并投影至实际裁切，不新增运行时图像分析、网络请求或第三方依赖。区域数据缺失或与内容清单 checksum 不符时回退到既有插画区域。数据方法与边界见 `docs/engineering/widget-quiet-layout.md`。

本阶段代码与模拟器验证完成。修改 ArtworkWidgetView.swift、DailyArtworkLibrary.swift、已有 WidgetArtworkQA.swift 和本文档；新增上述 JSON 及说明文档。iOS Simulator Debug 构建通过（含 Widget Extension），显式 QA 模式在 iOS 26.5 / 27.2 与现有 iPad 路径共渲染 1,520 张正常/探针样张；8 种插画构图、普通/紧凑尺寸及五种显示开关组合的 720 组探针检查通过：语录显示状态、留白边界、日期区不重叠，已标注人脸框零相交。该检查不能替代整批语义构图或真机视觉验收。Duo 竖版 40 张前后 PNG 字节一致；原竖版方法及后续共享绘制/锁屏代码逐字一致，133 张 JPG 与已确认批次 checksum 一致。执行 xcodebuild、simctl、像素区域与数据校验、备份差异核对、git diff --check 和 git status。仓库保持原先整体未跟踪状态，无新增异常顶层文件；未安装真机。备份、生成脚本、检测记录、样张及检查结果位于仓库外 `~/.cache/MaoStyleCalendar/widget-quiet-layout-20261111/`。建议用户验收 Widget 实际观感后再进入下一阶段。

2026-11-11 用户否决年度册白色描边效果，改为半透明阴影分离卡片。已移除年度册双层描边，在卡片背后的独立 4pt 圆角纸面形状上增加轻贴边阴影（ink 12%、radius 0.8、y 0.6）和柔和下落阴影（ink 9%、radius 4、y 2.5），不对整张文字/插画组合添加栅格化或 compositingGroup。免费与锁定卡片统一生效；保留尺寸、间距、原生滚动、懒加载/后台解码、付费逻辑、壁纸与刚完成的 Widget 排版。

本阶段完成，仅修改 RootTabView.swift 的年度册边缘效果及本文档，无新增仓库文件。iOS Simulator Debug 构建通过，iPhone 17 Pro / iOS 26.5 截图确认前两张卡片与下方锁定卡片均以柔影区分背景，白色边框已消失。执行 xcodebuild、simctl 安装/启动/截图、源码备份差异核对、git diff --check 与 git status。工程/签名/资源及其他页面未改；仓库仍为原先整体未跟踪状态，无新增异常顶层文件。日志、备份与截图位于仓库外 `~/.cache/MaoStyleCalendar/yearbook-card-shadow-20261111/`。无已知未解决问题，未安装真机；建议用户验收新版观感。

2026-11-11 桌面 Widget 语录底部对齐优化。按用户要求，普通小/中/大/横向超大使用独立顶部日期区与底部语录区；保留日期、星期及农历的原定字号，先测量顶部区域，语录只在剩余高度内以 1pt 步进选择能完整容纳的最大字号，保持顶部最小间距。小号底部留白沿用水平 inset（紧凑 141pt 宽约 8.46pt，常规 10pt），中号 18pt，大号和横向超大 16pt。关闭日期/农历时，语录继续贴近底部；关闭语录时只保留顶部日期区。插画、配色、透明度、日期数据、显示偏好和锁屏布局未改。

Duo 的 systemExtraLargePortrait 显式保留原前景布局：原方法正文及共享绘制函数逐字比对一致，iOS 27 的 40 张前后样张 PNG 哈希完全相同。只修改 ArtworkWidgetView.swift、已有 WidgetArtworkQA.swift（增加显式参数开启的离线排版样张模式）和本文档，无新增仓库文件。iOS Simulator Debug 构建通过（含 Widget Extension）。普通及紧凑小/中号、大号、横向超大在 iOS 26.5、iOS 27.2 和现有 iPad 横向超大字号路径完成短/普通/最长语录、浅/红底，以及日期/农历/语录显示组合验证。360 组色标像素位置检查全部通过：语录在底部留白内，未与顶部日期墨迹重叠；重点核对最长 105 字语录的缩字与全文显示。实际预览与色标探针分别归档，色标只用于 QA，不接入产品界面。

执行 xcodebuild、simctl 安装/启动、ImageRenderer 样张、Pillow 色标边界/底部留白/重叠检查、Duo 前后 SHA-256、源码备份差异核对、git diff --check 与 git status。构建日志、前后样张、位置检查和对照图位于仓库外 `~/.cache/MaoStyleCalendar/widget-bottom-alignment-20261111/`。工程配置、签名、资源、付费与 App 页面未改；仓库仍为原先整体未跟踪状态，无新增异常顶层文件。阶段完成，无已知布局失败；未安装真机，下一步建议用户查看主屏幕实际观感。

2026-11-11 年度册卡片描边优化。浅纸插画统一 A 版后与页面底色接近，按用户要求参照壁纸页样式，在 YearbookMonthGrid 的卡片外层增加 1.2pt、85% 白色外描边，以及内缩 1.5pt、0.5pt、30% paperEdge 的内描边，保持既有 4pt 小圆角。未解锁与已解锁卡片均显示完整边缘，描边位于锁定模糊之外并禁用命中测试。没有新增阴影或位图处理；卡片尺寸、间距、瀑布流、原生滚动、懒加载/后台解码、点击与付费逻辑均未改，壁纸页也未改。

本阶段完成，仅修改 RootTabView.swift 的年度册卡片外观和本文档，无新增仓库文件。iOS Simulator Debug 构建通过，iPhone 17 Pro / iOS 26.5 截图核对两张免费卡片及下方锁定卡片，边缘清晰且位置/尺寸保持原样。执行 xcodebuild、simctl 安装/启动/截图、与修改前源码备份差异核对、git diff --check 和 git status。工程/签名/资源/语录未改；仓库保持原先整体未跟踪状态，无新增异常顶层文件。构建日志、前后截图与源码备份位于仓库外 `~/.cache/MaoStyleCalendar/yearbook-card-outline-20261111/`。未安装真机，下一步建议用户查看新版实际观感。

2026-11-11 用户确认 A 版重新清洗样张及 OLD/新稿对照，授权整批按同一流程制作并压缩。已完成 108 幅浅纸底（两张确认样张复用、106 幅回到原扫描与旧无损母版重新清洗/绘制），25 幅红纸底保留并复用现有优化 JPG；七张书页字纹单独返修。原扫描 365 份 SHA-256 全部保持一致。按现有相同画面分组，将 365 套内容引用合并为 133 个 JPG，删除 232 个完全重复的文件副本，语录绑定/分段/版式/年度分配保持原样。全部 1024×1536、sRGB、渐进 JPG，资源从 71,540,569 降至 26,606,755 字节（减少 62.8%，不是 IPA 下载体积）。110 幅不超过 200 KB，23 幅为记录的质量例外，最大 266,701 字节。无损稿与旧资源保留在仓库外制作目录，完整路径、流程与验证见 [整批处理报告](assets/paper-reclean-A-20261111.md)。

已更新 DailyArtwork 图片、索引 filename/assetChecksum/浅纸 paperColor/对应 revision，以及外部制作登记表。DailyArtworkQA 的体积断言同步原规范的 350 KB 例外上限；没有修改业务、付费、滚动、字体、引文、工程/签名/版本配置，candidate 与 Release 隔离保留。新增整批报告，修改本文档；原扫描、生成稿、无损母版、提示词及构建日志均在仓库外。iOS Simulator Debug 构建通过，产物 365 引用/133 图片哈希通过，iPhone 17 Pro / iOS 26.5 完成 365 卡片渲染、730 次壁纸导出和年度分配/农历/构图检查。执行 Pillow/ImageCms 资源验证、SHA-256、备份字段差异核对、xcodebuild、simctl、git diff --check 与 git status。仓库原先全部未跟踪的状态未变，无新增异常顶层文件。整批资源阶段完成，未安装到真机；下一阶段建议用户验收整批实际观感，不将制作完成视作内容授权或发布批准。

2026-11-11 用户否决上述本地像素校色 v3：人物轮廓、人物间隙与黑板下沿残留旧纸色，核心区域像素未变不能证明边缘合格。按用户要求改为回到原始扫描重新清洗两张难例，先完成画面与 A 纸色的整体融合，再从无损母版一次导出 JPG。原始扫描 365 份均存在，SHA-256 与登记表一致；365 条压缩前母版引用均存在，对应 133 份独立母版路径。原扫描与已有母版保持只读。

本轮离线候选位于仓库外 `/Users/ideabox/Desktop/毛选资源制作/review-inventory/paper-reclean-A-20261111-r1/`。使用原扫描及旧无损母版作为参考重新清洗/绘制，再对全图做连续统一白平衡，未使用人物保护选区。两张候选均为 1024×1536，纸面参考区域中位数约 RGB(247,241,229)，保留无损 PNG；sRGB 渐进 JPG 采用 4:4:4，教室 quality 83、194202 字节，读书老人 quality 86、191350 字节。已核对整图及原尺寸学生间隙、长袍边缘、黑板下沿、老人头部和持书手部，并对照 PNG/JPG。新的清洗包含人物细节重绘，不是原图逐像素保留，仍待用户视觉确认；本轮尚不批量处理。

本阶段完成两张样张，新增文件均在仓库外（源文件审计、无损候选、压缩预览、对照、局部及处理记录）。仓库仅更新本文档，无新增文件；App 插画、paperColor、代码、工程配置、签名、内容绑定与分配算法未修改。执行 Pillow/ImageCms 导出及解码检查、尺寸/ICC/文件体积与源文件 SHA-256 核验、原尺寸视觉检查、git diff --check 和 git status。本阶段没有运行 Debug 构建，因为未改代码或接入资源。下一阶段以样张获用户认可为前提。

2026-11-11 用户在纸色对比中选择 A「温润象牙白」，作为插画纸色优化方向，保留轻微暖意并降低黄褐感及纸纹厚重感。生成预览中的人物与裁切存在偏差，只作为选色参考；正式样张需基于现有 JPG 做可回滚的像素校色并复核绘画细节。下一步先以教室 pack-0047 与读书老人 pack-0008 做原尺寸样张，样张确认后再处理整批。现有 365 张 JPG 均为 1024×1536 RGB，本轮核对到 145 种 paperColor 记录，正式统一时需结合实际纸张区域逐张检查。

用户随后明确同意本地像素校色（Python），先交付这两张样张。当前候选为仓库外 /Users/ideabox/Desktop/毛选资源制作/review-inventory/paper-color-A-20261111-v3/，保留 1024×1536 尺寸与 sRGB ICC，包含无损 PNG、高质量 JPG 预览、原图/A 版对照及原生人物局部。纸色参考区域中位数统一为 RGB(247,241,229)，纸纹对比系数 0.55。使用 Lab 纸面选区和逐图绘画保护区；v1 因浅色衣服受影响、v2 因局部亮边在内部检查中淘汰，v3 待用户视觉确认。两张各四处人物、衣服或物件核心区域在无损 PNG 中与原图像素差为 0；此检查只覆盖记录的核心区域，不代替整图与边缘验收。高质量 JPG 尚未执行 App 体积压缩。输入原 JPG 校验值保持一致，工程资源及 paperColor 数据仍沿用当前版本；未接入 App、未运行 Debug 构建，本阶段为离线资源候选。执行 Pillow/ImageCms 校色、ICC/尺寸/保护区域与 SHA-256 核验、原生局部及整图检查、git diff --check 与 git status。本轮仅更新本文档，无新增仓库文件；批量处理与接入等待样张确认。

2026-11-11 壁纸页背景接缝修正。用户截图中的横线来自横向 ScrollView 在底边截断卡片阴影。只在壁纸 ScrollView 关闭默认裁切，让阴影自然延伸至共用页面底色，卡片尺寸、间距与按钮位置沿用原值。iPhone 17 Pro / iOS 26.5 同位置截图核对通过，原截断边界相邻行的平均亮度跳变由 5.565/255 降至 0.052/255。模拟器及沿用现有签名的真机 Debug 构建通过。本轮只修改 RootTabView.swift 的壁纸显示修正与本文档，无新增仓库文件。执行 xcodebuild、simctl 截图、像素边界比较、备份差异检查、git diff --check 和 git status。对照图与日志位于仓库外 ~/.cache/MaoStyleCalendar/wallpaper-background-seam-20261111/。

新版已覆盖安装到连接的 iPhone 17 Pro Max；自动启动因设备锁屏返回 Locked，待用户解锁后查看真机显示。

2026-11-11 用户确认壁纸页原生滚动通过，要求年度册采用相同方向。年度册取消每次追加六张内容的策略及 YearbookWaterfallLayout 的全量测量；每月一次准备轻量日期与内容引用，纵向 ScrollView 内按列使用 LazyVStack，保留双列及现有自适应列数、2:3 卡片、间距和瀑布流排列。各卡片通过壁纸页已验证的后台 actor 读取和立即解码图片，结果就绪后只更新对应卡片；加载占位与成品尺寸一致，离屏取消任务并释放卡片图片。日期分配、月份/年份入口和免费边界沿用现有实现。只修改 RootTabView.swift 与本文档，壁纸部分与用户已确认版本逐字比对一致。

iPhone 17 Pro / iOS 26.5 四项 XCTest 通过，覆盖免费两张样张、付费拦截及取消保留位置、解锁续接、月份与年份切换、滚动到 31 天月份、普通二月和闰年二月，以及月底最后一张完整显示与打开详情后位置保持。临时加载诊断观察到首屏启动邻近 12 张卡片任务，而非整月 30 张；诊断输出已移除。iOS 模拟器 Debug、Release、macOS arm64 Debug 及使用现有签名的真机 Debug 构建通过。已覆盖安装到连接的 iPhone 17 Pro Max，并成功以年度册入口启动；实际触屏手感待用户确认。执行 xcodebuild、XCTest、simctl 录屏、devicectl 安装/启动、备份差异核对、git diff --check 与 git status。无新增仓库文件，工程/签名配置、资源、壁纸及其他业务未改。日志、截图、录屏及修改前备份位于仓库外 ~/.cache/MaoStyleCalendar/yearbook-native-scroll-20261111/。

2026-11-11 用户提供真机录屏并否决上一版壁纸轮播手感，要求改为普通横向滚动。壁纸预览现使用 ScrollView(.horizontal) 与 LazyHStack，拖动、惯性与卡片停靠由系统处理，移除每页的手动 offset、弹簧归位及五卡窗口重排。内容序列在手势期间固定，保留原有首尾循环；仅在停稳且到达远端循环缓冲边界时定位到相同内容的中间周期。iOS 18 及以上在系统滚动 idle 后提交当前卡片与处理付费边界；iOS 17 只观察触摸状态和卡片居中稳定状态，滚动位移仍由系统处理。快速滑动允许按系统惯性跨过多张内容。图片由懒加载卡片发起请求，在独立 actor 中读取、缩小并立即解码；预览使用单独的 32 MiB 已解码缓存，避免复用其他页面的惰性解码图像。结果回到主线程后只更新对应卡片，离屏释放卡片持有的图片。修改 RootTabView.swift、DailyArtworkCatalog.swift 与本文档，本条替代下方上一版轮播实现说明。

iPhone 17 Pro / iOS 26.5 的最终原生滚动三项 XCTest 通过，覆盖双向免费边界与取消回退、12 次高速双向甩动及停稳后导出到系统分享、16 次连续双向拖动、小幅拖动后的系统停靠和排版切换。测试按系统惯性允许一次滚动跨多张内容，替换旧手写轮播“一次手势必定一张”的断言；分享面板同时识别系统 Cell 与 Button 表示。iOS 模拟器 Debug、Release、macOS arm64 Debug 构建通过。预览解码缺缓存路径加入主线程断言，测试加载期间未触发。使用现有签名配置完成连接的 iPhone 17 Pro Max Debug 构建与覆盖安装；自动启动因设备锁屏返回 Locked，真机触屏手感及性能仍待用户解锁后确认。iOS 17 兼容观察分支完成编译检查，本机无对应运行时，尚未专项运行。执行 xcodebuild、XCTest、simctl 录屏、ffmpeg 抽帧、devicectl 安装/启动、git diff --check 与 git status，无新增仓库文件；签名配置、素材、其他业务与导出实现保留原样。日志、用户录屏抽帧和原生滚动录屏位于仓库外 ~/.cache/MaoStyleCalendar/wallpaper-native-scroll-20261111/。

2026-11-11 壁纸轮播响应调整。按用户反馈移除选中卡变化时的页面级五张预解码队列，图片改由各卡片自身异步加载；轮播以内容的绝对位置保持视图身份，预览内容未变时跳过重复构建。拖动位移直接更新，松手弹簧由 0.42 秒缩短为 0.28 秒，使用主要动画完成回调恢复响应。保留两侧邻卡及远端垫卡，避免拖动时边缘露空。修改范围为 RootTabView.swift 的壁纸预览与轮播，以及本文档；普通 iPhone 为本轮验收平台。

iPhone 17 Pro / iOS 26.5 无签名 Debug 与 arm64 Simulator Release 构建通过。仓库外三项 XCTest 最终通过，覆盖双向免费边界与取消回退、侧边预览与排版解锁续接、已解锁状态连续前后 16 次触点拖动、小幅拖动回弹及两种排版切换。侧边续接首轮未触发模拟解锁，测试改为先将 Debug 按钮完整滚入屏幕后复测通过。simctl 录屏及 ffmpeg 抽帧核对移动和切换期间的插画显示；这些检查不代表真机帧率或用户手感验收。执行 xcodebuild、XCTest、simctl、ffmpeg、git diff --check、备份差异检查和 git status。无新增仓库文件，源码与状态记录外的工程配置、签名、付费边界及导出业务沿用原实现。真机跟手感待用户运行新版确认。日志、录屏、抽帧及修改前备份位于仓库外 ~/.cache/MaoStyleCalendar/wallpaper-swipe-20261111/。

2026-11-11 用户完成真机 Sandbox 购买验收。付费墙显示 StoreKit 返回的人民币售价 ¥38.00，Apple 显示 Sandbox 购买成功；用户点击确认后 App 自动退出付费墙，设置页显示「已永久解锁」。本条确认购买与 App 内权益更新，恢复已有购买、重装后的权益读取、外部兑换、退款与组件联动继续分别验收。

2026-11-11 用户真机 Sandbox 首次认证完成后，空购买历史正确返回「未找到可恢复的购买」，同步耗时接近一分钟。本轮完善恢复等待体验：显示「正在恢复购买…」，允许关闭付费墙；前台等待 30 秒后提示 Apple 仍在同步。超时或关闭后仍处理原请求的权益结果，再次恢复复用同一同步请求。30 秒为本轮选定的界面等待时限。已有购买恢复、兑换和退款的真机验收继续待完成。

恢复等待改动的 iOS 模拟器 Debug、Release 与 macOS Debug 构建通过。仓库外提取原恢复等待逻辑的四项回归验证通过，覆盖正常返回、超时重试复用请求、取消等待后重开及超时后迟到解锁；两项 XCTest 通过，验证恢复期间可关闭并重开付费墙，以及 30 秒后提示并恢复界面可操作性。界面测试使用独立工程中的延迟响应，仅验证等待体验，Apple 实际同步耗时由 Sandbox 真机观察。

2026-11-10 iOS Full Access 接入 StoreKit 2。付费墙展示 StoreKit 返回的本地化名称与售价，接通购买、主动恢复及 App Store 外部兑换后的权益同步。今日、年度册、壁纸和设置共用已验证权益，主屏小组件读取 App Group 权益快照。首版兑换在 App Store 或兑换链接完成。iOS 模拟器 Debug、Release，macOS Debug 及 CalendarCore 25 项测试通过。iOS 26.5 模拟器观察到付费墙显示 `Full Access` 和 `$4.99`，该观察未覆盖其他地区。独立交易测试在 iOS 26.5 和 27.2 均因本地 StoreKitTest 环境返回 `notEntitled` 未能完成交易。购买、恢复、外部兑换及组件权益联动仍待 Apple Sandbox 真机验收。

2026-11-10 Full Access 权益展示由三行调整为六行。阅读行改为「所有插画和语录自由翻阅」，桌面小组件拆为每日更新插画和自定义显示，壁纸拆为浏览、排版及高清导出和分享。付费墙、中英文购买协议和首次使用引导的权益清单按 [定稿策略](product/iap-strategy.md#3-永久解锁能力) 对齐。本次只调整权益展示与文案。iOS 模拟器和 macOS Debug 构建通过，iPhone 17 Pro XCTest 核对中英文六行顺序、首屏购买按钮及可滚动到达的恢复购买和协议入口。无新增仓库文件。

2026-11-10 用户确认 Full Access 付费策略收口。一个非消耗型永久解锁包含「所有卡片自由翻阅」「桌面插画每日更新，自定义显示」「全部壁纸、排版方式与高清导出」三项权益。已归档四个场景的免费边界，并核对付费墙与中英文购买协议。付费交互已用 Debug 模拟验证，真实 StoreKit、售价和首次使用引导属于后续实现。详见 [IAP 产品与解锁策略](product/iap-strategy.md#3-永久解锁能力)。

2026-11-10 壁纸工坊越界付费墙取消后的回退改为反向弹簧动画。付费墙收起后，轮播沿相反方向回到上一张。开启减少动态效果时直接归位。仅修改壁纸轮播和相关文档，无新增仓库文件。iOS 模拟器与 macOS Debug 构建通过，iPhone 17 Pro XCTest 覆盖双向取消回退及模拟解锁后保留目标，另用录屏核对动效。

2026-11-10 壁纸工坊付费场景已实现。排版、高清导出、锁定预览和滑至锚点任一侧第 3 张共用 `wallpaperLimit` 场景。锁定预览复用年度册的蒙层和锁章。免费轮播以会话初始壁纸为锚点，切 Tab 保留位置，越界卡片在中央停稳后弹付费墙。取消回上一张，Debug 模拟购买后保留目标或继续排版、导出等原操作。付费墙权益和中英文购买协议已同步。详见 [壁纸工坊付费策略](product/iap-strategy.md#7-壁纸工坊已确认)。

iPhone 17 Pro / iOS 26.5 四项 XCTest 通过，覆盖双向轮播边界、切 Tab、排版、预览点击、中英文付费提示及导出续接。录屏逐帧核对第 3 张居中后付费墙进场。导出复验确认原目标 `pack-0002` 生成 1206 × 2622 JPG 并打开系统分享面板。iOS 模拟器 Debug、Release、macOS Debug 构建和 CalendarCore 25 项测试通过。无新增仓库文件。修改壁纸工坊、共用锁定预览与付费墙、购买协议和文档。工程配置、签名、真实 StoreKit 及其他场景的权益规则未改。

2026-11-10 年度册付费场景已确认并实现。免费态可预览本地公历当前月，1 日和 2 日可打开详情，3 日起显示暖米白蒙层、轻模糊和朱红锁章。点年份、其他月份或锁定卡片直接进入 `yearbookLimit` 付费墙。取消保留当前月和滚动位置，Debug 模拟购买成功后继续原操作。年份选择使用锚定在原胶囊上的弹出列表，保留原年份范围并支持解锁后自动打开。同步更新中英文购买协议与 [年度册付费策略](product/iap-strategy.md#6-年度册已确认)。

iPhone 17 Pro / iOS 26.5 三项 XCTest 通过，覆盖两张免费样张、三个拦截入口、取消保留位置、模拟购买后继续对应操作和英文付费提示。核对浅纸与朱红锁定预览及年份选择截图。iOS 模拟器 Debug、Release、macOS Debug 构建与 CalendarCore 25 项测试通过。无新增仓库文件。修改年度册、共用付费墙的年度册场景、购买协议和相关文档。真实 StoreKit、工程配置、签名及其他功能场景未改，普通 iPhone 的 Debug 版本供用户验收。

2026-11-10 今日卡片付费场景已实现。翻页和日期链接共用本地公历的前后各 5 天范围，越界直接打开 `todayCardLimit` 场景的 Full Access 付费墙。越界垫页仅显示纸张。关闭后保留当前日期，Debug 模拟解锁后继续到目标日期。跨日、时区变更和回到前台时重新计算范围。权益名称与中英文购买协议已同步。首次使用引导及其他付费场景依 [IAP 产品与解锁策略](product/iap-strategy.md#5-今日卡片已确认) 分阶段推进。

iPhone 17 Pro / iOS 26.5 两项 XCTest 通过，覆盖前后第 5 天与第 6 天边界、取消、模拟解锁与续翻、日期链接及中英文场景提示。CalendarCore 25 项测试通过，含新增跨年与夏令时用例。iOS 模拟器 Debug、Release 及 macOS Debug 构建通过。新增日期规则与测试文件，修改今日页、根导航、共用付费墙、两份购买协议及文档。工程配置、签名、年度册与壁纸业务逻辑未改，真实 StoreKit 和首次使用引导尚未接入。

2026-11-10 用户根据今日卡片截图重新选定免费桌面小组件的固定背景，最终使用骑马队伍插画 `pack-0259`，替代本轮暂选的 `pack-0325` 和此前的 `pack-0015`。复用候选原图及各尺寸现有裁切。仅修改默认背景 ID、付费策略和本记录。iOS 模拟器 Debug 构建通过，核对内置原图与源文件一致。iPhone 17 Pro 主屏 XCTest 和截图确认小号、中号、大号均使用新背景并显示当天日期及语录。正式发行仍须完成插画授权。

2026-11-10 用户确认桌面小组件各尺寸采用同一付费规则。免费态用固定插画「灯下阅读」(`pack-0015`)，日期和语录随当天内容更新。永久解锁后可开启每日换插画和显示农历，也可关闭日期和语录。英文设置隐藏农历开关，桌面小组件、今日和年度册卡片隐藏农历。以 [IAP 产品与解锁策略](product/iap-strategy.md) 为权益来源，同步中英文付费墙与购买协议中的组件描述。其他权益逐项确认。

本阶段使用 Debug 模拟购买，复用共享容器和现有组件标识。iPhone 17 Pro / iOS 26.5 的 XCTest 覆盖四项默认值、付费墙取消、模拟成功后应用本次选择、已购直接修改及英文隐藏农历。实际主屏截图确认免费与已解锁的插画不同，当天语录一致，已购中文显示的农历在切换英文后隐藏。另核对连续两日分配至不同内容包。iOS 模拟器 Debug 与 Release、macOS Debug 构建和 CalendarCore 23 项测试通过。Release 保持排除候选插画和模拟购买。工程配置、签名、锁屏组件与其他业务权益未改，真实 StoreKit 与正式插画授权仍待后续阶段。

2026-11-10 用户对照深红底和浅纸底的 100% 与 78% 渲染后，确认桌面小组件在显示语录时使用 78% 的插画不透明度，隐藏语录时使用 100%。对照图位于仓库外 `~/.cache/MaoStyleCalendar/widget-opacity-100-vs-78-20261110/`。

2026-11-10 桌面小组件显示语录时，插画不透明度由 82% 降至 78%。用两张深红插画的 Small 和 Medium 共用视图对照，人物衣纹略淡，浅色语录的可读性小幅改善。iOS 模拟器 Debug 构建通过，已安装到 Duo。仅修改 `ArtworkWidgetView.swift` 和本文档，无新增仓库文件。对照图位于仓库外 `~/.cache/MaoStyleCalendar/widget-artwork-opacity-78-20261110/deep-red-comparison.jpg`。

2026-11-10 桌面插画小组件试用 82% 的插画不透明度。显示语录时，插画与各素材原有纸色混合，减轻叠字区域的纹理干扰；隐藏语录时展示原图。仅修改 `ArtworkWidgetView.swift` 和本文档，无新增仓库文件。iOS 模拟器 Debug 构建通过，用五种桌面尺寸的共用视图渲染对照四张素材，深红底浅字和浅底墨字的对照图位于仓库外 `~/.cache/MaoStyleCalendar/widget-artwork-opacity-20261110/comparison.jpg`。

2026-11-10 Duo 主屏小组件排查发现，先前用 `CODE_SIGNING_ALLOWED=NO` 安装的模拟器产物未建立 App Group 共享容器。三个开关写进了 App 私有目录，原有 WidgetKit 刷新请求仍在调用，小组件无法读取新值。用本地临时签名 Debug 产物覆盖安装后已确认共享容器建立。验收共享偏好时使用带模拟器 entitlement 的 Debug 产物。Small 的组件库样例改为读取与主屏相同的三项偏好。

Duo iOS 27.2 Debug 构建通过。XCTest 在系统主屏确认农历和语录开启后显示、关闭后隐藏，日期保持显示。验收后恢复用户原先的开关状态。仅修改 `CalendarWidgets.swift` 和本文档，未新增仓库文件。

2026-11-10 桌面小组件各尺寸的农历由设置里的「显示农历」统一控制，首次默认关闭，保留用户此前保存的选择。Small 的组件库样例也读取同一开关。仅修改共享偏好、设置页、小组件 Provider 和本文档，无新增仓库文件。

iOS 模拟器和 macOS Debug 构建通过，CalendarCore 23 项测试通过。iPad 模拟器主屏验证默认隐藏、打开后显示、重启 App 后保留开启状态、再次关闭后隐藏。五种桌面尺寸的共用插画视图均已核对默认隐藏。

2026-11-10 插画版桌面小组件的语录恢复使用与「今日」卡片一致的逐张素材配色，替代下方的统一朱红方案。墨字和朱红字用暖白柔光，浅色字用深棕柔影，增强文字与插画的对比。日期排版沿用现有规格。仅修改 `ArtworkWidgetView.swift` 和本文档，无新增仓库文件。

iOS 模拟器无签名 Debug 构建通过，已通过 simctl 安装到 Duo 和 iPhone SE。用共用视图渲染核对墨字、朱红字及深红底浅字。样张位于仓库外 `~/.cache/MaoStyleCalendar/widget-quote-artwork-color-20261110/`。

2026-11-10 插画版桌面小组件语录统一用主题朱红 `#B81211`。叠在插画上的字加暖白近边阴影和外层柔光，阴影颜色与底图分开，红底素材上的笔画仍有对比。仅修改 `ArtworkWidgetView.swift` 和本文档，无新增仓库文件。

iOS 模拟器无签名 Debug 构建通过，已通过 simctl 安装到 Duo 和 iPhone SE。核对浅色和深红插画的 Small、Medium、Large 共用视图渲染。样张位于仓库外 `~/.cache/MaoStyleCalendar/widget-quote-vermilion-20261110/`。

2026-11-10 插画版 Small 的日期字号改为对齐用户给出的 Medium「什么叫问题？」长卡预览。根据截图字形与项目字体反推，日号采用 Medium 基准字号的 0.52 倍，月份和星期 12 pt，农历 9 pt。同一组件高度下，Small 的日期字号固定使用这档规格，仅语录随空间调整。本条替代下方的 Small 紧凑日期字号。仅修改 `ArtworkWidgetView.swift` 和本文档，无新增仓库文件。

iOS 模拟器无签名 Debug 构建通过，已通过 simctl 安装到 Duo 和 iPhone SE。核对 141 pt、170 pt 的短语录、超长语录和截图同素材渲染。不同容器高度下 Medium 仍根据空间选档，本轮以用户截图的参考档为准。样张位于仓库外 `~/.cache/MaoStyleCalendar/small-widget-medium-date-20261110/`。

2026-11-10 按用户澄清，插画版 Small 日期采用原长语录档位的三组字号。日号按组件高度计算，在 141 pt 和 170 pt 组件中分别约为 17.5 pt 和 20.8 pt，月份与星期固定 10 pt，农历固定 8 pt。同一尺寸下三组日期字号与语录长度无关，仅语录按空间调整。本条替代下方四项统一 10 pt 的记录。仅修改 `ArtworkWidgetView.swift` 和本文档，无新增仓库文件。

iOS 模拟器无签名 Debug 构建通过，已通过 simctl 安装到 Duo 和 iPhone SE。两种尺寸的短、超长语录共用视图渲染均核对通过。截图位于仓库外 `~/.cache/MaoStyleCalendar/small-widget-date-hierarchy-20261110/`。

2026-11-10 插画版 Small 桌面小组件的日号、月份、星期和农历统一为固定 10 pt，取原长语录档位的月／星期字号。日期文字不随语录长度切换大小，语录继续按可用空间自适应，最高 13 pt。仅修改 `ArtworkWidgetView.swift` 和本文档，无新增仓库文件。

iOS 模拟器无签名 Debug 构建通过，已通过 simctl 安装到 Duo 与 iPhone SE。在 141 pt 和 170 pt 的共用视图渲染中核对短、长语录，确认日期字号一致、语录按可用空间调整。截图位于仓库外 `~/.cache/MaoStyleCalendar/small-widget-fixed-date-20261110/`。

2026-11-10 插画版 Small 桌面小组件降低文字的视觉比重。日号以组件高度的 31% 计算，最高 52 pt，语录最高 13 pt，继续保留长语录的缩小档位。组件库样例与桌面时间线共用该排版。仅修改 `ArtworkWidgetView.swift` 和本文档，无新增仓库文件。

Duo iOS 27.2 模拟器无签名 Debug 构建通过。已在系统组件库重新打开同一 Small 样例核对前后截图，并检查 170 pt、141 pt 两种尺寸的共用视图渲染。截图与测试日志位于仓库外 `~/.cache/MaoStyleCalendar/small-widget-type-20261110/`。

2026-11-10 Duo 内屏横向年度册由四列改为三列。首批六张按原比例铺满两行的三列，继续滑到末尾时追加下一批六张。半展开和全展开共用，竖向仍为两列。仅修改 `RootTabView.swift` 和本文档，无新增仓库文件。

Duo 模拟器无签名 Debug 构建通过。界面测试确认首批六张、上滑后追加到十二张，截图核对半展开、全展开横向与旋转后的竖向。验证记录位于仓库外 `~/.cache/MaoStyleCalendar/duo-yearbook-three-columns-20261110/`。

2026-11-10 宽屏品牌开场在插画卡片上半部加读书语录。中文分三行，英文采用外文出版社对应译文。引用仅进入 Debug 预览，待项目负责人确认。iOS 无签名 Debug 和 Release 构建均通过，已检查 Release 二进制未包含引文。iPad 横竖屏与 Duo 内屏半展开、全展开截图已核对，iPad 英文整句及开场退出界面测试通过。仅修改 `BrandOpeningView.swift`、品牌说明和本文档，无新增仓库文件。底本见[品牌说明](design/handoff/v2/brand/README.md#宽屏开场引文)，截图位于仓库外 `~/.cache/MaoStyleCalendar/brand-opening-quote-20261110/`。

2026-11-10 品牌开场扩展到 iPhone、Duo 和 iPad 冷启动。窄窗口沿用上下版式，宽窗口左侧展示中英文标题和文案，右侧等比展示原插画卡片。保留约 1.4 秒自动进入、点按跳过、后台恢复直接进入和 VoiceOver 跳过。Mac 继续按独立阶段处理。仅修改 `StartupView.swift`、`BrandOpeningView.swift`、品牌说明和本文档，无新增仓库文件。

iOS 模拟器无签名 Debug 构建通过。iPad 横竖屏、点按跳过、自动进入及后台恢复界面测试通过。核对普通 iPhone 竖屏与 Duo 内屏半展开横向、全展开竖向。Duo 冷启动录屏确认显示开场，随后截图确认自动进入今日。截图和测试记录位于仓库外 `~/.cache/MaoStyleCalendar/brand-opening-wide-20261110/`。

2026-11-10 Duo 横向「今日」双页移除左侧纸堆各页和右侧详解的外投影。左侧累积投影在轮播边缘被截断，形成明显灰边。保留铜环、叠纸偏移、纸边以及换日的裁切范围。半展开与全展开共用此规则。仅修改 `TodayView.swift` 和本文档，无新增仓库文件。

Duo iOS 27.2 模拟器无签名 Debug 构建通过。使用 Device Hub 切换半展开、全展开，核对截图并在四处原阴影区域取样，修复后均与背景色一致。截图位于仓库外 `~/.cache/MaoStyleCalendar/duo-spread-shadow-20261110/`。

2026-11-10 Duo 内屏移除胶囊上方的「毛选日历」，侧栏由 112 pt 收窄到 72 pt，四个按钮沿用原有尺寸。竖向「今日」收紧页标题和纸堆周围的留白，主卡以 2:3 等比放大，模拟器上宽度增加约 13 pt。半展开和全展开共用布局，横向继续使用双页。仅修改 `RootTabView.swift`、`TodayView.swift` 和本文档，无新增仓库文件。

Duo iOS 27.2 模拟器无签名 Debug 构建通过，已截图核对半展开、全展开竖向和横向双页。界面测试确认侧栏标题移除及四个入口可点，翻面验证未通过，测试点按卡片后关闭按钮仍不可命中。截图与测试日志位于仓库外 `~/.cache/MaoStyleCalendar/duo-narrow-rail-20261110/`。

2026-11-10 Duo 竖向内屏壁纸预览复用 iPad 的主卡尺寸计算。主卡保持壁纸原比例，按内容区宽度与顶部切换、底部导出之间的可用高度放大，左右只露出部分邻卡。半展开与全展开共用竖向规则，横向沿用原轮播布局。仅修改 `RootTabView.swift` 和本文档，无新增仓库文件。

Duo iOS 27.2 模拟器无签名 Debug 构建通过。通过 Device Hub 和截图核对半展开、全展开竖向与转回横向，竖向主卡约从 365 pt 增至 610 pt。截图位于仓库外 `~/.cache/MaoStyleCalendar/duo-wallpaper-portrait-20261110/`，真机观感待确认。

2026-11-10 壁纸工坊统一复用 iPhone 标题下方的「原稿排版／仅插画」分段切换。Duo 内屏移除左栏两个壁纸样式按钮，半展开和全展开均走顶部入口。iPad 原本已走共用组件，本轮核对横竖屏。Duo 样式选择仍由原有绑定保存，轮播和导出继续使用同一选择。仅修改 `RootTabView.swift` 和本文档，无新增仓库文件。

iOS 模拟器无签名 Debug 构建通过。Duo 全展开横向与半展开竖向截图均显示顶部切换，Duo 和 iPad 均通过点按两种样式及预览更新验证。截图和测试记录位于仓库外 `~/.cache/MaoStyleCalendar/wallpaper-style-tabs-20261110/`，真机观感待确认。

2026-11-10 Duo 内屏导航与内容宽度分开判断。半展开与全展开共用四图标胶囊，旋转后继续显示左栏；800 pt 门槛只决定「今日」显示双页还是可翻面的单卡。切换单卡和双页时重置翻面状态，保留已选日期。合上后回到外屏底部标签栏。仅修改 `RootTabView.swift` 和本文档，无新增仓库文件。

Duo iOS 27.2 模拟器无签名 Debug 构建通过。通过 Device Hub 核对全展开与半展开、旋转、单卡翻面后转回双页、合上与重新展开。截图位于仓库外 `~/.cache/MaoStyleCalendar/duo-rotation-20261110/`。

2026-11-10 iPad 宽窗口壁纸工坊取消预览卡 360 pt 宽度上限。中央卡保留壁纸比例，按轮播可用宽度和高度等比放大，左右邻卡在内容区边缘部分可见，轮播下方预留导出间距。iPad Pro 13 英寸竖屏中央卡高度由 480 pt 增至约 1,010 pt。仅修改 `RootTabView.swift` 和本文档，无新增仓库文件。

iPad Pro 13 英寸模拟器无签名 Debug 构建通过。iPadOS 26.5 核对竖屏预览、双向滑动和样式切换，测试窗口未随旋转指令切换。iPadOS 27.2 横竖屏、双向滑动和样式切换界面测试通过，两种朝向下导出按钮均可见。截图位于仓库外 `~/.cache/MaoStyleCalendar/ipad-wallpaper-20261110/`，真机观感待确认。

2026-11-10 iPad 宽窗口改用居左、垂直居中的四图标胶囊导航，与 Duo 展开态共用按钮和样式。今日正反两面按右侧可用空间以 2:3 等比适配，移除该入口原有的 620 pt 宽度上限，保留页标题、铜环、叠纸和投影所需空间。iPad 紧凑窗口沿用底部标签栏。仅修改 `RootTabView.swift`、`TodayView.swift` 和本文档，无新增仓库文件。

iPad Pro 13 英寸（M5）模拟器无签名 Debug 构建通过。界面测试通过，核对四入口切换、左滑换日、翻面及关闭、横竖屏布局。竖屏、横屏和详解截图位于仓库外 `~/.cache/MaoStyleCalendar/ipad-capsule-20261110/`。真机观感待确认。

2026-11-10 结合线上原篇和研究资料复核典型语录语境，逐条润色 365 条「当下解读」。删改抽象表述，增加生活场景和判断依据。阅读正文为三至四段，书目、出处、历史背景和审核档案继续独立保存。[语录详解整理进度](research/daily-quote-detail-progress.md)

2026-11-10 扩写全部 365 条「当下解读」。从短例子和动作扩展到两至三段，补上现实情境、判断依据和可以尝试的下一步。今日和年度册共用正文，原文、历史背景及英文档案继续分别维护。[语录详解整理进度](research/daily-quote-detail-progress.md)

2026-11-10 将「通俗解读」改名为「当下解读」，重写 365 条中文解读。今日和年度册共用新标题与正文。360 条显示三栏，另 5 条只显示当下解读。英文材料继续独立归档。[语录详解整理进度](research/daily-quote-detail-progress.md)

2026-11-10 完成剩余 27 条语录的底本复核与补查。补齐 22 条的原文、出处及历史背景，中文详解完整覆盖增至 360 条。其余 5 条在页面保留通俗解读，核对结果及归属线索收入内部档案。另定位 2 条外文出版社的英文段落，留待多语言接入。[语录详解整理进度](research/daily-quote-detail-progress.md)

2026-11-10 语录详解移除重复的「摘编说明」，按条目呈现原文与出处、历史背景和通俗解读。字词差异留在内部核验档案，读者正文保留理解原文所需的上下文。

2026-11-10 365 套候选卡片接入中文通俗解读。其中 338 套同时有可定位的原文、出处及历史背景，27 套仍待核对归属或底本。英文出版译本的段落与篇目分别归档，后续随多语言接入。完整覆盖和核验线索见[语录详解整理进度](research/daily-quote-detail-progress.md)。

2026-11-09 启动 365 套详解内容补录。用户确认四卷之外的作品可扩大到有正式出版记录的中文底本并另查英文。中文原文、历史背景和项目编辑解读先进入 iOS Debug 详解，英文另行归档。候选内容保持原审核状态。

2026-11-09 退役 10 张插画试制。删除预览页、专用启动和导出分支，以及工程内的 10 张 JPG 和排版 JSON。365 套资源和 Widget 批量检查继续使用原路径。试制接入记录作为历史保留。

2026-11-09 移除 App 与 Widget 面向用户的素材预览和出处待核验标记，以及设置中的素材预览入口。壁纸预览和导出同步移除水印，语录详解隐藏无来源片段的出处占位区。内部核验状态和批量检查入口继续保留。

2026-11-09 壁纸插画改为等比铺满画布宽度，取代原有左右至少 3% 的留白规则。原稿排版、仅插画和 JPG 导出共用此布局，纵向中心保持在画布高度的 53% 处。详见 [壁纸布局](assets/yearbook-wallpaper-integration.md#壁纸安全布局)。

2026-11-09 品牌归档与 iPhone 开场页：中英文 1024 px Icon、透明 SVG／2048 px PNG Logo、品牌提示语与复现提示词已归档至 [v2 品牌目录](design/handoff/v2/brand/README.md)。系统启动屏用暖纸底，紧凑宽度的 iPhone 竖屏冷启动使用同一张整卡底图叠加原生中英文标题和文案，按安全区等比适配。开场约 1.4 秒后自动进入首页，可点按跳过，回到前台直接恢复。大字号用可滚动布局。iPhone SE、18 Pro 与 18 Pro Max 模拟器视觉检查，以及点按跳过、自动进入今日、后台返回流程测试已通过。真机视觉验收待用户确认。

2026-11-09 主题色与 iPhone 品牌：用户确认 `#B81211` 为唯一品牌朱红，沿用标准卡片的基准。界面、日期及图标使用同一朱红，深底上的浅色文字用于保持对比度，插画本身保留原色。用户选定第 1 稿「引文日历」。iOS 主屏幕名称按系统本地化为「毛选日历」和 `Mao Quotes`，中文「毛选」图标为主图标，英文 `MAO` 通过设置中的「主屏幕图标」切换。两套共享页眉、纸页和引号构图。英文商店名称建议 `Mao Quotes: Daily Calendar`。商店名称、发行地区、内容权利及最终上架仍待确认；命名依据见[中英文语录来源与核验规范](research/quote-source-policy.md)。

2026-11-09 产品调整：一级入口改为今日、年度册、壁纸、设置，设置页从今日工具栏移至第四个入口。今日正面只保留作品，点击整卡翻到语录详解，左右滑动换日。桌面小组件的显示偏好继续通过本机 App Group 保存；壁纸导出使用系统分享。

2026-11-06 全年素材接入：用户授权连续完成剩余 11 个月、归档并接入 App 全部现有功能和 Widget，最后统一普通 iPhone 实机验收。全年 365 套候选已归档至仓库外制作根目录与工程 DailyArtwork，今日／详解、年度册、双模式壁纸及导出和 iOS Widget 共用目录与既有年份种子分配器版本 1；替代 31 套循环。闰日仍为独立 Mock，占位不算新增正式插画。原扫描和 1 月已确认数据保留，签名／工程配置／字体／其他平台未改，Release 候选隔离继续生效。实际构建、批量渲染与验收边界见 [全年接入记录](assets/full-year-artwork-integration.md)。下方“暂缓 2 月／仅使用 31 套”等为已被本次授权替代的历史记录，不作为当前推进限制。


2026-11-06 Widget 素材与布局更新：普通 iPhone Debug App／Widget 共用 31 套内容目录与日期映射；Small、Large、纵向大组件采用整卡插画背景叠字，横条右侧约三分之二为插画。此决定替代本轮图文分区试排和旧纵向组件分区方案；锁屏遵循单色、极小空间限制，使用同日语录与矩形单色插画。新增设置中的 Debug Widget 素材预览，其他月份仍不推进。源码／资源通过共享文件接入，Release 隔离候选，原件、JPG、正式分配器、签名版本未改。Debug／Release 构建、核心 28 项测试和两系统 465 张共用视图渲染完成；最终系统桌面逐尺寸、真机及锁屏／StandBy 仍待验收。验收记录见 [Widget 素材接入](assets/widget-artwork-integration.md)。

更新日期：2026-11-06 现有素材接入年度册与壁纸完成：用户要求功能全部验收后再扩大范围，其他月份暂复用现有 31 套。iOS Debug 年度册与今日页逐日共用同一内容映射，支持普通年／闰年全年；壁纸独立浏览 31 套。五种样式简化为顶部“原稿排版／仅插画”，替代 2026-11-02 的五样式决定。预览与 JPG 导出共用画布，顶部20%、底部14%、左右至少3%留白，完整放入2:3插画；两种模式仅切换语录，不含动态日期。Debug／Release构建、核心28项测试、365／366天映射、62个1206×2622实际导出及四种几何比例检查通过。Release候选隔离、图片哈希、签名和构建设置未变；Widget与其他月份清洗未推进。真机不可连接，实际设置系统壁纸和用户整体体验仍待验收。详见 [年度册与壁纸接入](assets/yearbook-wallpaper-integration.md)。

2026-11-06 用户确认 1 月离线成果，要求暂缓 2 月，先接入工程统一看效果：已新增 Native/Resources/DailyArtwork（31 JPG＋语录版式 JSON）及共用 ArtworkPage 渲染，常规 iOS Debug 今日页默认使用 31 套。日期／农历运行时叠加，保留原分行分列，pack-0014 调小字号避让面部。Debug 暂用确定性 31 套循环，不改正式 365 套年度分配器；Release 排除这批待核验候选。核心 28 项测试、模拟器 Debug／Release、App 内 31 张 SwiftUI 渲染与图片哈希、农历换年检查通过，原扫描 365 张哈希未变；当前真机不可连接，真机与用户视觉验收仍待完成。年度册／Widget／壁纸工坊及签名版本未改。资源实际位置与完整文件清单见 [1 月工程接入](assets/january-engineering-integration.md)。当前先做今日页验收与微调，不开始 2 月。

2026-11-06 启动登记＋1 月批次已交付：31 套（4 复用＋27 新增重绘），19 横排、12 竖排、3 通版红底；背景均 1024×1536 sRGB 渐进 JPG，190,092～199,777 字节，合计 6,087,909 字节。365 张原件哈希复核未变，背景 OCR 31 张检出文字项为 0；语录边界、31 套对照与无日期长屏预览已生成，均为离线验证，未做本月新图实机验收。交付及当前版本见 [1 月月度报告](assets/source-month-01-delivery.md)。本月等待用户整体视觉确认，2 月未开始；全部内容 candidate，出处／英译／授权另行核验。仅新增月报并更新相关 docs，App／Widget／工程／原扫描未改，Debug 构建不适用。

2026-11-06 用户确认按月推进清单，已启动全量登记与 1 月批次：365 张原件解码、方向、尺寸与 SHA-256 登记通过，无完全相同文件重复组；既有 10 个 ID 保留，新 ID 延续至 pack-0365。仓库外工作目录 `/Users/ideabox/Desktop/毛选资源制作/`。1 月按 4 张复用＋27 张新增制作推进，整月提交后等待用户确认，未启动 2 月制作。App、Widget、工程配置与原扫描不改。

2026-11-06

## 当前阶段

2026-11-06 扫描插画制作方案与月度推进清单归档完成：用户确认最新 10 张试制、压缩与日期排版方向，要求先归档方案、按原扫描目录月份列出清单，等待确认后执行。本轮新增 [制作方案](assets/scan-cleanup-production-plan.md)与[月度清单](assets/scan-cleanup-monthly-checklist.md)，同步素材接收规范、试制确认记录与文档索引。来源月份只用于追溯和制作批次，最终背景＋语录＋版式绑定稳定内容 ID，由既定年度分配器另行分配日期；不保存原扫描日期作为成品内容字段。

原目录实查仍为 365 张 PNG。现有试制 10 张可复用：1 月 4、2 月 1、3 月 2、5 月 1、9 月 1、12 月 1；预计另制作 355 张。清单确认后先建立全量稳定 ID 登记，再从 1 月到 12 月顺序推进，每月完整交付并等待确认后进入下一月，不逐图增加确认点。复用试制仍须纳入整月复核，不计为该月份已经整批完成；正式底本与授权状态独立维护。

本阶段仅文档归档，无新增清洗、制作目录、App 资源或代码／工程变更。运行目录计数、来源交叉统计、清单合计、链接检查、git diff --check 与 git status；Debug 不适用，未重新构建。仓库仍整体未跟踪，无新增异常产物。方案方向已确认，当前等待用户确认具体推进清单，之后才启动登记＋1 月批次。

2026-11-05 试制卡片日期信息优化：用户要求月份、年份和星期各增大两号，月份与“年份＋星期”左／右对齐，并新增同字号干支年农历。仅修改 `ArtworkTrialGallery.swift` 的日期模板和农历 formatter，以及试制记录/本文档；顶部三行右对齐、底部三行左对齐，底部紧凑模板为新增行调整位置。日号字号、语录坐标、全部 JPG、主 App 默认页面、Widget、工程配置和签名未改。农历从卡片公历日期的本地正午换算，处理春节干支换年与闰月，当前示例为“丙午年 九月廿七”。

本轮真机签名 Debug 构建、安装及 10 张截图检查完成；6 个日期×3 个时区共 18 项农历核验通过，10 张图片校验值未变。使用 xcodebuild、生产 formatter 核验脚本、devicectl install/launch/capture、git diff --check 与 git status；无新增仓库文件、无异常构建产物。证据位于仓库外 `trial-date-20261105/` 缓存。阶段实现完成，等待用户视觉确认，不扩展其他功能或平台。

2026-11-05 10 张压缩插画 Debug 真机试制完成：用户授权先以已压缩的 10 张候选接入工程检查实机效果。新增“今日 → 设置 → 调试 → 10 张插画试制”入口，复用今日卡片容器，保留每图横竖排、逐行逐列、配色与动态日期；试制 ID 不进入年度分配器，标记只在会话内有效。JPG 直接打包，单张约 184～199 KB，总计 1.94 MB；04 号采用完整修订版，09/10 号采用去除底部红黑日期条后的延展重绘版。用户本轮允许重绘与二次创作，优先保证水墨风格统一和画面完整，该决定只覆盖这批插画制作，不代替内容或商业授权审核。

试制壁纸按设备像素比例合成，1440×3200 上限，完整插画下置、上方同色纸面延展，日期不进入壁纸；JPG 通过既有系统分享表交付，不新增照片权限。普通 Mock PNG 导出及正式默认数据源保持原样。实验代码限 Debug iOS；工程仅增加必要源码/资源引用与 Release 资源排除规则，签名、标识、版本、target、部署版本、依赖均未改。

iPhone 17 Pro Max / iOS 26.5.2 使用既有签名配置构建、安装、运行成功，10 张实际页面截图已捕获；设备上通过实际导出代码生成 10 张 1320×2868 JPG，约 575～776 KB。核心 28 项测试、Simulator Debug、真机 Debug、Simulator Release 构建通过，Release 产物不含试制图片；原 365 张 PNG 校验值未变。新增试制源码、10 JPG、排版 JSON 和验收文档；修改今日卡片实验分支、设置/启动入口、壁纸实验导出、工程资源引用与结构/状态文档。CalendarCore、年度分配、Widget 与其他平台专项布局未改。证据在仓库外 `artwork-trial-20261105/` 缓存；详见 [10 张试制接入记录](assets/ten-image-trial-integration.md)。本阶段工程与设备文件验证完成，用户视觉确认、手动保存/设为系统壁纸及正式内容审核仍待完成；不批量处理其余扫描。

2026-11-04 超大竖向 Widget 今日卡片构图：用户确认尺寸已生效，要求参考今日卡片并去掉底部操作栏。仅调整 CalendarWidgets.swift 的超大竖排分支，改为全幅等比插画、左上双列竖排语录与右上朱红大日期/年月/星期/农历；不显示操作栏或原底部阅读区。保留项目字体、原生文字、Mock 标记、日期链接；其他 Family、App 交互、数据、工程与签名不改。WidgetArtwork 新增默认保持原值的标记留白参数，仅新尺寸使用更大安全留白。

本阶段实现与 Debug 构建完成，已安装 Duo 并核对桌面截图；仅修改 CalendarWidgets.swift、Widget 规格及本文档，无新增文件。执行 xcodebuild、simctl install/io screenshot、截图检查、git diff --check 与 git status；构建成功，Git 仍整体未跟踪，无新增异常产物。尚待用户视觉确认；深色/辅助功能大字号未专项复验。建议当前阶段验收后再扩展。

2026-11-04 超大竖向组件直接添加验证成功：用户确认可从组件库直接添加。只读核对 IconState 的 Calendar.Desktop 为 extraLargePortrait，实际内屏截图确认超大竖向卡片已呈现，顶部日期、中部完整插画与底部语录/出处均可见。截图位于仓库外缓存 duo-portrait-widget-added.png。问题已缩小至已有组件长按菜单调整尺寸的系统宿主路径；暂未证明是系统缺陷还是其他宿主限制，不宣称该路径修复。当前可通过组件库直接添加使用，不再为此修改 App 布局或清除数据。本轮仅补充两份验收文档，无新增源码；沿用此前通过的 Debug 构建，运行 simctl io enumerate/screenshot、只读 plist 核对、git diff --check 与 git status。建议结束排查阶段并验收新布局。

2026-11-04 超大竖向组件切换复验未通过：用户确认最右尺寸可以点击，但实际尺寸不变；保留数据重启 Duo 后仍然复现。chronod 已登记新 Family 并成功加载其占位预览，SpringBoard 调整尺寸日志却将目标记录为 Large，已有组件的 IconState 仍为 large。因此排除“菜单可点击即修复”和“重启已解决”的结论；横竖超大声明冲突假设尚未证实。当前继续区分已有组件调整失败与组件库直接添加失败，未清除主屏布局、卸载 App 或修改模拟器状态文件。

2026-11-04 超大竖向组件无法切换排查：用户反馈新 Family 仍无法切换。只读日志确认之前 chronod 已登记 systemExtraLargePortrait，同时仍含 systemExtraLargeLandscape，故不是单纯漏声明。排除尺寸映射冲突的修正：iPhone 仅声明 Small/Medium/Large 及版本允许的 ExtraLargePortrait，iPad/Mac 保留横向超大。新构建安装后 chronod 描述符明确仅为 (systemSmall, systemMedium, systemLarge, systemExtraLargePortrait)。此时尚未证明横竖超大同时声明是唯一根因，不宣称切换问题已经解决；已请用户重新长按验证。自动化命中组件返回 cannotClickOffscreenElement，无主屏数据清除或卸载。

本轮修改 CalendarWidgets.swift 的 desktopFamilies、Widget 规格与本文档，无新增文件。Duo 无签名 Debug 构建通过，执行 xcodebuild、simctl install/get_app_container/spawn log show、产物比对、UI 读取、git diff --check、git status。App 业务、新组件布局、其他 Family 布局、工程和签名未改；Git 仍整体未跟踪，无新增异常产物。实际切换及新布局截图仍待确认。

2026-11-04 新增超大竖向 Widget：用户授权支持 iOS 27 的 systemExtraLargePortrait 并独立编排日期、语录与插画。DesktopCalendarWidget 按 availability 追加 Family，不提升最低系统版本。新布局顶部日期与年月/星期/农历、中部等比完整插画、底部语录和出处占位；新 Family 不使用原整卡插画背景，保留原生文本、亮暗配色、日期链接与辅助功能摘要。原 Small/Medium/Large/Extra Large 及锁屏排版分支不调整，未更改 Provider、内容分配、工程或签名。

本轮修改 CalendarWidgets.swift、Widget 尺寸规格与本文档，无新增文件。Duo iOS 27.2 无签名 Debug 构建成功，已安装新 App/Widget。主屏自动化尝试长按组件返回 cannotClickOffscreenElement，编辑模式菜单也未能可靠定位尺寸选项；未完成新尺寸实际添加与截图验收，不宣称菜单已启用或视觉已通过。执行 xcodebuild、simctl install、主屏 UI/截图检查、git diff --check、git status；Git 仍整体未跟踪，无新增异常产物。建议下一阶段手动切换新尺寸并验收排版；正式素材和引文仍待交付审核。

2026-11-04 Duo 付费墙左右双页：按用户要求将内屏半展开、全展开的付费墙重排为两张纸页。左页包含日历图标、原解锁标题、一次买断说明与三项权益；右页包含原价格/已解锁状态、永久解锁/完成按钮、恢复购买及协议入口。各页根据窗口等宽布局，高度不足独立滚动，保留项目纸张材质、字体、朱红按钮和右上关闭。复用公开铰链观察器（访问范围改为模块内），仅在半展开或全展开且宽度至少 800pt 时启用，普通 iPhone/外屏及小窗口保留原单列内容顺序。价格占位、尚未接入 App Store 提示、按钮行为、链接目的地均未改变，未引入 StoreKit 或网络。

本轮修改 AppSettingsView.swift、RootTabView.swift（仅共享观察器访问范围）与本文档，无新增文件；工程、签名、依赖及资源未改。Duo iOS 27.2 无签名 Debug 构建通过，实际经设置打开付费墙，截图核对半展开及切换全展开均为左右纸页，全部权益与价格、购买、恢复、协议、关闭入口可见；未执行实际购买或协议接受。执行 xcodebuild、simctl install/launch、Device Hub 姿态及截图检查、git diff --check、git status。未重新专项运行普通 iPhone/英文/辅助功能大字号验收；Git 仍整体未跟踪，无新增异常产物，建议用户验收双页布局。

2026-11-04 年度册横竖布局：年度册横屏 4 列、竖屏 2 列。页面以页面外层 GeometryReader 的可用窗口宽高比判断方向（宽大于高为横向），不用扣除标题/筛选栏后的滚动区高度判断，也不把所有 Duo 内屏姿态强制视为横屏。Duo 半展开、全展开共用同一规则，旋转后的竖向窗口统一两列。年度册去掉旧 size class/自适应 LazyVGrid 分支，统一复用可配置列数的 YearbookWaterfallLayout 与自然高度卡片；保留 2:3 比例、列距 16pt、项目间距 14pt。Duo 标志只继续控制详情呈现，不再决定年度册列数。详情、日期筛选、其他页面与工程/签名/资源不变。

本轮仅修改 RootTabView.swift 与本文档，无新增文件。Duo iOS 27.2 无签名 Debug 构建成功，安装启动后实际截图检查半展开横向年度册四列及旋转竖向年度册两列，卡片均保持竖向比例。执行 xcodebuild、simctl install/launch、Device Hub 旋转/姿态及截图检查、git diff --check、git status；未重新专项验收其他平台，也未重测存储或详情业务。Git 仍整体未跟踪，无新增异常产物。建议用户统一验收年度册旋转效果。

2026-11-04 今日双页：Duo 半展开与全展开时正反两页并列，左页可滑动换日，详情直接在右页呈现。单页场景保留点击卡片翻面。

本轮仅修改 TodayView.swift 与本文档，无新增文件，工程、签名、资源与其他页面未改。Duo 无签名 Debug 构建通过，完成调用点与默认值核对，执行 xcodebuild、rg、git diff --check、git status。未重新专项运行 UI 验收，待用户确认双页隐藏及单页保留效果。Git 仍整体未跟踪，无新增异常产物。

2026-11-04 Duo 壁纸样式及邻卡点击优化：按用户最新反馈移除样式区胶囊外框，样式缩略卡由 30×38pt 放大为 64×80pt，保留选中描边；左栏样式区可纵向滚动，以在有限高度中访问全部五种样式，上方主导航胶囊不变。仅 Duo 内屏增加左右可见邻卡的透明按钮命中区，点击调用与拖动共用的 settleCarousel，使用现有 0.42 秒 spring 将目标卡移到中央，完成后无动画重置索引；动画进行中禁用侧卡按钮，布局切换或拖动偏移未归零时忽略点击。减少动态效果设置仍使用既有简化路径。中央 2:3 比例、半展开/全展开共用入口、普通 iPhone/外屏及导出业务不变。

本轮修改 RootTabView.swift 与本文档，无新增文件，工程、签名及资源未改。Duo 无签名 Debug 构建通过；已安装截图确认无样式外框、缩略卡放大与样式区滚动布局，使用辅助功能下一张动作验证共用轮播动画路径由 mock-base-001 切到 mock-base-002。坐标点击自动化返回 noWindowsAvailable，侧卡实际触屏点击及逐帧动画观感仍待用户运行验收，不宣称已完成侧卡触屏自动验证。执行 xcodebuild、simctl install/launch、UI 状态/截图检查、git diff --check、git status，Git 仍整体未跟踪，无新增异常产物。建议用户统一验收放大尺寸及左右点击手感。

2026-11-04 Duo 内屏壁纸工坊调整：用户要求将底部五个样式移至左侧侧栏独立胶囊，腾出高度给中间壁纸预览。仅 Duo 专用导航增加样式胶囊与共享布局绑定；WallpaperWorkshopView 接收可选 Duo 绑定，普通 iPhone/外屏继续使用内部状态及原底部样式栏。中央预览根据可用高度和宽度联动计算严格 2:3 比例，完整显示中央卡片，左右相邻卡片允许裁切；沿用现有轮播、辅助功能切换与导出业务，未改导出尺寸或内容规则。半展开与全展开共用同一入口和规则。

本轮修改 RootTabView.swift 与本文档，无新增文件；未改工程、签名、资源、其他页面或平台入口。Duo 无签名 Debug 构建通过，已实际检查全展开与半展开画面：样式胶囊位于导航下方，底部仅保留导出按钮，中央卡片完整、左右部分可见；点击“留白竖排居右”后选中态及预览辅助功能标签同步，半展开后保持选择。本轮未实际导出文件、未自动拖拽验收轮播、未重新专项运行普通 iPhone。执行 xcodebuild、simctl install/launch、UI 状态与截图核对、git diff --check、git status；Git 仍整体未跟踪，无新增异常产物。待用户视觉验收。

2026-11-04 详情日期统一移除：用户指出 Duo 今日右页仍显示日期，要求详情统一去掉日期。删除 TodayDetailCard 的可选日期参数、日期渲染和 Duo 调用处传参，使共用详情组件仅显示固定“语录详解”标题，不再保留额外日期行。此决定替代此前详情 Header 带日期的约定，Duo 半展开与全展开共用生效；左侧正面日期、selectedDate 内容联动与滚动重置保留，普通入口原本不传日期，显示行为不变。

本轮仅修改 TodayView.swift 与本文档，无新增文件。Duo 无签名 Debug 构建成功，执行 xcodebuild、日期参数/渲染引用检查、git diff --check 与 git status；未重新运行视觉验收。未改其他布局、工程、签名、资源、Widget 或内容分配；Git 仍整体未跟踪，无新增异常产物。代码阶段完成，建议用户确认右页日期行已消失。

2026-11-04 Duo 全页面统一规则：用户明确要求今后所有页面的内屏半展开与全展开一致处理，不限于年度册或今日页。布局、交互、详情呈现及空间不足时的回退规则共用；适配判断不得遗漏 partiallyOpen，验收同时覆盖 partiallyOpen、fullyOpen 及相互切换。外屏保持独立路径，不改变普通 iPhone。已同步 AGENTS.md，作为后续页面适配的持续约束。本轮仅更新协作规范与本文档，无新增文件，未改源码、工程、签名或资源；未运行 Debug 构建（纯文档变更），执行 git diff --check 与 git status，无新增异常产物。

2026-11-04 Duo 半展开纳入专用布局：用户确认半展开也沿用已实现的 Duo 布局。将公开铰链状态启用条件从仅 fullyOpen 扩为 fullyOpen 或 partiallyOpen，继续要求窗口宽度至少 800pt；closed、未知/无铰链状态与空间不足回退路径不变。此决定替代此前只在完全展开时启用的限制。半展开复用纯图标导航、今日正反双页、年度册四列与详情渐显路径，未重新实现布局或修改普通 iPhone、外屏、工程、签名、资源。

本轮仅修改 RootTabView.swift 与本文档，无新增文件。Duo iOS 27.2 无签名 Debug 构建成功，安装启动后通过 Device Hub Partially Open 切换并实际截图确认弯折内屏显示项目标题、图标胶囊与四列竖向卡片，未落入旧侧栏。执行 xcodebuild、simctl install/launch、UI 状态与截图检查、git diff --check、git status；不把此前完全展开下的手势验证范围扩大为半展开已全部通过，本轮未专项重测换日手势和渐显逐帧动画。Git 保持整体未跟踪，无新增异常产物，建议用户统一验收半展开效果。

2026-11-04 Duo 年度册详情渐显调整：用户要求替换系统 fullScreenCover 的底部滑入动画。仅 Duo 专用导航改为在整个导航容器之上使用 opacity transition，0.25 秒 easeInOut 渐显/渐隐；年度册通过回调将选中卡片交给根容器，覆盖范围仍为整个展开界面。沿用 2:3 比例、整屏居中、四周留白及关闭操作，背景导航在详情期间禁止命中与辅助功能访问，离开展开导航时清理详情状态。普通 iPhone/收起状态及其他入口不变。

本轮修改 RootTabView.swift 与本文档，无新增文件；工程、签名、资源及其他业务未改。Duo 无签名 Debug 构建通过，已安装并启动，执行 xcodebuild、simctl install/launch、git diff --check、git status。尚未完成此次渐显动画的运行视觉复验，待用户确认观感；此前系统滑入的验证记录为历史状态，不代表当前动画已获验收。Git 仍整体未跟踪，无新增异常产物。

2026-11-04 Duo 展开年度册详情全屏呈现：按用户要求，仅 usesDuoGrid 入口使用系统 fullScreenCover(item:) 替换内容区内的淡入 overlay。透明呈现背景配合全屏蒙层，覆盖左侧导航；详情卡按与正面相同的宽高比 2:3，以屏幕可用尺寸减四周 24pt 留白等比适配。呈现根视图忽略不对称相机安全区，使卡片按整屏而非右侧内容区居中。复用详情正文与关闭能力，普通 iPhone、Duo 收起仍走原 overlay 默认尺寸。

本轮仅修改 RootTabView.swift 与本文档，无新增文件，工程、签名、资源和其他页面未改。Duo iOS 27.2 无签名 Debug 构建通过，实际点击年度册卡片打开系统全屏呈现，截图核对 2:3 卡片、整屏居中、蒙层覆盖左栏，测试关闭操作；截图 /Users/ideabox/.cache/MaoStyleCalendar/duo-yearbook-fullscreen-detail.png。执行 xcodebuild、simctl install/launch/io screenshot、git diff --check、git status；Git 保持整体未跟踪，无新增异常产物。未逐帧录制系统转场，待用户确认动画观感；本阶段不扩展其他入口。

2026-11-04 Duo 展开年度册四列瀑布流：用户反馈原宽屏自适应网格卡片压扁、行间留白过大，改为仅在 Duo 专用导航入口传入 usesDuoGrid。复用 YearbookWaterfallLayout，新增默认值为 2 的列数参数；Duo 固定 4 列，按各列累计高度放入最短列，列距 16pt、卡片间距 14pt。卡片按实际列宽和原 2:3 比例确定自然高度，取消 Duo 的旧 280pt 固定高度路径。普通 iPhone/收起状态保持原两列，其他平台原入口不变，不修改交互、工程、签名或资源。

本轮修改 RootTabView.swift 与本文档，无新增文件。Duo iOS 27.2 无签名 Debug 构建通过，已安装并打开年度册，实际截图确认首屏四列、竖向卡片、紧凑行距与日期文字无交叠；截图 /Users/ideabox/.cache/MaoStyleCalendar/duo-yearbook-four-columns.png。执行 xcodebuild、simctl install/launch/io screenshot、git diff --check、git status，Git 保持整体未跟踪，无新增异常产物。未重新运行其他平台专项验收，待用户视觉确认。

2026-11-04 Duo 展开专用布局：用户授权展开状态使用左侧纯图标胶囊与今日正反双页。通过 iOS 27.1+ 公开 UIHingeInteraction 的 fullyOpen 状态及窗口宽度至少 800pt 共同启用；iOS 编译条件与 availability 隔离，未使用机型字符串或仅靠 regular size class 判断。标题读取主 App CFBundleDisplayName。折叠状态现有胶囊来自系统 TabView，并无独立组件可直接复用；展开胶囊复用四个资源图标与配色并单独组合，不替换折叠路径。

今日左右页复用既有正面和详情卡片；左页保留铜环和换日手势，右页无铜环与关闭按钮、固定标题日期、独立滚动正文。日期与内容均由同一个 selectedDate 派生，右页以日期作为 identity 重置滚动；右页未安装换日手势。普通 iPhone、iPad/Mac 入口保留，未新增依赖或修改工程/签名/Widget/正式资源/内容分配。仅修改 RootTabView.swift、TodayView.swift 与本文档，无新增仓库文件。

验证：Duo / iOS 27.2 与 iPhone 17 / iOS 27.2 无签名 Debug 构建通过；Duo 从收起切到展开后已实际检查双页、标题、胶囊、无铜环详情，展开状态重启亦进入专用布局；再次收起恢复系统 TabView，日期保持 11 月 4 日。普通 iPhone 17 已启动并截图确认单页及底部系统 Tab。运行 xcodebuild、simctl install/launch/io screenshot、git diff --check 和 git status；截图在仓库外 /Users/ideabox/.cache/MaoStyleCalendar/duo-spread-preview.png 与 iphone-spread-regression.png。UI 自动化 drag 返回 noWindowsAvailable，左右换日联动、右侧滚动不换日与长内容滚动仍待人工运行验收，不宣称全部交互已通过。Git 仍整体未跟踪，无新增异常产物。下一阶段建议用户统一视觉及手势验收，未扩大至其他平台适配。

2026-11-03 Small 月/星期字号微调：按用户要求由 15pt 降至 Medium 同款 13pt 基准，两个尺寸复用新增的 `WidgetLayout.compactMetadataFontSize`，继续按既有容器比例缩放。Medium 视觉值不变，Small 保留项目标题字体、朱红、18pt 行框及已确认日号/月间距和左右留白；日号、语录和插画不改。仅修改 Widget 文件、Widget 规格及本文档，无新增仓库文件；App、Large/Extra Large/锁屏布局、农历、字体文件、素材、工程和签名未改。执行 xcodebuild 无签名 Simulator Debug 构建通过，simctl install 更新后实际截图检查 iPhone 17 Pro 主屏 Small，月/星期缩小且无裁切；执行 git diff --check、git status --short，无新增异常产物，仓库仍整体未跟踪。日志和截图在仓库外 `/Users/ideabox/.cache/MaoStyleCalendar/small-metadata-20261103/`。本轮不新增业务测试，待用户确认字号，不扩展下一阶段。

2026-11-03 Large Widget 对照用户原稿调整：用户随后纠正星期颜色要求，已将 Large 星期从棕色正文改为与年月一致的朱红中文标题字体。右侧日期块增加农历，继续复用 `WidgetDateBlock` 的公共日/月间距和 `WidgetLayout.contentInsets`；大日号由 62 调至 78pt 基准，年月/星期 14pt、农历 12pt。Large 内容依可用宽高等比缩放，日期区占内部宽约 36%；左侧语录为 24pt 基准、最多两行，移除原横跨文字区的长线和等宽 Mock ID，改为 32pt 短朱红线及项目正文字体的“出处待核验”。Mock Repository 没有核验篇名，未照抄截图出处或改数据模型；语录仍明确为 Mock。插画继续沿用现有整卡等比背景机制，素材不改，不宣称人物山水画面已还原。

本轮仅修改 `ios-client/Native/Widget/CalendarWidgets.swift` 的 Large 布局与对应农历辅助功能摘要、Widget 规格及本文档，无新增仓库文件；Small/Medium/Extra Large/锁屏布局、公共间距参数、App 页面、Provider/数据映射、字体/插画、工程配置和签名未改。iOS App/嵌入 Widget 无签名 Simulator Debug 构建通过，最终产物已安装到 iPhone 17 Pro / iOS 26.5，主屏 Large 截图确认语录/日期分栏、短线、出处占位、朱红星期及“农历九月廿五”均可见且无溢出。确认既有 18 项农历核验脚本包含未变更的生产 helper 后重新执行通过。命令包含 xcodebuild、swift、simctl install/io screenshot、差异范围核验、git diff --check 与 git status；截图和日志在仓库外 `/Users/ideabox/.cache/MaoStyleCalendar/large-widget-20261103/`。未做其他平台专项验收，Git 仍整体未跟踪且无新增异常产物。待用户确认本轮 Large 效果。

2026-11-03 Widget 公共留白微调：按用户后续反馈，将 `WidgetLayout.dateToMonthSpacing` 由 0 增至 4pt，所有上下日/月布局共用；增加统一 `leadingContentInset=18pt` 与 `contentInsets`，主屏左边距由 14 增至 18pt，其他三边仍 14pt，Small/Medium 按既有基准缩放。Medium 的文字宽度扣除同一左边距，保持插画右侧三分之二范围和等比填充不变。本轮仅改 Widget 文件、Widget 规格及本文档，无新增仓库文件；字体、农历逻辑、App、图片、工程和签名未改。

本轮验证：iOS App/嵌入 Widget 无签名 Simulator Debug 构建通过，已安装并实际截图检查 iPhone 17 Pro 上的 Small/Medium；留白增大，农历和两行 Mock 语录没有裁出容器。执行 xcodebuild、simctl install/io screenshot、源码差异检查、git diff --check、git status --short。修改前源码、构建日志及截图在仓库外 `/Users/ideabox/.cache/MaoStyleCalendar/widget-spacing-20261103/`。其他 Family 此轮未重新专项视觉验收；没有新增业务测试，Git 仍整体未跟踪且无异常产物。待用户确认当前间距，不扩展下一阶段。

2026-11-03 Medium 主屏 Widget 对照调整：左侧约三分之一显示日号、月份/星期、实际农历、短线和两行语录；右侧约三分之二展示插画。沿用既有 360×540 Mock 画幅，缩放值取 max(右侧宽/360, 容器高/540)，统一等比放大、居中裁切，不按横竖分别拉伸；左缘短渐变与纸面融合。原全卡顶部渐变仅保留给其他 Family。Medium 原“Mock 内容”行改为农历，语录仍明确显示 Mock，不宣称正式内容。

日期共用组件：同文件新增 `WidgetLayout`、`WidgetDateBlock`，Small/Medium/Large/Extra Large 及 Circular/Rectangular 共用日号行框、字体留白校正与日/月间距，不再为 Medium 单独调 padding；主屏内容边距统一 14pt 基准（Small/Medium 随容器缩放）。Small 保留先前 62pt 字号、50pt 行框和原光学校正结果。Inline 为单行，没有垂直日/月间距。新增同文件 `WidgetDateFormatting` 供农历展示使用，辅助功能摘要也包含 Medium 农历。

验证：iOS App/嵌入 Widget 无签名 Simulator Debug 构建通过，最终产物已安装到 iPhone 17 Pro / iOS 26.5。主屏实际切换 Small、Medium、Large 并截图检查，最后恢复 Medium；日期/月关系紧凑、农历显示为“农历九月廿五”、左侧文字区与右侧插画区分离。使用实际源码中的农历 helper（非另一份重写）执行 6 个日期×3 个时区共 18 项检查，春节、元宵、腊月、闰六月及原稿 2026-10-29 全部通过。执行 xcodebuild、swift 核验、simctl install/io screenshot、源码差异检查、git diff --check、git status --short；日志与截图在仓库外 `/Users/ideabox/.cache/MaoStyleCalendar/medium-widget-20261103/`。

范围：仅修改 `ios-client/Native/Widget/CalendarWidgets.swift`、Widget 设计规格及本文档，无新增仓库文件；App 页面、数据分配和 Provider、字体和素材母版、工程配置与签名未修改。Extra Large 和锁屏的公共组件变动仅编译验证，未做该 Family 的专项运行视觉验收；iPad/Mac 仍按既定顺序延后。真实插画未交付，当前展示仍是原程序化 Mock，不把占位画当作原稿人物山水还原。仓库仍整体未跟踪，未添加构建产物或异常文件。

2026-11-03 Small 主屏 Widget 排版修正：按用户附件调整小尺寸专用布局，大日号由 48pt 调至 170pt 基准下的 62pt，以紧凑日期行框及光学校正消除 Libre Bodoni 数字底部留白造成的月份间距；月份与星期分别使用 18pt 行框，星期改为与月份一致的项目中文标题字体和朱红色。短线和两行语录间距按原稿关系调整，文字区由 82pt 改为 98pt，语录基准字号 14pt；Small 内部尺寸随组件短边缩放。仅修改 `ios-client/Native/Widget/CalendarWidgets.swift` 的 small 分支及本文档，无新增仓库文件；Medium/Large/Extra Large、锁屏布局、Provider/日期映射/深链、共享字体、App 页面、素材、工程配置及签名设置未改。共享 Small 代码亦供其他平台使用，本轮只验收普通 iPhone，不宣称 iPad/Mac 已验证。

验证：首次复用旧缓存构建遇到 x86_64 与 arm64 CalendarCore 产物不匹配；改用仓库外独立 DerivedData，命令行限定 ARCHS=arm64、ONLY_ACTIVE_ARCH=YES 后 iPhone 17 Pro / iOS 26.5 Simulator Debug 构建通过，已通过 simctl install 更新并实际截图检查系统桌面 Small（11 月 3 日）。日期/月间距已明显收紧，星期为红色粗体，Mock 语录显示两行；未逐日运行所有日期或其他 Widget Family，未新增业务测试。执行 xcodebuild、simctl install/io screenshot、差异范围检查、git diff --check 与 git status --short。构建日志、修改前后截图位于仓库外 `/Users/ideabox/.cache/MaoStyleCalendar/small-widget-20261103/`。右侧仍为既有程序化 Mock，未用设计截图冒充正式插画；最终视觉待用户确认。仓库继续整体未跟踪状态，本轮没有新增构建产物或其他异常仓库文件。


2026-11-03 对照用户纸页效果图继续优化：保留当前页加四张底纸，共五张；露边改为 15/11/7/3pt 不等距、左右错位 -8/5/-5/1pt 与不同微角度，使用较窄的暖色接触阴影和柔和整体投影。今日正反面改为复用同一个 PaperPileBackdrop，删除详情原先纯色底纸的独立绘制，所有底纸沿用已有纹理素材。核对纸纹候选原图后，移除原来冲淡纤维的均匀纸色遮罩，适当增强纹理对比、增加细纸沿高光与暗边；背景插画上方增加轻量纤维正片叠底，避免安全区渐变和 Mock 色块把纸纹盖平。复用 PaperStack/CardArtworkBackground 的其他 App 卡片同步获得材质调整；未新增或覆盖图片，未截取设计图素材，未改字体、文字布局、插画内容、铜环、业务交互、Widget 或工程配置。现有候选纸纹与效果图并非相同素材，本轮为渲染优化，不宣称原稿完全还原。

验证：iOS arm64 Simulator 无签名 Debug 构建通过，实际安装启动并检查最终正面截图；第一版偏白的柔光纹理混合已改为 28% 正片叠底，并重新构建、安装、截图。执行 xcodebuild、simctl install/launch/io screenshot、git diff --check、git status --short；仅修改 TodayView.swift 与本文档，无新增仓库文件。修改前备份、build.log 与最终 today-final.png 均在仓库外 /Users/ideabox/.cache/MaoStyleCalendar/paper-refine-20261103/。背面及其他共用材质页面未逐一运行截图，仍待视觉确认。

2026-11-03 今日纸堆调整为共五张：正面与今日详情统一从六张底纸减至四张底纸，加当前纸页共五张。底纸纵向错位为 14/10/6/3pt，交替横向错位与微角度旋转收敛，减少散乱露边；每层改为较紧的接触阴影，正面纸堆增加柔和整体投影，避免多层大模糊阴影堆成灰边。详情底纸提高不透明度，让纸沿更清晰。本条替代此前七层纸堆规则；正文、插画背景、铜环、操作区、交互、其他页面和工程配置未改。仅修改 TodayView.swift 和本文档，无新增仓库文件。iOS arm64 Simulator 无签名 Debug 构建通过，已安装启动并检查正面截图，详情沿用同样四张底纸参数但未另行截图验收。执行 xcodebuild、simctl install/launch/io screenshot、git diff --check 与 git status --short；日志 five-sheets-build.log、截图 today-five-sheets.png 均位于仓库外 /Users/ideabox/.cache/MaoStyleCalendar/，最终视觉待用户确认。

2026-11-03 今日操作区背景纠正：按用户截图反馈删除底部操作 HStack 单独添加的纸色背景，使其直接透出整卡统一纸材质与插画，避免矩形底色覆盖纸张左下、右下圆角。本条替代上一轮“底部按钮保留淡纸色衬底”的决定；按钮、分隔线、整卡背景与纸张圆角本身未改。仅修改 TodayView.swift 和本文档，无新增仓库文件。iOS arm64 Simulator 无签名 Debug 构建通过，新版本安装并启动于 iPhone 17 Pro；执行 xcodebuild、simctl install/launch、git diff --check、git status --short。日志位于仓库外 background-20261103/footer-build.log。

2026-11-03 整卡插画背景：用户确认插画应按比例居中铺满整张卡片，语录、日期和农历等以结构化文字覆盖其上。今日与年度册改为“纸材质底层—整卡插画—信息层”，取消独立插画区。新增同文件共享 `CardArtworkBackground`，当前 Mock 固定 360×540 构图使用 max(容器宽/360, 容器高/540) 等比缩放、居中裁切，不拉伸或重复拼贴；年度册两列瀑布流高度改按当前 2:3 构图比例随列宽计算，不再累加文字和插画高度。Mock 尚无正式文字安全区，顶部使用轻薄纸色渐变保障文字可读性。壁纸预览、缩略图、导出通过同一背景组件保持一致，保留现有 Mock 输出标识。主屏 Widget 各 Family 将插画移到 containerBackground，以相同比例策略铺满，保留各尺寸独立文字排版；锁屏 Widget、详情正文卡、字体/原始图稿、数据层、工程与签名配置未改。正式插画未交付，当前仅验证 Mock 的背景机制，不宣称最终设计图稿已接入。

本轮验证：iOS App/嵌入 Widget 与 macOS App/嵌入 Widget 无签名 Debug 构建通过，Mac 仅作编译回归；iPhone 17 Pro 实际检查今日与年度册背景覆盖、文字叠加与两列比例布局，点击今日日期仍进入详情。最终构建截图 today.png、yearbook.png、构建日志和三个源码修改前备份保存在仓库外 /Users/ideabox/.cache/MaoStyleCalendar/background-20261103/。执行 xcodebuild、simctl install/launch/io screenshot、git diff --check、git status --short 和备份差异核对；仅修改 TodayView.swift、RootTabView.swift、CalendarWidgets.swift、本文档，无新增仓库文件。壁纸导出复用同一组合，实际导出图及 Widget 各 Family 的运行验收，仍待后续确认；未用构建通过替代最终视觉批准。

2026-11-03 今日卡片增加农历：星期下方加入较小棕色项目正文字体的“农历腊月十九”格式，支持正月、冬月、腊月与闰月；采用 Foundation 中国历与所选公历日期一致的本地时区离线转换，换日时同步更新。日期区增加 20pt、插画区相应减少 20pt，卡片整体尺寸不变。仅修改 TodayView.swift 和本文档，无新增仓库文件；年度册、详情、Widget、内容模型与工程配置未改。提取实际格式计算逻辑在仓库外执行春节、元宵、腊月十九、闰六月初一及三个时区共 12 项检查，全部通过；iOS arm64 Simulator 无签名 Debug 构建通过，新版本已安装并启动于 iPhone 17 Pro。执行 xcodebuild、swift 检查脚本、simctl install/launch、git diff --check 和 git status --short，产物均在仓库外缓存目录。本轮未完成大小屏实际视觉截图验收，待用户确认。

2026-11-03 壁纸样式缩略图竖排示例改为三列：按用户截图红框要求，将 WallpaperLayoutThumbnail 中前两个竖排样式的灰色示意条从两根改为三根，与后两个横排样式的三行示意统一。仅改变缩略图竖条数量，条宽、间距、长短关系和左右对齐保持不变；主画布真实语录的分列、五张插图、布局选择、轮播与导出逻辑未改。同步资源 README 的竖条说明，无新增文件。

验证：源码核对竖排和横排分支均为三条，普通 iPhone arm64 Simulator 无签名 Debug 构建通过；git diff --check 与 git status 检查通过，仓库仍为既有整体未跟踪状态，无新增异常文件。本次为单处示意条数量调整，未新增测试或运行截图验证，建议直接验收缩略图效果。

2026-11-02 本地协议预热与复用：用户指出内置 HTML 进入时不应出现下载式等待体验。此前 SettingsBrowser 在进入时新建 WKWebView，并对本地/远端统一显示 ProgressView。现改为 AppSettingsLibrary 持有当前语言三份本地协议的会话缓存，设置页 task 在初始渲染让出一次调度后预热；缓存以本地 URL 为键，切换语言时剔除旧语言页面，设置与付费墙内协议入口复用已加载 WKWebView，不因导航重进而重建/重载。本地取消转圈提示，保留缺资源/加载失败/内容进程退出后的失败提示和重试；EULA 使用独立非持久会话，仍保留网络加载与失败提示，绝不预加载远端 EULA。重试复用当前 WebView 重新加载，取消的导航不误报失败。缓存只在内存中，无新增文件缓存、网络请求、第三方依赖或权限。

只修改 AppSettingsView.swift 与本状态记录，无新增文件；协议 HTML、文案、购买逻辑、按钮动效、工程配置、签名及其他页面未改。iOS 通用 Simulator 无签名 Debug 构建通过。Pro 冷启动后进入设置，首次打开隐私政策已显示正文且无转圈，返回重进仍显示正文；用户协议首次打开同样已显示正文，无转圈。未做毫秒计时，不声称所有设备/启动即点均绝对零等待；WebKit 冷启动或进程被回收仍可能需要初始化，极端情况待真实设备验收。EULA 保留加载/重试及语言切换缓存淘汰分支已源码核对，本轮未逐项运行验证。git diff --check 与 git status 通过，仓库仍整体未跟踪，无异常构建产物。

2026-11-02 购买按钮动效增强：按用户要求将呼吸周期由 4.8 秒改为连续 2 秒，最大缩放由 1.2% 提至 3.5%，光晕峰值与范围同步加大；扫光宽度增至按钮宽度的 34%、峰值白色透明度增至 30%。右侧箭头使用与按钮共享的 TimelineView 进度，2 秒内向右 7pt 后回位，并最多放大 12%；仅作视觉变换，不改变排版和按钮命中边界。已购显示的 checkmark 不动，保持 Reduce Motion 静态、后台/离页/提示弹出暂停条件。不新增计时器、依赖或网络请求。

仅修改 AppSettingsView.swift 与本记录，无新增文件；购买回调、主视觉布局、文案、工程配置、签名和其他页面未改。iOS 通用模拟器无签名 Debug 构建通过；Pro 截图检查增强扫光、箭头位移和按钮未溢出主视觉区，点击仍正常弹出原购买暂未开放提示。减轻动态效果等分支沿用前轮代码并做源码核对，本轮未新增系统无障碍运行验证或业务测试。git diff --check、git status 通过，仓库仍整体未跟踪，无异常构建产物；动效强度待用户体验验收。

2026-11-02 永久解锁按钮动效：用户要求联网参考付费按钮动效并实现。参考 Adapty 付费按钮 Pulse（https://adapty.io/docs/paywall-buttons/）、Framer CTA 动态示例（https://www.framer.com/marketplace/components/pulse-animated-cta/）及 Apple Motion 指南（https://developer.apple.com/design/human-interface-guidelines/motion），选用轻呼吸、柔光扫描和按下反馈，不声称已有转化提升证据。新增私有 PaywallPurchaseButtonStyle/PurchaseButtonMotion，仅应用于付费墙主购买按钮：4.8 秒周期，前 1.6 秒最大 1.2% 视觉缩放，约 1.05 秒柔光扫描，其余休止；按下缩至 97.5%，减轻动态效果时禁用位移/缩放与扫光，仅保留静态/按压明暗反馈。TimelineView 最大 30fps，只在未解锁、页面可见、App active、无购买提示且未按住时运行，已解锁/离开/后台暂停；装饰不响应点击或进入可访问性树，不改布局尺寸、购买回调或真实 IAP 未接入状态。

仅修改 AppSettingsView.swift 与本记录，无新增文件、依赖、网络运行请求、资源或工程配置变更；主视觉、权益文案、协议与其他页面未改。iOS 通用 Simulator 无签名 Debug 构建通过，Pro 实际页面观察到扫光且无裁切，点击主按钮仍正常弹出原购买暂不可用提示。减少动态效果、后台及离开页面分支完成源码核对，未逐项进行系统设置运行验收，不混称完整无障碍验证。低影响视觉动效不新增业务单元测试；git diff --check 与 git status 检查通过，仓库仍整体未跟踪，无异常构建产物。动效节奏及强度待用户体验验收。

2026-11-02 付费墙删减说明：按用户红框，仅移除“语录出处、详解与英文内容”权益行，以及“今日页与基础小组件可免费使用”说明和两侧分隔线；中文与英文同步移除。保留主视觉购买区、其余三项权益、恢复购买与协议入口，不改变免费/付费业务边界或真实购买状态。仅修改 AppSettingsView.swift 与本记录，无新增文件；工程、版本、签名、资源及其他业务页面未改。本轮为低影响视图删除，不新增业务单元测试。iOS 通用模拟器无签名 Debug 构建通过，源码检查确认中英两项均已移除且保留三条权益；git diff --check 通过。仓库仍整体未跟踪，无异常构建产物；未执行新的运行截图验收。

2026-11-02 设置精简、固定样式及购买区前置：用户取消外观模式切换，设置页删除整个“偏好设置”Section，根视图固定当前浅色样式；删除 AppSettingsLibrary 和 CalendarCore 中旧偏好持久化/外观 API，不读取旧版本保存的语言或外观值。正式语言以系统首选语言解析，中文映射 zh-Hans，其余回退 en；全 App 文案本地化明确后置，本轮仍只有现有设置/付费墙/协议中英文可预览。Debug 区增加仅中文/English 两项的语言 Picker，状态仅存在于当前进程，冷启动重新跟随系统，Release 不编译覆盖入口和属性。旧偏好持久化测试随已删除能力移除，保留主语言判定、未知语言英文兜底和显式双语解析测试。

用户明确授权工程版本调整：全部四个 targets 的 Debug/Release MARKETING_VERSION 统一由 1.0 改为 1.0.0，CURRENT_PROJECT_VERSION 保持 1；不修改 Bundle ID、Team、签名、部署版本或其他工程配置。付费墙按本次截图要求调整 v2 排序：日历图标、黑红标题、副标题、价格状态与朱红购买按钮合成顶部细框主视觉区，后接四项权益及恢复/免费能力/协议辅助入口；删除旧购买卡片重复的“完整功能永久解锁”和第二处“一次付费”说明。全屏展示、关闭按钮和真实购买未接入状态保持。

修改 AppSettingsView.swift、RootTabView.swift、CalendarCore 设置枚举/旧 Repository 文件及其测试、project.pbxproj、本状态文档；无新增文件或素材。正式内容、其他业务逻辑、Widget 源码、协议 HTML、字体与签名未改。验证：iOS 通用 Simulator 无签名 Debug/Release 构建通过，28 项 CalendarCore 测试通过；两种产物 App 与 Widget 的 Info.plist 均确认 1.0.0 (1)，Release 无 debugLanguage、Mock IAP Purchase 及已删除偏好项中文文本。Pro 实际核对设置无偏好 Section、语言在 Debug 且只有两项、英文切换与冷启动恢复系统中文；中英付费墙截图均显示首屏合并购买区及正常按钮。系统语言兜底由单元测试验证；仍未声称全 App 本地化、真实 IAP、小屏/大字号专项或其他平台运行验收完成。git diff --check、工程 plist 语法与 git status 已检查，仓库仍整体未跟踪，无异常构建文件。待用户验收本轮视觉。

2026-11-02 v2 付费墙与全屏展示：经核查没有原付费墙 SwiftUI 实现后，用户明确选择“按 v2 付费墙定稿实现，再全屏展示”。本轮删除此前简化的 FullAccessPaywallView，实现 V2LifetimePaywallView：纸纹背景、居中日历图标、黑红标题、四组权益及竖分隔线、朱红细框购买区、价格待定、带箭头永久解锁按钮、恢复购买、免费能力及本地协议入口。复用既有字体与候选纸纹/图标，没有生成或新增素材。设置入口圆角改为 8pt，保留行内留白以避开 List 容器的大圆角裁切；iPhone 改为 fullScreenCover 中的独立 NavigationStack，右上 xmark 关闭后返回原设置页；macOS 仅保留既有可编译 sheet 容器，未做专项适配验收。Debug 已购模拟继续驱动权益呈现；未接入 StoreKit、不虚构价格或交易。

只修改 AppSettingsView.swift 和本状态记录，无新增文件；协议资源、偏好存储、其他业务页、Widget、工程配置、签名、正式内容未改。iOS 通用模拟器无签名 Debug 构建通过；Pro 实际截图验证小圆角入口、全屏独立页面、布局及购买按钮纸纹裁切；点击购买协议后可返回付费墙，再点右上关闭可回到设置页。git diff --check 通过，仓库仍整体未跟踪且未写入构建产物。本轮没有新增或重复运行业务单元测试；真实购买、小屏/大字号专项与最终视觉仍未验收，不把候选材质近似当作用户视觉批准。

2026-11-02 设置入口圆角及付费墙来源核查：用户要求删除本轮新写的 IAP 页，复用原付费墙并以可关闭的全屏模态展示。全仓库（含隐藏路径、不含 .git/.build）检索 Swift/HTML/前端源码及付费相关文件名，仅找到当前 AppSettingsView.swift 中新增的 FullAccessPaywallView，原有付费墙仅存在 v2 approved/paywall.png 等设计稿；历史状态记录为此前尚未接入付费墙。已请求用户确认原实现位置或是否指 v2 定稿，未擅自以新实现冒充原页面，页面删除及全屏接线待来源确认。独立完成按钮圆角由 12 调为 8pt，行内保留 8pt 留白避免 List 分组大圆角裁切按钮。仅修改 AppSettingsView.swift 与本状态文档，无新增文件；购买、协议、外观逻辑及工程配置未改。iOS 通用 Simulator 无签名 Debug 构建通过，git diff --check 通过；本小步未作运行截图验收。仓库仍整体未跟踪，无新增构建产物。

2026-11-02 设置页细节修订：按用户截图反馈去掉顶部“订阅”Section 标题，以普通 Button 加 navigationDestination 进入付费墙，移除 disclosure 箭头并撑满 List 行宽（保留列表左右外边距）。语言选择中中文保留 character.bubble，English 改为 a.square，避免随系统本地化成中文字形。协议页面移除自定义右上返回，恢复 NavigationStack 左侧系统返回；六份本地 HTML 删除正文重复大标题及日期，保留网页 title 和导航栏标题。设置/付费墙/中英协议统一使用“购买协议 / Purchase Terms”，删除为旧订阅命名作解释的文字。

Apple 官方核对：标准 EULA 并非自动续期订阅专用，未提供自定义 EULA 的 App Store 应用默认适用（https://developer.apple.com/help/app-store-connect/manage-app-information/provide-a-custom-license-agreement）。因此用户提出“若仅针对订阅则删除”的条件不成立，本轮保留 EULA 入口，不把终身非消耗型购买误认为无许可约束。无新增文件，仅修改 AppSettingsView.swift、六份 HTML 及本状态记录；偏好存储、真实购买逻辑、其他业务页、Widget、字体、深色适配、工程配置和签名均未改。iOS 通用模拟器无签名 Debug 构建通过；六份打包 HTML 与源码一致，无正文 h1/日期或旧协议名；Pro 模拟器截图核对新按钮、English 图标、隐私页左侧返回和正文首节。未新增测试或重复运行无关业务测试，最终视觉待用户验收。

2026-11-02 设置页重建：用户确认删除旧“内容显示”“阅读与辅助功能”“说明”及其旧说明页面，改为订阅、偏好设置、信息、Debug 调试四组，所有条目使用语义图标。订阅提供大按钮进入可返回的永久解锁付费墙，延续一次购买的非消耗型规划；真实 StoreKit、产品 ID 和价格尚未接入，购买/恢复按钮明确提示暂不可用，不触发交易。Debug 模拟 IAP 默认关闭、仅当次进程有效，驱动设置/付费墙的已购呈现，Release 不包含开关及模拟状态；本轮不新增其他功能的付费拦截。

语言设置改为跟随系统、中文、English，默认跟随系统，非中文系统语言回退英文；既有明确中文/英文偏好保留，旧双语或未知值回退跟随系统。新设置、付费墙及本地协议可即时中英切换，根视图注入解析后的 Locale；今日/年度册/壁纸等既有硬编码中文尚未全局本地化，不声称全 App 英文化完成。外观提供跟随系统/浅色/深色，App Group 持久化并接入 preferredColorScheme；现有固定色板的完整深色视觉适配按用户要求留到设置页验收后，不将模式切换等同于深色视觉已验收。

隐私政策、用户协议、订阅协议以六份中英 HTML 内置在 Native/Resources/Legal，经 WKWebView push 打开，右上返回；本地文档禁脚本、无远端资源，导航限制在本地目录。Apple 标准 EULA 通过官方 HTTPS 页面加载，使用非持久网页存储，并提供加载/失败重试状态。文档按当前实现起草，并非发布法律审核完成；开发者支持入口和正式购买接入后的条款仍待发布前复核。工程仅增加 App targets 的 Legal 文件夹资源引用、主 App 声明 en/zh-Hans 本地化与英文兜底；签名、Bundle ID、Team、Version、Build、Widget 源码与正式内容未改，未加依赖。

验证：iOS Simulator 通用架构无签名 Debug 与 Release 构建通过；CalendarCore 31 项测试通过（含偏好持久化、旧值回退、语言解析与英文兜底）。Debug/Release 六份 HTML 与源文件逐字节一致；Release 二进制不含 Mock IAP Purchase/mockIAP。iPhone 17 Pro iOS 26.5 实际验证四组设置、中文本地隐私页及右上返回、英文即时切换及冷启动保留、模拟购买开关对设置/付费墙的影响、冷启动模拟重置、未购付费墙提示、Apple 官方 EULA 页面。未执行真机或其他平台专项验收；最终艺术/交互验收待用户确认。

2026-11-02 仅插画样式补齐简洁版：用户确认前四张 v3 后，要求最后一张也重绘得简单好看。通过内置 ImageGen 将旧秋树村落全景简化为一株秋枫、浅淡远山和开阔水面，删除村落、石桥、密集山层和前景碎细节，不添加任何灰色排版条。只替换 WallpaperStyle-artworkOnly.imageset/illustration.png；前四张已确认资源保持不变。本轮新增 generation-artwork-only-v2.json，记录完整提示词、原始输出与输入/导入哈希，并更新资源 README 和本状态文档。

验证：新图为 216×288 PNG；四张受保护插图 SHA-256 与修改前一致，壁纸相关 Swift 代码与既有 QA 副本一致；普通 iPhone arm64 Simulator 无签名 Debug 构建通过，SE 实际页面核对第五张正确加载且没有占位条，五张视觉风格统一。未新增测试或修改代码、交互、工程配置、签名与正式内容。图片旧版在仓库外留有回滚副本，正式源码构建恢复至用于验证的 SE。最后一张的艺术效果仍待用户验收，不把 UI 指示资源视为正式每日插画。

2026-11-02 今日正面整卡点击：将打开详情的普通点击手势从插画区域提升到 `TodayFrontCard` 根节点，并沿用整张纸页圆角命中区域，使语录、日期、插画与纸面留白均可打开详情；移除插画重复的点击及按钮可访问性标记，补充整卡的“查看本日语录详解”可访问性操作。外层左右换日高优先级拖拽手势及换日过程的点击禁用规则未改。仅修改本视图和状态文档，无新增文件、数据层或工程配置修改。iOS arm64 Simulator 无签名 Debug 构建通过，执行 `xcodebuild`、`git diff --check` 与 `git status --short`；新版本已安装并启动于 iPhone 17 Pro 模拟器，日志保存在仓库外 `/Users/ideabox/.cache/MaoStyleCalendar/today-whole-card-build.log`。界面操作工具当前不可用，拖拽不误触等实际手势回归仍待手动确认。

2026-11-02 壁纸样式插图 v3 减法重绘：用户指出 v2 过于复杂、在堆砌内容充实画面，要求再次重绘。前四张通过内置 ImageGen 收敛为松下单人阅读、柳岸一舟、远山曲水、疏竹单鹤四个单一意境，删除密集村落、亭台、花丛、碎石、双树框景和反复叠加的远景细节，以宽笔触和浅淡连续水墨连接画面，保留自然文案空隙与主体辨识度。第五张仅插画仍按本轮边界保留，灰色占位条仍由现有代码叠加。

本轮仅修改前四个 WallpaperStyle imageset 的 illustration.png、资源 README 与本状态文档，新增 generation-v3.json 归档完整提示词、输入/输出哈希和原始生成路径。v1、v2 记录保留为历史，旧 v2 PNG 有仓库外回滚副本。所有 Swift 代码、样式栏尺寸与命中区域、轮播/Toast、主画布、导出器、内容仓库、工程配置及签名均未修改。

验证：四张 216×288 PNG 的不同内容及记录哈希通过；RootTabView.swift 与第五张 SHA-256 和修改前完全一致；普通 iPhone arm64 Simulator 无签名 Debug 构建通过。通过仓库外 QA 启动入口复核 Pro 和 SE 的实际 82pt 样式栏截图，四张简化主体与对应灰条均正确加载。本次是资源视觉修订，未新增测试或重新验证交互，助手缩略图检查不替代用户艺术验收。完成后恢复安装仓库源码构建，建议本轮统一验收构图。

2026-11-02 壁纸样式插图构图纠偏：用户否决上一版前四张插图，指出应像新附件一样由完整插画铺满卡片，并在场景中自然留下文案空隙，而不是把小插画放在一角、剩余大片空纸。按此要求通过内置 ImageGen 重新绘制前四张：松下读书人与河村（左上局部雾白）、梅下女读者与渡舟村落（右上局部雾白）、两松围合的桥村溪景（顶部雾带）、竹鹤亭台与完整溪谷（下方平缓水面）；横排居上稿额外修正过穿过占位条区域的树枝。插画本身完整铺满，灰色占位条继续由现有代码叠加，第五张仅插画保持原图。新图仅用于样式指示，不进入正式内容包。

本轮修改四个 WallpaperStyle imageset 的 illustration.png，以及资源 README 和本状态文档；新增 generation-v2.json，归档提示词、参考角色、局部修订与原始/导入 SHA-256。旧 v1 提示词保留作被否决构图的历史记录，四张旧导入 PNG 留有仓库外回滚副本。Swift 源码、占位条的位置与样式、82pt 选择栏、命中与 Toast、轮播、主画布、导出、第五张图片及工程配置均未修改。

验证：四张均为不同内容的 216×288 PNG，逐项校验记录哈希，RootTabView.swift 与第五张的修改前后 SHA-256 一致；xcodebuild 普通 iPhone arm64 Simulator 无签名 Debug 构建通过。通过仓库外 QA 启动入口核对 Pro 与 SE 实际 82pt 样式卡截图，确认新构图和现有灰色条同时加载、无大块空纸式分区；这属于助手视觉复核，仍待用户统一验收，不代表正式插画发布批准。未新增测试或修改业务逻辑，最终恢复安装仓库源码构建。

2026-11-02 壁纸导出与样式栏第二轮优化：用户要求滑动时导出按钮保持正常外观，动画中点击改为 Toast，删除五种样式下方文字并用五张不同插图表达留白方向。导出按钮移除 `.disabled` 的滑动状态控制；点击时先判断拖动位移、轮播回弹、样式动画和重复生成，分别提示且不调用导出器。Toast 约 2 秒后消失、支持重复点击重置计时并发送辅助功能公告。正常导出先固定内容包及布局快照，避免异步开始前用户切换布局导致导出对象变化。

样式栏改为固定 82pt 高、五个明确等宽的按钮，各按钮用实体纸色底形状和矩形 contentShape 建立独立命中区域；缩略插画、选择边框、选中点及轮播装饰卡片不参与命中，轮播手势只保留在其父容器，样式栏提高层级，避免裁切后仍可能越界的装饰层遮挡按钮。修正旧版 GeometryReader/装饰图层的命中范围不明确问题；此前辅助操作能触发按钮，不能据此证明普通触点可用。可见样式名称删除，VoiceOver 仍保留五个完整名称及选中状态；节省高度交给上方预览卡片。样式动画用版本号避免连续点击时旧完成回调提前解除动画锁。

按用户授权，通过内置 ImageGen 分别生成松亭、梅舟、溪桥、竹鹤、秋村五张小景，前四张分别具有左上、右上、上方、下方留白，最后一张完整构图；叠加灰色竖/横条指示，不绘制真实文字。长边 288px 的优化 PNG 接入既有 `DecorCandidates.xcassets`，五张共 526,961 字节；不修改工程文件。生成提示词、来源路径及 SHA-256 见 [样式指示图资源记录](assets/wallpaper-style-thumbnails-v1/README.md)。这些图只用于布局按钮，不进入 DailyContentPack，也不替代主画布的 Mock 插画。

验证：iOS Simulator arm64 与 macOS arm64 无签名 Debug 构建通过；Pro 和 SE 的运行截图显示五个样式完整、无下方名称、主卡片高度增加；通过辅助操作逐一点击五项，中央画布布局与选中边框同步。仓库外 QA 副本仅调整启动 Tab，并用启动参数暂时固定轮播动画状态，验证导出按钮仍是可用状态、点击出现 Toast、2 秒后消失，且 PNG 文件清单及修改时间完全不变；恢复正常状态后点击导出，实际生成 PNG 并打开系统分享表。普通坐标点击工具仍返回 `noWindowsAvailable`，最终普通手指点击与滑动手感保留用户统一验收，不把辅助操作冒充触点验证。QA 参数未进入仓库源码，完成后恢复安装正式源码构建。本轮只修改壁纸组件及本状态文档，新增五个 imageset（五张 PNG、五份 Contents.json）与两份资源记录；年度内容入口、日历/年度册、导出器、Widget、模型、正式插画与语录、字体、工程配置、签名均未改。

2026-11-02 壁纸与日历数据解耦：用户明确壁纸只浏览插画及其关联语录，卡片数量取决于实际内容包数量，与当前年、日期、普通年/闰年和年度洗牌无关；后续可持续更新插画包，不以年份限制壁纸资源。此决定替代本日上一轮“缓存当前年度列表”的壁纸实现，年度册和今日页继续遵循年度分配规则。

壁纸入口改为直接读取 `MockDailyContentRepository.allContent()`，持有 `[DailyContentPack]`；预览、辅助说明与导出直接使用同一个包，不再依赖包含日期的 `CatalogItem` / `MockCatalog.items(year:)`。已有 `DailyContentPack` 同时绑定插画资产与语录，不需要新建映射模型或修改年度分配器。当前显示仓库中的全部 366 套 Mock（365 套基础包加 1 套原闰日包），原闰日包在壁纸中作为普通内容参与浏览。包内不同尺寸用途的插画资产属于同一内容的资源变体，不额外制造重复壁纸卡。保留五种布局、轮播动画、原生尺寸导出与 Mock 标记，不显示日历日期。后续正式插画包的导入与版本更新机制尚未实现，本轮不引入网络更新或包管理功能。

验证：iOS arm64 Simulator 与 macOS arm64 无签名 Debug 构建通过，29 项核心测试通过；源码范围断言确认壁纸不再引用年份、系统日期、年度分配器或带日期的条目，其他页面和画布实现未改。仓库外 QA 副本实测首张为 `mock-base-001`、总数 366，上一张正确循环至第 366 张 `mock-leap-day-001`，直接导出该包 PNG 的尺寸为 `1206×2622`；QA 启动入口不进入交付源码。仅修改 `RootTabView.swift` 的壁纸入口/预览入参与本状态文档，内容模型、内容仓库、年度册、今日页、Widget、导出器、工程配置及签名不变。

2026-11-02 壁纸工坊 UI 细节优化：用户确认以本次五种布局替代旧六种布局，且本轮全部完成后一次验收。普通 iPhone 轮播采用等宽等高纸卡，中央卡片占页面宽度约 70%（最大 360pt），两侧各露出相邻卡片窄边；保留纸纹，增加白色纸边及双层投影。拖动实时平移，以位移与预测终点决定换页或回弹，弹簧停止后无动画重设索引，支持首尾循环；动画与拖动期间禁用导出，减少动态效果时直接切换。新增上一张/下一张辅助操作。壁纸页缓存当前年度内容列表，避免拖动时重复分配全年内容，不改变年度分配算法。

布局栏取消横向滚动，五项等宽单行排列：留白竖排居左、留白竖排居右、留白横排居上、留白横排居下、仅插画，名称分两行。插画始终占满画布，文案叠加到画布左上、右上、顶部或底部，切换布局不再挤压插画。预览与高清 PNG 共用 `WallpaperCompositionCanvas`；页面预览随可用空间适配比例，导出仍使用设备纵向原生像素，两者比例不同会按画布高度重新分配竖排文字列数，不宣称逐像素相同。长 Mock 语录根据可用高度从右到左分列，保留完整文字与底部 Mock 标记；正式插画与正式语录仍未接入。

验证：最终源码 iPhone arm64 Simulator 无签名 Debug 构建通过，macOS arm64 无签名 Debug 编译回归通过（不构成 Mac 运行或视觉验收）；29 项核心测试通过。仓库外临时 QA 副本仅改变启动 Tab 并调用既有导出函数，已核对 iPhone 17 Pro 与 iPhone SE（第 3 代）页面，逐项点击验证 Pro 五种布局，实际打开高清 PNG 系统分享表。两台设备各导出五种 PNG，尺寸分别为 `1206×2622` 和 `750×1334`，像素差分核验文字位于指定区域，布局切换没有移动插画底图；辅助操作验证首张→末张→首张及下一张切换、弹簧停止后居中与导出按钮恢复。坐标输入工具持续返回 `noWindowsAvailable`，未完成手指慢拖、快滑、未达阈值回弹及 Reduce Motion 开关的运行实测，实际触控手感保留用户本轮统一验收。测试入口与批量导出任务仅在仓库外副本，未进入正式源码；最终恢复安装仓库源码构建。仅修改壁纸组件、导出画布和本状态文档，其他页面、Widget 源码、工程配置、签名、资源母版、IAP、网络与权限未改。

2026-11-02 统一详情卡片并清理废弃展示配置：用户明确今日页已关闭的详情内容今后不再使用，因此从共享 `TodayDetailCard` 中删除日期副标题、Header 分割线、重复的独立“出处”、额外“翻译说明”视图和四项旧展示开关；移除不再使用的日期入参与字号属性。正文统一沿用今日页的“原文与出处、历史背景、通俗解读”，翻译说明数据保持在原模型中但不参与详情展示，未修改内容存储或审核字段。仅保留 `showsBinding`（圆孔与金属环）和 `showsBackingSheets`（层叠纸页）两项外观配置：今日入口均为 true，年度册入口均为 false；单张卡片顶部使用 22pt 内边距，不保留装订区的大块空白。两列瀑布流、卡片尺寸、蒙层、翻转与关闭逻辑、Widget、工程/签名配置均未调整。

本轮验证：iOS arm64 Simulator 与 macOS 无签名 Debug 构建均通过，Mac 仅作共享代码编译回归；通过 `rg` 确认旧开关和 `onRemoved` 均已从 App 源码清除，并核对两处详情调用配置。执行 `xcodebuild`、`git diff --check`、`git status --short` 和修改前备份差异检查；新构建已通过 `xcrun simctl install/launch` 安装并启动于 iPhone 17 Pro。当前界面操作工具不可用，未执行本轮详情截图、关闭和正文滚动的运行验收，待用户手动确认；不沿用旧截图作为本轮验证。仅修改 `TodayView.swift`、`RootTabView.swift` 与本状态文档，无新增仓库文件；构建日志和修改前备份位于仓库外 `/Users/ideabox/.cache/MaoStyleCalendar/detail-unification-20261102/`。

2026-11-02 年度册改为两列瀑布流：用户取消“固定两行”，要求删除截图红框中的卡片底部“今日”标记及多余留白。普通 iPhone 改为固定两列的原生 SwiftUI Layout，按列宽测量每张卡片的自然高度，依日期顺序将下一张放入当前较短列；不再使用屏幕高度计算行数或拉伸卡片。年度册文字区由内容撑开，Mock 插画按既有 180:150 画布比例和可用列宽确定高度，底部仅保留 7pt 纸边；目前 Mock 内容结构相同，因此卡片自然等高，不人为制造高低差。年月选择、其他页面和工程配置未改，不进入 Duo/iPad/Mac 专项适配。

本轮验证：iOS arm64 Simulator 无签名 Debug 构建通过，已重新安装并截图检查 iPhone 17 Pro 与 SE（第 3 代），两者均为两列、自然内容高度，卡片底部不再显示“今日”。执行 `xcodebuild`、`xcrun simctl install/launch/io screenshot`、`git diff --check` 与 `git status --short`，并与本轮修改前的源码备份逐段核对；未新增依赖、测试或仓库文件，数据层未修改。模拟器自动化纵向滚动操作返回 `windowNotFoundAtPosition`，因此本轮不宣称已完成月末触控滚动回归，留待手动确认。日志 `waterfall-build.log`、截图 `iphone-pro-waterfall.png` / `iphone-se-waterfall.png` 和备份 `RootTabView.before-waterfall.swift` 保存在 `/Users/ideabox/.cache/MaoStyleCalendar/yearbook-20261102/`。此前固定两行及按屏幕高分两/三行的规则均由本条替代，历史验证记录仅代表当时版本。

2026-11-02 年度册行数调整：用户明确取消大小屏行数特化，普通 iPhone 内容区统一为两列、两行，仍按实际可用高度动态计算卡片高度，宽度随容器计算。本条替代下方“至少 592pt 显示三行”的规则；年月选择、卡片装饰及其他平台专项适配范围保持不变。iPhone 17 Pro 与 SE（第 3 代）重新安装后截图均确认完整两行；iOS arm64 Simulator 无签名 Debug 构建通过，执行 `xcodebuild`、`xcrun simctl` 截图、`git diff --check` 和 `git status --short`，未重复运行未受影响的数据层测试。日志 `two-rows-build.log` 与截图 `iphone-pro-two-rows.png`、`iphone-se-two-rows-updated.png` 继续保存在上述仓库外验证目录。无新增仓库文件，仍待用户视觉确认。

2026-11-02 阶段 6E 年度册 iPhone 打磨：用户确认后，将年份胶囊下拉选择与横滑月份放在同一行；默认选中系统当前年月，月份以朱红文字和下划线标记，切年保留已选月份并刷新对应日期与内容，切月回到月初。年份菜单当前提供系统年份前后各 10 年。普通 iPhone 紧凑宽度固定两列，以扣除标题、年月栏与 Tab 后的实际可用高度计算卡片大小：内容区至少 592pt 时显示三行，否则两行，计算包含行距和上下留白。年度册卡片移除铜环与孔洞。本轮未修改今日、壁纸、详情、年度分配、Widget 源码、字体/图像资源、工程配置及 IAP；此决定替代旧年度册原稿中的铜环卡片要求，原稿文件保留不变。

本轮验证：iPhone 17 Pro 截图显示完整三行，iPhone SE（第 3 代）显示完整两行，年月栏均保持同行；实测月份选择、2026→2024 年份切换后日期/星期/Mock 内容刷新，以及卡片点击打开并关闭详解。CalendarCore 原有 29 项测试通过；iOS arm64 Simulator 与 macOS 无签名 Debug 构建通过，Mac 仅编译回归，不属于平台适配或运行验收。首次 iOS 构建命中旧 DerivedData 中 x86_64 模块缺少类型的错误，指定 `ARCHS=arm64 ONLY_ACTIVE_ARCH=YES` 后通过，未修改工程架构配置。验证命令为 `xcodebuild`（两平台 Debug、`CODE_SIGNING_ALLOWED=NO`）、`swift test`、`xcrun simctl install/launch/terminate/io screenshot`、`git diff --check` 和 `git status --short`；因仓库整体仍未跟踪，额外对修改前备份做逐文件差异和空白检查。截图、日志与备份保存在仓库外 `/Users/ideabox/.cache/MaoStyleCalendar/yearbook-20261102/`。仍为 Mock 内容与候选材质，等待用户视觉确认；不进入 Duo/iPad/Mac 适配。

2026-11-02 阶段 6E 今日页视觉确认跟进（四）：用户复核指出铜环末端仍未穿过孔洞中心。复盘确认上一轮错误使用铜环“下半部整体 Alpha 重心”作为光学校正基准，导致水平补偿过度；本轮改为测量透明素材最末端接触区域最后 6–18 行的 Alpha 中心，其渲染偏差仅约 `0.62–0.90pt`。水平校正由 `-2.75pt` 改为 `-0.7pt`，并将铜环顶部基准下移 `0.5pt`，使末端穿入孔洞的水平中心与纵向中心。孔洞样式、七层纸堆、资源文件、业务逻辑、Widget、工程配置与 IAP 均未修改。

2026-11-02 阶段 6E 今日页视觉确认跟进（三）：修正纸张孔洞与金属环的光学中心偏差。核对铜环透明 PNG 后确认其整体与下半部 Alpha 重心均偏向画布右侧，因此不重做纸纹版纸；改为统一装订参数，并对铜环施加 `-2.75pt` 水平光学校正。正面与背面现在共享同一孔径、孔洞纵向基准、铜环尺寸和顶部基准；孔洞由单一灰色圆改为纸沿、暗部、细高光与轻微内阴影组成的打孔效果。未修改铜环、纸纹或其他图片资源，未改变七层纸堆、业务交互、Widget、工程配置和 IAP。

2026-11-02 阶段 6E 今日页视觉确认跟进（二）：依据用户提供的定稿效果图继续收敛实体日历质感。今日正面与背面装订孔、铜环同步缩小；纸张由正面加 3 张底纸调整为正面加 6 张底纸，共 7 张一周纸页，并通过不等距横纵偏移、微角度旋转与分层阴影加强左侧露边、底部压层和自然纸堆效果；纸页圆角由 7pt 收至 4pt。未替换候选铜环或纸纹资源，未修改布局内容、业务交互、Widget、工程配置与 IAP。

2026-11-02 阶段 6E 今日页视觉确认跟进：按用户截图精简今日页背面“语录详解”卡片，移除日期副标题及其分割线；内容区保留信息更完整的“原文与出处”，移除重复的独立“出处”和末尾“翻译说明”。本次只改变今日页详解卡片的展示配置，年度册复用的详情卡保持原展示，未进入阶段 7，未接入 IAP/StoreKit。

2026-10-30 阶段 6E 普通 iPhone 整体交互与视觉工程回归已完成，等待用户最终视觉确认：本轮在 iPhone 17 Pro 与 iPhone SE（第 3 代）上覆盖今日正面、固定 Header 详解、年度册、壁纸工坊、设置、浅色/深色外观、`accessibility-extra-large` 与 Reduce Motion。修复年度册缩略卡完整竖排语录越界并压住插画标识的问题，缩略卡改用带省略号的短摘录且保留完整 VoiceOver 文本；修复超大辅助字号下今日卡片日期、竖排语录、Mock 标识和底部操作彼此重叠的问题，在保持可读放大的同时为固定物理卡片布局设置有界排版，并压缩 Mock 视觉标识为短 ID。iPhone SE 小屏默认字号无裁切；Reduce Motion 开启时左右换日实际从 10 月 30 日切换到 10 月 31 日，关闭后已恢复系统默认。核心 29 项测试通过，iPhone 17 Pro arm64 Simulator 无签名 Debug 构建通过。当前仍是候选装饰资源与 Mock 内容的工程验收，不等同于正式插画、正式语录或最终发布视觉获准。用户明确要求 IAP/StoreKit 延后到交互和视觉验收全部完成后再接入，本阶段未新增 StoreKit、付费墙或购买逻辑。

2026-10-30 阶段 6D 普通 iPhone Widget 宿主闭环已完成：`CalendarCore.AppRoute` 新增唯一的日期 URL 生成入口并补充往返测试，主屏与锁屏 Widget 统一使用该入口；修复锁屏 Widget 原先只显示、未绑定日期深链的问题。iPhone 17 Pro 模拟器已在真实系统宿主中添加并核对 Small 主屏 Widget 与 Rectangular 锁屏 Widget，两个入口点击后均打开 App 今日页并命中 `2026-10-30`。使用带模拟器 entitlement 的正常 Debug 构建后，App Group 共享容器实际建立。系统锁屏选择器同时识别 Circular 与 Rectangular Family；Inline Family 通过编译和现有分支覆盖，但本轮系统下方 Widget 选择器没有提供独立 Inline 卡片，因此未把它记为单独宿主点击验收。核心测试由 28 项增加至 29 项，iOS arm64 Simulator Debug 构建通过；正式真机 provisioning、锁屏隐私状态和着色模式仍待设备阶段验证。

2026-10-30 阶段 6C 普通 iPhone 分享与高清壁纸导出已实现：壁纸工坊六种版式不再导出页面截图，而是通过独立 SwiftUI 画布按当前设备纵向原生像素生成 PNG，并以临时文件交给系统分享表；不申请照片权限、不直接写入相册，也不尝试绕过系统设置壁纸限制。当前仍使用 Mock 内容，因此文件名和画布底部强制包含 `MOCK` / `NOT FOR RELEASE` 标识，避免被误认成正式发布素材。今日卡片分享按钮已接入系统文字分享，包含当前公历日期、星期、Mock 语录与内容 ID。iPhone 17 Pro 模拟器已逐一导出留白竖排、留白横排、上文下画、上画下文、左右对景、仅插画六种 PNG，均核验为设备原生 `1206×2622`；壁纸文件分享表和今日文字分享表均实际打开并在不发送到外部应用的前提下关闭。核心 28 项测试及 iOS Debug 构建通过；macOS 以 arm64 Debug 验证通过，Mac 导出仍按平台顺序保留到后续阶段。

2026-10-30 阶段 6B 普通 iPhone 设置与说明已实现：今日页齿轮按钮现打开原生设置 Sheet，提供中文、English、中英双语三种内容显示偏好，并通过既有 App Group `UserDefaults` 在重启后持久化。当前 Mock 仅含中文占位，因此设置页明确说明英文与双语将在批准内容接入后生效，不使用机器翻译冒充权威英译。设置内新增内容来源与核验、插画与授权、数据与隐私、字体许可及关于本项目五个说明入口；文字依据现有项目规则，明确候选资源、正式品牌和 Release 内容仍未获准，不新增网络、账号、敏感权限或虚假能力。辅助功能状态只说明跟随系统，不建立无效的应用内开关。核心测试由 25 项增加至 28 项，覆盖默认语言、跨 Repository 持久化和未知值安全回退。iPhone 17 Pro 模拟器已实测设置入口、全部说明入口、语言切换及 App 终止重启后的偏好保留；长标题裁切在实测后已改为内联项目字体标题并复核。

2026-10-30 阶段 6A 普通 iPhone 日期路由与 Widget 深链已实现：`CalendarCore` 新增严格校验的 `maostylecalendar://date/<year>-<month>-<day>` 路由解析，App 注册 URL Scheme，并由根容器统一持有今日页日期。合法深链会切回“今日”、打开指定公历日期并关闭可能存在的详解/拖拽状态；非法日期、未知路径、查询参数和额外路径不会改变当前页面。核心测试由 22 项增加至 25 项。iPhone 17 Pro 模拟器已实际验证冷启动打开 `2028-02-29` 命中闰日专属 Mock，以及从“年度册”运行中打开 `2032-12-31` 返回今日页并显示指定日期。首次自定义 URL 的系统“打开”确认属于模拟器/系统行为。Widget 主屏与锁屏实际宿主点击仍保留到阶段 6 整体验收。

2026-10-30 用户确认调整平台推进顺序：当前集中完成普通 iPhone 的全部 App 功能、主屏/锁屏 Widget 与视觉验收；通过后再适配 iPhone Duo、iPad，最后单独处理 Mac。此前已做的宽屏和 Mac 代码保留，不继续并行扩展或要求同步验收。该决定调整交付顺序，产品目标平台不变；后续按整体里程碑统一验收，正式插画/语录交付前继续使用 Mock。执行规则见根目录 `AGENTS.md` 第 7 节及 [平台适配策略](product/platform-adaptation.md)。

2026-10-30 开发者后台登记更新：用户提供截图并确认主 App、iOS/iPadOS Widget、macOS Widget 三个 App ID 已创建，全部关联 `group.com.ideaboxapps.maostylecalendar`。后台操作由用户完成；真实设备 provisioning、签名与 Widget 共享读取仍待验证。截图中 macOS Widget ID 末尾为 `.macOS`，工程当前为 `.macos`，已登记为待对齐核验项，本轮未修改 Bundle ID。Team、准确标识及后续 App Store Connect/IAP 待创建项统一维护于 [AGENTS.md 第 7.1 节](../AGENTS.md#71-项目标识与后台配置)。本条更新下方阶段 5 的后台注册待办状态。


2026-10-30 阶段 4 多端自适应与 Widget Mock 视觉还原已实现：iPhone 紧凑宽度继续使用四 Tab；iPad、横向扩展宽度与 macOS 改用 Sidebar + Detail，四个一级入口共享现有页面与状态。iPad Pro 13-inch 模拟器已实际启动并截图核对宽屏层级，macOS App 已启动并通过可访问性树确认 Sidebar、四入口与今日详情同时存在。Widget Provider 复用 `CalendarCore` 的本地日期、366 条 Mock Repository 与年度确定性映射，同一天在 Small、Medium、Large、Extra Large、Circular、Rectangular、Inline 中使用相同内容 ID；四种桌面 Family 按确认稿独立编排，锁屏 Family 使用单色精简布局，Timeline 请求下一本地午夜后刷新。五套项目字体分别打包进 App 与 Widget 产物。本阶段仍不接入 AppIntent、正式语录/插画、农历文案、系统着色专项资源或 StoreKit。

2026-10-30 阶段 3 主入口 Mock 闭环已实现：年度册与壁纸工坊 Tab 已替换占位页。年度册直接使用 `CalendarCore` 年度确定性映射，支持年份切换、月份索引、两列自适应单页卡与复用“语录详解”；壁纸工坊支持绑定同一内容包的左右切换、六种编排缩略图与排版预览，高清导出暂以明确提示门禁，不生成低清截图或申请照片权限。本阶段不建立持久化、App Group、StoreKit、网络或正式插画/内容资源，不改变 Widget 与年度分配算法。

2026-10-30 铜环候选运行修订：当前实际引用已由 V2 收敛为 `CalendarCopperRingCandidateV3`；V3 缩短后侧扣脚，并将铜环与穿孔整体下移 2 pt，使扣脚仅轻微覆盖卡片上沿，避免 V2 越界过深。本条替代下方阶段 2 段落中的 V2 资源描述；V1/V2 母版与倍率资源均保留，候选状态不变，最终仍待设计验收。

2026-10-30 阶段 2 今日页里程碑已实现：原生四 Tab 外壳、Mock 年度映射、实体纸页正面、左右换日、3D 翻转详解、暖色蒙层、固定 Header、独立正文滚动、Reduce Motion 降级与基础无障碍已接入。换日手势采用双层卡片交互：当前卡片跟手位移、轻微旋转并按距离或甩动速度离场，目标日期卡片从下层补位；未达到阈值时弹性回位且不误触详情。首页三层装饰纸页以不同方向、克制的横向错位和递进纵深固定在卡片容器底部，已与可拖内容页解耦；金属圆环同样固定在容器前景，并按素材视觉重量进行光学居中，滑动时只移动当前纸页及其穿孔阴影。铜环现使用保留透明背景的 V2 Candidate，后侧扣脚已延长并在正面/详解页覆盖卡片上沿，不再露出空气缝。`DecorCandidates.xcassets` 与 `IconCandidates.xcassets` 仅接入 iOS/macOS App targets 作为内部候选视觉资源，不进入 Widget，也不改变其 Candidate 状态；程序化插画明确显示 MOCK ID。iPhone 17 Pro 模拟器已实际验证打开/关闭详解、双向甩动换日、纯点击与拖拽手势互斥及背面禁用换日；低速未过阈值的回弹由手势分支保证，仍列入本里程碑手感验收。

2026-10-30 阶段 1 数据层已建立：`CalendarCore` 新增数据库无关的每日内容契约、Repository 与 366 条内存 Mock（365 个基础包 + 1 个闰日包），逻辑表、关系、审核字段和后续持久化边界见 [内容数据结构](engineering/content-data-schema.md)。Mock 全部保持 `candidate` / `mock_placeholder` / `placeholder`，不含伪造出处或核验记录，不得进入 Release 内容资源。本阶段未接入 UI、数据库后端、App Group 或正式插画。

2026-10-30 用户确认先归档当前资源、后续按需调整：资源已作为 `v2-resources-r1` 保留在 `docs/design/handoff/v2/resources/`，见 [归档记录](design/handoff/v2/resources/ARCHIVE.md)。本轮结束，不再继续生成/打磨素材，也未开始业务编码。既有候选状态和缺件说明保留，不把进一步资源打磨作为新增开发前置条件。

2026-10-30 实现前资源复核当时确认 v2 缺独立切图，随后补齐基础装饰候选、倍率导出及矢量图标；阶段 2 已将候选接入 App 内部实现。正式插画、局部材质贴合和深色/着色仍未齐备，不能把资源准备、工具编译或当前 Mock 页面记为最终视觉验收。见 [资源审计](assets/v2-resource-readiness.md)。

阶段 4.2：现有原稿与最新五角色字体规范已归档；CalendarCore 的 11 项年度分配测试与后续新增的 6 项 Mock Repository 测试均通过。iOS/iPadOS 与 macOS App、各自 Widget 共四个 targets 已建立，均完成无签名 Debug 编译；iPhone 模拟器启动通过。此条记录工程启动时状态，后续页面实现见上方阶段记录。

2026-10-30 目录整理：Apple 工程、Native 源码和 CalendarCore 已统一迁入 `ios-client/`；`android-client/` 预留后续 Android 实现，公共文档与设计仍在根目录 `docs/`。当前结构入口为 [仓库结构说明](engineering/repository-structure.md)。目录迁移不改变产品行为、target、Bundle ID、Team 或最低系统版本。

## 已确认决定

- 所有日历插画由用户的设计师手工原创绘制。
- 后续由用户提供原图扫描件，再进行数字资源处理。
- 产品支持中文和英文，并要求每条中文语录有可靠出处、英文采用可核验的权威译文。
- 产品必须与现有毛选日历和通用语录 Widget 形成明显差异。
- 项目规则记录在根目录 `AGENTS.md`，相关文档归档在 `docs/`。
- 2026-10-29 首批底本限定为《毛泽东选集》第一至第四卷。2026-11-09 用户确认，对现有卡片扩展到有正式出版记录的其他底本，并逐篇核对英文。
- 365 张原创插画与 365 条对应语录组成固定配对内容池，运行时再按年度规则映射到日期。
- 载体 App 将 365 套内容作为可翻阅的数字小册子，提供出处、历史背景、编辑解读和壁纸衍生能力。
- 原文、权威英译和项目编辑解读必须分层存储、分层展示。
- 已登记 Foreign Languages Press, Peking 1965 年四卷英文扫描检索副本及 SHA-256；扫描件仅作内部核验，不进入仓库或产品包。
- 首批 10 条样本已完成英文页码定位和中文官方入口交叉定位，但在中文 1991 年版底本取得前全部保持 `candidate`。
- 产品允许对原文做编辑性摘编，包括省略主语、截取精华片段和组合非连续句段；非连续或未加省略号本身不构成失败。
- 编辑性摘编必须保存全部来源片段与上下文；英文优先复用权威英译片段，重组后的整体属于项目编辑译文。
- 目标平台包括 iPhone、iPhone Duo、iPad 和 Mac，采用共享 SwiftUI 内容/组件与平台自适应容器。
- App 一级入口确定为今日、年度册、壁纸和设置。
- Widget 首发覆盖 Small、Medium、Large、锁屏 Family，并在 iPad/Mac 支持 Extra Large。
- 以高保真 UI、真实字体与设计资源交接后直接进入原生 SwiftUI；2026-10-29 用户明确取消前端可交互原型，不再作为 Coding 前置条件。
- 今日页采用实体铜环翻页日历风格；左滑下一天，右滑上一天。
- 点击卡片内容将卡片翻转到背面；点击蒙层或关闭按钮翻回正面。
- 背面固定 Header 只显示“语录详解”，不显示日期；Header 下方正文根据内容高度自然滚动。
- 背面不显示“继续阅读”或向下箭头提示。
- 主标题、副标题和正文使用随 App 内置的项目字体，不以系统字体作为正式视觉；选型前必须完成移动 App/Widget/Mac 商业嵌入授权核验。
- 当前字体方案（2026-11-19 用户验收后）：中文标题与中文语录使用思源宋体 SC Bold 2.003，中文正文使用 Apple 系统 Regular；英文语录使用 Source Serif 4 SemiBold 4.004（wght=600），大日期使用 Libre Bodoni Bold 2.005（wght=700）。思源宋体 SemiBold 与 Regular 不再进入 App 包；历史字体选型记录保留。
- 用户指定 Bundle ID `com.ideaboxapps.maostylecalendar`、最低 iOS/iPadOS 17（2026-10-30 由原 15 提升）；macOS 采用建议的最低 14。App 与主屏/锁屏组件统一以 iOS 17 为基线，已移除 iOS 15/16 兼容分支。
- Team `C2EN8G3ZSM`（Hangzhou IdeaBox Technology Co., Ltd.）经钥匙链公开证书信息确认；工程记录 Team，当前构建关闭签名，未导出私钥/证书文件、未配置线上签名与商店记录。
- 产品不绑定 2027；根据系统年份生成当年日历，365 套基础内容按年份确定性洗牌，同一年不重复、下一年重置。
- 闰年实际为 366 天；为满足年内不重复，需要额外提供 1 套 2 月 29 日专属内容。
- 主 Tab 调整为今日、年度册、壁纸、设置。
- 壁纸移除锁屏/主屏和语言选择，语录跟随系统语言；支持“原稿排版／仅插画”两种模式（2026-11-06 替代此前五种排版），当前先用 31 套内容池滑动切换和全年复用，待统一验收后再扩充，不显示日期；主操作为“导出高清壁纸”，默认按当前设备屏幕像素尺寸生成。
- 普通 App 不能直接设置系统壁纸；导出后通过系统分享表或照片进入系统设置流程。
- IAP 为不绑定年份的完整功能永久解锁；付费墙不使用年份、365 或“原创手绘”营销文案。
- 2026-10-30 用户明确将 IAP/StoreKit 放到交互与视觉验收全部完成之后再接入；在此之前不新增付费墙、购买状态或后台产品占位。

## 尚未确认

- App Store 中英文名称的可用性及最终发布名。iPhone 主屏幕中英文名称已接入。
- 设计师授权文件的具体形式和授权主体。
- 365 张插画的交付格式、分辨率、色彩空间和批次安排。
- 闰日专属插画与语录内容。
- 中文纸本的具体印次，以及英文四卷本的具体印次和可用扫描来源。
- 产品正式提供的 365 条“日期—插画—中文语录”映射清单。
- 商业定价和首发国家/地区；永久解锁模式已确认。
- 字体打包体积与是否子集化；核心五角色家族和字重已确认，字号、字距、英文正文/篇名等辅助角色仍需依原稿配准。

## 当前风险

- 中文 1991 年版与外文出版社早期英文版不一定逐页、逐句完全对应，需要双底本校核。
- 已有竞品使用《毛选日历》名称，正式品牌需规避混淆和 Copycat 风险。
- 原创插画仍需形成可证明的商业授权链和交付记录。
- 长期、大规模收录中英文引文以及海外商业发行的版权边界仍需目标市场法律审查。
- 设计稿摘编若未记录来源片段、组合逻辑与英文文本类型，会产生不可追溯或错误宣称“权威原句”的风险。
- 概念稿字体无法直接提取；若未先确认真实字体文件和多平台嵌入授权，会产生视觉偏差与版权风险。
- 只有 365 套基础内容时无法覆盖闰年 366 天且保持年内零重复；闰日内容是正式发布前阻塞项。

## 下一阶段建议

阶段 6E 的工程自测已通过，下一步先由用户对本轮普通 iPhone 截图和实际模拟器交互做一次整体视觉确认；此确认点不再新增功能。用户确认普通 iPhone 通过后，建议进入阶段 7，开始 iPhone Duo 与 iPad 的专项自适应和 Widget 验收，复用现有共享层但只修改确有平台差异的容器与布局。IAP/StoreKit 继续后置，不与阶段 7 混做；iPhone Duo/iPad 通过后再单独处理 Mac，最后在各平台交互和视觉均稳定、且 Product ID/价格/App Store Connect 信息完整时接入永久解锁。macOS Widget ID `.macOS` / `.macos` 拼写核对归入 Mac 阶段。


2026-11-06 今日卡片日期信息区微调：根据用户截图，左上日号模板右侧三行整体下移约 12 设计点；两种顶部模板统一月份 19.28、辅助行 10.28 设计点（360 宽基准），保持右对齐。仅修改共用 ArtworkPage 渲染与文档，未改日号、语录、背景、底部模板、工程配置或 2 月计划。此决定替代旧顶部模板使用不同字号的规则，详见 1 月工程接入记录末节。

2026-11-06 用户要求顶部留白充足的共读卡片改用左上日号＋右上三行日期信息：已将 DailyArtwork 的 pack-0009、pack-0010 从 bottomLeftCompact 改为 topLeft（修订 2），沿用统一字号、下移位置和右对齐。仅调整工程 JSON 与记录，不改图片、语录、Swift 日期渲染或工程配置，旧试制历史数据保留。


## 2026-11-13 Firebase 使用统计接入

- 用户明确授权新增 Firebase Analytics，替代此前完全无统计 SDK 的边界；仅 iOS 主 App，Widget/Mac 不接入。
- 用户在控制台创建项目 `MaoStyleCalendar`，Project ID `maostylecalendar`，注册 Bundle ID `com.ideaboxapps.maostylecalendar`；配置已匹配，Analytics 属性关联仍须控制台验证。
- SPM 固定 Firebase 13.1.1，仅链接 FirebaseAnalyticsCore（无 IDFA 能力）。用户随后明确改为默认开启，不新增提示、设置开关或入口；随 App 启动初始化，广告 consent 全部 denied，IDFV/自动屏幕上报关闭；保留 SDK 自动事件，购买事件范围按 Firebase 官方行为披露。
- 自定义事件不携带阅读内容、具体日期、内容 ID、图片、交易或个人信息；不自定义用户 ID。停止使用并删除 App 可停止该安装的后续采集，不承诺删除远端历史。
- 配置文件本地提供并忽略 Git；不记录 API key。CI/其他开发机需自行放置匹配的配置。
- 中英本地隐私政策同步，App Store 隐私问卷、线上隐私政策与 Google 数据共享/保留设置仍须发布前人工核对。未修改 App Store 后台、签名、标识或版本。
- iOS 无签名 Debug 构建通过；独立模拟器记录自动事件和实际换日事件，SDK 状态显示上传成功。后台 DebugView、GA 属性 ID 与其余 UI 事件闭环仍待核验，未宣称报表验收通过。验证详见 `docs/engineering/firebase-analytics.md`。


### 2026-11-13 追加：Debug 构建不参与行为统计

用户要求所有 Debug 相关行为均不上报。统计封装统一限定 `os(iOS) && !DEBUG`，Debug 不初始化 Firebase，不调用页面或行为事件 API，涵盖预览、QA 和模拟购买；Release 默认开启、不新增提示或入口。此前用于验证链路的 Debug 测试事件属于历史验证数据，不代表修订后的采集策略。验收见 `docs/engineering/firebase-analytics.md`。

本次修订 Debug/Release 无签名模拟器构建均通过；安装 Debug 并运行既有 QA 换日/Tab 路由后，历史统计计数保持不变。只修改 `AppAnalytics.swift` 和两份记录文档，无新增文件。


### 2026-11-13 追加：购买/恢复结果统计

新增购买成功、失败、取消、待批准、验签失败、已有权益，以及恢复成功、未找到权益、失败、取消，共 10 个无参数结果事件。Debug 仍不初始化或调用 Firebase。恢复按真实 AppStore.sync 请求记录 started 和终态，重试等待不重复计数，UI 等待超时不伪报失败。未修改购买、验签、恢复和权益返回逻辑；中英隐私政策同步披露操作结果。事件清单及验证见 `docs/engineering/firebase-analytics.md`。

结果统计修订验收：Debug/Release 无签名构建均通过；从当前生产方法抽取的无网络桩测试共 19 项断言通过，覆盖恢复超时重试去重和 UI 取消后真实结果回报。未进行 Sandbox 真交易或后台收数验收。

## 2026-11-26 大尺寸 Widget 语录与节气

- 普通 iPhone 标准大尺寸 Widget 的语录候选宽度调整为可用宽度的 80%、70%、60%，避免自动布局优先选择日期右侧过窄的竖栏；紧凑大尺寸与其他 Widget 尺寸沿用原候选规则。
- 中文且开启农历显示时，节气当日于农历日期后追加 `· 节气名`；普通日期不显示节气。按设备时区中的当天起止时刻，计算太阳视黄经跨越 15° 的节气边界；不新增网络或静态年份映射。
- 用香港天文台 2026、2027 年公历农历转换表核对节气日期；代表性布局由 Debug Widget QA 渲染标准/紧凑大尺寸及农历/节气状态。保持语录内容、插画、Widget 设置含义与工程配置不变。

### 2026-11-27 今日卡片节气补充

- 中文今日卡片在农历日期后显示当天节气，普通日期保持原农历文字；复用现有 `ArtworkSolarTerm` 本地算法。
- 仅今日卡片开启，年度册缩略图和其他共用日期组件的卡片暂不改变；今日卡片 VoiceOver 日期摘要同步包含农历与节气。
- Debug QA 对四种日期位置分别渲染节气日和普通日期，确认单行显示及无裁切。

### 2026-11-27 壁纸预览付费边界

- 未购买时保留中心左右各两张的原免费浏览范围；滑到第 3 张锁定卡片仍触发原付费墙，但滑动最终停在该卡片。快速滑过边界会收敛到第 3 张，外侧第 4 张仍作为锁定邻卡可见。
- 关闭付费墙后不再回退到滑动前的位置；重新进入壁纸页时保留 `-3...3` 的当前预览位置。点击邻卡触发付费墙时也会先把可停留的卡片移到中心。
- 已购买后的连续浏览、布局选择、导出和购买流程保持原实现；Debug 增加边界位置预览参数用于左右两端截图检查。

#### 同日修正：未解锁滚动末端仍留白

用户实机截图显示，上一版仅在 `-3...3` 的停留位置补邻卡，但未解锁轨道仍是 `-4..<5` 的有限数据。若滚动视图晚于停止事件才更新到末端 `4`，右侧会露出空白。现将未解锁和已解锁统一使用相同的三轮循环轨道；未解锁卡片直接在同一预览上叠加模糊与锁，不再用透明按钮包裹。未解锁位置仍限制在 `-3...3`，晚到的目标位置另作纠正；只有真实拖动进入边界才弹付费墙，关闭后保留触发卡片。前一条仅靠有限轨道邻卡避免留白的结论被本次修正替代。

#### 同日修正：恢复壁纸边界付费墙

统一轨道后，用户反馈实际滑到锁定边界未弹付费墙。原因是前次新增的拖动标记在边界停稳时可能已失效；现在从 `-2...2` 进入 `±3` 直接触发付费墙，已停在边界再向外拖动仍按拖动状态触发。Debug 提供左右滑入边界的验证入口，两侧均在 iPhone 模拟器中看到付费墙；未改购买、恢复或已解锁浏览逻辑。
