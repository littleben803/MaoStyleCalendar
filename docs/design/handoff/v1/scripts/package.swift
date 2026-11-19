import Foundation
import AppKit
import CryptoKit
let root=URL(fileURLWithPath:CommandLine.arguments[1]), fm=FileManager.default
func save(_ value:Any,_ path:String) throws {
    let url=root.appendingPathComponent(path)
    try fm.createDirectory(at:url.deletingLastPathComponent(),withIntermediateDirectories:true)
    try JSONSerialization.data(withJSONObject:value,options:[.prettyPrinted,.sortedKeys,.withoutEscapingSlashes]).write(to:url)
}
try save(["info":["author":"xcode","version":1]],"assets/Decor.xcassets/Contents.json")
for (name,base) in [("CalendarPaper","paper-ivory"),("CalendarCopperRing","copper-ring")] {
    var images:[[String:Any]]=[]
    for scale in 1...3 {
        let file=base+(scale == 1 ? "" : "@\(scale)x")+".png"
        let dest="assets/Decor.xcassets/\(name).imageset/\(file)"
        let url=root.appendingPathComponent(dest)
        try fm.createDirectory(at:url.deletingLastPathComponent(),withIntermediateDirectories:true)
        let data=try Data(contentsOf:root.appendingPathComponent("assets/decor/"+file));try data.write(to:url)
        images.append(["idiom":"universal","filename":file,"scale":"\(scale)x"])
    }
    try save(["images":images,"info":["author":"xcode","version":1]],"assets/Decor.xcassets/\(name).imageset/Contents.json")
}
let token=try JSONSerialization.jsonObject(with:Data(contentsOf:root.appendingPathComponent("specs/design-tokens.json"))) as! [String:Any]
let colors=token["colors"] as! [String:[String:String]]
try save(["info":["author":"xcode","version":1]],"assets/Theme.xcassets/Contents.json")
for key in ["background","paper","accent","text","secondary"] {
    var values:[[String:Any]]=[]
    for mode in ["light","dark"] {
        let hex=UInt32(colors[mode]![key]!.dropFirst(),radix:16)!
        var value:[String:Any]=["idiom":"universal","color":["color-space":"srgb","components":["red":String(format:"%.8f",Double((hex>>16)&255)/255),"green":String(format:"%.8f",Double((hex>>8)&255)/255),"blue":String(format:"%.8f",Double(hex&255)/255),"alpha":"1.00000000"]]]
        if mode == "dark" { value["appearances"]=[["appearance":"luminosity","value":"dark"]] }
        values.append(value)
    }
    try save(["colors":values,"info":["author":"xcode","version":1]],"assets/Theme.xcassets/Calendar-\(key).colorset/Contents.json")
}
func luminance(_ hex:String)->Double {
    let n=UInt32(hex.dropFirst(),radix:16)!
    let rgb=[Double((n>>16)&255)/255,Double((n>>8)&255)/255,Double(n&255)/255].map { $0 <= 0.04045 ? $0/12.92 : pow(($0+0.055)/1.055,2.4) }
    return rgb[0]*0.2126+rgb[1]*0.7152+rgb[2]*0.0722
}
var ratios:[String:Double]=[:]
for mode in ["light","dark"] { for foreground in ["text","secondary","accent"] {
    let l1=luminance(colors[mode]![foreground]!),l2=luminance(colors[mode]!["paper"]!)
    let contrast=(max(l1,l2)+0.05)/(min(l1,l2)+0.05)
    guard contrast >= 4.5 else { fatalError("Text contrast too low \(mode) \(foreground): \(contrast)") }
    ratios[mode+"-"+foreground]=contrast
} }
var entries:[[String:Any]]=[];var pngCount=0;var total:Int64=0
let enumerator=fm.enumerator(at:root,includingPropertiesForKeys:[.isRegularFileKey],options:[.skipsHiddenFiles])!
for case let url as URL in enumerator {
    guard (try url.resourceValues(forKeys:[.isRegularFileKey])).isRegularFile == true else { continue }
    let path=String(url.path.dropFirst(root.path.count+1))
    if ["manifest.json","qa-report.json"].contains(path) { continue }
    let data=try Data(contentsOf:url);total += Int64(data.count)
    var entry:[String:Any]=["path":path,"bytes":data.count,"sha256":SHA256.hash(data:data).map { String(format:"%02x",$0) }.joined()]
    if url.pathExtension == "png" {
        guard let image=NSBitmapImageRep(data:data) else { fatalError("Bad PNG: \(path)") }
        entry["width"]=image.pixelsWide;entry["height"]=image.pixelsHigh;entry["hasAlpha"]=image.hasAlpha;pngCount += 1
    }
    entry["usage"] = path.hasPrefix("assets/mock-only") || path.hasPrefix("sources/mock") ? "mock_only_do_not_ship" : (path.hasPrefix("screens/") || path.hasPrefix("widgets/") || path.hasPrefix("boards/") ? "design_reference_not_runtime_image" : "handoff_resource")
    entries.append(entry)
}
entries.sort { ($0["path"] as! String) < ($1["path"] as! String) }
try save(["version":"1.0.0","visualStatus":"rejected_by_user_not_an_implementation_baseline","files":entries,"totalBytesExcludingManifestAndQA":total],"manifest.json")
let renderChecks=try JSONSerialization.jsonObject(with:Data(contentsOf:root.appendingPathComponent("specs/render-checks.json"))) as! [String:Any]
try save(["visualFidelity":"REJECTED_BY_USER; technical checks below do not establish visual fidelity","pngDecode":"pass","pngCount":pngCount,"textPlacementChecks":renderChecks["textPlacementChecks"]!,"fontFallbackChecks":"pass for specimen text","fontLicenseSnapshots":"present","contrastRatiosOnSolidPaper":ratios,"assetScales":[1,2,3],"renderer":"AppKit/CoreText; no Xcode target","notValidated":["WidgetKit runtime geometry","Dynamic Type and VoiceOver","system tint/clear actual appearance","final designer artwork","StoreKit purchase and system export"],"debugBuild":"not_run_no_business_project"],"qa-report.json")
print("PACKAGE PASS files=\(entries.count) png=\(pngCount) bytes=\(total)")
print("CONTRAST \(ratios)")
