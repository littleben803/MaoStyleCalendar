import Foundation
import XCTest
@testable import CalendarCore

final class CalendarLocalizationTests: XCTestCase {
    func testChineseVariantsAndEnglishFallback() {
        for code in ["zh-Hans", "zh-Hant-TW", "zh_CN"] {
            XCTAssertEqual(Locale(identifier: code).calendarText("今日", "Today"), "今日")
        }
        for code in ["en", "en-GB", "fr", "ja"] {
            XCTAssertEqual(Locale(identifier: code).calendarText("今日", "Today"), "Today")
            XCTAssertEqual(Locale(identifier: code).calendarMonth(11), "Nov")
        }
    }

    func testCivilDateFormattingDoesNotShiftDayOrUseSystemLanguage() throws {
        let date = try CalendarDate(year: 2028, month: 2, day: 29)
        XCTAssertEqual(date.displayDate(locale: Locale(identifier: "en")), "Feb 29, 2028")
        XCTAssertEqual(date.displayDate(locale: Locale(identifier: "en"), template: "EEE"), "Tue")
        XCTAssertEqual(date.displayDate(locale: Locale(identifier: "zh-Hans")), "2028年2月29日")
        XCTAssertEqual(Locale(identifier: "en").calendarMonth(0), "—")
        XCTAssertEqual(Locale(identifier: "en").calendarMonth(13), "—")
    }
    func testEveryMockPackIncludingLeapDayHasEnglishAndChinese() throws {
        for pack in try MockDailyContentRepository().allContent() {
            let english = pack.localizedQuote(locale: Locale(identifier: "en"))
            let chinese = pack.localizedQuote(locale: Locale(identifier: "zh-Hans"))
            XCTAssertTrue(english.hasPrefix("Mock quote "))
            XCTAssertTrue(chinese.contains("待审核"))
            XCTAssertEqual(pack.reviewStatus, .candidate)
            XCTAssertEqual(pack.localizedEditorialSections(locale: Locale(identifier: "en")).count, 2)
            XCTAssertTrue(pack.localizedEditorialSections(locale: Locale(identifier: "en")).allSatisfy { $0.languageTag == "en" })
            XCTAssertEqual(pack.localizedQuote(locale: Locale(identifier: "fr")), english)
        }
    }

}
