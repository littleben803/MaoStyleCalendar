import Foundation
import XCTest
@testable import CalendarCore

final class AppRouteTests: XCTestCase {
    func testParsesWidgetDateRoute() throws {
        let url = try XCTUnwrap(URL(string: "maostylecalendar://date/2026-10-30"))
        let date = try CalendarDate(year: 2026, month: 10, day: 30)

        XCTAssertEqual(AppRoute(url: url), .date(date))
    }

    func testAcceptsUnpaddedMonthAndDayFromExistingWidgetFormat() throws {
        let url = try XCTUnwrap(URL(string: "maostylecalendar://date/2028-2-29"))
        let date = try CalendarDate(year: 2028, month: 2, day: 29)

        XCTAssertEqual(AppRoute(url: url), .date(date))
    }

    func testDateRouteBuildsCanonicalWidgetURLAndRoundTrips() throws {
        let date = try CalendarDate(year: 2028, month: 2, day: 29)
        let route = AppRoute.date(date)

        XCTAssertEqual(route.url.absoluteString, "maostylecalendar://date/2028-2-29")
        XCTAssertEqual(AppRoute(url: route.url), route)
    }

    func testRejectsInvalidOrUnsupportedRoutes() throws {
        let invalidURLs = [
            "https://date/2026-10-30",
            "maostylecalendar://unknown/2026-10-30",
            "maostylecalendar://date/2026-02-29",
            "maostylecalendar://date/2026-10-30/extra",
            "maostylecalendar://date/2026-10-30?detail=1",
            "maostylecalendar://date/not-a-date"
        ]

        for rawURL in invalidURLs {
            let url = try XCTUnwrap(URL(string: rawURL))
            XCTAssertNil(AppRoute(url: url), rawURL)
        }
    }
}
