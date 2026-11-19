import Foundation

public struct DesktopWidgetDisplayPreferences: Equatable, Sendable {
    public static let widgetKind = "Calendar.Desktop"
    public static let showsDateKey = "settings.desktop-widget.shows-date"
    public static let showsLunarDateKey = "settings.desktop-widget.shows-lunar-date"
    public static let showsQuoteKey = "settings.desktop-widget.shows-quote"
    public static let followsDailyArtworkKey = "settings.desktop-widget.follows-daily-artwork"
    public static let languageCodeKey = "settings.desktop-widget.language"
    public static let verifiedFullAccessKey = "settings.desktop-widget.verified-full-access"
    public static let defaultShowsLunarDate = false
    #if DEBUG
    public static let mockFullAccessKey = "debug.desktop-widget.mock-full-access"
    public static let debugLanguageKey = "debug.desktop-widget.language"
    #endif

    public static var sharedDefaults: UserDefaults? {
        UserDefaults(suiteName: "group.com.ideaboxapps.maostylecalendar")
    }

    public let showsDate: Bool
    public let showsLunarDate: Bool
    public let showsQuote: Bool
    public let followsDailyArtwork: Bool

    public init(showsDate: Bool = true, showsLunarDate: Bool = Self.defaultShowsLunarDate,
                showsQuote: Bool = true, followsDailyArtwork: Bool = false) {
        self.showsDate = showsDate
        self.showsLunarDate = showsLunarDate
        self.showsQuote = showsQuote
        self.followsDailyArtwork = followsDailyArtwork
    }

    public init(defaults: UserDefaults?) {
        self.init(
            showsDate: defaults?.object(forKey: Self.showsDateKey) as? Bool ?? true,
            showsLunarDate: defaults?.object(forKey: Self.showsLunarDateKey) as? Bool ?? Self.defaultShowsLunarDate,
            showsQuote: defaults?.object(forKey: Self.showsQuoteKey) as? Bool ?? true,
            followsDailyArtwork: defaults?.object(forKey: Self.followsDailyArtworkKey) as? Bool ?? false
        )
    }

    public func resolved(hasFullAccess: Bool, languageCode: String) -> Self {
        guard hasFullAccess else { return Self() }
        return Self(
            showsDate: showsDate,
            showsLunarDate: showsLunarDate && languageCode == "zh-Hans",
            showsQuote: showsQuote,
            followsDailyArtwork: followsDailyArtwork
        )
    }
}
