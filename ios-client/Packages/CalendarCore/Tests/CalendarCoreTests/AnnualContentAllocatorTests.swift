import XCTest
@testable import CalendarCore

final class AnnualContentAllocatorTests: XCTestCase {
    private let allocator = AnnualContentAllocator()
    private var ids: [String] { (1...365).map { String(format: "MCP-%03d", $0) } }

    func testCommonYearIsCompleteChronologicalAndUnique() throws {
        let schedule = try allocator.schedule(year: 2026, contentIDs: ids)
        XCTAssertEqual(schedule.entries.count, 365)
        XCTAssertEqual(Set(schedule.entries.map(\.contentID)), Set(ids))
        XCTAssertEqual(schedule.entries.map(\.date), schedule.entries.map(\.date).sorted())
        XCTAssertEqual(schedule.entries.first?.date, try CalendarDate(year: 2026, month: 1, day: 1))
        XCTAssertEqual(schedule.entries.last?.date, try CalendarDate(year: 2026, month: 12, day: 31))
    }

    func testSourceOrderAndRepeatedCallsDoNotChangeMapping() throws {
        let first = try allocator.schedule(year: 2026, contentIDs: ids)
        XCTAssertEqual(first, try allocator.schedule(year: 2026, contentIDs: Array(ids.reversed())))
        XCTAssertEqual(first, try allocator.schedule(year: 2026, contentIDs: ids))
    }

    func testNewYearReusesPoolWithDifferentOrder() throws {
        let first = try allocator.schedule(year: 2026, contentIDs: ids)
        let next = try allocator.schedule(year: 2027, contentIDs: ids)
        XCTAssertEqual(Set(first.entries.map(\.contentID)), Set(next.entries.map(\.contentID)))
        XCTAssertNotEqual(first.entries.map(\.contentID), next.entries.map(\.contentID))
    }

    func testLeapYearUsesDedicatedContentWithoutDisplacingBasePool() throws {
        let schedule = try allocator.schedule(year: 2028, contentIDs: ids, leapDayContentID: "LEAP-001")
        XCTAssertEqual(schedule.entries.count, 366)
        XCTAssertEqual(Set(schedule.entries.map(\.contentID)).count, 366)
        XCTAssertEqual(schedule[try CalendarDate(year: 2028, month: 2, day: 29)], "LEAP-001")
        XCTAssertEqual(Set(schedule.entries.filter { $0.contentID != "LEAP-001" }.map(\.contentID)), Set(ids))
    }

    func testMissingLeapContentIsExplicitError() {
        XCTAssertThrowsError(try allocator.schedule(year: 2028, contentIDs: ids)) {
            XCTAssertEqual($0 as? AnnualContentAllocator.AllocationError, .leapDayContentMissing)
        }
    }

    func testLeapContentIsNotUsedInCommonYear() throws {
        let a = try allocator.schedule(year: 2026, contentIDs: ids, leapDayContentID: "LEAP-001")
        XCTAssertEqual(a, try allocator.schedule(year: 2026, contentIDs: ids))
    }

    func testInvalidPoolAndVersionAreRejected() {
        XCTAssertThrowsError(try allocator.schedule(year: 2026, contentIDs: Array(ids.dropLast()))) {
            XCTAssertEqual($0 as? AnnualContentAllocator.AllocationError, .incorrectPoolCount(364))
        }
        var duplicate = ids; duplicate[1] = duplicate[0]
        XCTAssertThrowsError(try allocator.schedule(year: 2026, contentIDs: duplicate)) {
            XCTAssertEqual($0 as? AnnualContentAllocator.AllocationError, .duplicateIdentifier)
        }
        XCTAssertThrowsError(try allocator.schedule(year: 2026, contentIDs: ids, leapDayContentID: ids[0])) {
            XCTAssertEqual($0 as? AnnualContentAllocator.AllocationError, .leapDayContentInBasePool)
        }
        XCTAssertThrowsError(try allocator.schedule(year: 2026, contentIDs: ids, algorithmVersion: 2)) {
            XCTAssertEqual($0 as? AnnualContentAllocator.AllocationError, .unsupportedVersion(2))
        }
        var empty = ids; empty[1] = " "
        XCTAssertThrowsError(try allocator.schedule(year: 2026, contentIDs: empty)) {
            XCTAssertEqual($0 as? AnnualContentAllocator.AllocationError, .invalidIdentifier)
        }
        XCTAssertThrowsError(try allocator.schedule(year: 0, contentIDs: ids)) {
            XCTAssertEqual($0 as? AnnualContentAllocator.AllocationError, .invalidYear)
        }
    }

    func testGregorianCenturyRules() throws {
        XCTAssertFalse(CalendarDate.isLeapYear(1900))
        XCTAssertTrue(CalendarDate.isLeapYear(2000))
        XCTAssertFalse(CalendarDate.isLeapYear(2100))
        XCTAssertEqual(try allocator.schedule(year: 2100, contentIDs: ids).entries.count, 365)
        XCTAssertEqual(try allocator.schedule(year: 2000, contentIDs: ids, leapDayContentID: "LEAP-001").entries.count, 366)
    }

    func testRejectsInvalidCivilDates() {
        for (year, month, day) in [(2026,2,29),(2026,4,31),(2026,0,1),(2026,13,1),(2026,1,0),(0,1,1)] {
            XCTAssertThrowsError(try CalendarDate(year: year, month: month, day: day))
        }
    }

    func testTimeZoneControlsYearBoundary() throws {
        let instant = Date(timeIntervalSince1970: 1798759800) // 2026-12-31 23:30:00 UTC
        XCTAssertEqual(try CalendarDate.localDate(at: instant, timeZone: TimeZone(secondsFromGMT: 0)!), try CalendarDate(year: 2026, month: 12, day: 31))
        XCTAssertEqual(try CalendarDate.localDate(at: instant, timeZone: TimeZone(secondsFromGMT: 8*3600)!), try CalendarDate(year: 2027, month: 1, day: 1))
    }

    func testVersionOneSnapshot() throws {
        let schedule = try allocator.schedule(year: 2026, contentIDs: ids)
        XCTAssertEqual(schedule.entries.prefix(5).map(\.contentID), ["MCP-298", "MCP-334", "MCP-038", "MCP-014", "MCP-218"])
        XCTAssertEqual(schedule.algorithmVersion, 1)
    }
}
