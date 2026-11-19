import AppKit
import CoreText
let base=CommandLine.arguments[1], extra=CommandLine.arguments[2], output=CommandLine.arguments[3]
let paths=[base+"/SourceHanSerifSC-Regular.otf",base+"/SourceHanSerifSC-SemiBold.otf",base+"/Literata.ttf",extra+"/BodoniModa.ttf",extra+"/LibreBodoni.ttf",extra+"/SourceSerif4.ttf",extra+"/SourceHanSerifSC-Bold.otf"]
var names:[String]=[]
for path in paths {
    let url=URL(fileURLWithPath:path)
    guard CTFontManagerRegisterFontsForURL(url as CFURL,.process,nil) else { fatalError("Cannot register \(path)") }
    let descriptors=CTFontManagerCreateFontDescriptorsFromURL(url as CFURL) as! [CTFontDescriptor]
    let ct=CTFontCreateWithFontDescriptor(descriptors[0],20,nil)
    names.append(CTFontCopyPostScriptName(ct) as String)
    print("FONT \(url.lastPathComponent): \(names.last!) version=\(CTFontCopyName(ct,kCTFontVersionNameKey)!)")
    if let table=CTFontCopyTable(ct,CTFontTableTag(0x4F532F32),[]) as Data?,table.count>9 {print("fsType=\(Int(table[8])*256+Int(table[9]))")}
}
func font(_ index:Int,_ size:CGFloat,_ weight:CGFloat=400)->NSFont {
    var descriptor=CTFontDescriptorCreateWithAttributes([kCTFontNameAttribute:names[index]] as CFDictionary)
    let ct=CTFontCreateWithFontDescriptor(descriptor,size,nil)
    if let axes=CTFontCopyVariationAxes(ct) as? [[CFString:Any]] {
        for axis in axes {
            let id=axis[kCTFontVariationAxisIdentifierKey] as! NSNumber
            let low=(axis[kCTFontVariationAxisMinimumValueKey] as! NSNumber).doubleValue, high=(axis[kCTFontVariationAxisMaximumValueKey] as! NSNumber).doubleValue
            let value=id.uint32Value == 2003265652 ? Double(weight) : Double(size)
            descriptor=CTFontDescriptorCreateCopyWithVariation(descriptor,id, min(high,max(low,value)))
        }
    }
    return CTFontCreateWithFontDescriptor(descriptor,size,nil) as NSFont
}
let ink=NSColor(srgbRed:0.10,green:0.08,blue:0.07,alpha:1), red=NSColor(srgbRed:0.67,green:0.10,blue:0.09,alpha:1)
for index in [2,3,4,5] {print("AXES \(names[index]): \(String(describing:CTFontCopyVariation(font(index,112,700) as CTFont)))")}
func t(_ value:String,_ x:CGFloat,_ y:CGFloat,_ w:CGFloat,_ h:CGFloat,_ index:Int,_ size:CGFloat,_ weight:CGFloat=400,_ color:NSColor?=nil) {
    let p=NSMutableParagraphStyle();p.lineSpacing=5
    let a:[NSAttributedString.Key:Any]=[.font:font(index,size,weight),.foregroundColor:color ?? ink,.paragraphStyle:p]
    let b=(value as NSString).boundingRect(with:CGSize(width:w,height:h),options:[.usesLineFragmentOrigin,.usesFontLeading],attributes:a)
    guard b.height<=h else {fatalError("Overflow \(value) \(b.height)>\(h)")}
    (value as NSString).draw(with:CGRect(x:x,y:y,width:w,height:h),options:[.usesLineFragmentOrigin,.usesFontLeading],attributes:a)
}
let rep=NSBitmapImageRep(bitmapDataPlanes:nil,pixelsWide:2400,pixelsHigh:2600,bitsPerSample:8,samplesPerPixel:4,hasAlpha:true,isPlanar:false,colorSpaceName:.deviceRGB,bytesPerRow:0,bitsPerPixel:0)!
let context=NSGraphicsContext(bitmapImageRep:rep)!,cg=context.cgContext
NSGraphicsContext.saveGraphicsState();cg.scaleBy(x:2,y:2);cg.translateBy(x:0,y:1300);cg.scaleBy(x:1,y:-1);NSGraphicsContext.current=NSGraphicsContext(cgContext:cg,flipped:true)
NSColor(srgbRed:0.98,green:0.96,blue:0.91,alpha:1).setFill();CGRect(x:0,y:0,width:1200,height:1300).fill()
t("原稿字体匹配研究 · 真实字库对照",28,18,1140,60,1,30)
t("候选对照，不宣称识别出原稿确切字体；不修改当前 B 方案",28,79,1140,35,0,16)
t("中文：同字号比较字重",28,131,1140,40,1,21)
for (column,index) in [0,1,6].enumerated() {
    let x=CGFloat(column)*390+28
    t(["思源宋体 Regular","思源宋体 SemiBold","思源宋体 Bold"][column],x,184,365,30,0,16)
    t("语录详解",x,226,365,75,index,42)
    t("如果真想做宣传，\n就要看对象。",x,308,365,85,index,24)
}
t("日期：相同 112 pt，比较字形与字重",28,423,1140,40,1,21)
for (col,item) in [(2,400.0,"Literata 400（原基线）"),(2,700.0,"Literata 700"),(3,700.0,"Bodoni Moda 700"),(4,700.0,"Libre Bodoni 700")].enumerated() {
    let x=CGFloat(col)*294+28
    t(item.2,x,477,282,32,0,14)
    t("29",x,521,282,180,item.0,112,item.1,red)
    t("19  27  04",x,713,282,68,item.0,35,item.1,red)
}
t("英文：同为 600 字重，比较衬线、字宽和墨色",28,815,1140,40,1,21)
for (col,index) in [2,5].enumerated() {
    let x=CGFloat(col)*584+28
    t(col == 0 ? "Literata 600" : "Source Serif 4 600",x,872,550,35,0,17)
    t("No investigation,\nno right to speak.",x,920,550,150,index,34,600)
    t("Preface and Postscript\nto Rural Surveys",x,1091,550,103,index,23,400)
}
t("CoreText / AppKit 实绘；均为可嵌入候选；原稿配准与 iOS 真机仍待验证",28,1237,1140,42,0,16)
NSGraphicsContext.restoreGraphicsState()
try rep.representation(using:.png,properties:[:])!.write(to:URL(fileURLWithPath:output))
print("RENDER PASS 2400x2600")
