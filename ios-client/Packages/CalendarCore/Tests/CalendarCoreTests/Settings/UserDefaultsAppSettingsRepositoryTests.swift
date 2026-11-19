import Foundation
import XCTest
@testable import CalendarCore

final class AppLanguageResolutionTests: XCTestCase {
    func testSystemLanguageUsesPrimaryLanguageAndEnglishFallback() {
        XCTAssertEqual(ContentLanguagePreference.system.resolvedLanguage(preferredLanguages: ["zh-Hant-TW", "en"]), "zh-Hans")
        XCTAssertEqual(ContentLanguagePreference.system.resolvedLanguage(preferredLanguages: ["en-US", "zh-Hans"]), "en")
        XCTAssertEqual(ContentLanguagePreference.system.resolvedLanguage(preferredLanguages: ["fr-FR", "zh-Hans"]), "en")
        XCTAssertEqual(ContentLanguagePreference.system.resolvedLanguage(preferredLanguages: []), "en")
    }

    func testExplicitLanguageOverridesSystem() {
        XCTAssertEqual(ContentLanguagePreference.chinese.resolvedLanguage(preferredLanguages: ["fr"]), "zh-Hans")
        XCTAssertEqual(ContentLanguagePreference.english.resolvedLanguage(preferredLanguages: ["zh-Hans"]), "en")
    }
}
