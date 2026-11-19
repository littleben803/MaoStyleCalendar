// Export project-authored vector paths as universal PDF assets and a design review sheet.
import AppKit
let root = URL(fileURLWithPath: #filePath).deletingLastPathComponent().deletingLastPathComponent()
let spec = try JSONSerialization.jsonObject(with: Data(contentsOf: root.appendingPathComponent("vector-spec.json"))) as! [String: Any]
let icons = spec["icons"] as! [[String: String]]
let fm = FileManager.default
let catalog = root.appendingPathComponent("IconCandidates.xcassets")
try fm.createDirectory(at: catalog, withIntermediateDirectories: true)
func json(_ value: Any, _ url: URL) throws {
    try JSONSerialization.data(withJSONObject: value, options: [.prettyPrinted,.sortedKeys]).write(to: url)
}
let info: [String: Any] = ["version": 1, "author": "MaoStyleCalendar design handoff"]
try json(["info": info], catalog.appendingPathComponent("Contents.json"))
func path(_ string: String) -> CGPath {
    let tokens = string.split(separator: " ").map(String.init)
    var i = 0
    let p = CGMutablePath()
    func number() -> CGFloat { defer { i += 1 }; return CGFloat(Double(tokens[i])!) }
    while i < tokens.count {
        let command = tokens[i]; i += 1
        switch command {
        case "M": p.move(to: CGPoint(x: number(), y: number()))
        case "L": p.addLine(to: CGPoint(x: number(), y: number()))
        case "C":
            let a = CGPoint(x: number(), y: number()), b = CGPoint(x: number(), y: number()), e = CGPoint(x: number(), y: number())
            p.addCurve(to: e, control1: a, control2: b)
        case "Z": p.closeSubpath()
        default: fatalError("Unsupported vector command")
        }
    }
    return p
}
func draw(_ p: CGPath, _ c: CGContext, _ color: CGColor) {
    c.addPath(p); c.setLineWidth(1.5); c.setLineCap(.round); c.setLineJoin(.round)
    c.setStrokeColor(color); c.strokePath()
}
let preview = CGContext(data: nil, width: 1320, height: 1120, bitsPerComponent: 8, bytesPerRow: 1320*4,
                        space: CGColorSpace(name: CGColorSpace.sRGB)!, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
preview.translateBy(x: 0, y: 1120); preview.scaleBy(x: 1, y: -1)
preview.setFillColor(CGColor(red: 0.98, green: 0.96, blue: 0.92, alpha: 1)); preview.fill(CGRect(x: 0, y: 0, width: 1320, height: 1120))
NSGraphicsContext.saveGraphicsState(); NSGraphicsContext.current = NSGraphicsContext(cgContext: preview, flipped: true)
("v2 icon candidates / template PDF + editable SVG / no text baked in" as NSString).draw(at: CGPoint(x: 28, y: 24), withAttributes: [.font: NSFont.systemFont(ofSize: 27), .foregroundColor: NSColor.black])
for (i, icon) in icons.enumerated() {
    let p = path(icon["path"]!), name = icon["name"]!
    let folder = catalog.appendingPathComponent("CalendarIcon-\(name)-Candidate.imageset")
    try fm.createDirectory(at: folder, withIntermediateDirectories: true)
    let file = "\(name).pdf"
    var box = CGRect(x: 0, y: 0, width: 24, height: 24)
    let pdf = CGContext(folder.appendingPathComponent(file) as CFURL, mediaBox: &box, nil)!
    pdf.beginPDFPage(nil); pdf.translateBy(x: 0, y: 24); pdf.scaleBy(x: 1, y: -1)
    draw(p, pdf, CGColor(gray: 0, alpha: 1)); pdf.endPDFPage(); pdf.closePDF()
    try json(["info": info, "images": [["idiom": "universal", "filename": file]],
              "properties": ["preserves-vector-representation": true, "template-rendering-intent": "template"]], folder.appendingPathComponent("Contents.json"))
    let x = CGFloat(28+(i%6)*216), y = CGFloat(110+(i/6)*240)
    preview.saveGState(); preview.translateBy(x: x+45, y: y); preview.scaleBy(x: 3, y: 3)
    draw(p, preview, CGColor(red: 0.70, green: 0.08, blue: 0.07, alpha: 1)); preview.restoreGState()
    (name as NSString).draw(at: CGPoint(x: x, y: y+100), withAttributes: [.font: NSFont.systemFont(ofSize: 18), .foregroundColor: NSColor.black])
    preview.saveGState(); preview.translateBy(x: x+63, y: y+140)
    draw(p, preview, CGColor(red: 0.44, green: 0.32, blue: 0.23, alpha: 1)); preview.restoreGState()
}
NSGraphicsContext.restoreGraphicsState()
let rep = NSBitmapImageRep(cgImage: preview.makeImage()!)
try rep.representation(using: .png, properties: [:])!.write(to: root.appendingPathComponent("previews/icon-check.png"))
print("EXPORT PASS: \(icons.count) template PDF image sets + editable SVG sources")
