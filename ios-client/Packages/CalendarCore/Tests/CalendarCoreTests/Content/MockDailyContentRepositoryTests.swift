import XCTest
@testable import CalendarCore

final class MockDailyContentRepositoryTests: XCTestCase {
    private let repository = MockDailyContentRepository()

    func testRepositoryContainsExactly365BasePacksAndOneLeapDayPack() throws {
        let packs = try repository.allContent()

        XCTAssertEqual(packs.count, 366)
        XCTAssertEqual(packs.filter { $0.kind == .base }.count, 365)
        XCTAssertEqual(packs.filter { $0.kind == .leapDay }.count, 1)
        XCTAssertEqual(try repository.leapDayContentID(), MockDailyContentRepository.leapDayID)
    }

    func testMockIdentifiersAreStableAndUnique() throws {
        let packs = try repository.allContent()
        let ids = packs.map(\.id)

        XCTAssertEqual(Set(ids).count, 366)
        XCTAssertEqual(ids.first, "mock-base-001")
        XCTAssertEqual(ids[364], "mock-base-365")
        XCTAssertEqual(ids.last, MockDailyContentRepository.leapDayID)
    }

    func testMockContentCannotBeMistakenForApprovedReleaseContent() throws {
        let packs = try repository.allContent()

        XCTAssertTrue(packs.allSatisfy { $0.reviewStatus == .candidate })
        XCTAssertTrue(packs.allSatisfy { $0.quoteTexts.allSatisfy { $0.kind == .mockPlaceholder } })
        XCTAssertTrue(packs.allSatisfy { $0.sourceFragments.isEmpty })
        XCTAssertTrue(packs.allSatisfy { $0.verificationRecords.isEmpty })
        XCTAssertTrue(packs.allSatisfy { $0.artworkAssets.allSatisfy { $0.approvalStatus == .placeholder } })
    }

    func testPackRoundTripsThroughJSONWithoutLosingSchemaFields() throws {
        let original = try XCTUnwrap(repository.content(id: "mock-base-019"))
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(DailyContentPack.self, from: data)

        XCTAssertEqual(decoded, original)
    }

    func testMockRepositoryFeedsCommonAndLeapYearAllocation() throws {
        let allocator = AnnualContentAllocator()
        let baseIDs = try repository.baseContentIDs()
        let leapDayID = try XCTUnwrap(repository.leapDayContentID())

        let commonYear = try allocator.schedule(year: 2027, contentIDs: baseIDs, leapDayContentID: leapDayID)
        let leapYear = try allocator.schedule(year: 2028, contentIDs: baseIDs, leapDayContentID: leapDayID)

        XCTAssertEqual(commonYear.entries.count, 365)
        XCTAssertEqual(Set(commonYear.entries.map(\.contentID)).count, 365)
        XCTAssertFalse(commonYear.entries.contains { $0.contentID == leapDayID })
        XCTAssertEqual(leapYear.entries.count, 366)
        XCTAssertEqual(Set(leapYear.entries.map(\.contentID)).count, 366)
        XCTAssertEqual(leapYear[try CalendarDate(year: 2028, month: 2, day: 29)], leapDayID)
    }

    func testLookupReturnsMatchingPackAndNilForUnknownID() throws {
        XCTAssertEqual(try repository.content(id: "mock-base-001")?.id, "mock-base-001")
        XCTAssertNil(try repository.content(id: "missing-content"))
    }
}
