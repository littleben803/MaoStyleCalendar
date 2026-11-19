// Typography/layout specimens only; no production App or Widget target.
import AppKit
import CoreText
import CoreImage
let cache = CommandLine.arguments[1], out = CommandLine.arguments[2]
let tokens = try JSONSerialization.jsonObject(with: Data(contentsOf:URL(fileURLWithPath:out+"/specs/design-tokens.json"))) as! [String:Any]
let colors = tokens["colors"] as! [String:[String:String]]
func color(_ mode:String,_ name:String)->NSColor {
    let h=UInt32(colors[mode]![name]!.dropFirst(),radix:16)!
    return NSColor(srgbRed:CGFloat((h>>16)&255)/255,green:CGFloat((h>>8)&255)/255,blue:CGFloat(h&255)/255,alpha:1)
}
let artImage = NSImage(contentsOfFile: out + "/assets/mock-only/reader-landscape.png")!
let paperImage = NSImage(contentsOfFile: out + "/assets/decor/paper-ivory@3x.png")!
let ringImage = NSImage(contentsOfFile: out + "/assets/decor/copper-ring@3x.png")!
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
var paper = color("light","paper"), bg = color("light","background"), red = color("light","accent"), ink = color("light","text"), meta = color("light","secondary")
var appearance = "light"
var currentArt = artImage
func theme(_ name: String) {
    appearance = name
    paper=color(name,"paper");bg=color(name,"background");red=color(name,"accent");ink=color(name,"text");meta=color(name,"secondary")
    if name == "light" { currentArt=artImage }
    else {
        let ci = CIImage(data:artImage.tiffRepresentation!)!
        let adjusted = name == "tinted" ? ci.applyingFilter("CIColorMonochrome",parameters:["inputColor":CIColor(red:0.48,green:0.68,blue:0.88),"inputIntensity":1]) : ci.applyingFilter("CIColorControls",parameters:["inputSaturation":0.7,"inputBrightness":-0.06])
        let cg=CIContext().createCGImage(adjusted,from:adjusted.extent)!;currentArt=NSImage(cgImage:cg,size:artImage.size)
    }
}
let quote = "没有调查，没有发言权。"
let en = "No investigation, no right to speak."
let source = "《〈农村调查〉的序言和跋》"
var checks = 0
func rect(_ x: CGFloat, _ y: CGFloat, _ w: CGFloat, _ h: CGFloat) -> CGRect { CGRect(x: x, y: y, width: w, height: h) }
func fill(_ r: CGRect, _ color: NSColor, _ radius: CGFloat = 0) {
    let cg = NSGraphicsContext.current!.cgContext
    cg.saveGState()
    if radius > 0 { cg.setShadow(offset: CGSize(width:0,height:3),blur:8,color:NSColor.black.withAlphaComponent(0.10).cgColor) }
    color.setFill(); let path = NSBezierPath(roundedRect: r, xRadius: radius, yRadius: radius); path.fill()
    cg.restoreGState()
    if appearance == "light" && (color == paper || color == bg) {
        cg.saveGState(); path.addClip(); paperImage.draw(in:r,from:.zero,operation:.sourceOver,fraction:color == paper ? 0.32 : 0.14,respectFlipped:true,hints:nil); cg.restoreGState()
    }
}
func art(_ r: CGRect, _ opacity: CGFloat = 1) {
    let cg = NSGraphicsContext.current!.cgContext; cg.saveGState(); NSBezierPath(roundedRect:r,xRadius:8,yRadius:8).addClip()
    let s=currentArt.size;let factor=max(r.width/s.width,r.height/s.height);let sw=r.width/factor,sh=r.height/factor
    currentArt.draw(in:r,from:CGRect(x:(s.width-sw)*0.70,y:(s.height-sh)*0.25,width:sw,height:sh),operation:.sourceOver,fraction:opacity,respectFlipped:true,hints:nil); cg.restoreGState()
}
func ring(_ r: CGRect) { ringImage.draw(in:r,from:.zero,operation:.sourceOver,fraction:1,respectFlipped:true,hints:nil) }
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
func icon(_ name: String, _ r: CGRect, _ color: NSColor? = nil) {
    let img = NSImage(systemSymbolName: name, accessibilityDescription: nil)!.withSymbolConfiguration(NSImage.SymbolConfiguration(paletteColors:[color ?? red]))!
    img.draw(in: r)
}
func rule(_ y: CGFloat, _ x: CGFloat = 20, _ w: CGFloat = 350) { fill(rect(x, y, w, 0.6), meta.withAlphaComponent(0.3)) }
func header(_ title: String) { t(title, rect(24, 25, 320, 45), 28, 1) }
func tabs(_ active: Int) {
    fill(rect(0, 764, 390, 80), bg); rule(764, 0, 390)
    let labels = ["今日", "年度册", "壁纸", "设置"]
    let symbols = ["calendar", "books.vertical", "photo", "gearshape"]
    for i in 0..<4 { let x = CGFloat(i) * 97.5; icon(symbols[i], rect(x + 35, 777, 26, 26),i == active ? red : meta); t(labels[i], rect(x + 22, 810, 73, 25), 15, 0, i == active ? red : meta) }
}
func button(_ label: String, _ y: CGFloat) { fill(rect(24, y, 342, 56), red, 12); t(label, rect(44, y + 12, 302, 42), 22, 1, .white, 3, .center) }
func dayCard(_ x: CGFloat, _ y: CGFloat, _ n: Int) {
    fill(rect(x, y, 164, 238), paper, 8)
    t(String(format: "%02d", n), rect(x + 12, y + 3, 115, 76), 48, 2, red, 0)
    t("10月 · 星期" + ["一", "二", "三", "四"][n - 26], rect(x + 12, y + 82, 145, 24), 12, 0, meta)
    let samples = ["真理的标准只能是社会的实践。", "没有调查，没有发言权。", "人民，只有人民，才是创造世界历史的动力。", "一切反动派都是纸老虎。"]
    t(samples[n - 26], rect(x + 12, y + 112, 140, 76), 13)
    art(rect(x + 2, y + 160, 160, 76))
}
let pageNames = ["today", "detail", "annual", "wallpaper", "paywall"]
func page(_ name: String) {
    fill(rect(0, 0, 390, 844), bg)
    switch name {
    case "today":
        header("今日")
        fill(rect(28, 105, 334, 637), paper, 10); fill(rect(24, 98, 342, 637), paper, 10)
        fill(rect(20, 91, 350, 637), paper, 12)
        art(rect(22, 399, 346, 327)); ring(rect(182, 70, 26, 63))
        vertical(rect(46, 132, 140, 255))
        t("29", rect(226, 104, 131, 145), 94, 2, red, 0)
        t("2026年10月\n星期四\n农历九月二十", rect(210, 259, 145, 100), 16, 0, meta)
        tabs(0)
    case "detail", "detail-long":
        page("today")
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
        header("壁纸工坊"); fill(rect(42, 91, 306, 468), paper, 16); art(rect(44, 349, 302, 208)); vertical(rect(65, 121, 130, 220), 25)
        let labels = ["留白\n竖排", "留白\n横排", "上文\n下画", "上画\n下文", "左右\n对景", "仅插画"]
        for i in 0..<6 {
            let x = 20 + CGFloat(i) * 59; fill(rect(x, 583, 53, 59), paper, 5)
            if i == 3 { art(rect(x+2,585,49,32)) } else if i == 4 { art(rect(x+2,590,25,45)) } else { art(rect(x+2,i == 5 ? 587 : 612,49,i == 5 ? 50 : 28)) }
            if i < 5 { for row in 0..<3 { let rr = i == 0 ? rect(x+8+CGFloat(row)*5,589,1,16) : (i == 4 ? rect(x+32,591+CGFloat(row)*5,15,1) : rect(x+8,(i == 3 ? 624 : 590)+CGFloat(row)*4,36,1)); fill(rr,meta.withAlphaComponent(0.55)) } }
            if i == 0 { red.setStroke(); let p=NSBezierPath(roundedRect:rect(x,583,53,59),xRadius:5,yRadius:5); p.lineWidth=1.4;p.stroke() }
            t(labels[i], rect(x + 1, 649, 51, 50), 12, 0, i == 0 ? red : meta, 1, .center)
        }
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
for name in pageNames { try render("screens/"+name, 390, 844) { page(name) } }
try render("screens/detail-long", 390, 844) { page("detail-long") }
try render("boards/app-overview", 1170, 1688) {
    let cg = NSGraphicsContext.current!.cgContext
    for (i, name) in pageNames.enumerated() { cg.saveGState(); cg.translateBy(x: CGFloat(i % 3) * 390, y: CGFloat(i / 3) * 844); page(name); cg.restoreGState() }
}
func widget(_ w: CGFloat, _ h: CGFloat, _ english: Bool) {
    fill(rect(0, 0, w, h), paper, 16)
    let small = w < 200, medium = h < 200 && !small, xl = w > 500
    let dateX: CGFloat = small || medium ? 14 : (xl ? w * 0.62 : w - 105)
    if small { art(rect(91,12,w-93,91),0.85) }
    else if medium { art(rect(w*0.54,2,w*0.46-2,h-4)) }
    else if xl { art(rect(2,2,w*0.51,h-4)) }
    else { art(rect(2,h*0.46,w-4,h*0.54-2)) }
    let size: CGFloat = small || medium ? 43 : 62
    t("29", rect(dateX, 5, 100, size * 1.6), size, 2, red, 0)
    if !small && !medium && !xl {
        t(english ? "OCT\nTHURSDAY" : "10月\n星期四\n农历九月二十", rect(dateX,size*1.6+6,w-dateX-12,65),11,english ? 2 : 0,meta)
    } else {
        t(english ? "OCT · THU" : (xl ? "10月 · 星期四\n农历九月二十" : "10月 · 星期四"), rect(dateX, size * 1.6 + 6,small || medium ? w-dateX-12 : w-dateX-16,xl ? 59 : 27),small ? 12 : 14,english ? 2 : 0,meta)
    }
    if small || medium {
        let textWidth: CGFloat = small ? w - 28 : w*0.51-14
        t(english ? en : "没有调查，\n没有发言权。", rect(14, 109, textWidth, h - 115), english ? 13 : 15, english ? 2 : 0)
    } else {
        let x: CGFloat = xl ? w * 0.53 : 16
        t(english ? en : "没有调查，\n没有发言权。", rect(x, xl ? 157 : 20, xl ? w * 0.43 : w - 135, 100), english ? 21 : 23, english ? 2 : 0)
        t(english ? "Preface and Postscript\nto Rural Surveys" : source, rect(x, xl ? 239 : 142, xl ? w * 0.43 : w - 140, 59), english ? 12 : 13, english ? 2 : 0, meta)
    }
}
for english in [false, true] {
    try render(english ? "boards/widgets-en" : "boards/widgets-zh", 1080, 750) {
        t(english ? "B / English / size references" : "B 字体 / 中文 / 尺寸参照", rect(20, 12, 1030, 42), 23, 1)
        let cg = NSGraphicsContext.current!.cgContext
        for (label, x, y, w, h) in [("Small 170×170", 20.0, 95.0, 170.0, 170.0), ("Medium 364×170", 220.0, 95.0, 364.0, 170.0), ("Large 364×382", 20.0, 310.0, 364.0, 382.0), ("XL 640×300", 415.0, 310.0, 640.0, 300.0)] {
            t(label, rect(x, y - 28, w, 26), 13, 2, meta)
            cg.saveGState(); cg.translateBy(x: x, y: y); widget(w, h, english); cg.restoreGState()
        }
        t("B 字体高保真 · 尺寸为设计参照 · 占位画不可发布", rect(20, 715, 1040, 28), 13, 0, meta)
    }
}
let stressEN = "The comrades must be taught to remain modest, prudent and free from arrogance and rashness in their style of work. The comrades must be taught to preserve the style of plain living and hard struggle."
let stressCN = "务必使同志们继续地保持谦虚、谨慎、不骄、不躁的作风，务必使同志们继续地保持艰苦奋斗的作风。"
func fits(_ s: String, _ w: CGFloat, _ h: CGFloat, _ size: CGFloat, _ latin: Bool) -> Bool {
    let p = NSMutableParagraphStyle(); p.lineSpacing = 3
    let b = (s as NSString).boundingRect(with: CGSize(width: w, height: .greatestFiniteMagnitude), options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: [.font: f(size, latin ? 2 : 0), .paragraphStyle: p])
    return b.height <= h
}
try render("boards/long-text-policy", 1080, 750) {
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

let families: [(String,Int,Int)] = [("small",170,170),("medium",364,170),("large",364,382),("extra-large",640,300)]
for mode in ["light","dark","tinted"] {
    theme(mode)
    for english in [false,true] { for (name,w,h) in families {
        try render("widgets/\(name)-\(english ? "en" : "zh")-\(mode)",w,h) { widget(CGFloat(w),CGFloat(h),english) }
    } }
    if mode == "dark" {
        for name in pageNames { try render("screens/\(name)-dark",390,844) { page(name) } }
    }
    try render("boards/widget-family-\(mode)",1080,720) {
        t("Widget / \(mode) / B 字体",rect(20,12,1040,42),24,1)
        let cg=NSGraphicsContext.current!.cgContext
        for (name,x,y,w,h) in [("Small",20.0,85.0,170.0,170.0),("Medium",220.0,85.0,364.0,170.0),("Large",20.0,300.0,364.0,382.0),("Extra Large",415.0,300.0,640.0,300.0)] {
            t(name,rect(x,y-26,w,25),13,2,meta);cg.saveGState();cg.translateBy(x:x,y:y);widget(w,h,false);cg.restoreGState()
        }
        t("静态高保真；系统着色以实际渲染为准；占位插画不可发布",rect(415,642,640,38),13,0,meta)
    }
}
theme("dark")
for (name,w,h) in [("accessory-circular",76,76),("accessory-rectangular",172,76),("accessory-inline",330,30)] {
    try render("widgets/\(name)",w,h) {
        let white=NSColor.white
        if name == "accessory-circular" { t("29",rect(10,0,62,58),35,2,white,0);t("10月",rect(18,56,53,20),11,0,white) }
        else if name == "accessory-inline" { t("10月29日 · 没有调查，没有发言权。",rect(2,2,326,27),13,0,white) }
        else { t("29",rect(4,2,52,58),32,2,white,0);t("没有调查，\n没有发言权。",rect(61,13,108,58),13,0,white) }
    }
}
try render("widgets/standby-night",170,170) {
    fill(rect(0,0,170,170),.black);t("29",rect(16,3,140,104),65,2,red,0);t("10月 · 星期四",rect(16,109,140,25),12,0,red);t(quote,rect(16,140,140,27),11,0,red)
}
try render("widgets/clear-concept",364,170) {
    fill(rect(0,0,364,170),NSColor(srgbRed:0.19,green:0.22,blue:0.24,alpha:1));t("29",rect(18,8,120,100),60,2,.white,0);t("10月 · 星期四",rect(18,115,150,28),13,0,.white);t("没有调查，\n没有发言权。",rect(180,48,165,78),21,0,.white)
}
theme("light")
func wide(_ width: CGFloat,_ height: CGFloat,_ platform: String) {
    fill(rect(0,0,width,height),bg);fill(rect(0,0,180,height),paper)
    t(platform,rect(20,24,155,40),23,1)
    for (i,label) in ["今日","年度册","壁纸","设置"].enumerated() { let y=100+CGFloat(i)*55;if i == 0 { fill(rect(12,y-3,156,43),red.withAlphaComponent(0.08),8) };t(label,rect(24,y,140,35),18,0,i == 0 ? red : meta) }
    t("2026年10月",rect(202,25,220,35),22,1)
    for i in 0..<7 { t("\(23+i)日",rect(205,100+CGFloat(i)*58,95,35),17,0,i == 6 ? red : meta) }
    let x:CGFloat=330,w=width-354
    fill(rect(x,76,w,height-100),paper,16)
    let left=w*0.52;art(rect(x+4,220,left-8,height-262));vertical(rect(x+30,112,140,198),26)
    let tx=x+left+18,tw=w-left-36
    t("29",rect(tx,92,tw,143),90,2,red,0)
    t("2026年10月 · 星期四\n农历九月二十",rect(tx,249,tw,66),16,0,meta)
    t("语录详解",rect(tx,336,tw,45),26,1)
    t(source,rect(tx,397,tw,66),16,0,meta)
    t(quote,rect(tx,479,tw,70),21)
    t("这里是编辑测试说明，供阅读排版比较。正式出处、原文与解读将在内容核验后提供。",rect(tx,579,tw,130),16,0,ink,6)
}
try render("screens/ipad-today",1024,768) { wide(1024,768,"iPad 日历") }
try render("screens/mac-today",1280,800) { wide(1280,800,"Mac 日历") }
let templateNames=["留白竖排","留白横排","上文下画","上画下文","左右对景","仅插画"]
func wallpaperLayout(_ index:Int,_ english:Bool) {
    fill(rect(0,0,390,844),paper)
    switch index {
    case 0:
        art(rect(0,410,390,434));if english { t(en,rect(38,138,180,220),27,2) } else { vertical(rect(38,138,130,230),30) }
    case 1:
        art(rect(0,425,390,419));t(english ? en : "没有调查，\n没有发言权。",rect(45,192,300,160),28,english ? 2 : 0)
    case 2:
        t(english ? en : "没有调查，\n没有发言权。",rect(40,145,310,160),28,english ? 2 : 0);art(rect(0,354,390,490))
    case 3:
        art(rect(0,50,390,505));t(english ? en : "没有调查，\n没有发言权。",rect(42,625,306,160),28,english ? 2 : 0)
    case 4:
        art(rect(0,130,235,620));t(english ? en : "没有调查，\n没有发言权。",rect(248,250,136,350),21,english ? 2 : 0)
    default: art(rect(0,0,390,844))
    }
}
for english in [false,true] { for i in 0..<6 { try render("screens/wallpaper-template-\(i+1)-\(english ? "en" : "zh")",390,844) { wallpaperLayout(i,english) } } }
try render("boards/wallpaper-templates",1170,1688) {
    let cg=NSGraphicsContext.current!.cgContext
    for i in 0..<6 { cg.saveGState();cg.translateBy(x:CGFloat(i%3)*390,y:CGFloat(i/3)*844);wallpaperLayout(i,false);cg.restoreGState() }
}
print("FINAL CHECKS PASS \(checks) placements; all rendered with B fonts")
try JSONSerialization.data(withJSONObject:["textPlacementChecks":checks,"fontFallback":"pass","renderer":"AppKit/CoreText"],options:[.prettyPrinted,.sortedKeys]).write(to:URL(fileURLWithPath:out+"/specs/render-checks.json"))
