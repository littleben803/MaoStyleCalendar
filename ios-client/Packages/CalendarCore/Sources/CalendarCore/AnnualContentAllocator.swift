import Foundation

/// Algorithm versions must stay stable after shipping. Never use Swift.Hasher or system random state.
public struct AnnualContentAllocator: Sendable {
    public enum AllocationError: Error, Equatable {
        case invalidYear
        case unsupportedVersion(Int)
        case incorrectPoolCount(Int)
        case invalidIdentifier
        case duplicateIdentifier
        case leapDayContentMissing
        case leapDayContentInBasePool
    }

    public struct Entry: Equatable, Sendable {
        public let date: CalendarDate
        public let contentID: String
    }

    public struct Schedule: Equatable, Sendable {
        public let year: Int
        public let algorithmVersion: Int
        /// Chronological order, suitable for yearbook browsing and deterministic serialization by callers.
        public let entries: [Entry]

        public subscript(date: CalendarDate) -> String? {
            entries.first { $0.date == date }?.contentID
        }
    }

    public init() {}

    public func schedule(
        year: Int,
        contentIDs: [String],
        leapDayContentID: String? = nil,
        algorithmVersion: Int = 1
    ) throws -> Schedule {
        guard (1...9999).contains(year) else { throw AllocationError.invalidYear }
        guard algorithmVersion == 1 else { throw AllocationError.unsupportedVersion(algorithmVersion) }
        guard contentIDs.count == 365 else { throw AllocationError.incorrectPoolCount(contentIDs.count) }
        guard contentIDs.allSatisfy({ !$0.isEmpty && $0 == $0.trimmingCharacters(in: .whitespacesAndNewlines) }),
              leapDayContentID.map({ !$0.isEmpty && $0 == $0.trimmingCharacters(in: .whitespacesAndNewlines) }) ?? true else {
            throw AllocationError.invalidIdentifier
        }
        guard Set(contentIDs).count == 365 else { throw AllocationError.duplicateIdentifier }
        if let leapDayContentID, contentIDs.contains(leapDayContentID) {
            throw AllocationError.leapDayContentInBasePool
        }
        if CalendarDate.isLeapYear(year), leapDayContentID == nil { throw AllocationError.leapDayContentMissing }

        // Stable lexical order makes the source JSON/file delivery order irrelevant.
        var pool = contentIDs.sorted()
        var generator = SplitMix64(state: UInt64(year) ^ (UInt64(algorithmVersion) &* 0xD1B54A32D192ED03))
        for index in stride(from: pool.count - 1, through: 1, by: -1) {
            pool.swapAt(index, Int(generator.bounded(UInt64(index + 1))))
        }
        var entries: [Entry] = []
        var poolIndex = 0
        for month in 1...12 {
            for day in 1...CalendarDate.daysInMonth(month, year: year) {
                let date = try CalendarDate(year: year, month: month, day: day)
                if month == 2 && day == 29 {
                    guard let leapDayContentID else { throw AllocationError.leapDayContentMissing }
                    entries.append(Entry(date: date, contentID: leapDayContentID))
                } else {
                    entries.append(Entry(date: date, contentID: pool[poolIndex]))
                    poolIndex += 1
                }
            }
        }
        return Schedule(year: year, algorithmVersion: algorithmVersion, entries: entries)
    }
}

private struct SplitMix64 {
    var state: UInt64

    mutating func next() -> UInt64 {
        state &+= 0x9E3779B97F4A7C15
        var value = state
        value = (value ^ (value >> 30)) &* 0xBF58476D1CE4E5B9
        value = (value ^ (value >> 27)) &* 0x94D049BB133111EB
        return value ^ (value >> 31)
    }

    mutating func bounded(_ bound: UInt64) -> UInt64 {
        let threshold = (0 &- bound) % bound
        while true {
            let value = next()
            if value >= threshold { return value % bound }
        }
    }
}
