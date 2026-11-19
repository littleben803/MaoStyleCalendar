import Foundation

public enum ContentLanguagePreference: String, CaseIterable, Codable, Sendable {
    case system
    case chinese = "zh-Hans"
    case english = "en"

    public func resolvedLanguage(preferredLanguages: [String] = Locale.preferredLanguages) -> String {
        switch self {
        case .chinese: "zh-Hans"
        case .english: "en"
        case .system: preferredLanguages.first?.lowercased().hasPrefix("zh") == true ? "zh-Hans" : "en"
        }
    }
}
