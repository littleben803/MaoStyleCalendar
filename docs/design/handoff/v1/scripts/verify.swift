import Foundation
import AppKit
import CryptoKit
let root=URL(fileURLWithPath:CommandLine.arguments[1])
let manifest=try JSONSerialization.jsonObject(with:Data(contentsOf:root.appendingPathComponent("manifest.json"))) as! [String:Any]
let files=manifest["files"] as! [[String:Any]]
for entry in files {
    let path=entry["path"] as! String
    let data=try Data(contentsOf:root.appendingPathComponent(path))
    guard data.count == entry["bytes"] as! Int else { fatalError("SIZE \(path)") }
    let hash=SHA256.hash(data:data).map { String(format:"%02x",$0) }.joined()
    guard hash == entry["sha256"] as! String else { fatalError("HASH \(path)") }
    if let width=entry["width"] as? Int {
        let image=NSBitmapImageRep(data:data)!
        guard image.pixelsWide == width, image.pixelsHigh == entry["height"] as! Int else { fatalError("IMAGE SIZE \(path)") }
    }
    if path.hasSuffix(".imageset/Contents.json") {
        let object=try JSONSerialization.jsonObject(with:data) as! [String:Any]
        for image in object["images"] as! [[String:Any]] {
            let url=root.appendingPathComponent(path).deletingLastPathComponent().appendingPathComponent(image["filename"] as! String)
            guard FileManager.default.fileExists(atPath:url.path) else { fatalError("CATALOG REFERENCE \(path)") }
        }
    }
}
let expected=["SourceHanSerifSC-Regular.otf":"78aa7a328fd974df2d688c8a9fd74a33d8334dfa84ab24d9d11efb2ffc464117","SourceHanSerifSC-SemiBold.otf":"faf16caeaf207e1926e01af8d9f1a8e71b0e9d8f51bf3b5d9a78f9f30e7e3e31","Literata.ttf":"b41138c9373112f32abb589cc22e8674b06ed4048b0c513be922bdd26f274440"]
for (file,hash) in expected {
    let data=try Data(contentsOf:root.appendingPathComponent("fonts/"+file))
    guard SHA256.hash(data:data).map({String(format:"%02x",$0)}).joined() == hash else { fatalError("FONT HASH \(file)") }
}
print("VERIFY PASS \(files.count) files, all hashes/dimensions/catalog references; pinned fonts unchanged")
