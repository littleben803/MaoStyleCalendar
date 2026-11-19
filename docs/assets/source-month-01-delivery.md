# 1 月来源批次制作交付

日期：2026-11-06。状态：**制作与离线验证完成，等待用户整月视觉验收；尚未开始 2 月制作。**

## 本阶段结果

- 全量登记 365 张 PNG：解码通过、稳定 ID 与 SHA-256 基线齐全；交付前再次核对，365 张原件校验值全部未变。
- 1 月 31 套：复用 4 套（pack-0001、0003、0009、0010），新增重绘 27 套；横排 19、竖排 12，通版红纸底 3。
- 每套包含无损母版、优化背景 JPG、语录与逐行／逐列版式、配色、原稿对照、叠字、无日期长屏壁纸及原生局部对照。
- 31 张背景均为 1024×1536、sRGB、渐进 JPG，190,092～199,777 字节，合计 **6,087,909 字节（约 6.09 MB）**；没有超过 200,000 字节的例外。母版另存，未提交 Git。
- 原件底部色条来源共 3 张：第 5 张红条、第 10 张黑条复用有效试制；第 15 张红条新增延展重绘。通版红底保持红纸＋深墨，人物衣服完整，不做躯干擦淡留白。
- 已修订 5 张构图：pack-0013 降低书架、0018 降低读者群、0019 清理顶部竹枝、0020 降低人物、0033 缩短锹柄，避开三行日期区。旧候选保留，metadata 指向 v002；叠字与体积检查均从当前有效 JPG 重新生成。
- 对 pack-0032、0036、0037 调整语录位置／字号，避免覆盖人物；pack-0027 调整竖排步长。原有换行／分列不变，未改 App 模板。

## 查看交付

制作目录：`/Users/ideabox/Desktop/毛选资源制作/batches/source-month-01/`。

- [整月原稿／背景／叠字对照与下载入口](/Users/ideabox/Desktop/毛选资源制作/batches/source-month-01/review/index.html)
- [31 套结构化内容和版式](/Users/ideabox/Desktop/毛选资源制作/batches/source-month-01/metadata/content-packs.json)
- [尺寸、质量、体积和有效文件哈希](/Users/ideabox/Desktop/毛选资源制作/batches/source-month-01/metadata/export-metrics.json)
- [校验报告](/Users/ideabox/Desktop/毛选资源制作/batches/source-month-01/metadata/validation-report.json)
- 优化背景目录：`/Users/ideabox/Desktop/毛选资源制作/app-assets/`，目前仅有本月 31 张。
- 无损母版与每张独立提示词在批次目录下各 pack 子目录；使用内置 ImageGen，未切换 CLI/API。视觉批准母版目录仍空，待用户确认后登记。

以下为整月总览；每幅左上角编号对应稳定内容 ID，按来源文件顺序展示，不是日期。

| 组 | 无字背景 | 日期与语录叠字 |
| --- | --- | --- |
| 1 | [背景 1](/Users/ideabox/Desktop/毛选资源制作/batches/source-month-01/review/background-board-1.jpg) | [叠字 1](/Users/ideabox/Desktop/毛选资源制作/batches/source-month-01/review/overlay-board-1.jpg) |
| 2 | [背景 2](/Users/ideabox/Desktop/毛选资源制作/batches/source-month-01/review/background-board-2.jpg) | [叠字 2](/Users/ideabox/Desktop/毛选资源制作/batches/source-month-01/review/overlay-board-2.jpg) |
| 3 | [背景 3](/Users/ideabox/Desktop/毛选资源制作/batches/source-month-01/review/background-board-3.jpg) | [叠字 3](/Users/ideabox/Desktop/毛选资源制作/batches/source-month-01/review/overlay-board-3.jpg) |
| 4 | [背景 4](/Users/ideabox/Desktop/毛选资源制作/batches/source-month-01/review/background-board-4.jpg) | [叠字 4](/Users/ideabox/Desktop/毛选资源制作/batches/source-month-01/review/overlay-board-4.jpg) |
| 5 | [背景 5](/Users/ideabox/Desktop/毛选资源制作/batches/source-month-01/review/background-board-5.jpg) | [叠字 5](/Users/ideabox/Desktop/毛选资源制作/batches/source-month-01/review/overlay-board-5.jpg) |
| 6 | [背景 6](/Users/ideabox/Desktop/毛选资源制作/batches/source-month-01/review/background-board-6.jpg) | [叠字 6](/Users/ideabox/Desktop/毛选资源制作/batches/source-month-01/review/overlay-board-6.jpg) |

## 验证与限制

运行仓库外 `prepare.py`、`export.py`、`render.swift`、`review.py`、`ocr-backgrounds.swift` 与 `audit.py`；前者整理结构，后续分别检查 JPEG／ICC／解码、文本边界及项目字体渲染、对照文件、文字残留线索和来源哈希。最终背景 OCR 覆盖 31 张，检出文字项为 0；该结果与人工检查结合，不单独作为绝对无字证明。叠字预览采用现有项目字体及月份／年份星期增大两号、三行对齐与农历规则，示例统一为 2026-11-06；示例日期仅在预览脚本，未写入内容日期字段。31 张无日期壁纸为 1320×2868 的离线版式预览，不代表新增实机验证或新的原生细节分辨率。

已检查整月背景与叠字总览，抽看原生衣纹、手部、书本、红纸和桌面压缩对照。所有 31 套均提供完整 100% 局部文件，用户可继续放大检查。人物与场景为允许的重绘／再创作，不承诺扫描原稿逐像素复原。未新增确定的缺字待办；扫描抄录仍须正式底本核验，不能从视觉通过推导权威出处。

新增本交付报告；修改方案、月度清单、docs 索引和项目状态。新增资源、母版、提示词、脚本与登记全部位于仓库外制作目录。App／Widget 源码、现有试制资源、年度分配器、工程配置、签名、版本及 365 张原扫描均未修改。Debug 构建不适用：本阶段为离线资源生产，未做工程接入。

运行 `git diff --check`、`git status --short`。仓库延续整体未跟踪状态（根目录已有 `.gitignore`、AGENTS.md、android-client、design-qa.md、docs、ios-client），未见新生成的大图或构建产物混入仓库。

未解决事项：本月用户视觉确认、正式中文底本和英文对应、语境审校、设计师商业使用授权均待完成。全部内容保持 candidate，不进入正式 Release。建议先确认本月 31 套视觉效果，再开始 2 月；不自动接入正式默认路径。
