import Foundation
import XCTest
@testable import CalendarCore

final class TodayCardAccessTests: XCTestCase {
    func testFiveDaysOnEachSideAcrossNewYear() throws {
        let utc = try XCTUnwrap(TimeZone(secondsFromGMT: 0))
        let access = TodayCardAccess(now: try instant("2027-01-01T12:00:00Z"), timeZone: utc)

        for offset in -6...6 {
            let date = try XCTUnwrap(access.date(byAddingDays: offset, to: access.today))
            XCTAssertEqual(access.allows(date, hasFullAccess: false), (-5...5).contains(offset))
            XCTAssertTrue(access.allows(date, hasFullAccess: true))
        }
    }

    func testWindowMovesAtLocalMidnightAcrossDaylightSavingChange() throws {
        let zone = try XCTUnwrap(TimeZone(identifier: "America/Los_Angeles"))
        let beforeMidnight = TodayCardAccess(now: try instant("2026-03-08T07:59:00Z"), timeZone: zone)
        let afterMidnight = TodayCardAccess(now: try instant("2026-03-08T08:00:00Z"), timeZone: zone)
        let pastEdge = try instant("2026-03-02T20:00:00Z")
        let futureEdge = try instant("2026-03-13T19:00:00Z")

        XCTAssertTrue(beforeMidnight.allows(pastEdge, hasFullAccess: false))
        XCTAssertFalse(afterMidnight.allows(pastEdge, hasFullAccess: false))
        XCTAssertFalse(beforeMidnight.allows(futureEdge, hasFullAccess: false))
        XCTAssertTrue(afterMidnight.allows(futureEdge, hasFullAccess: false))
    }

    private func instant(_ iso8601: String) throws -> Date {
        try XCTUnwrap(ISO8601DateFormatter().date(from: iso8601))
    }
}
