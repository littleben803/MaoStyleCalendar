import XCTest
@testable import CalendarCore

final class ArtworkSolarTermTests: XCTestCase {
    private let china = TimeZone(secondsFromGMT: 8 * 3600)!

    func testPublished2026And2027Dates() {
        // Hong Kong Observatory Gregorian-Lunar Conversion Tables (HKT, UTC+8).
        let cases: [(Int, Int, Int, String)] = [
            (2026, 1, 5, "小寒"), (2026, 1, 20, "大寒"), (2026, 2, 4, "立春"), (2026, 2, 18, "雨水"),
            (2026, 3, 5, "惊蛰"), (2026, 3, 20, "春分"), (2026, 4, 5, "清明"), (2026, 4, 20, "谷雨"),
            (2026, 5, 5, "立夏"), (2026, 5, 21, "小满"), (2026, 6, 5, "芒种"), (2026, 6, 21, "夏至"),
            (2026, 7, 7, "小暑"), (2026, 7, 23, "大暑"), (2026, 8, 7, "立秋"), (2026, 8, 23, "处暑"),
            (2026, 9, 7, "白露"), (2026, 9, 23, "秋分"), (2026, 10, 8, "寒露"), (2026, 10, 23, "霜降"),
            (2026, 11, 7, "立冬"), (2026, 11, 22, "小雪"), (2026, 12, 7, "大雪"), (2026, 12, 22, "冬至"),
            (2027, 2, 19, "雨水"), (2027, 3, 21, "春分"), (2027, 5, 6, "立夏"),
            (2027, 9, 23, "秋分"), (2027, 12, 22, "冬至")
        ]
        for (year, month, day, expected) in cases {
            XCTAssertEqual(ArtworkSolarTerm.name(year: year, month: month, day: day, timeZone: china), expected)
        }
    }

    func testOrdinaryDaysAndYearBoundaryHaveNoTerm() {
        XCTAssertNil(ArtworkSolarTerm.name(year: 2026, month: 11, day: 26, timeZone: china))
        XCTAssertNil(ArtworkSolarTerm.name(year: 2026, month: 12, day: 31, timeZone: china))
        XCTAssertNil(ArtworkSolarTerm.name(year: 2027, month: 1, day: 1, timeZone: china))
        XCTAssertNil(ArtworkSolarTerm.name(year: 2026, month: 2, day: 30, timeZone: china))
    }

    func testUsesCivilDateInSpecifiedTimeZone() {
        // The 2026 winter solstice is 04:50 HKT on Dec 22, still Dec 21 in UTC-8.
        let pacific = TimeZone(secondsFromGMT: -8 * 3600)!
        XCTAssertEqual(ArtworkSolarTerm.name(year: 2026, month: 12, day: 21, timeZone: pacific), "冬至")
        XCTAssertNil(ArtworkSolarTerm.name(year: 2026, month: 12, day: 22, timeZone: pacific))
    }
}
