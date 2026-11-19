#if os(iOS)
import Foundation
import CalendarCore

struct ArtworkIllustrationRegion: Codable, Sendable {
    let x: Double
    let y: Double
    let width: Double
    let height: Double
    var aspectRatio: Double { width / (height * 1.5) }
}

enum ArtworkWidgetQuotePlacement: String, Decodable, Sendable {
    case upperRight, narrowLeft
}

struct ArtworkWidgetComposition: Decodable, Sendable {
    let columns: Int
    let rows: Int
    let weights: [UInt8]
    let protectedRegions: [ArtworkIllustrationRegion]
    let sourceChecksum: String

    private enum CodingKeys: String, CodingKey {
        case columns, rows, ink, protectedRegions, sourceChecksum
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        columns = try values.decode(Int.self, forKey: .columns)
        rows = try values.decode(Int.self, forKey: .rows)
        protectedRegions = try values.decode([ArtworkIllustrationRegion].self, forKey: .protectedRegions)
        sourceChecksum = try values.decode(String.self, forKey: .sourceChecksum)
        let hex = Array(try values.decode(String.self, forKey: .ink))
        guard columns > 0, rows > 0, hex.count == columns * rows * 2 else {
            throw DecodingError.dataCorruptedError(forKey: .ink, in: values, debugDescription: "Invalid composition grid")
        }
        weights = try stride(from: 0, to: hex.count, by: 2).map { index in
            guard let weight = UInt8(String(hex[index...index + 1]), radix: 16) else {
                throw DecodingError.dataCorruptedError(forKey: .ink, in: values, debugDescription: "Invalid ink weight")
            }
            return weight
        }
    }
}

private struct ArtworkWidgetCompositionAtlas: Decodable {
    let version: Int
    let artworks: [String: ArtworkWidgetComposition]
}

private struct ArtworkEditorialRecord: Decodable {
    let sourceFragments: [SourceFragment]
    let sections: [EditorialSection]
}

struct ArtworkEnglishRecord: Decodable {
    let title: String
    let quote: String
    let sections: [EditorialSection]
    let sourceChecksum: String
}

private struct ArtworkEnglishAtlas: Decodable {
    let version: Int
    let provenance: String
    let status: String
    let records: [String: ArtworkEnglishRecord]
}

struct ArtworkPage: Decodable, Identifiable, Sendable {
    let id: String
    let contentPackID: String
    let revision: Int?
    let illustrationRegion: ArtworkIllustrationRegion?
    let widgetQuotePlacement: ArtworkWidgetQuotePlacement?
    let widgetSourceWindowTop: Double?
    let title: String
    let filename: String
    let assetChecksum: String?
    let segments: [String]
    let direction: String
    let quoteColor: String
    let dateColor: String
    let auxiliaryColor: String
    let paperColor: String
    let x: Double
    let y: Double
    let fontSize: Double
    let step: Double
    let columnSpacing: Double
    let punctuationExtraGap: Double
    let datePosition: String
    let reviewStatus: String
    let notes: [String]

    var quote: String { segments.joined().replacingOccurrences(of: "　", with: "") }
    var english: ArtworkEnglishRecord? { DailyArtworkCatalog.englishEditorial[id] }
    func localizedQuote(locale: Locale) -> String {
        locale.calendarIsChinese ? quote : english?.quote ?? "English translation unavailable"
    }
    func localizedAccessibleQuote(locale: Locale) -> String {
        localizedQuote(locale: locale)
    }
    func localizedTitle(locale: Locale) -> String {
        locale.calendarIsChinese ? title : english?.title ?? id
    }
    var widgetComposition: ArtworkWidgetComposition? {
        guard let composition = DailyArtworkCatalog.widgetCompositions[filename],
              composition.sourceChecksum == assetChecksum else { return nil }
        return composition
    }
    var content: DailyContentPack {
        let contentID = contentPackID
        let details = DailyArtworkCatalog.editorialDetails[contentID]
        var texts = [QuoteText(id: "\(contentID)-zh", languageTag: "zh-Hans", kind: .editorialExcerpt,
                               text: quote, translationProvenance: .notApplicable)]
        var sections = details?.sections ?? []
        if let english {
            texts.append(QuoteText(id: "\(contentID)-en", languageTag: "en", kind: .editorialTranslation,
                                   text: english.quote, translationProvenance: .projectEditorial))
            sections += english.sections
            sections.append(EditorialSection(id: "\(contentID)-translation-note-en", languageTag: "en",
                kind: .translationNote, displayOrder: 0,
                body: "Project editorial translation from the Chinese text, not a verbatim published English translation. References cite the Chinese edition." + ((details?.sourceFragments.isEmpty ?? true) ? " Attribution to Mao Zedong remains unverified for this card." : "")))
        }
        return DailyContentPack(
            id: contentID, kind: .base, revision: revision ?? 1, reviewStatus: .candidate, pairingLocked: true,
            quoteTexts: texts,
            sourceFragments: details?.sourceFragments ?? [],
            editorialSections: sections,
            artworkAssets: [ArtworkAsset(id: "\(contentID)-art", role: .primary, assetName: filename, approvalStatus: .candidate)],
            verificationRecords: []
        )
    }
}

/// Candidate artwork shared by the iPhone App and its Widget, excluded from Release.
/// The complete pool uses the existing versioned annual allocator.
enum DailyArtworkCatalog {
    static let defaultWidgetArtworkID = "pack-0259"
    static let directory = CalendarResources.bundle?.resourceURL?.appendingPathComponent("DailyArtwork", isDirectory: true)
    static let widgetCompositions: [String: ArtworkWidgetComposition] = {
        guard let url = directory?.appendingPathComponent("widget-composition.json"),
              let data = try? Data(contentsOf: url),
              let atlas = try? JSONDecoder().decode(ArtworkWidgetCompositionAtlas.self, from: data),
              atlas.version == 1 else { return [:] }
        return atlas.artworks
    }()
    static let pages: [ArtworkPage] = {
        guard let url = directory?.appendingPathComponent("content-packs.json"),
              let data = try? Data(contentsOf: url),
              let pages = try? JSONDecoder().decode([ArtworkPage].self, from: data),
              pages.count == 365, Set(pages.map(\.id)).count == pages.count,
              pages.allSatisfy({ $0.contentPackID == $0.id && $0.reviewStatus == "candidate"
                  && !$0.segments.isEmpty && ["horizontal", "vertical"].contains($0.direction)
                  && FileManager.default.fileExists(atPath: directory!.appendingPathComponent($0.filename).path) }) else {
            assertionFailure("DailyArtwork bundle is missing or invalid")
            return []
        }
        return pages
    }()

    private static let pagesByID = Dictionary(uniqueKeysWithValues: pages.map { ($0.id, $0) })

    fileprivate static let editorialDetails: [String: ArtworkEditorialRecord] = {
        guard let url = directory?.appendingPathComponent("editorial-details.json"),
              let data = try? Data(contentsOf: url),
              let records = try? JSONDecoder().decode([String: ArtworkEditorialRecord].self, from: data) else {
            assertionFailure("Daily artwork editorial details are missing or invalid")
            return [:]
        }
        return records
    }()

    static let englishEditorial: [String: ArtworkEnglishRecord] = {
        guard let url = directory?.appendingPathComponent("english-editorial.json"),
              let data = try? Data(contentsOf: url),
              let atlas = try? JSONDecoder().decode(ArtworkEnglishAtlas.self, from: data),
              atlas.version == 1, atlas.provenance == "project_editorial", atlas.status == "candidate",
              Set(atlas.records.keys) == Set(pages.map(\.id)),
              atlas.records.values.allSatisfy({ !$0.quote.isEmpty && !$0.title.isEmpty &&
                  $0.sections.allSatisfy { $0.languageTag == "en" && !$0.body.isEmpty } }) else {
            assertionFailure("English editorial translations are missing or invalid")
            return [:]
        }
        return atlas.records
    }()

    static func page(contentID: String) -> ArtworkPage? {
        pagesByID[contentID]
    }

    static func page(for date: CalendarDate) -> ArtworkPage? {
        // The 366th illustration has not been supplied. Keep the dedicated
        // Mock leap-day entry rather than repeating any of the 365 pairs.
        guard let schedule = try? AnnualContentAllocator().schedule(
            year: date.year, contentIDs: pages.map(\.id),
            leapDayContentID: MockDailyContentRepository.leapDayID
        ), let id = schedule[date] else { return nil }
        return page(contentID: id)
    }

}
#endif
