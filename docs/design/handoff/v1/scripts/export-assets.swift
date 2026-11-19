import AppKit
import CoreGraphics
let root = CommandLine.arguments[1]
func load(_ path: String) -> CGImage { let i = NSImage(contentsOfFile: root + path)!; return i.cgImage(forProposedRect: nil, context: nil, hints: nil)! }
let ring = load("/sources/copper-ring-master.png")
let c = CGContext(data: nil, width: ring.width, height: ring.height, bitsPerComponent: 8, bytesPerRow: ring.width * 4, space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
c.draw(ring, in: CGRect(x: 0, y: 0, width: ring.width, height: ring.height))
let bytes = c.data!.assumingMemoryBound(to: UInt8.self)
var minX = ring.width, minY = ring.height, maxX = 0, maxY = 0, transparent = 0
for y in 0..<ring.height { for x in 0..<ring.width { let a = bytes[(y * ring.width + x)*4+3]; if a > 8 { minX = min(minX,x); minY = min(minY,y); maxX = max(maxX,x); maxY = max(maxY,y) } else { transparent += 1 } } }
guard transparent > 0, maxX > minX else { fatalError("Ring has no transparent background") }
let trimmed = ring.cropping(to: CGRect(x: minX, y: minY, width: maxX-minX+1, height: maxY-minY+1))!
func export(_ image: CGImage, _ w: Int, _ h: Int, _ path: String) throws {
    let context = CGContext(data:nil,width:w,height:h,bitsPerComponent:8,bytesPerRow:w*4,space:CGColorSpaceCreateDeviceRGB(),bitmapInfo:CGImageAlphaInfo.premultipliedLast.rawValue)!
    context.interpolationQuality = .high
    let ratio = min(CGFloat(w)/CGFloat(image.width),CGFloat(h)/CGFloat(image.height))
    let size = CGSize(width: CGFloat(image.width)*ratio,height: CGFloat(image.height)*ratio)
    context.draw(image,in:CGRect(x:(CGFloat(w)-size.width)/2,y:(CGFloat(h)-size.height)/2,width:size.width,height:size.height))
    let rep = NSBitmapImageRep(cgImage:context.makeImage()!)
    try rep.representation(using:.png,properties:[:])!.write(to:URL(fileURLWithPath:root+path))
    print("EXPORT \(path) \(w)x\(h) alpha=\(rep.hasAlpha)")
}
for scale in 1...3 {
    let suffix = scale == 1 ? "" : "@\(scale)x"
    try export(trimmed,24*scale,58*scale,"/assets/decor/copper-ring\(suffix).png")
    try export(load("/sources/paper-master.png"),256*scale,256*scale,"/assets/decor/paper-ivory\(suffix).png")
}
try export(load("/sources/mock-reader-master.png"),1536,1024,"/assets/mock-only/reader-landscape.png")
print("ALPHA PASS ring transparent pixels \(transparent)/\(ring.width*ring.height)")
