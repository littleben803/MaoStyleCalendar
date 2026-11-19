// Typography/layout specimens only; no production App or Widget target.
import AppKit
import CoreText
let cache = CommandLine.arguments[1], out = CommandLine.arguments[2]
let names = ["SourceHanSerifSC-Regular", "SourceHanSerifSC-SemiBold", "Literata-Regular_ExtraLight"]
for file in ["SourceHanSerifSC-Regular.otf", "SourceHanSerifSC-SemiBold.otf", "Literata.ttf"] {
    guard CTFontManagerRegisterFontsForURL(URL(fileURLWithPath: cache + "/" + file) as CFURL, .process, nil) else { fatalError("Cannot load \(file)") }
}
func f(_ size: CGFloat, _ role: Int = 0) -> NSFont {
    if role == 2 {
        let d = CTFontDescriptorCreateWithAttributes([kCTFontNameAttribute: names[2], kCTFontVariationAttribute: [2003265652: 400, 1869640570: max(7, min(72, size))]] as CFDictionary)
        return CTFontCreateWithFontDescriptor(d, size, nil) as NSFont
    }
    guard let font = NSFont(name: names[role], size: size) else { fatalError("Font unavailable") }
    return font
}
let paper = NSColor(srgbRed: 0.97, green: 0.945, blue: 0.90, alpha: 1)
let bg = NSColor(srgbRed: 0.995, green: 0.985, blue: 0.96, alpha: 1)
let red = NSColor(srgbRed: 0.65, green: 0.12, blue: 0.10, alpha: 1)
let ink = NSColor(srgbRed: 0.15, green: 0.13, blue: 0.11, alpha: 1)
let meta = NSColor(srgbRed: 0.43, green: 0.38, blue: 0.33, alpha: 1)
let quote = "没有调查，没有发言权。"
let en = "No investigation, no right to speak."
let source = "《〈农村调查〉的序言和跋》"
var checks = 0
func rect(_ x: CGFloat, _ y: CGFloat, _ w: CGFloat, _ h: CGFloat) -> CGRect { CGRect(x: x, y: y, width: w, height: h) }
func fill(_ r: CGRect, _ color: NSColor, _ radius: CGFloat = 0) { color.setFill(); NSBezierPath(roundedRect: r, xRadius: radius, yRadius: radius).fill() }
func t(_ s: String, _ r: CGRect, _ size: CGFloat, _ role: Int = 0, _ color: NSColor = ink, _ spacing: CGFloat = 3, _ alignment: NSTextAlignment = .left) {
    let p = NSMutableParagraphStyle(); p.lineSpacing = spacing; p.lineBreakMode = .byWordWrapping; p.alignment = alignment
    let font = f(size, role)
    let a: [NSAttributedString.Key: Any] = [.font: font, .foregroundColor: color, .paragraphStyle: p]
    let bounds = (s as NSString).boundingRect(with: r.size, options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: a)
    guard bounds.height <= r.height + 0.5, bounds.width <= r.width + 0.5 else { fatalError("OVERFLOW \(s.prefix(25)): \(bounds.size) in \(r.size)") }
    let attr = NSAttributedString(string: s, attributes: a)
    let line = CTLineCreateWithAttributedString(attr)
    for run in CTLineGetGlyphRuns(line) as! [CTRun] {
        let actual = (CTRunGetAttributes(run) as NSDictionary)[kCTFontAttributeName] as! CTFont
        guard CTFontCopyFamilyName(actual) == CTFontCopyFamilyName(font as CTFont) else { fatalError("Unexpected fallback: \(s.prefix(20))") }
    }
    checks += 1
    (s as NSString).draw(with: r, options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: a)
}
func vertical(_ r: CGRect, _ size: CGFloat = 27) {
    let a = NSAttributedString(string: "没有调查，\n没有发言权。", attributes: [.font: f(size), .foregroundColor: ink, .verticalGlyphForm: true])
    let frame = CTFramesetterCreateFrame(CTFramesetterCreateWithAttributedString(a), CFRange(location: 0, length: 0), CGPath(rect: CGRect(origin: .zero, size: r.size), transform: nil), [kCTFrameProgressionAttributeName: CTFrameProgression.rightToLeft.rawValue] as CFDictionary)
    guard CTFrameGetVisibleStringRange(frame).length == a.length else { fatalError("Vertical overflow") }
    let cg = NSGraphicsContext.current!.cgContext
    cg.saveGState(); cg.translateBy(x: r.minX, y: r.maxY); cg.scaleBy(x: 1, y: -1); cg.textMatrix = .identity; CTFrameDraw(frame, cg); cg.restoreGState(); checks += 1
}
func icon(_ name: String, _ r: CGRect) {
    let img = NSImage(systemSymbolName: name, accessibilityDescription: nil)!
    img.draw(in: r)
}
func rule(_ y: CGFloat, _ x: CGFloat = 20, _ w: CGFloat = 350) { fill(rect(x, y, w, 0.6), meta.withAlphaComponent(0.3)) }
func header(_ title: String) { t(title, rect(24, 25, 320, 45), 28, 1) }
func tabs(_ active: Int) {
    fill(rect(0, 764, 390, 80), bg); rule(764, 0, 390)
    let labels = ["今日", "年度册", "壁纸", "设置"]
    let symbols = ["calendar", "books.vertical", "photo", "gearshape"]
    for i in 0..<4 { let x = CGFloat(i) * 97.5; icon(symbols[i], rect(x + 35, 777, 26, 26)); t(labels[i], rect(x + 22, 810, 73, 25), 15, 0, i == active ? red : meta) }
}
func button(_ label: String, _ y: CGFloat) { fill(rect(24, y, 342, 56), red, 12); t(label, rect(44, y + 12, 302, 42), 22, 1, .white, 3, .center) }
func dayCard(_ x: CGFloat, _ y: CGFloat, _ n: Int) {
    fill(rect(x, y, 164, 238), paper, 8)
    t(String(format: "%02d", n), rect(x + 12, y + 3, 115, 76), 48, 2, red, 0)
    t("10月 · 星期" + ["一", "二", "三", "四"][n - 26], rect(x + 12, y + 82, 145, 24), 12, 0, meta)
    let samples = ["真理的标准只能是社会的实践。", "没有调查，没有发言权。", "人民，只有人民，才是创造世界历史的动力。", "一切反动派都是纸老虎。"]
    t(samples[n - 26], rect(x + 12, y + 119, 140, 96), 14)
}
let pageNames = ["today", "detail", "annual", "wallpaper", "paywall"]
func page(_ name: String) {
    fill(rect(0, 0, 390, 844), bg)
    switch name {
    case "today":
        header("今日")
        fill(rect(20, 91, 350, 637), paper, 12)
        vertical(rect(46, 132, 140, 255))
        t("29", rect(226, 104, 131, 145), 94, 2, red, 0)
        t("2026年10月\n星期四\n农历九月二十", rect(210, 259, 145, 100), 16, 0, meta)
        tabs(0)
    case "detail", "detail-long":
        fill(rect(0, 0, 390, 844), ink.withAlphaComponent(0.12)); fill(rect(20, 91, 350, 637), paper, 12)
        t("语录详解", rect(40, 114, 232, 43), 26, 1)
        t("2026年10月29日 · 星期四", rect(40, 166, 280, 28), 14, 0, meta)
        icon("xmark", rect(326, 122, 16, 16)); rule(209, 40, 310)
        t("出处", rect(40, 231, 300, 32), 18, 1, red)
        t(source, rect(40, 272, 310, 61), 17)
        t("本页文字", rect(40, 346, 300, 32), 18, 1, red)
        t(quote, rect(40, 389, 310, 55), 20)
        t("排版说明", rect(40, 461, 300, 32), 18, 1, red)
        let sample = "此处为编辑测试文字，用于检查正文宽度与行距，不是历史解读。标题和日期保持固定，下面正文按内容高度自然滚动。"
        if name == "detail-long" {
            let cg = NSGraphicsContext.current!.cgContext
            cg.saveGState(); cg.clip(to: rect(40, 507, 310, 197))
            t(Array(repeating: sample, count: 6).joined(separator: "\n\n"), rect(40, 507, 310, 1500), 17, 0, ink, 7)
            cg.restoreGState()
        } else { t(sample, rect(40, 507, 310, 178), 17, 0, ink, 7) }
    case "annual":
        header("年度册")
        t("2026年     9月   10月   11月", rect(24, 91, 340, 34), 18, 1, red)
        for i in 0..<4 { dayCard(CGFloat(i % 2) * 180 + 24, CGFloat(i / 2) * 258 + 151, i + 26) }
        tabs(1)
    case "wallpaper":
        header("壁纸工坊"); fill(rect(42, 91, 306, 468), paper, 16); vertical(rect(65, 121, 130, 240), 25)
        let labels = ["留白\n竖排", "留白\n横排", "上文\n下画", "上画\n下文", "左右\n对景", "仅插画"]
        for i in 0..<6 { let x = 20 + CGFloat(i) * 59; fill(rect(x, 591, 53, 47), paper, 5); t(labels[i], rect(x + 3, 646, 50, 50), 12, 0, i == 0 ? red : meta, 1) }
        button("导出高清壁纸", 701); tabs(2)
    default:
        icon("xmark", rect(344, 22, 18, 18)); t("解锁完整日历", rect(28, 70, 340, 55), 29, 1)
        t("一次买断，永久使用", rect(28, 139, 340, 35), 18, 0, meta)
        let benefits = ["全年日历随时翻阅", "全部桌面与锁屏组件", "语录出处、详解与英文内容", "全部壁纸排版与高清导出"]
        for (i, value) in benefits.enumerated() { let y = 213 + CGFloat(i) * 57; icon("checkmark", rect(28, y + 3, 18, 18)); t(value, rect(60, y, 306, 41), 18) }
        fill(rect(20, 462, 350, 245), paper, 12)
        t("完整功能永久解锁", rect(40, 482, 310, 34), 20, 1)
        t("价格待定", rect(40, 530, 310, 50), 29, 1)
        t("一次付费 · 永久使用", rect(40, 588, 310, 30), 16, 0, meta)
        button("永久解锁", 633)
        t("恢复购买", rect(146, 735, 150, 29), 16, 0, meta)
        t("今日页与基础小组件可免费使用", rect(56, 780, 310, 27), 13, 0, meta)
        t("服务条款 · 隐私政策", rect(118, 814, 250, 25), 12, 0, meta)
    }
}
func render(_ name: String, _ w: Int, _ h: Int, _ draw: () -> Void) throws {
    let rep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: w * 2, pixelsHigh: h * 2, bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
    let context = NSGraphicsContext(bitmapImageRep: rep)!, cg = context.cgContext
    NSGraphicsContext.saveGraphicsState(); cg.scaleBy(x: 2, y: 2); cg.translateBy(x: 0, y: CGFloat(h)); cg.scaleBy(x: 1, y: -1)
    NSGraphicsContext.current = NSGraphicsContext(cgContext: cg, flipped: true); fill(rect(0, 0, CGFloat(w), CGFloat(h)), bg); draw(); NSGraphicsContext.restoreGraphicsState()
    try rep.representation(using: .png, properties: [:])!.write(to: URL(fileURLWithPath: out + "/" + name + ".png")); print("RENDER \(name) \(w*2)x\(h*2)")
}
for name in pageNames { try render(name, 390, 844) { page(name) } }
try render("detail-long", 390, 844) { page("detail-long") }
try render("app-overview", 1170, 1688) {
    let cg = NSGraphicsContext.current!.cgContext
    for (i, name) in pageNames.enumerated() { cg.saveGState(); cg.translateBy(x: CGFloat(i % 3) * 390, y: CGFloat(i / 3) * 844); page(name); cg.restoreGState() }
}
func widget(_ w: CGFloat, _ h: CGFloat, _ english: Bool) {
    fill(rect(0, 0, w, h), paper, 16)
    let small = w < 200, medium = h < 200 && !small, xl = w > 500
    let dateX: CGFloat = small || medium ? 14 : (xl ? w * 0.62 : w - 105)
    let size: CGFloat = small || medium ? 43 : 62
    t("29", rect(dateX, 5, 100, size * 1.6), size, 2, red, 0)
    t(english ? "OCT · THU" : "10月 · 星期四", rect(dateX, size * 1.6 + 6, small || medium ? 150 : 175, 27), small ? 12 : 14, english ? 2 : 0, meta)
    if small || medium {
        let textWidth: CGFloat = small ? w - 28 : 185
        t(english ? en : "没有调查，\n没有发言权。", rect(14, 109, textWidth, h - 115), english ? 13 : 15, english ? 2 : 0)
    } else {
        let x: CGFloat = xl ? w * 0.53 : 16
        t(english ? en : "没有调查，\n没有发言权。", rect(x, xl ? 157 : 20, xl ? w * 0.43 : w - 135, 100), english ? 21 : 23, english ? 2 : 0)
        t(english ? "Preface and Postscript\nto Rural Surveys" : source, rect(x, xl ? 259 : 142, xl ? w * 0.43 : w - 32, 65), english ? 12 : 13, english ? 2 : 0, meta)
    }
}
for english in [false, true] {
    try render(english ? "widgets-en" : "widgets-zh", 1080, 750) {
        t(english ? "B / English / size references" : "B 字体 / 中文 / 尺寸参照", rect(20, 12, 1030, 42), 23, 1)
        let cg = NSGraphicsContext.current!.cgContext
        for (label, x, y, w, h) in [("Small 170×170", 20.0, 95.0, 170.0, 170.0), ("Medium 364×170", 220.0, 95.0, 364.0, 170.0), ("Large 364×382", 20.0, 310.0, 364.0, 382.0), ("XL 640×300", 415.0, 310.0, 640.0, 300.0)] {
            t(label, rect(x, y - 28, w, 26), 13, 2, meta)
            cg.saveGState(); cg.translateBy(x: x, y: y); widget(w, h, english); cg.restoreGState()
        }
        t("排版参照，非 WidgetKit 截图；插画区域暂留白，待设计师交付。", rect(20, 715, 1040, 28), 13, 0, meta)
    }
}
let stressEN = "The comrades must be taught to remain modest, prudent and free from arrogance and rashness in their style of work. The comrades must be taught to preserve the style of plain living and hard struggle."
let stressCN = "务必使同志们继续地保持谦虚、谨慎、不骄、不躁的作风，务必使同志们继续地保持艰苦奋斗的作风。"
func fits(_ s: String, _ w: CGFloat, _ h: CGFloat, _ size: CGFloat, _ latin: Bool) -> Bool {
    let p = NSMutableParagraphStyle(); p.lineSpacing = 3
    let b = (s as NSString).boundingRect(with: CGSize(width: w, height: .greatestFiniteMagnitude), options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: [.font: f(size, latin ? 2 : 0), .paragraphStyle: p])
    return b.height <= h
}
try render("long-text-policy", 1080, 750) {
    t("长句排版 / 无审定短版时的降级样张", rect(20, 12, 1030, 42), 23, 1)
    for (idx, english) in [false, true].enumerated() {
        let y = CGFloat(idx) * 330 + 95
        let value = english ? stressEN : stressCN
        for (x, w, name) in [(20.0, 170.0, "Small"), (220.0, 364.0, "Medium"), (620.0, 430.0, "XL text zone")] {
            let r = rect(x + 14, y + 109, w - 28, 170)
            let available: CGFloat = name == "XL text zone" ? 170 : 55
            let size: CGFloat = english ? 14 : 16
            let canFit = fits(value, r.width, available, size, english)
            t(name + (canFit ? " / full quote" : " / date + art"), rect(x, y - 27, w, 25), 12, 2, meta)
            fill(rect(x, y, w, 280), paper, 12)
            t("29", rect(x + 14, y + 5, 100, 82), 48, 2, red, 0)
            if canFit { t(value, r, size, english ? 2 : 0) }
            print("LONG TEXT \(english ? "EN" : "ZH") \(name): \(canFit ? "fits" : "expected fallback without approved short text")")
        }
    }
    t("降级样张不代表语录缺失：无可用短摘编时保留日期与插画，完整语录进入 App 阅读。插画此轮暂留白。", rect(20, 713, 1040, 33), 12, 0, meta)
}
print("CHECKS PASS \(checks) measured text/vertical placements; no fallback fonts")
