// Assemble reference boards without redrawing any UI or altering individual originals.
import AppKit
import CryptoKit
let root=URL(fileURLWithPath:CommandLine.arguments[1]),fm=FileManager.default
if !CommandLine.arguments.contains("--manifest-only") {
let names=["today","detail","annual","wallpaper","paywall"]
let rep=NSBitmapImageRep(bitmapDataPlanes:nil,pixelsWide:2340,pixelsHigh:3376,bitsPerSample:8,samplesPerPixel:4,hasAlpha:true,isPlanar:false,colorSpaceName:.deviceRGB,bytesPerRow:0,bitsPerPixel:0)!
let context=NSGraphicsContext(bitmapImageRep:rep)!,cg=context.cgContext
NSGraphicsContext.saveGraphicsState();cg.translateBy(x:0,y:3376);cg.scaleBy(x:1,y:-1);NSGraphicsContext.current=NSGraphicsContext(cgContext:cg,flipped:true)
for (i,name) in names.enumerated() {
    let image=NSImage(contentsOf:root.appendingPathComponent("approved/"+name+".png"))!
    let cell=CGRect(x:(i%3)*780,y:(i/3)*1688,width:780,height:1688)
    let scale=min(cell.width/image.size.width,cell.height/image.size.height)
    let s=CGSize(width:image.size.width*scale,height:image.size.height*scale)
    image.draw(in:CGRect(x:cell.midX-s.width/2,y:cell.midY-s.height/2,width:s.width,height:s.height),from:.zero,operation:.sourceOver,fraction:1,respectFlipped:true,hints:nil)
}
NSGraphicsContext.restoreGraphicsState()
try rep.representation(using:.png,properties:[:])!.write(to:root.appendingPathComponent("boards/app-approved-originals.png"))
for locale in ["zh","en"] {
    let data=try Data(contentsOf:root.appendingPathComponent("approved/widgets-"+locale+".png"))
    try data.write(to:root.appendingPathComponent("boards/widgets-"+locale+".png"))
}
}
var entries:[[String:Any]]=[]
for case let url as URL in fm.enumerator(at:root,includingPropertiesForKeys:[.isRegularFileKey],options:[.skipsHiddenFiles])! {
    guard try url.resourceValues(forKeys:[.isRegularFileKey]).isRegularFile == true else {continue}
    let path=String(url.path.dropFirst(root.path.count+1));if path == "manifest.json" {continue}
    let data=try Data(contentsOf:url)
    var e:[String:Any]=["path":path,"bytes":data.count,"sha256":SHA256.hash(data:data).map{String(format:"%02x",$0)}.joined()]
    if url.pathExtension == "png" {let r=NSBitmapImageRep(data:data)!;e["width"]=r.pixelsWide;e["height"]=r.pixelsHigh}
    entries.append(e)
}
let m:[String:Any]=["status":"approved-original-visual-baseline; not reconstructed editable UI","files":entries.sorted{($0["path"] as! String)<($1["path"] as! String)}]
try JSONSerialization.data(withJSONObject:m,options:[.prettyPrinted,.sortedKeys,.withoutEscapingSlashes]).write(to:root.appendingPathComponent("manifest.json"))
print("ARCHIVE PASS \(entries.count) files; originals retained unchanged; boards are assembly only")
