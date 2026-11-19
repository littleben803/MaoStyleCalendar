public protocol DailyContentRepository: Sendable {
    func allContent() throws -> [DailyContentPack]
    func content(id: String) throws -> DailyContentPack?
}

public extension DailyContentRepository {
    func baseContentIDs() throws -> [String] {
        try allContent()
            .filter { $0.kind == .base }
            .map(\.id)
    }

    func leapDayContentID() throws -> String? {
        try allContent().first { $0.kind == .leapDay }?.id
    }
}
