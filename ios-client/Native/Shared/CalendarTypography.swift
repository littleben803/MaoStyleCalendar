import SwiftUI
import CoreText
import Foundation

enum CalendarResources {
    static let bundle: Bundle? = {
        let main = Bundle.main
        #if os(iOS)
        if main.bundleURL.pathExtension == "appex" {
            // iOS embeds the Widget in the containing app's PlugIns directory.
            let appURL = main.bundleURL.deletingLastPathComponent().deletingLastPathComponent()
            return Bundle(url: appURL)
        }
        #endif
        return main
    }()
}

enum CalendarTypography {
    enum Role { case chineseTitle, chineseQuote, chineseBody, englishTitle, englishQuote, date }

    // Register the bundled CJK face only when a view needs it.
    private static let titleRegistration = register("SourceHanSerifSC-Bold", "otf")
    private static let englishRegistration = register("SourceSerif4", "ttf")
    private static let dateRegistration = register("LibreBodoni", "ttf")

    private static func register(_ name: String, _ ext: String) -> Bool {
        guard let url = CalendarResources.bundle?.url(forResource: name, withExtension: ext) else {
            assertionFailure("Missing bundled font: \(name)")
            return false
        }
        return CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
    }

    static func font(_ role: Role, size: CGFloat) -> Font {
        let name: String
        var weight: Int?
        switch role {
        case .chineseTitle, .chineseQuote:
            _ = titleRegistration
            name = "SourceHanSerifSC-Bold"
        case .chineseBody:
            return .system(size: size, weight: .regular)
        case .englishTitle, .englishQuote:
            _ = englishRegistration
            name = "SourceSerif4Roman-ExtraLight"
            weight = role == .englishTitle ? 700 : 600
        case .date: _ = dateRegistration; name = "LibreBodoni-Regular"; weight = 700
        }
        var descriptor = CTFontDescriptorCreateWithAttributes([kCTFontNameAttribute: name] as CFDictionary)
        if let weight {
            descriptor = CTFontDescriptorCreateCopyWithVariation(descriptor, NSNumber(value: 2003265652), Double(weight))
        }
        if role == .englishTitle || role == .englishQuote {
            // Source Serif 4 optical-size range: 8–60. Recheck on any font upgrade.
            descriptor = CTFontDescriptorCreateCopyWithVariation(descriptor, NSNumber(value: 1869640570), Double(min(60, max(8, size))))
        }
        return Font(CTFontCreateWithFontDescriptor(descriptor, size, nil))
    }
}
