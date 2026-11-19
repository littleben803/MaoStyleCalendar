import AppKit
import CryptoKit
let root = URL(fileURLWithPath: #filePath).deletingLastPathComponent().deletingLastPathComponent()
let fm = FileManager.default
func hash(_ url: URL) throws -> String {
    SHA256.hash(data: try Data(contentsOf: url)).map { String(format: "%02x", $0) }.joined()
}
func json(_ object: Any, _ url: URL) throws {
    try JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted,.sortedKeys,.withoutEscapingSlashes]).write(to: url)
}
var imageResults: [[String: Any]] = []
for (name, width, height, transparent) in [
    ("CalendarCopperRingCandidate",24,64,true),
    ("CalendarCopperRingCandidateV2",24,64,true),
    ("CalendarCopperRingCandidateV3",24,64,true),
    ("CalendarPaperIvoryCandidate",256,256,false),
    ("CalendarPrintVermilionCandidate",256,256,false)
] {
    let folder = root.appendingPathComponent("DecorCandidates.xcassets/\(name).imageset")
    let spec = try JSONSerialization.jsonObject(with: Data(contentsOf: folder.appendingPathComponent("Contents.json"))) as! [String: Any]
    let images = spec["images"] as! [[String: String]]
    precondition(images.count == 3)
    for scale in 1...3 {
        let filename = "\(name)@\(scale)x.png"
        precondition(images.contains { $0["filename"] == filename && $0["scale"] == "\(scale)x" })
        let rep = NSBitmapImageRep(data: try Data(contentsOf: folder.appendingPathComponent(filename)))!
        precondition(rep.pixelsWide == width*scale && rep.pixelsHigh == height*scale)
        var clear = 0, opaque = 0, visible = 0
        for y in 0..<rep.pixelsHigh { for x in 0..<rep.pixelsWide {
            let a = rep.colorAt(x: x, y: y)!.alphaComponent
            if a == 0 { clear += 1 }
            if a >= 0.999 { opaque += 1 }
            if a > 8.0/255.0 { visible += 1 }
        }}
        if transparent {
            precondition(rep.hasAlpha && clear > 0 && visible > rep.pixelsWide*rep.pixelsHigh/10)
            precondition(rep.colorAt(x: 0, y: 0)!.alphaComponent == 0)
            precondition(rep.colorAt(x: rep.pixelsWide-1, y: rep.pixelsHigh-1)!.alphaComponent == 0)
        } else { precondition(opaque == rep.pixelsWide*rep.pixelsHigh) }
        imageResults.append(["file": filename, "size": [rep.pixelsWide,rep.pixelsHigh], "clearPixels": clear, "visiblePixels": visible])
    }
}
let vectors = try JSONSerialization.jsonObject(with: Data(contentsOf: root.appendingPathComponent("vector-spec.json"))) as! [String: Any]
let icons = vectors["icons"] as! [[String: String]]
precondition(icons.count == 18)
for icon in icons {
    let name = icon["name"]!
    let folder = root.appendingPathComponent("IconCandidates.xcassets/CalendarIcon-\(name)-Candidate.imageset")
    let pdf = CGPDFDocument(folder.appendingPathComponent("\(name).pdf") as CFURL)!
    precondition(pdf.numberOfPages == 1)
    precondition(pdf.page(at: 1)!.getBoxRect(.mediaBox) == CGRect(x: 0, y: 0, width: 24, height: 24))
    let svg = try String(contentsOf: root.appendingPathComponent("vectors/\(name).svg"), encoding: .utf8)
    precondition(svg.contains(icon["path"]!) && !svg.contains("<text"))
    let contents = try JSONSerialization.jsonObject(with: Data(contentsOf: folder.appendingPathComponent("Contents.json"))) as! [String: Any]
    let properties = contents["properties"] as! [String: Any]
    precondition(properties["preserves-vector-representation"] as? Bool == true)
    precondition(properties["template-rendering-intent"] as? String == "template")
}
// Confirm the already-approved images against the existing parent manifest before updating it.
let parent = root.deletingLastPathComponent()
let manifest = try JSONSerialization.jsonObject(with: Data(contentsOf: parent.appendingPathComponent("manifest.json"))) as! [String: Any]
var originalCount = 0
for entry in manifest["files"] as! [[String: Any]] {
    let path = entry["path"] as! String
    if path.hasPrefix("approved/") || path.hasPrefix("boards/") {
        let actualHash = try hash(parent.appendingPathComponent(path))
        precondition(actualHash == entry["sha256"] as! String)
        originalCount += 1
    }
}
try json(["status": "technical_checks_passed_visual_confirmation_pending", "rasterExports": imageResults,
          "vectorPDFCount": icons.count, "unchangedOriginalAndBoardCount": originalCount,
          "seamlessTilingApproved": false, "pixelPerfectApproved": false, "releaseReady": false,
          "projectIntegrated": true], root.appendingPathComponent("qa-report.json"))
var files: [[String: Any]] = []
for case let url as URL in fm.enumerator(at: root, includingPropertiesForKeys: [.isRegularFileKey], options: [.skipsHiddenFiles])! {
    guard try url.resourceValues(forKeys: [.isRegularFileKey]).isRegularFile == true else { continue }
    let path = String(url.path.dropFirst(root.path.count+1))
    if path == "resource-manifest.json" { continue }
    files.append(["path": path, "bytes": try Data(contentsOf: url).count, "sha256": try hash(url)])
}
try json(["files": files.sorted { ($0["path"] as! String) < ($1["path"] as! String) }], root.appendingPathComponent("resource-manifest.json"))
print("VERIFY PASS: 15 PNG scales, \(icons.count) vector PDFs + SVG sources, \(originalCount) approved images/boards unchanged")
