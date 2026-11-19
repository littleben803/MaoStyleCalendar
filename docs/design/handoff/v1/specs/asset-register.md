# 资源与切图登记

| 资源 | 逻辑尺寸/倍率 | 交付位置 | 用途与状态 |
|---|---|---|---|
| CalendarPaper | 256×256 pt，1×/2×/3× | Decor.xcassets / assets/decor | AI 辅助纸纹候选，轻量叠加在程序绘制的底色上；不保证无缝平铺 |
| CalendarCopperRing | 24×58 pt，1×/2×/3×，Alpha | Decor.xcassets / assets/decor | AI 辅助铜环候选，独立透明切图；最终稿以 26×63 pt 小幅缩放展示 |
| Calendar-background/paper/accent/text/secondary | 动态浅/深 sRGB | Theme.xcassets | SwiftUI 命名色，值与 design-tokens.json 一致 |
| 思源宋体 SC Regular | 原始 OTF 2.003 | fonts/ | 中文正文、竖排、元数据；OFL 许可见 licenses |
| 思源宋体 SC SemiBold | 原始 OTF 2.003 | fonts/ | 中文标题；OFL 许可见 licenses |
| Literata | 原始变量 TTF 3.103 | fonts/ | 英文和大日期，wght=400；OFL 许可见 licenses |
| reader-landscape | 1536×1024 px，Alpha | assets/mock-only/ | 由旧概念稿衍生的占位画，只用于设计展示，不可随 App 发布 |
| 高保真稿 PNG | 逻辑参照尺寸的 2× | screens/widgets/boards | 还原与比对依据，不是运行时页面切图 |
| 素材生成母版及旧稿 | 原尺寸 | sources/ | 生成/追溯依据，不导入 App |

所有文件的字节数、尺寸和 SHA-256 以 manifest.json 为准。PNG 含 Alpha 通道不等于所有像素都有透明度：铜环必须有透明外部与孔洞；纸纹可为不透明底纹；占位画是否适合具体构图仍由视觉检查判断。

## 仍需设计师交付

- 365 套插画的独立母版或可分层资源、正式语录与对应出处清单。
- 闰日专属内容，或后续经产品明确调整的闰日规则。
- 插画作者和授权信息、裁切焦点、安全区、必要时的暗底适配版本。

这些不因本包提供占位画而视为已交付。本阶段没有批量去除设计师扫描稿背景，没有改变任何设计师原件。

## Alpha 与导出

铜环源图由图像生成工具输出透明背景，脚本只根据 Alpha 边界修剪并按比例导出各倍率，不用颜色阈值去白。纸纹按原始平方构图缩放。人物占位画按原图比例保留；不同布局的展示裁切发生在排版层，不覆盖母版。

截图文字、日期、按钮、卡片形状和阴影不需要切图：SwiftUI 原生绘制。动态日期、语言、着色适配不能烘焙进背景 PNG。
