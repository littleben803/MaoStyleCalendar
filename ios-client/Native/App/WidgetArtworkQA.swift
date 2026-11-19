#if DEBUG && os(iOS)
import CalendarCore
import Foundation
import SwiftUI
import UIKit
import WidgetKit

private struct ArtworkWidgetSpec {
    let id: String
    let family: WidgetFamily
    let size: CGSize
    let lockScreen: Bool

    static var all: [Self] {
        let portraitFamily: WidgetFamily
        if #available(iOS 27.0, *) {
            portraitFamily = .systemExtraLargePortrait
        } else {
            portraitFamily = .systemLarge
        }
        return [
            .init(id: "small", family: .systemSmall, size: CGSize(width: 170, height: 170), lockScreen: false),
            .init(id: "medium", family: .systemMedium, size: CGSize(width: 364, height: 170), lockScreen: false),
            .init(id: "large", family: .systemLarge, size: CGSize(width: 364, height: 382), lockScreen: false),
            .init(id: "extra-large", family: .systemExtraLarge, size: CGSize(width: 720, height: 350), lockScreen: false),
            .init(id: "portrait", family: portraitFamily, size: CGSize(width: 364, height: 622), lockScreen: false),
            .init(id: "circular", family: .accessoryCircular, size: CGSize(width: 64, height: 64), lockScreen: true),
            .init(id: "rectangular", family: .accessoryRectangular, size: CGSize(width: 172, height: 72), lockScreen: true),
            .init(id: "inline", family: .accessoryInline, size: CGSize(width: 230, height: 24), lockScreen: true)
        ]
    }
}

private struct ArtworkWidgetSample: View {
    let page: ArtworkPage
    let date: CalendarDate
    let spec: ArtworkWidgetSpec

    var body: some View {
        Group {
            if spec.lockScreen {
                ArtworkLockWidgetView(page: page, date: date, family: spec.family)
                    .foregroundStyle(.white).environment(\.colorScheme, .dark).background(Color(white: 0.18))
            } else {
                ArtworkWidgetView(page: page, quote: page.quote, date: date, family: spec.family)
            }
        }
        .frame(width: spec.size.width, height: spec.size.height)
        .clipShape(RoundedRectangle(cornerRadius: spec.lockScreen ? 12 : 22))
    }
}

@MainActor
enum WidgetArtworkQA {
    static func run() async throws {
        if ProcessInfo.processInfo.arguments.contains("--widget-gallery-qa") {
            try await renderWidgetGalleryQA()
            return
        }
        if ProcessInfo.processInfo.arguments.contains("--widget-bottom-alignment-qa")
            || ProcessInfo.processInfo.arguments.contains("--widget-quiet-layout-qa")
            || ProcessInfo.processInfo.arguments.contains("--widget-medium-artwork-qa")
            || ProcessInfo.processInfo.arguments.contains("--widget-extra-large-artwork-qa") {
            try await bottomAlignmentSamples()
            return
        }
        let folder = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("WidgetArtworkQA", isDirectory: true)
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        let date = try CalendarDate.localDate(at: Date())
        var records: [[String: Any]] = []
        let compactSpecs: [ArtworkWidgetSpec] = [
            .init(id: "small-compact", family: .systemSmall,
                  size: CGSize(width: 141, height: 141), lockScreen: false),
            .init(id: "medium-compact", family: .systemMedium,
                  size: CGSize(width: 292, height: 141), lockScreen: false),
            .init(id: "large-compact", family: .systemLarge,
                  size: CGSize(width: 292, height: 302), lockScreen: false),
            .init(id: "rectangular-compact", family: .accessoryRectangular,
                  size: CGSize(width: 148, height: 58), lockScreen: true)
        ]
        for page in DailyArtworkCatalog.pages {
            let region = page.illustrationRegion!
            precondition(region.x >= 0 && region.y >= 0 && region.width > 0 && region.height > 0)
            precondition(region.x + region.width <= 1.0001 && region.y + region.height <= 1.0001)
            for spec in ArtworkWidgetSpec.all + compactSpecs {
                await Task.yield()
                try autoreleasepool {
                    let renderer = ImageRenderer(content: ArtworkWidgetSample(page: page, date: date, spec: spec))
                    renderer.proposedSize = ProposedViewSize(spec.size)
                    renderer.scale = 3
                    renderer.isOpaque = true
                    guard let rendered = renderer.uiImage, let data = rendered.jpegData(compressionQuality: 0.92) else {
                        throw CocoaError(.fileWriteUnknown)
                    }
                    let filename = "\(page.id)-\(spec.id).jpg"
                    try data.write(to: folder.appendingPathComponent(filename))
                    records.append(["id": page.id, "family": spec.id, "file": filename,
                                    "width": rendered.size.width * rendered.scale,
                                    "height": rendered.size.height * rendered.scale])
                }
            }
        }
        WidgetCenter.shared.reloadAllTimelines()
        try JSONSerialization.data(withJSONObject: ["records": records,
                                                   "dateContentID": DailyArtworkCatalog.page(for: date)?.id ?? MockDailyContentRepository.leapDayID],
                                   options: [.prettyPrinted, .sortedKeys])
            .write(to: folder.appendingPathComponent("report.json"), options: .atomic)
    }

    private static func bottomAlignmentSamples() async throws {
        let mediumOnly = ProcessInfo.processInfo.arguments.contains("--widget-medium-artwork-qa")
        let extraLargeOnly = ProcessInfo.processInfo.arguments.contains("--widget-extra-large-artwork-qa")
        let quiet = ProcessInfo.processInfo.arguments.contains("--widget-quiet-layout-qa") || mediumOnly || extraLargeOnly
        let folder = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(extraLargeOnly ? "WidgetExtraLargeArtworkQA" : mediumOnly ? "WidgetMediumArtworkQA" : quiet ? "WidgetQuietLayoutQA" : "WidgetBottomAlignmentQA", isDirectory: true)
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        let data = try Data(contentsOf: DailyArtworkCatalog.directory!.appendingPathComponent("content-packs.json"))
        let metadata = try JSONSerialization.jsonObject(with: data) as! [[String: Any]]
        let date = try CalendarDate(year: 2026, month: 11, day: 11)
        var specs: [(String, WidgetFamily, CGSize)] = [
            ("small", .systemSmall, CGSize(width: 170, height: 170)),
            ("small-compact", .systemSmall, CGSize(width: 141, height: 141)),
            ("medium", .systemMedium, CGSize(width: 364, height: 170)),
            ("medium-compact", .systemMedium, CGSize(width: 292, height: 141)),
            ("large", .systemLarge, CGSize(width: 364, height: 382)),
            ("large-compact", .systemLarge, CGSize(width: 292, height: 302)),
            ("extra-large", .systemExtraLarge, CGSize(width: 720, height: 350))
        ]
        if #available(iOS 27.0, *) {
            specs.append(("duo-portrait", .systemExtraLargePortrait, CGSize(width: 364, height: 622)))
        }
        var states: [(String, Bool, Bool, Bool)] = [
            ("date", true, false, true), ("lunar", true, true, true),
            ("lunar-only", false, true, true), ("quote-only", false, false, true),
            ("no-quote", true, true, false)
        ]
        var records: [[String: Any]] = []
        let ids: [String]
        if mediumOnly || extraLargeOnly {
            var seen = Set<String>()
            ids = DailyArtworkCatalog.pages.filter { seen.insert($0.filename).inserted }.map(\.id)
            specs = specs.filter { $0.1 == (extraLargeOnly ? .systemExtraLarge : .systemMedium) }
            states = states.filter { $0.0 == "lunar" }
        } else {
            ids = quiet ? ["pack-0259", "pack-0047", "pack-0013", "pack-0008", "pack-0011", "pack-0050", "pack-0021", "pack-0335", "pack-0104", "pack-0078", "pack-0080", "pack-0079"]
            : ["pack-0335", "pack-0047", "pack-0021", "pack-0050"]
        }
        for id in ids {
            let page = DailyArtworkCatalog.page(contentID: id)!
            let quote = quiet && id == "pack-0259" ? DailyArtworkCatalog.page(contentID: "pack-0047")!.quote : page.quote
            if quiet { precondition(page.widgetComposition != nil) }
            var marked = metadata.first { $0["id"] as? String == id }!
            marked["quoteColor"] = "#FF00FF"
            marked["dateColor"] = "#0099FF"
            let probe = try JSONDecoder().decode(ArtworkPage.self,
                from: JSONSerialization.data(withJSONObject: marked))
            for (name, family, size) in specs {
                for (state, showsDate, showsLunar, showsQuote) in states {
                    for (style, sample) in [("normal", page), ("probe", probe)] {
                        await Task.yield()
                        try autoreleasepool {
                            let view = ArtworkWidgetView(page: sample, quote: quote, date: date, family: family,
                                display: .init(showsDate: showsDate, showsLunarDate: showsLunar,
                                               showsQuote: showsQuote, followsDailyArtwork: true))
                                .frame(width: size.width, height: size.height)
                                .environment(\.dynamicTypeSize, .large)
                            let renderer = ImageRenderer(content: view)
                            renderer.proposedSize = ProposedViewSize(size)
                            renderer.scale = 2
                            renderer.isOpaque = true
                            let filename = "\(id)-\(name)-\(state)-\(style).png"
                            WidgetQuoteLayoutDiagnostics.last = nil
                            try renderer.uiImage!.pngData()!.write(to: folder.appendingPathComponent(filename))
                            let imageSize = WidgetArtworkImages.image(page, maxPixels: family == .systemSmall ? 640 : 1200)!.size
                            let crop = WidgetArtworkCrop(page: page, size: size, imageSize: imageSize, fittingIllustration: family == .systemMedium || family == .systemExtraLarge)
                            let faces = (page.widgetComposition?.protectedRegions ?? []).map { crop.project($0, into: size) }
                            records.append(["id": id, "family": name, "state": state, "style": style,
                                            "file": filename, "width": size.width, "height": size.height,
                                            "scale": 2,
                                            "selectedQuoteSize": WidgetQuoteLayoutDiagnostics.last?.fontSize ?? 0,
                                            "quoteTruncated": WidgetQuoteLayoutDiagnostics.last?.truncates ?? false,
                                            "showsDate": showsDate, "showsLunar": showsLunar,
                                            "showsQuote": showsQuote, "quote": quote, "artwork": page.filename,
                                            "crop": [crop.sourceRect.minX, crop.sourceRect.minY,
                                                     crop.sourceRect.width, crop.sourceRect.height],
                                            "faces": faces.map { [$0.minX, $0.minY, $0.width, $0.height] },
                                            "illustration": page.illustrationRegion.map {
                                                let rect = crop.project($0, into: size)
                                                return [rect.minX, rect.minY, rect.width, rect.height]
                                            } ?? []])
                        }
                    }
                }
            }
        }
        try JSONSerialization.data(withJSONObject: ["records": records], options: [.prettyPrinted, .sortedKeys])
            .write(to: folder.appendingPathComponent("report.json"), options: .atomic)
    }
}
#endif
