// Design-resource preparation only. Does not edit the Xcode project or application.
// Run from repository root: swift docs/design/handoff/v2/resources/scripts/export.swift
import AppKit
import CryptoKit

let fm = FileManager.default
let root = URL(fileURLWithPath: #filePath).deletingLastPathComponent().deletingLastPathComponent()
let catalog = root.appendingPathComponent("DecorCandidates.xcassets")
try fm.createDirectory(at: catalog, withIntermediateDirectories: true)
func json(_ value: Any, _ url: URL) throws {
    try JSONSerialization.data(withJSONObject: value, options: [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]).write(to: url)
}
let info: [String: Any] = ["author": "MaoStyleCalendar design handoff", "version": 1]
try json(["info": info], catalog.appendingPathComponent("Contents.json"))

func load(_ url: URL) throws -> NSBitmapImageRep {
    guard let rep = NSBitmapImageRep(data: try Data(contentsOf: url)) else { fatalError("Invalid bitmap: \(url)") }
    return rep
}
func context(_ w: Int, _ h: Int) -> CGContext {
    CGContext(data: nil, width: w, height: h, bitsPerComponent: 8, bytesPerRow: w * 4,
              space: CGColorSpace(name: CGColorSpace.sRGB)!, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
}
func save(_ image: CGImage, _ url: URL) throws {
    try NSBitmapImageRep(cgImage: image).representation(using: .png, properties: [:])!.write(to: url)
}

struct Asset {
    let name: String
    let master: String
    let width: Int
    let height: Int
    let transparent: Bool
}
let assets = [
    Asset(name: "CalendarCopperRingCandidate", master: "copper-ring-candidate.png", width: 24, height: 64, transparent: true),
    Asset(name: "CalendarCopperRingCandidateV2", master: "copper-ring-candidate-v2.png", width: 24, height: 64, transparent: true),
    Asset(name: "CalendarCopperRingCandidateV3", master: "copper-ring-candidate-v3.png", width: 24, height: 64, transparent: true),
    Asset(name: "CalendarPaperIvoryCandidate", master: "paper-ivory-candidate.png", width: 256, height: 256, transparent: false),
    Asset(name: "CalendarPrintVermilionCandidate", master: "print-vermilion-candidate.png", width: 256, height: 256, transparent: false)
]
var rows: [[String: Any]] = []
for asset in assets {
    let source = root.appendingPathComponent("masters/\(asset.master)")
    let rep = try load(source)
    var image = rep.cgImage!
    var alphaBounds: [Int] = []
    if asset.transparent {
        var minX = rep.pixelsWide, minY = rep.pixelsHigh, maxX = 0, maxY = 0
        for y in 0..<rep.pixelsHigh { for x in 0..<rep.pixelsWide {
            // Ignore near-invisible generator specks when choosing the crop rectangle.
            // The master and retained pixels are unchanged; this is a rectangular crop only.
            if rep.colorAt(x: x, y: y)!.alphaComponent > 8.0 / 255.0 {
                minX = min(minX, x); minY = min(minY, y); maxX = max(maxX, x); maxY = max(maxY, y)
            }
        }}
        guard maxX > minX, maxY > minY else { fatalError("Empty alpha") }
        alphaBounds = [minX, minY, maxX - minX + 1, maxY - minY + 1]
        image = image.cropping(to: CGRect(x: minX, y: minY, width: maxX-minX+1, height: maxY-minY+1))!
    }
    let folder = catalog.appendingPathComponent("\(asset.name).imageset")
    try fm.createDirectory(at: folder, withIntermediateDirectories: true)
    var entries: [[String: String]] = []
    for scale in 1...3 {
        let w = asset.width * scale, h = asset.height * scale
        let c = context(w, h)
        c.interpolationQuality = .high
        if !asset.transparent {
            c.setFillColor(CGColor(red: 1, green: 1, blue: 1, alpha: 1)); c.fill(CGRect(x: 0, y: 0, width: w, height: h))
        }
        // Pixel-exact trimming and downsampling only: no repainting or generated alpha repair.
        let inset = asset.transparent ? CGFloat(2 * scale) : 0
        let ratio = min((CGFloat(w)-2*inset)/CGFloat(image.width), (CGFloat(h)-2*inset)/CGFloat(image.height))
        let size = CGSize(width: CGFloat(image.width)*ratio, height: CGFloat(image.height)*ratio)
        c.draw(image, in: CGRect(x: (CGFloat(w)-size.width)/2, y: (CGFloat(h)-size.height)/2, width: size.width, height: size.height))
        let filename = "\(asset.name)@\(scale)x.png"
        try save(c.makeImage()!, folder.appendingPathComponent(filename))
        entries.append(["filename": filename, "idiom": "universal", "scale": "\(scale)x"])
    }
    try json(["images": entries, "info": info], folder.appendingPathComponent("Contents.json"))
    rows.append(["name": asset.name, "master": "masters/\(asset.master)", "logicalSize": [asset.width,asset.height],
                 "masterSize": [rep.pixelsWide,rep.pixelsHigh], "alphaBounds": alphaBounds,
                 "status": "candidate_requires_visual_confirmation", "releaseReady": false])
}
try json(["status": "candidate_integrated_app_only", "assets": rows], root.appendingPathComponent("export-report.json"))

// Resource inspection sheet, not a replacement high-fidelity screen.
let c = context(1440, 1120)
c.translateBy(x: 0, y: 1120); c.scaleBy(x: 1, y: -1)
c.setFillColor(CGColor(red: 0.94, green: 0.92, blue: 0.88, alpha: 1)); c.fill(CGRect(x: 0, y: 0, width: 1440, height: 1120))
NSGraphicsContext.saveGraphicsState()
NSGraphicsContext.current = NSGraphicsContext(cgContext: c, flipped: true)
func label(_ text: String, _ x: CGFloat, _ y: CGFloat, size: CGFloat = 22) {
    (text as NSString).draw(at: CGPoint(x: x, y: y), withAttributes: [.font: NSFont.systemFont(ofSize: size), .foregroundColor: NSColor.black])
}
func draw(_ path: String, _ rect: CGRect) {
    let image = NSImage(contentsOf: root.appendingPathComponent(path))!
    image.draw(in: rect, from: .zero, operation: .sourceOver, fraction: 1, respectFlipped: true, hints: nil)
}
label("v2 resource inspection / CANDIDATES / not a new screen design", 36, 24, size: 28)
label("Copper: cream / charcoal / checkerboard (same RGBA)", 36, 80)
let ring = "DecorCandidates.xcassets/CalendarCopperRingCandidateV3.imageset/CalendarCopperRingCandidateV3@3x.png"
for i in 0..<3 {
    let x = CGFloat(36+i*220), y: CGFloat = 122
    c.setFillColor(i == 1 ? CGColor(gray: 0.14, alpha: 1) : CGColor(red: 0.98, green: 0.96, blue: 0.91, alpha: 1))
    c.fill(CGRect(x: x, y: y, width: 200, height: 260))
    if i == 2 { for row in 0..<13 { for col in 0..<10 where (row+col)%2 == 0 {
        c.setFillColor(CGColor(gray: 0.78, alpha: 1)); c.fill(CGRect(x: x+CGFloat(col*20), y: y+CGFloat(row*20), width: 20, height: 20))
    }}}
    draw(ring, CGRect(x: x+76, y: y+62, width: 48, height: 128))
}
label("Actual-size ring (24 x 64 pt)", 750, 125)
draw(ring, CGRect(x: 805, y: 180, width: 24, height: 64))
label("No shadow / no paper baked into sprite", 750, 280, size: 18)
label("Ivory tile: 2 x 2 seam test", 36, 420)
label("Vermilion tile: 2 x 2 seam test", 740, 420)
for (index,name) in ["CalendarPaperIvoryCandidate","CalendarPrintVermilionCandidate"].enumerated() {
    let x: CGFloat = index == 0 ? 36 : 740
    let path = "DecorCandidates.xcassets/\(name).imageset/\(name)@2x.png"
    for row in 0..<2 { for col in 0..<2 {
        draw(path, CGRect(x: x+CGFloat(col*256), y: 468+CGFloat(row*256), width: 256, height: 256))
    }}
}
label("Visual direction follows approved references; final matching and runtime checks remain.", 36, 1030, size: 21)
NSGraphicsContext.restoreGraphicsState()
try fm.createDirectory(at: root.appendingPathComponent("previews"), withIntermediateDirectories: true)
try save(c.makeImage()!, root.appendingPathComponent("previews/material-check.png"))
print("EXPORT PASS: 5 candidate image sets, 15 PNG scales, resource inspection sheet")
