import Foundation

public enum ContentReviewStatus: String, Codable, CaseIterable, Sendable {
    case candidate
    case cnVerified = "cn_verified"
    case bilingualVerified = "bilingual_verified"
    case editorialReviewed = "editorial_reviewed"
    case approved
    case blockedVersionMismatch = "blocked_version_mismatch"
}

public enum ContentPackKind: String, Codable, Sendable {
    case base
    case leapDay = "leap_day"
}

public enum QuoteTextKind: String, Codable, Sendable {
    case verbatim
    case editorialExcerpt = "editorial_excerpt"
    case editorialTranslation = "editorial_translation"
    case mockPlaceholder = "mock_placeholder"
}

public enum TranslationProvenance: String, Codable, Sendable {
    case notApplicable = "not_applicable"
    case sourceEdition = "source_edition"
    case projectEditorial = "project_editorial"
    case pending
}

public struct QuoteText: Codable, Equatable, Sendable, Identifiable {
    public let id: String
    public let languageTag: String
    public let kind: QuoteTextKind
    public let text: String
    public let workTitle: String?
    public let volume: Int?
    public let edition: String?
    public let sourceLocator: String?
    public let articleDate: String?
    public let translationProvenance: TranslationProvenance

    public init(
        id: String,
        languageTag: String,
        kind: QuoteTextKind,
        text: String,
        workTitle: String? = nil,
        volume: Int? = nil,
        edition: String? = nil,
        sourceLocator: String? = nil,
        articleDate: String? = nil,
        translationProvenance: TranslationProvenance
    ) {
        self.id = id
        self.languageTag = languageTag
        self.kind = kind
        self.text = text
        self.workTitle = workTitle
        self.volume = volume
        self.edition = edition
        self.sourceLocator = sourceLocator
        self.articleDate = articleDate
        self.translationProvenance = translationProvenance
    }
}

public struct SourceFragment: Codable, Equatable, Sendable, Identifiable {
    public let id: String
    public let quoteTextID: String
    public let sequence: Int
    public let sourceText: String
    public let contextBefore: String?
    public let contextAfter: String?
    public let sourceLocator: String
    public let isContinuousWithPrevious: Bool

    public init(
        id: String,
        quoteTextID: String,
        sequence: Int,
        sourceText: String,
        contextBefore: String? = nil,
        contextAfter: String? = nil,
        sourceLocator: String,
        isContinuousWithPrevious: Bool
    ) {
        self.id = id
        self.quoteTextID = quoteTextID
        self.sequence = sequence
        self.sourceText = sourceText
        self.contextBefore = contextBefore
        self.contextAfter = contextAfter
        self.sourceLocator = sourceLocator
        self.isContinuousWithPrevious = isContinuousWithPrevious
    }
}

public enum EditorialSectionKind: String, Codable, Sendable {
    case excerptNote = "excerpt_note"
    case originalContext = "original_context"
    case historicalBackground = "historical_background"
    case plainLanguageInterpretation = "plain_language_interpretation"
    case translationNote = "translation_note"
    case readingNote = "reading_note"
}

public struct EditorialSection: Codable, Equatable, Sendable, Identifiable {
    public let id: String
    public let languageTag: String
    public let kind: EditorialSectionKind
    public let displayOrder: Int
    public let body: String

    public init(id: String, languageTag: String, kind: EditorialSectionKind, displayOrder: Int, body: String) {
        self.id = id
        self.languageTag = languageTag
        self.kind = kind
        self.displayOrder = displayOrder
        self.body = body
    }
}

public enum ArtworkRole: String, Codable, Sendable {
    case primary
    case widgetSmall = "widget_small"
    case widgetMedium = "widget_medium"
    case widgetLarge = "widget_large"
    case widgetExtraLarge = "widget_extra_large"
    case wallpaper
}

public enum ArtworkApprovalStatus: String, Codable, Sendable {
    case placeholder
    case candidate
    case approved
    case rejected
}

public struct NormalizedArtworkFocus: Codable, Equatable, Sendable {
    public let x: Double
    public let y: Double
    public let safeWidth: Double
    public let safeHeight: Double

    public init(x: Double, y: Double, safeWidth: Double, safeHeight: Double) {
        self.x = x
        self.y = y
        self.safeWidth = safeWidth
        self.safeHeight = safeHeight
    }
}

public struct ArtworkAsset: Codable, Equatable, Sendable, Identifiable {
    public let id: String
    public let role: ArtworkRole
    public let assetName: String?
    public let creator: String?
    public let creationDate: String?
    public let deliveryBatch: String?
    public let licenseScope: String?
    public let sourceChecksumSHA256: String?
    public let focus: NormalizedArtworkFocus?
    public let approvalStatus: ArtworkApprovalStatus

    public init(
        id: String,
        role: ArtworkRole,
        assetName: String? = nil,
        creator: String? = nil,
        creationDate: String? = nil,
        deliveryBatch: String? = nil,
        licenseScope: String? = nil,
        sourceChecksumSHA256: String? = nil,
        focus: NormalizedArtworkFocus? = nil,
        approvalStatus: ArtworkApprovalStatus
    ) {
        self.id = id
        self.role = role
        self.assetName = assetName
        self.creator = creator
        self.creationDate = creationDate
        self.deliveryBatch = deliveryBatch
        self.licenseScope = licenseScope
        self.sourceChecksumSHA256 = sourceChecksumSHA256
        self.focus = focus
        self.approvalStatus = approvalStatus
    }
}

public enum VerificationScope: String, Codable, Sendable {
    case chineseSource = "chinese_source"
    case englishSource = "english_source"
    case editorialContext = "editorial_context"
    case artworkLicense = "artwork_license"
}

public struct VerificationRecord: Codable, Equatable, Sendable, Identifiable {
    public let id: String
    public let scope: VerificationScope
    public let reviewer: String
    public let reviewedAt: String
    public let result: ContentReviewStatus
    public let notes: String?

    public init(
        id: String,
        scope: VerificationScope,
        reviewer: String,
        reviewedAt: String,
        result: ContentReviewStatus,
        notes: String? = nil
    ) {
        self.id = id
        self.scope = scope
        self.reviewer = reviewer
        self.reviewedAt = reviewedAt
        self.result = result
        self.notes = notes
    }
}

public struct DailyContentPack: Codable, Equatable, Sendable, Identifiable {
    public let id: String
    public let kind: ContentPackKind
    public let revision: Int
    public let reviewStatus: ContentReviewStatus
    public let pairingLocked: Bool
    public let quoteTexts: [QuoteText]
    public let sourceFragments: [SourceFragment]
    public let editorialSections: [EditorialSection]
    public let artworkAssets: [ArtworkAsset]
    public let verificationRecords: [VerificationRecord]

    public init(
        id: String,
        kind: ContentPackKind,
        revision: Int,
        reviewStatus: ContentReviewStatus,
        pairingLocked: Bool,
        quoteTexts: [QuoteText],
        sourceFragments: [SourceFragment],
        editorialSections: [EditorialSection],
        artworkAssets: [ArtworkAsset],
        verificationRecords: [VerificationRecord]
    ) {
        self.id = id
        self.kind = kind
        self.revision = revision
        self.reviewStatus = reviewStatus
        self.pairingLocked = pairingLocked
        self.quoteTexts = quoteTexts
        self.sourceFragments = sourceFragments
        self.editorialSections = editorialSections
        self.artworkAssets = artworkAssets
        self.verificationRecords = verificationRecords
    }
}
