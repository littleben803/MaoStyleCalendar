#if DEBUG && os(iOS)
import CalendarCore
import CoreText
import CryptoKit
import SwiftUI
import UIKit
import WidgetKit

/// Opt-in runtime verification, not run during normal launches.
@MainActor
enum DailyArtworkQA {
    private static var didRun = false
    private static var detailReviewWindow: UIWindow?

    static func runYearbookThumbnails() {
        var shortened = 0
        for page in DailyArtworkCatalog.pages {
            let placement = EnglishArtworkLayout.placement(page: page, height: 540, hasDate: true,
                                                            isThumbnail: true)
            precondition(placement.fontSize == 23, "Yearbook thumbnail font changed: \(page.id)")
            precondition(!placement.usedFallback, "Yearbook thumbnail has no safe quote area: \(page.id)")
            if placement.text != page.localizedQuote(locale: Locale(identifier: "en")) { shortened += 1 }
            let descriptor = UIFontDescriptor(fontAttributes: [.name: "SourceSerif4Roman-ExtraLight",
                UIFontDescriptor.AttributeName(rawValue: kCTFontVariationAttribute as String):
                    [NSNumber(value: 2003265652): 600, NSNumber(value: 1869640570): 23]])
            let font = UIFont(descriptor: descriptor, size: 23)
            let paragraph = NSMutableParagraphStyle(); paragraph.lineSpacing = 2
            let bounds = (placement.text as NSString).boundingRect(
                with: CGSize(width: placement.rect.width, height: .greatestFiniteMagnitude),
                options: [.usesLineFragmentOrigin, .usesFontLeading],
                attributes: [.font: font, .paragraphStyle: paragraph], context: nil)
            precondition(bounds.height + 24 <= placement.rect.height,
                         "Yearbook thumbnail quote overflows: \(page.id)")
        }
        let folder = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("YearbookThumbnailQA", isDirectory: true)
        try! FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        for day in [11, 13, 14] {
            let date = try! CalendarDate(year: 2026, month: 11, day: day)
            let entry = AppCatalog.entries(year: 2026).first { $0.date == date }!
            let page = DailyArtworkCatalog.page(contentID: entry.contentID)!
            let view = ArtworkPageSurface(sample: page, date: date, isThumbnail: true)
                .environment(\.locale, Locale(identifier: "en"))
                .frame(width: 170, height: 255)
            let renderer = ImageRenderer(content: view)
            renderer.scale = 2
            try! renderer.uiImage!.pngData()!.write(to: folder.appendingPathComponent("nov-\(day).png"))
        }
        let result = "\(DailyArtworkCatalog.pages.count) cards at 23pt; \(shortened) excerpts"
        try! result.write(to: folder.appendingPathComponent("result.txt"), atomically: true, encoding: .utf8)
        print("Yearbook thumbnail QA passed: \(result)")
    }

    static func runLocalization() async throws {
        let locale = Locale(identifier: "en")
        let date = try CalendarDate(year: 2026, month: 11, day: 12)
        let folder = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("LocalizationQA", isDirectory: true)
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        var results: [[String: Any]] = []
        precondition(DailyArtworkCatalog.englishEditorial.count == 365)
        for page in DailyArtworkCatalog.pages {
            await Task.yield()
            try autoreleasepool {
                let content = page.content
                let english = content.quoteTexts.filter { $0.languageTag == "en" }
                precondition(english.count == 1 && english[0].kind == .editorialTranslation &&
                    english[0].translationProvenance == .projectEditorial && content.reviewStatus == .candidate)
                let sections = content.localizedEditorialSections(locale: locale)
                precondition(sections.contains { $0.kind == .translationNote })
                precondition(sections.allSatisfy { !$0.body.isEmpty && $0.languageTag == "en" })
                let placement = EnglishArtworkLayout.placement(page: page, height: 540, hasDate: true)
                precondition(placement.rect.minX >= 0 && placement.rect.maxX <= 360 && placement.rect.maxY <= 540)
                let renderer = ImageRenderer(content: ArtworkPageSurface(sample: page, date: date)
                    .environment(\.locale, locale).frame(width: 360, height: 540))
                renderer.scale = 1; renderer.proposedSize = ProposedViewSize(width: 360, height: 540)
                let image = renderer.uiImage!
                try image.jpegData(compressionQuality: 0.85)!.write(to: folder.appendingPathComponent("\(page.id)-en.jpg"))
                results.append(["id": page.id, "fontSize": placement.fontSize,
                                "quoteCharacters": english[0].text.count, "sections": sections.count,
                                "x": placement.rect.minX, "y": placement.rect.minY,
                                "width": placement.rect.width, "height": placement.rect.height])
            }
        }
        // Export through the production path, not a separate test-only composition.
        for id in ["pack-0001", "pack-0006", "pack-0138", "pack-0341"] {
            let page = DailyArtworkCatalog.page(contentID: id)!
            for language in ["en", "zh-Hans"] {
                let output = try WallpaperExporter.export(content: page.content, layout: .original, locale: Locale(identifier: language))
                try Data(contentsOf: output).write(to: folder.appendingPathComponent("\(id)-wallpaper-\(language).jpg"))
            }
        }
        for id in ["pack-0006", "pack-0050", "pack-0138"] {
            let page = DailyArtworkCatalog.page(contentID: id)!
            let specs: [(String, WidgetFamily, CGSize)] = [
                ("small", .systemSmall, CGSize(width: 170, height: 170)),
                ("medium", .systemMedium, CGSize(width: 364, height: 170)),
                ("large", .systemLarge, CGSize(width: 364, height: 382)),
                ("circular", .accessoryCircular, CGSize(width: 76, height: 76)),
                ("rectangular", .accessoryRectangular, CGSize(width: 172, height: 76)),
                ("inline", .accessoryInline, CGSize(width: 240, height: 30))
            ]
            for (name, family, size) in specs {
                let view = Group {
                    if name == "small" || name == "medium" || name == "large" {
                        ArtworkWidgetView(page: page, quote: page.localizedQuote(locale: locale), date: date,
                                          family: family).background(widgetArtworkColor(page.paperColor))
                    } else {
                        ArtworkLockWidgetView(page: page, date: date, family: family)
                            .foregroundStyle(.white).background(.black)
                    }
                }.environment(\.locale, locale).frame(width: size.width, height: size.height)
                let renderer = ImageRenderer(content: view)
                renderer.proposedSize = ProposedViewSize(size); renderer.scale = 2
                try renderer.uiImage!.pngData()!.write(to: folder.appendingPathComponent("\(id)-widget-\(name)-en.png"))
            }
        }
        for id in ["pack-0001", "pack-0138", "pack-0341"] {
            let page = DailyArtworkCatalog.page(contentID: id)!
            for width: CGFloat in [320, 393] {
                let view = LocalizationDetailPreview(content: page.content)
                    .environment(\.locale, locale).frame(width: width, height: 660)
                guard let scene = UIApplication.shared.connectedScenes.compactMap({ $0 as? UIWindowScene }).first else {
                    throw CocoaError(.coderInvalidValue)
                }
                let previousWindow = scene.windows.first { $0.isKeyWindow }
                let window = UIWindow(windowScene: scene)
                window.frame = CGRect(x: 0, y: 0, width: width, height: 660)
                let host = UIHostingController(rootView: view)
                window.rootViewController = host
                window.windowLevel = .normal + 1
                window.makeKeyAndVisible()
                try await Task.sleep(for: .milliseconds(250))
                host.view.setNeedsLayout(); host.view.layoutIfNeeded()
                func snapshot(_ suffix: String) throws {
                    let image = UIGraphicsImageRenderer(bounds: host.view.bounds).image { _ in
                        host.view.drawHierarchy(in: host.view.bounds, afterScreenUpdates: true)
                    }
                    try image.pngData()!.write(to: folder.appendingPathComponent("\(id)-detail-\(Int(width))-en-\(suffix).png"))
                }
                try snapshot("top")
                func scrollView(in view: UIView) -> UIScrollView? {
                    if let scroll = view as? UIScrollView { return scroll }
                    return view.subviews.lazy.compactMap { scrollView(in: $0) }.first
                }
                if let scroll = scrollView(in: host.view) {
                    precondition(scroll.contentSize.height > scroll.bounds.height)
                    for _ in 0..<12 {
                        let end = max(0, scroll.contentSize.height - scroll.bounds.height)
                        scroll.setContentOffset(CGPoint(x: 0, y: end), animated: false)
                        try await Task.sleep(for: .milliseconds(100))
                        let updatedEnd = max(0, scroll.contentSize.height - scroll.bounds.height)
                        if abs(updatedEnd - scroll.contentOffset.y) < 1 { break }
                    }
                    host.view.setNeedsLayout(); host.view.layoutIfNeeded()
                    try snapshot("bottom")
                }
                if id == "pack-0001", width == 320,
                   ProcessInfo.processInfo.arguments.contains("--localization-detail-hold") {
                    detailReviewWindow = window
                    return
                }
                window.isHidden = true
                previousWindow?.makeKeyAndVisible()
            }
        }
        try JSONSerialization.data(withJSONObject: results, options: [.prettyPrinted, .sortedKeys])
            .write(to: folder.appendingPathComponent("results.json"))
    }

    static func run() async throws {
        guard !didRun else { return }
        didRun = true
        if ProcessInfo.processInfo.arguments.contains("--today-solar-term-qa") {
            try renderTodaySolarTermSamples()
            return
        }
        let pages = DailyArtworkCatalog.pages
        precondition(pages.count == 365)
        let date = try CalendarDate.localDate(at: Date(), timeZone: .autoupdatingCurrent)
        let shanghai = TimeZone(identifier: "Asia/Shanghai")!
        precondition(ArtworkLunarDate.text(year: 2026, month: 11, day: 6, timeZone: shanghai) == "丙午年 九月廿八")
        precondition(ArtworkLunarDate.text(year: 2027, month: 2, day: 5, timeZone: shanghai)?.hasPrefix("丙午年") == true)
        precondition(ArtworkLunarDate.text(year: 2027, month: 2, day: 6, timeZone: shanghai)?.hasPrefix("丁未年") == true)

        let folder = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("DailyArtworkQA", isDirectory: true)
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        let raw = try Data(contentsOf: DailyArtworkCatalog.directory!.appendingPathComponent("content-packs.json"))
        let metadata = try JSONSerialization.jsonObject(with: raw) as! [[String: Any]]
        var results: [[String: Any]] = []
        for page in pages {
            await Task.yield()
            try autoreleasepool {
                let bytes = try Data(contentsOf: DailyArtworkCatalog.directory!.appendingPathComponent(page.filename))
                let hash = SHA256.hash(data: bytes).map { String(format: "%02x", $0) }.joined()
                precondition(hash == metadata.first { $0["id"] as? String == page.id }?["assetChecksum"] as? String)
                // 200 KB is the target; dense illustrations may use the documented 350 KB exception.
                precondition(bytes.count <= 350_000)
                precondition(page.content.id == page.id && page.content.pairingLocked && page.content.reviewStatus == .candidate)
                precondition(!page.quote.contains("《毛选》"))
                let image = ArtworkPageImages.image(page)!
                precondition(image.size == CGSize(width: 1024, height: 1536))
                let view = TodayFrontCard(date: date, content: page.content, openDetail: {})
                    .frame(width: 360, height: 540)
                let renderer = ImageRenderer(content: view)
                renderer.proposedSize = ProposedViewSize(width: 360, height: 540)
                renderer.scale = 3
                renderer.isOpaque = true
                let rendered = renderer.uiImage!
                try rendered.jpegData(compressionQuality: 0.92)!.write(to: folder.appendingPathComponent("\(page.id).jpg"))
                results.append(["id": page.id, "bytes": bytes.count, "sha256": hash,
                                "direction": page.direction, "contentID": page.content.id,
                                "renderedWidth": Int(rendered.size.width * rendered.scale),
                                "renderedHeight": Int(rendered.size.height * rendered.scale)])
            }
        }
        var yearCounts: [String: Int] = [:]
        for year in [2026, 2028] {
            let items = AppCatalog.items(year: year)
            precondition(items.count == (year == 2028 ? 366 : 365))
            for month in 1...12 { precondition(items.contains { $0.date.month == month }) }
            for item in items {
                let expectedID = DailyArtworkCatalog.page(for: item.date)?.id ?? MockDailyContentRepository.leapDayID
                precondition(item.content.id == expectedID)
            }
            let illustratedItems = items.filter { $0.content.id != MockDailyContentRepository.leapDayID }
            precondition(illustratedItems.count == 365)
            precondition(Set(illustratedItems.map { $0.content.id }).count == 365)
            let expected = try AnnualContentAllocator().schedule(
                year: year, contentIDs: pages.map(\.id), leapDayContentID: MockDailyContentRepository.leapDayID
            )
            for item in items { precondition(item.content.id == expected[item.date]) }
            yearCounts[String(year)] = items.count
        }
        precondition(WallpaperLayout.allCases.count == 2)
        precondition(AppCatalog.wallpaperContents.map(\.id) == pages.map(\.id))
        var geometries: [[String: Any]] = []
        for size in [CGSize(width: 750, height: 1334), CGSize(width: 1206, height: 2622),
                     CGSize(width: 1320, height: 2868), CGSize(width: 1440, height: 3200),
                     CGSize(width: 1440, height: 1920)] {
            let rect = WallpaperSafeComposition.artworkRect(in: size)
            precondition(rect.minX == 0 && rect.maxX == size.width)
            precondition(abs(rect.midY / size.height - 0.53) < 0.0001)
            precondition(abs(rect.height / rect.width - 1.5) < 0.0001)
            geometries.append(["width": size.width, "height": size.height,
                               "artworkX": rect.minX, "artworkY": rect.minY,
                               "artworkWidth": rect.width, "artworkHeight": rect.height])
        }
        var wallpapers: [[String: Any]] = []
        for page in pages {
            for mode in WallpaperLayout.allCases {
                await Task.yield()
                try autoreleasepool {
                    let url = try WallpaperExporter.export(content: page.content, layout: mode)
                    let data = try Data(contentsOf: url)
                    let image = UIImage(data: data)!
                    precondition(image.size == WallpaperExporter.outputPixelSize)
                    let filename = "\(page.id)-\(mode.rawValue).jpg"
                    try data.write(to: folder.appendingPathComponent(filename))
                    wallpapers.append(["id": page.id, "mode": mode.rawValue, "bytes": data.count,
                                       "width": image.size.width, "height": image.size.height])
                }
            }
        }
        try JSONSerialization.data(withJSONObject: ["pages": results, "allocation": "year_seeded_365_unique", "lunarChecks": "passed",
                                                    "yearbookCounts": yearCounts, "wallpapers": wallpapers,
                                                    "safeGeometries": geometries],
                                   options: [.prettyPrinted, .sortedKeys])
            .write(to: folder.appendingPathComponent("report.json"), options: .atomic)
    }

    private static func renderTodaySolarTermSamples() throws {
        let folder = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("TodaySolarTermQA", isDirectory: true)
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        var seen = Set<String>()
        let samples = DailyArtworkCatalog.pages.filter { seen.insert($0.datePosition).inserted }
        for page in samples {
            for (label, day) in [("solar-term", 22), ("ordinary", 26)] {
                let date = try CalendarDate(year: 2026, month: 11, day: day)
                let view = TodayFrontCard(date: date, content: page.content, openDetail: {})
                    .frame(width: 360, height: 540)
                    .environment(\.locale, Locale(identifier: "zh_CN"))
                let renderer = ImageRenderer(content: view)
                renderer.proposedSize = ProposedViewSize(width: 360, height: 540)
                renderer.scale = 2
                renderer.isOpaque = true
                try renderer.uiImage!.pngData()!.write(to: folder.appendingPathComponent("\(page.id)-\(page.datePosition)-\(label).png"))
            }
        }
    }
}
private struct LocalizationDetailPreview: View {
    let content: DailyContentPack
    @AccessibilityFocusState private var headingFocused: Bool
    var body: some View {
        TodayDetailCard(content: content, close: {}, headingFocused: $headingFocused,
                        showsBinding: false, showsBackingSheets: false)
    }
}
#endif
