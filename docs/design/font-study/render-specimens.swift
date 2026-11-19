// Design-only AppKit/CoreText renderer. No App target or global font installation.
import AppKit
import CoreText

let cache = CommandLine.arguments[1]
let output = CommandLine.arguments[2]
let files = ["SourceHanSerifSC-Regular.otf", "SourceHanSerifSC-SemiBold.otf", "LXGWWenKai-Regular.ttf", "Literata.ttf"]
var loaded: [String] = []
for file in files {
    let url = URL(fileURLWithPath: cache).appendingPathComponent(file)
    var error: Unmanaged<CFError>?
    guard CTFontManagerRegisterFontsForURL(url as CFURL, .process, &error) else { fatalError("Font registration failed: \(file) \(String(describing: error))") }
    let descriptors = CTFontManagerCreateFontDescriptorsFromURL(url as CFURL) as! [CTFontDescriptor]
    let ct = CTFontCreateWithFontDescriptor(descriptors[0], 20, nil)
    let name = CTFontCopyPostScriptName(ct) as String
    loaded.append(name)
    print("FONT \(file): \(name), version \(CTFontCopyName(ct, kCTFontVersionNameKey) ?? "unknown" as CFString)")
}
func font(_ index: Int, _ size: CGFloat) -> NSFont {
    if index == 3 {
        let attrs: [CFString: Any] = [kCTFontNameAttribute: loaded[index], kCTFontVariationAttribute: [NSNumber(value: 2003265652): 400, NSNumber(value: 1869640570): min(72, max(14, size))]]
        let descriptor = CTFontDescriptorCreateWithAttributes(attrs as CFDictionary)
        return CTFontCreateWithFontDescriptor(descriptor, size, nil) as NSFont
    }
    guard let f = NSFont(name: loaded[index], size: size) else { fatalError("No font: \(loaded[index])") }
    return f
}
let red = NSColor(srgbRed: 0.65, green: 0.12, blue: 0.10, alpha: 1)
let ink = NSColor(srgbRed: 0.16, green: 0.13, blue: 0.11, alpha: 1)
let muted = NSColor(srgbRed: 0.43, green: 0.37, blue: 0.31, alpha: 1)
let paper = NSColor(srgbRed: 0.97, green: 0.94, blue: 0.88, alpha: 1)
let body = "这段文字用于比较正文的屏幕阅读效果，不属于毛泽东原文或权威解读。请观察横竖笔画的粗细、标点间距与连续阅读时的舒适程度。正文需要清楚、耐读，并与标题保持适当层次。"
let english = "No investigation, no right to speak."
let testCN = "语录详解出处原文片段年月日星期四农历九月二十没有调查没有发言权《〈农村调查〉的序言和跋》，。；：！？设置永久解锁"
print("LITERATA VARIATIONS \(CTFontCopyVariation(font(3, 22) as CTFont)!)")
print("LITERATA AXES \(CTFontCopyVariationAxes(font(3, 22) as CTFont)!)")
for i in 0..<4 {
    let ct = font(i, 20) as CTFont
    if let table = CTFontCopyTable(ct, CTFontTableTag(0x4F532F32), []) as Data?, table.count >= 10 {
        let fsType = Int(table[8]) * 256 + Int(table[9])
        print("EMBEDDING \(loaded[i]) fsType=\(fsType)")
    }
    let chars = Array((english + "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz.,;:!?").utf16)
    var glyphs = [CGGlyph](repeating: 0, count: chars.count)
    guard CTFontGetGlyphsForCharacters(ct, chars, &glyphs, chars.count) else { fatalError("Missing Latin glyph") }
}
for i in [0, 1, 2] {
    let ct = font(i, 20) as CTFont
    let chars = Array((testCN + body).utf16)
    var glyphs = [CGGlyph](repeating: 0, count: chars.count)
    let ok = CTFontGetGlyphsForCharacters(ct, chars, &glyphs, chars.count)
    guard ok else { fatalError("Missing glyph in \(loaded[i])") }
    print("GLYPHS PASS \(loaded[i]) \(chars.count) UTF16 units")
}
struct Choice { let code: String; let title: String; let cn: Int; let heading: Int; let latin: Int }
let choices = [
    Choice(code: "A", title: "思源宋体 · 统一出版感", cn: 0, heading: 1, latin: 0),
    Choice(code: "B", title: "思源宋体 + Literata", cn: 0, heading: 1, latin: 3),
    Choice(code: "C", title: "霞鹜文楷 + Literata", cn: 2, heading: 2, latin: 3)
]
func text(_ s: String, _ rect: CGRect, _ f: NSFont, _ color: NSColor = ink, _ line: CGFloat = 4) {
    let p = NSMutableParagraphStyle(); p.lineSpacing = line; p.lineBreakMode = .byWordWrapping
    let attrs: [NSAttributedString.Key: Any] = [.font: f, .foregroundColor: color, .paragraphStyle: p]
    let height = (s as NSString).boundingRect(with: rect.size, options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: attrs).height
    if height > rect.height + 1 { fatalError("Text overflow: \(s.prefix(24)), \(height) > \(rect.height)") }
    (s as NSString).draw(with: rect, options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: attrs)
}
func box(_ r: CGRect, _ color: NSColor) { color.setFill(); NSBezierPath(roundedRect: r, xRadius: 14, yRadius: 14).fill() }
func vertical(_ s: String, _ r: CGRect, _ f: NSFont) {
    let a = NSAttributedString(string: s, attributes: [.font: f, .foregroundColor: ink, .verticalGlyphForm: true])
    let fs = CTFramesetterCreateWithAttributedString(a)
    let path = CGPath(rect: CGRect(origin: .zero, size: r.size), transform: nil)
    let frame = CTFramesetterCreateFrame(fs, CFRange(location: 0, length: 0), path, [kCTFrameProgressionAttributeName: CTFrameProgression.rightToLeft.rawValue] as CFDictionary)
    guard CTFrameGetVisibleStringRange(frame).length == a.length else { fatalError("Vertical overflow") }
    let cg = NSGraphicsContext.current!.cgContext
    cg.saveGState(); cg.translateBy(x: r.minX, y: r.maxY); cg.scaleBy(x: 1, y: -1); cg.textMatrix = .identity
    CTFrameDraw(frame, cg); cg.restoreGState()
}
func column(_ c: Choice) {
    text(c.code + "  " + c.title, CGRect(x: 24, y: 18, width: 432, height: 40), font(c.heading, 24))
    text("真实字库 / 同文本、同字号 / 无插画干扰", CGRect(x: 24, y: 60, width: 432, height: 26), font(c.cn, 13), muted)
    box(CGRect(x: 24, y: 104, width: 432, height: 246), paper)
    vertical("没有调查，\n没有发言权。", CGRect(x: 52, y: 128, width: 132, height: 194), font(c.cn, 27))
    text("29", CGRect(x: 246, y: 104, width: 190, height: 162), font(c.latin, 108), red, 0)
    text("2026年10月 · 星期四\n农历九月二十", CGRect(x: 225, y: 250, width: 215, height: 65), font(c.cn, 16), muted)
    text("语录详解", CGRect(x: 24, y: 374, width: 432, height: 46), font(c.heading, 28))
    text("出处 · 原文片段", CGRect(x: 24, y: 426, width: 432, height: 30), font(c.heading, 18), red)
    text("《〈农村调查〉的序言和跋》", CGRect(x: 24, y: 460, width: 432, height: 30), font(c.cn, 17), muted)
    text(body, CGRect(x: 24, y: 504, width: 432, height: 145), font(c.cn, 17), ink, 6)
    box(CGRect(x: 24, y: 674, width: 432, height: 138), paper)
    text("English / Numerals", CGRect(x: 42, y: 688, width: 396, height: 24), font(c.latin, 15), muted)
    text(english, CGRect(x: 42, y: 722, width: 396, height: 48), font(c.latin, 22))
    text("0123456789 · 2026 · 2027", CGRect(x: 42, y: 774, width: 396, height: 28), font(c.latin, 18), red)
    box(CGRect(x: 24, y: 838, width: 432, height: 128), ink)
    text("语录详解 · 深色正文", CGRect(x: 42, y: 852, width: 396, height: 32), font(c.heading, 21), paper)
    text("没有调查，没有发言权。", CGRect(x: 42, y: 889, width: 396, height: 30), font(c.cn, 17), paper)
    text(english, CGRect(x: 42, y: 928, width: 396, height: 30), font(c.latin, 17), paper)
    text("中文 17 / 标题 28 / 竖排 27 / 数字 108", CGRect(x: 24, y: 990, width: 432, height: 26), font(c.cn, 13), muted)
    text("CoreText / AppKit 实绘 · 非 Widget 系统截图", CGRect(x: 24, y: 1022, width: 432, height: 26), font(c.cn, 12), muted)
}
func render(_ name: String, _ list: [Choice]) throws {
    let w = list.count * 480, h = 1080, scale = 2
    let rep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: w * scale, pixelsHigh: h * scale, bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
    let ctx = NSGraphicsContext(bitmapImageRep: rep)!
    NSGraphicsContext.saveGraphicsState(); NSGraphicsContext.current = ctx
    let cg = ctx.cgContext; cg.scaleBy(x: CGFloat(scale), y: CGFloat(scale)); cg.translateBy(x: 0, y: CGFloat(h)); cg.scaleBy(x: 1, y: -1)
    NSGraphicsContext.current = NSGraphicsContext(cgContext: cg, flipped: true)
    NSColor(srgbRed: 0.995, green: 0.985, blue: 0.96, alpha: 1).setFill(); CGRect(x: 0, y: 0, width: w, height: h).fill()
    for (i, c) in list.enumerated() { cg.saveGState(); cg.translateBy(x: CGFloat(i * 480), y: 0); column(c); cg.restoreGState() }
    NSGraphicsContext.restoreGraphicsState()
    try rep.representation(using: .png, properties: [:])!.write(to: URL(fileURLWithPath: output).appendingPathComponent(name + ".png"))
    print("RENDER PASS \(name) \(w * scale)x\(h * scale)")
}
try render("comparison", choices)
for c in choices { try render("specimen-" + c.code, [c]) }

// Typography contexts: fixed comparison widths, not device/widget screenshots.
func contexts(_ c: Choice) throws {
    let rep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: 2400, pixelsHigh: 1800, bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
    let ctx = NSGraphicsContext(bitmapImageRep: rep)!
    NSGraphicsContext.saveGraphicsState(); let cg = ctx.cgContext
    cg.scaleBy(x: 2, y: 2); cg.translateBy(x: 0, y: 900); cg.scaleBy(x: 1, y: -1)
    NSGraphicsContext.current = NSGraphicsContext(cgContext: cg, flipped: true)
    NSColor(srgbRed: 0.995, green: 0.985, blue: 0.96, alpha: 1).setFill(); CGRect(x: 0, y: 0, width: 1200, height: 900).fill()
    text(c.code + "  " + c.title, CGRect(x: 24, y: 18, width: 1140, height: 40), font(c.heading, 28))
    text("排版参照宽度；不是设备或 Widget 系统截图", CGRect(x: 24, y: 64, width: 1140, height: 30), font(c.cn, 15), muted)
    box(CGRect(x: 24, y: 120, width: 390, height: 692), paper)
    text("iPhone · 390 pt 参照", CGRect(x: 44, y: 138, width: 350, height: 30), font(c.cn, 15), muted)
    text("语录详解", CGRect(x: 44, y: 194, width: 350, height: 50), font(c.heading, 28))
    text("2026年10月29日 · 星期四", CGRect(x: 44, y: 251, width: 350, height: 30), font(c.cn, 15), muted)
    text("出处", CGRect(x: 44, y: 310, width: 350, height: 34), font(c.heading, 20), red)
    text("《〈农村调查〉的序言和跋》", CGRect(x: 44, y: 354, width: 350, height: 60), font(c.cn, 17))
    text(body, CGRect(x: 44, y: 425, width: 350, height: 200), font(c.cn, 17), ink, 7)
    text(english, CGRect(x: 44, y: 655, width: 350, height: 110), font(c.latin, 22))
    box(CGRect(x: 450, y: 120, width: 720, height: 300), paper)
    text("Extra Large · 720 pt 排版参照", CGRect(x: 472, y: 138, width: 676, height: 30), font(c.cn, 15), muted)
    vertical("没有调查，\n没有发言权。", CGRect(x: 480, y: 190, width: 170, height: 200), font(c.cn, 28))
    text("29", CGRect(x: 720, y: 180, width: 220, height: 150), font(c.latin, 96), red, 0)
    text("2026年10月 · 星期四", CGRect(x: 720, y: 334, width: 425, height: 35), font(c.cn, 18), muted)
    box(CGRect(x: 450, y: 450, width: 720, height: 362), paper)
    text("Mac · 720 pt 正文栏参照", CGRect(x: 472, y: 468, width: 676, height: 30), font(c.cn, 15), muted)
    text("语录详解", CGRect(x: 480, y: 514, width: 650, height: 50), font(c.heading, 30))
    text(body, CGRect(x: 480, y: 580, width: 650, height: 150), font(c.cn, 18), ink, 8)
    text(english, CGRect(x: 480, y: 740, width: 650, height: 50), font(c.latin, 24))
    text("真实字库 · 同字号比较 · 竖排使用 CoreText 字形与标点 · 插画未纳入本轮", CGRect(x: 24, y: 846, width: 1140, height: 34), font(c.cn, 15), muted)
    NSGraphicsContext.restoreGraphicsState()
    try rep.representation(using: .png, properties: [:])!.write(to: URL(fileURLWithPath: output).appendingPathComponent("contexts-" + c.code + ".png"))
    print("RENDER PASS contexts-\(c.code) 2400x1800")
}
for c in choices { try contexts(c) }
