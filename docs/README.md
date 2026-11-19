# MaoStyleCalendar 文档索引

本目录保存产品、内容考据、设计和资源处理的长期项目文档。

## SwiftUI 实现交接入口

[已确认原稿视觉基准 v2](design/handoff/v2/README.md)：用户原稿、直接拼合总览与偏差复核；最新字体为思源宋体三字重 + Source Serif 4 SemiBold 英文语录 + Libre Bodoni Bold 大日期。v1 已被否决，前端原型取消。

用户最新决定：不再重新生成高保真。按现有原稿和最新字体规范开始 SwiftUI 工程；[工程启动与共享核心层](engineering/native-startup.md)记录当前实现和本机工具链核验。

## 当前文档

- [`assets/full-year-artwork-integration.md`](assets/full-year-artwork-integration.md)：全年 365 套候选清洗归档、App／Widget 共用年度分配及一次普通 iPhone 实机验收。此记录覆盖旧“暂缓 2 月／仅 31 套”推进限制。

- [`assets/widget-artwork-integration.md`](assets/widget-artwork-integration.md)：31 套素材接入 Widget、整卡背景叠字与横条三分之二插画、Debug 逐图预览及验收边界。

- [`assets/scan-cleanup-production-plan.md`](assets/scan-cleanup-production-plan.md)：已确认的扫描清洗／重绘、内容绑定、排版、压缩和交付规范。
- [`assets/yearbook-wallpaper-integration.md`](assets/yearbook-wallpaper-integration.md)：现有 31 套复用于全年年度册、双模式壁纸及安全留白／导出验证，待统一验收。
- [`assets/january-engineering-integration.md`](assets/january-engineering-integration.md)：1 月 31 套接入常规今日页、新卡片版式、资源目录和构建验证，待用户统一视觉确认。
- [`assets/source-month-01-delivery.md`](assets/source-month-01-delivery.md)：1 月 31 套候选的背景、叠字、壁纸、结构数据与离线验证结果，待用户整月确认。
- [`assets/scan-cleanup-monthly-checklist.md`](assets/scan-cleanup-monthly-checklist.md)：按原扫描月份推进的 12 批清单；365 张中复用 10 张试制，预计另制作 355 张；清单已确认，启动登记完成，1 月批次制作已交付，待用户验收。
- [`assets/ten-image-trial-integration.md`](assets/ten-image-trial-integration.md)：10 张试制、真机证据、日期优化及用户确认记录。
- [`engineering/repository-structure.md`](engineering/repository-structure.md)：最新树形工程结构、Apple/Android 目录边界、模块职责及构建命令。
- [`assets/v2-resource-readiness.md`](assets/v2-resource-readiness.md)：最终原稿对应的切图就绪审计、候选资源包、原生效果与正式插画缺件。
- [`project-status.md`](project-status.md)：当前阶段、已确认决定和待解决事项。
- [`research/quote-source-policy.md`](research/quote-source-policy.md)：中英文语录来源等级、核验流程和记录字段。
- [`research/source-register.md`](research/source-register.md)：已确认底本、数字副本、校验值和版本风险。
- [`research/quote-register.schema.json`](research/quote-register.schema.json)：365 条语录结构化记录的字段与状态约束。
- [`research/sample-verification-001.md`](research/sample-verification-001.md)：首批 10 条端到端核验样本与附件问题。
- [`product/differentiation-principles.md`](product/differentiation-principles.md)：产品定位与竞品差异化原则。
- [`product/content-experience-brief.md`](product/content-experience-brief.md)：365 套内容包、小册子和壁纸的产品边界。
- [`product/app-information-architecture.md`](product/app-information-architecture.md)：App 页面结构、导航、关键交互和多端页面形态。
- [`product/widget-information-architecture.md`](product/widget-information-architecture.md)：各 Widget Family 的内容层级、交互与平台支持。
- [`product/platform-adaptation.md`](product/platform-adaptation.md)：iPhone、iPhone Duo、iPad 和 Mac 的共享代码与自适应策略。
- [`product/mvp-scope.md`](product/mvp-scope.md)：V1 必做、可降级、不做事项和验收标准。
- [`product/content-allocation.md`](product/content-allocation.md)：跨年份确定性洗牌、闰日内容和稳定引用规则。
- [`product/iap-strategy.md`](product/iap-strategy.md)：永久解锁、免费边界、付费触点和审核要求。
- [`assets/artwork-intake.md`](assets/artwork-intake.md)：原创扫描件接收、授权和非破坏性处理规则。
- [`design/today-card-interaction.md`](design/today-card-interaction.md)：今日卡片正反面、换日手势、固定 Header 和正文滚动规则。
- [`design/typography.md`](design/typography.md)：内置字体角色、授权门禁、动态字号和多 target 打包要求。
- [`design/font-study/README.md`](design/font-study/README.md)：真实字体 A/B/C 对照、许可快照、版本及可重现渲染。
- [`research/font-matching/README.md`](research/font-matching/README.md)：针对原稿中文、英文和大数字的再次匹配研究、真实字体对照及最终确认记录。
- [`design/layout-study/README.md`](design/layout-study/README.md)：B 字体六屏排版、中英文 Widget、长正文及长句降级样张。
- [`design/core-screen-specifications.md`](design/core-screen-specifications.md)：年度册、设置、壁纸、四 Tab 和通用付费墙规范。

## 计划中的文档

- `research/quote-register.json`：产品提供 365 条清单后建立的正式逐条登记库。
- `design/widget-layouts.md`：Small 至 Extra Large 的正式视觉规格。

