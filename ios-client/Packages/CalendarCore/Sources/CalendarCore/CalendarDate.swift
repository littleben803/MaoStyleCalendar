import Foundation

/// A Gregorian civil date without a time zone or time of day.
public struct CalendarDate: Hashable, Comparable, Sendable {
    public let year: Int
    public let month: Int
    public let day: Int

    public enum ValidationError: Error, Equatable { case invalidDate }

    public init(year: Int, month: Int, day: Int) throws {
        guard (1...9999).contains(year), (1...12).contains(month),
              (1...Self.daysInMonth(month, year: year)).contains(day) else {
            throw ValidationError.invalidDate
        }
        self.year = year
        self.month = month
        self.day = day
    }

    public static func localDate(at instant: Date = Date(), timeZone: TimeZone = .autoupdatingCurrent) throws -> Self {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timeZone
        let components = calendar.dateComponents([.year, .month, .day], from: instant)
        guard let year = components.year, let month = components.month, let day = components.day else {
            throw ValidationError.invalidDate
        }
        return try Self(year: year, month: month, day: day)
    }

    public static func isLeapYear(_ year: Int) -> Bool {
        year.isMultiple(of: 400) || (year.isMultiple(of: 4) && !year.isMultiple(of: 100))
    }

    static func daysInMonth(_ month: Int, year: Int) -> Int {
        if month == 2 { return isLeapYear(year) ? 29 : 28 }
        return [4, 6, 9, 11].contains(month) ? 30 : 31
    }

    public static func < (lhs: Self, rhs: Self) -> Bool {
        (lhs.year, lhs.month, lhs.day) < (rhs.year, rhs.month, rhs.day)
    }
}
