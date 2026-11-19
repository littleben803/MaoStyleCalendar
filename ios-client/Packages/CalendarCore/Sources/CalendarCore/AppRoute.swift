import Foundation

public enum AppRoute: Equatable, Sendable {
    public static let scheme = "maostylecalendar"

    case date(CalendarDate)

    public var url: URL {
        switch self {
        case let .date(date):
            URL(string: "\(Self.scheme)://date/\(date.year)-\(date.month)-\(date.day)")!
        }
    }

    public init?(url: URL) {
        guard url.scheme?.lowercased() == Self.scheme,
              url.host?.lowercased() == "date",
              url.user == nil,
              url.password == nil,
              url.port == nil,
              url.query == nil,
              url.fragment == nil
        else {
            return nil
        }

        let components = url.path.split(separator: "/", omittingEmptySubsequences: true)
        guard components.count == 1 else { return nil }

        let dateComponents = components[0].split(separator: "-", omittingEmptySubsequences: false)
        guard dateComponents.count == 3,
              let year = Int(dateComponents[0]),
              let month = Int(dateComponents[1]),
              let day = Int(dateComponents[2]),
              let date = try? CalendarDate(year: year, month: month, day: day)
        else {
            return nil
        }

        self = .date(date)
    }
}
