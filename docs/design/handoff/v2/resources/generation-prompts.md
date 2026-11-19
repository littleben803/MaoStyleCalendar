# 候选素材生成记录

工具：内置 `image_gen.imagegen`，非 CLI/API 回退；没有配置密钥或安装依赖。日期 2026-10-30。输出复制到本包 `masters/`，原始生成文件仍在 Codex 默认目录保留。

这些素材属于基于展平截图的 AI 辅助重建，**不是从设计师分层文件无损导出的原件**。后续仅做确定性裁边、等比缩小和格式导出。

## 铜环：选用第三次提取候选

输入：`../approved/today.png`；`transparent_background=true`。输出原文件：`exec-6652d622-986d-42d4-9b72-0aafbc9ccbc2.png`，复制为 `masters/copper-ring-candidate.png`。

最终提示词：

> Extract the exact tiny copper binder loop at the very top center of this calendar screenshot as an isolated transparent PNG sprite. Do not redesign it. It is the small vertically oriented copper loop between x400..444 and y158..279 in the 853x1844 reference. Preserve its very narrow tall silhouette, slender metal tube, shading and oblique view. No new shape. Canvas 256x512 with generous transparent padding. All paper, text, page hole and surrounding colors removed; preserve only the visible metal. Outside object is actual transparent alpha, including hole. No glow or haze or surrounding shadow whatsoever. Crisp cutout only. No black rectangle, no orange clouds, no opaque backdrop. This is production asset extraction, not a product beauty render.

工具实际输出为 887×1774，不把提示中的期望画布当实际尺寸；真实像素见 export-report.json。第一次及一次修正产生的两张大铜环有明显光晕和形态偏差，未纳入资源包。最终候选有真实 alpha、无大范围可见光晕，但形态仍需对照原稿，提示要求不等于验收结果。

## 铜环 V2：卡片上沿接缝修订

输入：`masters/copper-ring-candidate.png` 为编辑目标，阶段 2 运行截图为接缝问题参考；`transparent_background=true`。输出原文件：`exec-37ab9322-7c03-4094-8d74-e807fff824c6.png`，非破坏式复制为 `masters/copper-ring-candidate-v2.png`。V1 及其倍率导出保持不变。

最终提示词：

> Use case: precise-object-edit. Asset type: transparent iOS calendar binding-ring UI asset. Image 1 is the edit target and material/shape authority; Image 2 is layout context showing the unwanted gap at the paper top edge. Rebuild the isolated copper half-ring so its upper rear/left clasp leg extends farther downward with a clean flat terminal edge. In the app, that rear clasp leg must overlap and meet the paper card's top edge with no visible gap, creating a believable ring passing over and behind the paper. Preserve the front copper loop's exact overall proportions, narrow vertical orientation, warm copper color, polished highlights, dark inner cavity, thickness, perspective, and realistic metal texture. One isolated vertical copper half-ring centered on a generous transparent canvas; keep the same viewing angle. The rear/left leg should be visibly longer than in Image 1, reaching roughly level with the middle-upper section of the front loop so the paper edge can hide its terminal. Transparent background and clean alpha; change only the upper rear/left clasp geometry; preserve the front loop and lower rounded end; no paper, gray hole, text, border, shadow plate, UI, background, or watermark; do not crop any copper pixels.

工具实际输出为 887×1774；确定性裁边和等比缩小导出为 `CalendarCopperRingCandidateV2` 的 24×64、48×128、72×192 PNG。阶段 2 已在 iPhone 17 Pro 模拟器的今日正面和语录详解背面核对：后侧扣脚覆盖卡片上沿，不再出现空气缝；仍为 Candidate，不代表设计师正式批准。

## 铜环 V3：扣脚压边幅度收敛

输入：`masters/copper-ring-candidate-v2.png` 为编辑目标，用户标注的运行截图为越界问题参考；`transparent_background=true`。输出原文件：`exec-860f6071-aedc-43ea-8e3c-c3a003b66bc7.png`，非破坏式复制为 `masters/copper-ring-candidate-v3.png`。V1、V2 及其倍率导出保持不变。

最终提示词：

> Use case: precise-object-edit. Asset type: transparent iOS calendar binding-ring UI asset. Edit only the isolated copper ring in Image 1. Shorten only the upper rear/left clasp leg by about one third compared with V2, placing its flat terminal between the original V1 and the too-long V2 endpoint. At runtime the paper top edge should cover only about 2–3 points of this rear leg: enough to remove the air gap, but without the dark copper block visibly extending deep into the paper. Preserve the front loop, lower rounded end, exact narrow vertical proportions, material, highlights, inner cavity, thickness, perspective, centered placement, generous transparent padding and clean alpha. No paper, gray hole, text, border, UI, shadow plate, background or watermark. Do not crop any copper pixels.

工具实际输出为 887×1774；确定性裁边和等比缩小导出为 `CalendarCopperRingCandidateV3` 的 24×64、48×128、72×192 PNG。运行布局将铜环与穿孔整体下移 2 pt，使短扣脚仅轻微压住卡片上沿。该资源仍为 Candidate，不代表设计师正式批准。

## 米白纸纹

输入：`../approved/wallpaper.png`；`transparent_background=false`。输出：`exec-b0b7a73b-eda1-40ff-a061-fe27bf0c2dfd.png` → `masters/paper-ivory-candidate.png`。

最终提示词：

> Use case: precise-object-edit. Asset type: seamless square ivory paper material tile for calendar UI. Use the approved wallpaper reference ONLY as material reference. Produce a flat evenly lit close-up of its warm ivory mulberry/xuan paper texture, particularly blank paper in upper center of the card. Same delicate pale interlaced short paper fibers, faint honey/peach fibers sparingly scattered, organic fine crinkling, extremely subtle low contrast, off-white warm cream base approximately #F7F0E3. No directional lighting, vignette, edge, bevel, shadow, crease or gradient. NO writing, numbers, illustration, people, ring, border, card silhouette, UI, icons, watermark. The square must tile seamlessly on all edges without a repetitive large motif. Full bleed opaque texture only, 1024 square. Do not design a new style or dirty/yellow parchment. Preserve the approved fine bright paper aesthetic.

## 朱红印刷纹理

输入：`../approved/wallpaper.png`；`transparent_background=false`。输出：`exec-565c853f-7771-440e-a35b-67e8cbd55963.png` → `masters/print-vermilion-candidate.png`。

最终提示词：

> Use case: precise-object-edit. Asset type: seamless red print/paper tile for the approved primary CTA and large date ink. Reference is approved wallpaper screen; reproduce only the subtle fibrous/cellular red paper material inside the bottom red export button. Warm rich vermilion base approximately #BE1715, tiny slightly lighter and darker interlaced fiber/cellular wrinkles as seen in that button, understated printed-paper texture, uniform flat illumination. Make a full-bleed seamless 1024 square opaque texture. Remove all text, arrow, rounded rectangle, borders, bevels, highlights, drop shadows, icons, human figures, illustrations and UI. No gold, embossing, fabric, leather, geometric wallpaper pattern, large folds or new ornament. Match original red saturation and restrained low contrast; texture should remain quiet beneath white text. No words, watermark, numbers.

两张实际输出为 1254×1254，重复铺排检查未达到无缝要求，不能按提示里的 seamless 宣称验收通过。当前只登记为局部填充候选。

## 图标

18 个图标直接制作成 SVG 路径，并导出同源 PDF Template。没有使用图像生成工具绘制图标，也没有下载第三方图标包。来源、画布与线宽见 vector-spec.json；全部是项目候选，不是对原稿逐像素追踪的最终图标。
