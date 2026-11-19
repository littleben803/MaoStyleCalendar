import Foundation

/// The free Today window is measured in local Gregorian days.
public struct TodayCardAccess: Equatable, Sendable {
    private let calendar: Calendar
    public let today: Date

    public init(now: Date = .now, timeZone: TimeZone = .current) {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timeZone
        self.calendar = calendar
        today = calendar.startOfDay(for: now)
    }

    public func date(byAddingDays days: Int, to date: Date) -> Date? {
        calendar.date(byAdding: .day, value: days, to: date).map { calendar.startOfDay(for: $0) }
    }

    public func allows(_ date: Date, hasFullAccess: Bool) -> Bool {
        if hasFullAccess { return true }
        let day = calendar.startOfDay(for: date)
        guard let offset = calendar.dateComponents([.day], from: today, to: day).day else { return false }
        return (-5...5).contains(offset)
    }
}
