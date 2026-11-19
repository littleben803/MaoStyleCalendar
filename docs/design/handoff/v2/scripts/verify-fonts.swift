import Foundation
import AppKit
import CoreText
import CryptoKit
let root=URL(fileURLWithPath:CommandLine.arguments[1])
let spec=try JSONSerialization.jsonObject(with:Data(contentsOf:root.appendingPathComponent("specs/font-roles.json"))) as! [String:Any]
let fonts=spec["fonts"] as! [String:[String:Any]]
for key in fonts.keys.sorted() {
    let entry=fonts[key]!,url=root.appendingPathComponent("fonts/"+(entry["file"] as! String)),data=try Data(contentsOf:url)
    guard SHA256.hash(data:data).map({String(format:"%02x",$0)}).joined() == entry["sha256"] as! String else {fatalError("Hash mismatch")}
    guard CTFontManagerRegisterFontsForURL(url as CFURL,.process,nil) else {fatalError("Registration failed")}
    var descriptor=CTFontDescriptorCreateWithAttributes([kCTFontNameAttribute:entry["postScriptName"]!] as CFDictionary)
    let baseFont=CTFontCreateWithFontDescriptor(descriptor,24,nil)
    guard CTFontCopyPostScriptName(baseFont) as String == entry["postScriptName"] as! String else {fatalError("Unexpected base font")}
    let weight=(entry["variation"] as? [String:Int])?["wght"]
    if let weight {descriptor=CTFontDescriptorCreateCopyWithVariation(descriptor,NSNumber(value:2003265652),Double(weight))}
    let font=CTFontCreateWithFontDescriptor(descriptor,24,nil)
    guard CTFontCopyFamilyName(font) == CTFontCopyFamilyName(baseFont) else {fatalError("Unexpected font family")}
    if let weight {
        let variation=CTFontCopyVariation(font) as! [NSNumber:NSNumber]
        guard variation[NSNumber(value:2003265652)]?.intValue == weight else {fatalError("Weight not applied")}
    }
    let sample=key.hasPrefix("cn") ? "语录详解如果真想做宣传就要看对象年月日农历《〈〉》，。" : "No investigation, no right to speak.0123456789"
    let chars=Array(sample.utf16);var glyphs=[CGGlyph](repeating:0,count:chars.count)
    guard CTFontGetGlyphsForCharacters(font,chars,&glyphs,chars.count) else {fatalError("Missing sample glyph")}
    print("PASS \(key): \(CTFontCopyPostScriptName(font)) weight=\(weight.map(String.init) ?? "static") hash+registration+sample glyphs")
}
