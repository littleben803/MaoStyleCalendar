# MaoStyleCalendar 项目协作规范

## 1. 产品目标

- 建设一款以原创手绘插画、动态日期信息和可溯源毛泽东著作语录为核心的中英双语 Apple 平台日历应用。
- iPhone 主屏幕 Widget 是核心使用场景，载体 App 负责完整日历页、出处、上下文和设置。
- 产品必须形成自己的视觉语言和内容可信度，不复制现有《毛选日历》、语录 Widget 或圣经语录产品的名称、界面和功能组合。
- 产品不绑定 2027 或其他具体年份；根据系统当前年份生成当年日历。

## 2. 默认沟通和执行方式

- 默认使用中文，先给专业结论，再解释关键依据。
- 开发或资源处理开始前，先明确产品目标、技术方案、任务边界、允许修改文件、不允许修改文件和验收标准。
- 按阶段小步执行；每完成一个阶段先汇报并等待确认。
- 修改必须小、聚焦、可回滚，不顺手修改无关文件。

## 3. 内容真实性红线

- 不从语录网站、社交媒体、图片搜索结果或二手文章直接录入正式语录。
- 中文正式底本优先采用人民出版社正式出版的《毛泽东选集》第一至第四卷；网络页面只作为检索入口，纸本或可信扫描版用于最终页码核验。
- 英文正式底本优先采用外文出版社（Foreign Languages Press, Peking）正式出版的 `Selected Works of Mao Tse-tung` 第一至第四卷。
- 每条语录必须记录：稳定 ID、中文原文、英文原文、中文篇名、英文篇名、卷次、版本、页码或稳定定位、文章日期、上下文、核验人、核验日期和状态。
- 中文和英文必须分别从各自底本抄录。禁止把自译、机器翻译或润色文字标记为“权威英译”。
- 中英文版本无法逐句对应时，状态必须为 `blocked_version_mismatch`，不得进入正式资源。
- 允许产品对原文进行编辑性摘编，包括省略主语、截取精华片段和组合同篇文章中的非连续句段；必须记录每个来源片段及完整上下文，并检查组合后是否歪曲原意。
- 编辑性摘编不因“非连续”或“未使用省略号”自动失败，但必须与逐字原文分型存储。英文应优先复用对应英文底本片段；重新组合或补写的部分属于项目编辑译文，不能伪称为外文出版社逐字原句。
- 对常见误引、伪引、后人概括和出处不明内容，宁缺毋滥。

## 4. 内容状态

- `candidate`：候选，尚未完成底本核验。
- `cn_verified`：中文原文、篇名、卷次和页码已核验。
- `bilingual_verified`：中英文均已逐句核验且含版本信息。
- `editorial_reviewed`：已完成语境、截句和产品呈现审校。
- `approved`：可进入正式 App 资源。
- `blocked_version_mismatch`：中英文版本存在差异，等待人工处理。
- 只有 `approved` 内容可以进入 Release 构建。

- 2026-11-13 用户明确授权将已验收的功能和现有资源接入 Release，并要求调试入口保留在 Debug、冻结已确认视觉和交互。此授权替代此前把整套 DailyArtwork / OnboardingPreview 仅限 Debug 的工程隔离；沿用现有资源 ID、正文、翻译分类和审计记录，不将工程接入写成出版底本核验或商业授权状态已升级。后续不得仅依据历史 `candidate` 标签重新隐藏本次获准接入的整套功能；未获确认的新内容仍遵守原审核流程。

## 5. 原创插画和资源规则

- 设计师提供的原图扫描件视为不可变母版，不覆盖、不涂改、不直接用于批处理输出。
- 每张插画记录作者、创作日期、交付批次、对应日期、授权范围和源文件校验值。
- 设计交付必须包含可独立使用的插画层或插画母版；只提供已经烘焙日期、语录和插画的整页扫描件，不能满足动态年份要求。
- 正式导入前确认 App、Widget、宣传图、App Store 页面和海外发行的商业使用授权。
- 原始扫描、清理候选、批准成品和 App 优化资源分层保存；具体目录在首次导入阶段确定。
- 不把未经明确允许的大尺寸扫描件、构建产物或临时修图文件提交到 Git。
- 不使用来源不明的历史照片、宣传画或第三方插画作为可发布素材。

## 6. 产品差异化约束

- 核心卖点是“365 张原创手绘日历 + 有出处的中英双语阅读”，不是普通随机语录换背景。
- Small、Medium、Large、Extra Large、Lock Screen 和 StandBy 必须独立编排，禁止把同一张成品图机械缩放到所有尺寸。
- 主 App 必须提供 Widget 之外的长期价值，例如完整日历页、原文出处、上下文和往日回看。
- MVP 不加入 AI 模仿人物对话、占卜、替用户做决定、用户生成内容或未经核验的自动翻译。
- 不把历史与思想内容描述为确定性预测、医疗/法律/投资建议或现实行动指令。

## 6.1 已确认的今日卡片交互

- 今日页采用实体铜环翻页日历风格；左滑进入下一天，右滑返回上一天。
- 点击卡片内容区域将卡片翻转到背面；正面为完整作品，不设底部操作栏。
- 背面固定 Header 只显示“语录详解”，不显示日期；Header 不随正文滚动。
- Header 以下的出处、摘编说明、历史背景、通俗解读等正文区域根据内容高度决定是否滚动。
- 背面不显示“继续阅读”或向下箭头；点击卡片外半透明蒙层或关闭按钮翻回正面。
- 背面打开期间禁用左右换日手势，避免与正文滚动和关闭交互冲突。
- 主 Tab 固定为：今日、年度册、壁纸、设置。

## 6.2 字体约束

- 2026-11-19 用户验收后的字体方案：中文标题和中文语录使用内置思源宋体 SC Bold，中文正文使用 Apple 系统 Regular；英文语录使用 Source Serif 4 SemiBold（wght=600），大日期数字使用 Libre Bodoni Bold（wght=700）。已移除思源宋体 SemiBold 与 Regular 文件。准确文件、版本、PostScript 名称与校验值见 `docs/design/handoff/v2/specs/font-roles.json`；不得退回 Literata 或擅自替换。
- 除已确认的中文正文系统 Regular 外，主标题、语录及大日期继续使用随 App 内置的项目字体。
- 字体必须具有 iOS、iPadOS、Widget、macOS 和商业发行所需的合法嵌入授权；来源不明或仅限桌面使用的字体不得进入工程。
- 概念稿只能定义字体气质，不能据此推断或提取具体字体文件。正式选型必须用真实字体样张确认。
- 自定义字体仍须支持 Dynamic Type、VoiceOver、粗体文本、中文/英文字符覆盖和合理的回退策略。
- Widget Extension 与 Mac target 必须分别验证字体打包和加载，不得假设主 App 注册后扩展自动可用。

## 6.3 年度内容分配规则

- 365 套插画与语录组成稳定的 `DailyContentPack` 资源池；插画与对应语录视为不可拆分的一套内容。
- 每年使用“年份 + 分配算法版本”作为固定种子，对 365 套内容做确定性洗牌；同一年内每套内容最多出现一次。
- 不能依赖用户打开 App 的先后顺序做真随机抽取；App、Widget、不同设备和重装后必须得到相同映射。
- 新的一年重置资源池并重新洗牌，允许再次使用上一年度出现过的内容。
- 普通年为 365 天；闰年为 366 天。若坚持年内不重复，必须额外提供 1 套闰日专属内容，不计入基础 365 套资源池。
- 内容修订保持稳定 ID，不得在年中改变算法版本或资源 ID 顺序而导致当天内容整体重排。
- 日期、年份、公历/农历和星期由运行时结构化数据渲染，不得烘焙在插画位图中。

## 7. 技术和隐私边界

- 2026-10-30 工程启动配置：用户指定 `com.ideaboxapps.maostylecalendar`、最低 iOS/iPadOS 17（用户于 2026-10-30 将原 15 提升为 17）；macOS 采用建议的 14。Team `C2EN8G3ZSM` 经授权只读核验公开证书信息。当前允许建立 App/Widget targets 与无签名 Debug 验证，不代表允许线上 provisioning、App Store 配置或发布。App 与主屏/锁屏 Widget 统一以 iOS 17 为基线，不保留 iOS 15/16 的兼容分支。

- 默认本地优先、离线可用、无账号、无广告、无追踪。
- 未经明确允许，不新增网络请求、服务端、在线 AI、分析 SDK、广告 SDK、StoreKit、CloudKit、iCloud 同步或敏感权限。
- 未经明确允许，不新增第三方依赖，不修改工程配置、签名、Bundle ID、Team、Version、Build 或 App Store 配置。
- Widget 使用结构化日期和文本数据渲染，不把所有文字栅格化进图片。
- 产品目标平台包括 iPhone、iPhone Duo、iPad 和 Mac；优先使用共享 SwiftUI 组件与自适应布局，平台专属容器和交互允许少量差异。
- 2026-11-04 用户明确：今后所有页面的 iPhone Duo 内屏适配，半展开（partiallyOpen）与全展开（fullyOpen）统一采用相同的布局、交互与呈现规则，不得只适配 fullyOpen。验收必须同时覆盖两种内屏状态及两者切换；空间不足时沿用相同的自适应回退规则。外屏独立处理，不因此改变普通 iPhone 布局。
- 2026-10-30 用户调整开发与验收顺序：先完成普通 iPhone 全部功能与视觉验收（含该平台 App、主屏/锁屏 Widget）；统一通过后再适配 iPhone Duo 与 iPad，最后单独开发和验收 Mac。此决定替代此前多平台并行推进方式，目标平台范围不变。
- 当前里程碑只围绕普通 iPhone 推进；其他平台已有代码、targets、标识与设计保留，不主动扩展适配或要求用户同步验收。共享层修改应保持现有接口可用，后续平台专项运行验收按上述顺序进行。每个整体里程碑完成后统一验收，不拆成大量细步骤。
- 正式插画和核验语录尚待交付期间，普通 iPhone 使用 Mock 完成功能与布局验收；正式素材替换、内容审核与最终发布验收仍须单独完成，不把 Mock 验收记为正式内容获准发布。

## 7.1 项目标识与后台配置

- Android 包名：2026-11-16 用户明确确认后续统一使用 `com.ideaboxapps.maostylecalendar.android`，用于 Android 工程的 applicationId、备案和正式打包。当前仅确认标识，尚未创建 Android 工程或完成包名配置；不代表 Android 已打包、签名核验或备案通过。

- 团队：Hangzhou IdeaBox Technology Co., Ltd.，Team ID：`C2EN8G3ZSM`。
- 2026-10-30 用户提供后台截图并确认以下三个 App ID 已创建，且均已关联 App Group `group.com.ideaboxapps.maostylecalendar`：

| 用途 | 后台 Identifier（按用户截图记录） | 工程 target |
| --- | --- | --- |
| 主 App | `com.ideaboxapps.maostylecalendar` | MaoStyleCalendar-iOS / MaoStyleCalendar-macOS |
| iOS/iPadOS Widget | `com.ideaboxapps.maostylecalendar.widgets` | CalendarWidget-iOS |
| macOS Widget | `com.ideaboxapps.maostylecalendar.widgets.macOS` | CalendarWidget-macOS |

- 待核对差异：后台截图 macOS Widget ID 末尾为 `.macOS`，工程当前为 `.macos`；签名验证时须核对并统一准确拼写，不擅自修改 Bundle ID。
- 四个 targets 共用 `ios-client/Native/Configuration/Shared.entitlements`，同设备 App/Widget 通过上述 App Group 共享桌面小组件显示偏好。模拟器共享容器及 App 重启持久化已验证；后台注册与关联由用户完成，真机 provisioning、签名及 Widget 实际读取仍待验证。
- App Store Connect：2026-11-10 核验「毛选日历: IdeaBox」的数字 Apple ID 为 `6833003207`。SKU 待核验。
- IAP：2026-11-10 在上述 App 下创建并核验非消耗型永久解锁产品 `Full Access`，Product ID 为 `com.ideaboxapps.maostylecalendar.fullaccess`，IAP 数字 Apple ID 为 `6833003940`。用户确认后台定价已配置。iOS 已接入 StoreKit 2，购买界面读取 Apple 返回的本地化价格，支持购买、恢复购买和 App Store 外部兑换后的权益同步。首个内购尚未送审，后台商品与真机 Sandbox 待联调。Universal Purchase 规划覆盖 iPhone、iPad、Mac，跨平台购买待验证。具体策略见 `docs/product/iap-strategy.md`。
- 后续创建 IAP 后，在本节补充准确 Product ID、数字 Apple ID、所属应用、创建日期及验证状态，并同步代码产品配置。Product ID 不加入年份，不为 Widget 单独创建购买产品。
- 本节集中维护项目公开标识；不再新增独立登记表。区分规划、已创建、已关联、已验证与已发布状态，不保存证书、私钥、Token 或 provisioning 文件。

## 8. 文档与项目记忆

- 仓库按客户端分区：Apple 代码、Xcode 工程和 Swift Package 统一在 `ios-client/`（含 iOS/iPadOS/macOS）；Android 代码统一在 `android-client/`，当前仅预留说明。公共产品、设计与内容资料保留根目录 `docs/`。目录树、模块职责及根目录构建命令统一维护在 `docs/engineering/repository-structure.md`；移动目录时必须同步资源引用和文档。

- 2026-10-29 用户明确取消前端可交互原型；字体按 6.2 最新角色方案执行。v1 程序合成高保真因偏离原稿已被否决，当前唯一视觉入口为 `docs/design/handoff/v2/README.md`。必须忠实保留原稿的构图、字体层级、材质和微细节，不能用简化程序稿或不溢出检查替代视觉还原验收；不要再把前端原型作为建工程前置条件。
- 用户随后明确不再重新生成高保真：归档现有原稿和最新字体规范后进入工程。不要再将生成字体替换版高保真、分层稿或前端原型作为前置；代码中按字体规范和原稿视觉实现。
- 2026-10-30 用户要求先核对和准备定稿对应的实现资源，不急于业务编码。本轮 `docs/design/handoff/v2/resources/` 装饰/图标仅为候选，未接入工程；禁止因 Asset Catalog 编译或尺寸/哈希通过而宣称视觉批准。正式插画不从概念截图或 AI 候选冒充提取；资源状态见 `docs/assets/v2-resource-readiness.md`。
- 项目文档统一归档在 `docs/`。
- 长期决定和当前状态记录在 `docs/project-status.md`。
- 权威来源和语录核验规则记录在 `docs/research/`。
- 产品定位、差异化和 Widget 方案记录在 `docs/product/`。
- 插画接收、处理和授权规则记录在 `docs/assets/`。
- 新决定与旧决定冲突时，不静默覆盖；记录变更原因、日期和影响范围。

## 9. Git 和验收

- 结束任务前必须检查 `git status`，说明新增、修改和异常文件。
- 不提交密钥、Token、证书、模型、签名资产、私钥、构建产物、本地环境文件或未经允许的大文件。
- 每阶段汇报：是否完成、新增文件、修改文件、未修改区域、验证命令、Debug 构建结果、未解决问题和是否建议进入下一阶段。

