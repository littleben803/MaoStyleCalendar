import Foundation

public struct MockDailyContentRepository: DailyContentRepository {
    public static let baseContentCount = 365
    public static let leapDayID = "mock-leap-day-001"

    private let packs: [DailyContentPack]
    private let packsByID: [String: DailyContentPack]

    public init() {
        let basePacks = (1...Self.baseContentCount).map { index in
            Self.makePack(id: String(format: "mock-base-%03d", index), kind: .base, sequence: index)
        }
        let leapDayPack = Self.makePack(id: Self.leapDayID, kind: .leapDay, sequence: 366)
        packs = basePacks + [leapDayPack]
        packsByID = Dictionary(uniqueKeysWithValues: packs.map { ($0.id, $0) })
    }

    public func allContent() throws -> [DailyContentPack] {
        packs
    }

    public func content(id: String) throws -> DailyContentPack? {
        packsByID[id]
    }

    private static func makePack(id: String, kind: ContentPackKind, sequence: Int) -> DailyContentPack {
        let quoteID = "\(id)-quote-zh"
        return DailyContentPack(
            id: id,
            kind: kind,
            revision: 1,
            reviewStatus: .candidate,
            pairingLocked: true,
            quoteTexts: [
                QuoteText(
                    id: quoteID,
                    languageTag: "zh-Hans",
                    kind: .mockPlaceholder,
                    text: "此处为第\(sequence)条待审核语录占位文本，正式内容将由设计与内容核验流程提供。",
                    translationProvenance: .notApplicable
                ),
                QuoteText(id: "\(id)-quote-en", languageTag: "en", kind: .mockPlaceholder,
                    text: "Mock quote \(sequence). Final content is pending artwork delivery and source verification.",
                    translationProvenance: .notApplicable)
            ],
            sourceFragments: [],
            editorialSections: [
                EditorialSection(
                    id: "\(id)-editorial-source",
                    languageTag: "zh-Hans",
                    kind: .originalContext,
                    displayOrder: 0,
                    body: "Mock 数据：正式出处、上下文与页码待核验。"
                ),
                EditorialSection(
                    id: "\(id)-editorial-background",
                    languageTag: "zh-Hans",
                    kind: .historicalBackground,
                    displayOrder: 1,
                    body: "Mock 数据：历史背景内容待编辑审校。"
                ),
                EditorialSection(
                    id: "\(id)-editorial-interpretation",
                    languageTag: "zh-Hans",
                    kind: .plainLanguageInterpretation,
                    displayOrder: 2,
                    body: "Mock 数据：通俗解读内容待编辑审校。"
                ),
                EditorialSection(id: "\(id)-editorial-background-en", languageTag: "en", kind: .historicalBackground,
                    displayOrder: 1, body: "Mock content: historical context is pending editorial review."),
                EditorialSection(id: "\(id)-editorial-interpretation-en", languageTag: "en", kind: .plainLanguageInterpretation,
                    displayOrder: 2, body: "Mock content: reading notes are pending editorial review.")
            ],
            artworkAssets: [
                ArtworkAsset(
                    id: "\(id)-artwork-primary",
                    role: .primary,
                    focus: NormalizedArtworkFocus(x: 0.5, y: 0.5, safeWidth: 1, safeHeight: 1),
                    approvalStatus: .placeholder
                )
            ],
            verificationRecords: []
        )
    }
}
