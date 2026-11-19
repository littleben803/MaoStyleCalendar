#if os(iOS)
import CalendarCore
import ImageIO
import SwiftUI
import UIKit
import WidgetKit

@MainActor
enum WidgetArtworkImages {
    private static let cache: NSCache<NSString, UIImage> = {
        let result = NSCache<NSString, UIImage>()
        result.totalCostLimit = 8 * 1024 * 1024
        result.countLimit = 2
        return result
    }()

    static func image(_ page: ArtworkPage, maxPixels: Int) -> UIImage? {
        let key = "\(page.id)-\(maxPixels)" as NSString
        if let image = cache.object(forKey: key) { return image }
        guard let url = DailyArtworkCatalog.directory?.appendingPathComponent(page.filename),
              let source = CGImageSourceCreateWithURL(url as CFURL, nil),
              let decoded = CGImageSourceCreateThumbnailAtIndex(source, 0, [
                kCGImageSourceCreateThumbnailFromImageAlways: true,
                kCGImageSourceCreateThumbnailWithTransform: true,
                kCGImageSourceThumbnailMaxPixelSize: maxPixels
              ] as CFDictionary) else { return nil }
        let image = UIImage(cgImage: decoded)
        cache.setObject(image, forKey: key, cost: decoded.bytesPerRow * decoded.height)
        return image
    }
}

struct WidgetArtworkCrop {
    let width: CGFloat
    let height: CGFloat
    let left: CGFloat
    let top: CGFloat
    let sourceRect: CGRect

    init(page: ArtworkPage, size: CGSize, imageSize: CGSize, fittingIllustration: Bool = false) {
        if fittingIllustration {
            var subject = page.illustrationRegion.map {
                CGRect(x: $0.x, y: $0.y, width: $0.width, height: $0.height)
            } ?? CGRect(x: 0, y: 0, width: 1, height: 1)
            let faces = page.widgetComposition?.protectedRegions ?? []
            for face in faces {
                subject = subject.union(CGRect(x: face.x, y: face.y, width: face.width, height: face.height))
            }
            subject = subject.intersection(CGRect(x: 0, y: 0, width: 1, height: 1))
            var scale = size.width * (2.0 / 3.0) / max(1, imageSize.width * subject.width)
            let faceBounds = faces.reduce(CGRect.null) { result, face in
                result.union(CGRect(x: face.x, y: face.y, width: face.width, height: face.height))
            }.intersection(CGRect(x: 0, y: 0, width: 1, height: 1))
            if !faceBounds.isNull {
                // Exceptionally tall face groups take priority over filling the whole artwork region.
                scale = min(scale, size.height / max(1, imageSize.height * faceBounds.height))
            }
            width = imageSize.width * scale
            height = imageSize.height * scale
            left = subject.maxX - size.width / width
            let visibleHeight = size.height / height
            var sourceTop = max(0, min(1 - visibleHeight, subject.minY))
            if !faceBounds.isNull {
                let lower = max(0, faceBounds.maxY - visibleHeight)
                let upper = min(max(0, 1 - visibleHeight), faceBounds.minY)
                sourceTop = min(max(sourceTop, lower), upper)
            }
            top = sourceTop
            sourceRect = CGRect(x: left, y: top, width: size.width / width, height: size.height / height)
            return
        }
        let scale = max(size.width / imageSize.width, size.height / imageSize.height)
        width = imageSize.width * scale
        height = imageSize.height * scale
        let visibleWidth = size.width / width
        let visibleHeight = size.height / height
        let region = page.illustrationRegion
            ?? ArtworkIllustrationRegion(x: 0, y: 0, width: 1, height: 1)
        left = min(max(0, region.x + (region.width - visibleWidth) / 2), 1 - visibleWidth)
        let excessHeight = region.height - visibleHeight
        let subjectOffset = excessHeight > 0 ? min(0.04, excessHeight * 0.20) : excessHeight
        top = min(max(0, region.y + subjectOffset), 1 - visibleHeight)
        sourceRect = CGRect(x: left, y: top, width: visibleWidth, height: visibleHeight)
    }

    func project(_ region: ArtworkIllustrationRegion, into size: CGSize) -> CGRect {
        CGRect(x: (region.x - sourceRect.minX) / sourceRect.width * size.width,
               y: (region.y - sourceRect.minY) / sourceRect.height * size.height,
               width: region.width / sourceRect.width * size.width,
               height: region.height / sourceRect.height * size.height)
    }
}

private struct WidgetArtworkBackground: View {
    let page: ArtworkPage
    let size: CGSize
    let maxPixels: Int
    var fittingIllustration = false

    var body: some View {
        if let image = WidgetArtworkImages.image(page, maxPixels: maxPixels),
           size.width > 0, size.height > 0 {
            let crop = WidgetArtworkCrop(page: page, size: size, imageSize: image.size, fittingIllustration: fittingIllustration)
            if fittingIllustration {
                Image(uiImage: image)
                    .resizable()
                    .frame(width: crop.width, height: crop.height)
                    .offset(x: -crop.left * crop.width, y: -crop.top * crop.height)
                    .frame(width: size.width, height: size.height, alignment: .topLeading)
                    .mask {
                        HStack(spacing: 0) {
                            Color.clear.frame(width: size.width / 3)
                            LinearGradient(stops: [.init(color: .clear, location: 0),
                                                   .init(color: .black, location: 0.06),
                                                   .init(color: .black, location: 1)],
                                           startPoint: .leading, endPoint: .trailing)
                        }
                    }
                    .clipped()
                    .accessibilityHidden(true)
            } else {
                Image(uiImage: image)
                    .resizable()
                    .frame(width: crop.width, height: crop.height)
                    .mask { Rectangle() }
                    .offset(x: -crop.left * crop.width, y: -crop.top * crop.height)
                    .frame(width: size.width, height: size.height, alignment: .topLeading)
                    .clipped()
                    .accessibilityHidden(true)
            }
        }
    }
}

private struct WidgetQuietnessGrid {
    let columns = 24
    let rows: Int
    let size: CGSize
    let sums: [CGFloat]
    let protectedRects: [CGRect]

    init(composition: ArtworkWidgetComposition?, region: ArtworkIllustrationRegion?,
         crop: WidgetArtworkCrop, size: CGSize, artworkLeading: CGFloat = 0) {
        self.size = size
        rows = max(12, min(48, Int((24 * size.height / size.width).rounded())))
        var sums = Array(repeating: CGFloat.zero, count: 25 * (rows + 1))
        for y in 0..<rows {
            for x in 0..<24 {
                let sx = crop.sourceRect.minX + (CGFloat(x) + 0.5) / 24 * crop.sourceRect.width
                let sy = crop.sourceRect.minY + (CGFloat(y) + 0.5) / CGFloat(rows) * crop.sourceRect.height
                let weight: CGFloat
                if (CGFloat(x) + 0.5) / 24 * size.width < artworkLeading
                    || sx < 0 || sx > 1 || sy < 0 || sy > 1 {
                    weight = 0
                } else if let composition {
                    let ix = min(composition.columns - 1, max(0, Int(sx * CGFloat(composition.columns))))
                    let iy = min(composition.rows - 1, max(0, Int(sy * CGFloat(composition.rows))))
                    weight = CGFloat(composition.weights[iy * composition.columns + ix]) / 255
                } else if let region {
                    weight = CGRect(x: region.x, y: region.y, width: region.width, height: region.height)
                        .contains(CGPoint(x: sx, y: sy)) ? 0.65 : 0.02
                } else { weight = 0.1 }
                let index = (y + 1) * 25 + x + 1
                sums[index] = weight + sums[index - 1] + sums[index - 25] - sums[index - 26]
            }
        }
        self.sums = sums
        protectedRects = (composition?.protectedRegions ?? []).map { crop.project($0, into: size) }
            .filter { $0.intersects(CGRect(origin: .zero, size: size)) }
    }

    func ink(in rect: CGRect) -> CGFloat {
        let x0 = max(0, min(columns - 1, Int(floor(rect.minX / size.width * CGFloat(columns)))))
        let y0 = max(0, min(rows - 1, Int(floor(rect.minY / size.height * CGFloat(rows)))))
        let x1 = max(x0 + 1, min(columns, Int(ceil(rect.maxX / size.width * CGFloat(columns)))))
        let y1 = max(y0 + 1, min(rows, Int(ceil(rect.maxY / size.height * CGFloat(rows)))))
        let total = sums[y1 * 25 + x1] - sums[y0 * 25 + x1] - sums[y1 * 25 + x0] + sums[y0 * 25 + x0]
        return max(0, total / CGFloat((x1 - x0) * (y1 - y0)))
    }

    func faceOverlap(in rect: CGRect) -> CGFloat {
        protectedRects.reduce(CGFloat.zero) { result, face in
            let overlap = face.insetBy(dx: -2, dy: -2).intersection(rect)
            guard !overlap.isNull else { return result }
            return result + overlap.width * overlap.height / max(1, face.width * face.height)
        }
    }
}

private struct WidgetQuoteCandidate {
    let width: CGFloat
    let fontSize: CGFloat
    var truncates = false
}

#if DEBUG
enum WidgetQuoteLayoutDiagnostics {
    private final class Storage: @unchecked Sendable {
        let lock = NSLock()
        var value: (fontSize: CGFloat, truncates: Bool)?
    }
    private static let storage = Storage()
    static var last: (fontSize: CGFloat, truncates: Bool)? {
        get { storage.lock.withLock { storage.value } }
        set { storage.lock.withLock { storage.value = newValue } }
    }
}

#endif

private struct WidgetQuietQuoteLayout: Layout {
    let size: CGSize
    let crop: WidgetArtworkCrop
    let composition: ArtworkWidgetComposition?
    let region: ArtworkIllustrationRegion?
    let inset: CGFloat
    let leadingInset: CGFloat
    let bottomInset: CGFloat
    let gap: CGFloat
    let hasHeader: Bool
    let minimumHeaderWidth: CGFloat
    let artworkLeading: CGFloat
    let candidates: [WidgetQuoteCandidate]

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize { size }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        guard subviews.count == candidates.count + 1 else { return }
        let width = max(1, size.width - leadingInset - inset)
        let headerWidth = hasHeader ? min(width, max(minimumHeaderWidth, subviews[0].sizeThatFits(.unspecified).width)) : 0
        let header = hasHeader ? subviews[0].sizeThatFits(ProposedViewSize(width: headerWidth, height: nil)) : .zero
        subviews[0].place(at: CGPoint(x: bounds.minX + leadingInset, y: bounds.minY + inset),
                          proposal: ProposedViewSize(width: headerWidth, height: header.height))
        guard !candidates.isEmpty else { return }
        let top = inset + (hasHeader ? header.height + gap : 0)
        let free = CGRect(x: leadingInset, y: top, width: width,
                          height: max(1, size.height - bottomInset - top))
        let grid = WidgetQuietnessGrid(composition: composition, region: region, crop: crop, size: size, artworkLeading: artworkLeading)
        var areas = [free]
        let sideX = leadingInset + headerWidth + gap
        if hasHeader, size.width - inset - sideX >= 88 {
            areas.append(CGRect(x: sideX, y: inset, width: size.width - inset - sideX,
                                height: max(1, size.height - inset - bottomInset)))
        }
        // Measure the exact wrapped text that will be drawn, without a second fitting pass.
        let measured = candidates.enumerated().map { index, candidate in
            subviews[index + 1].sizeThatFits(ProposedViewSize(width: candidate.width, height: candidate.truncates ? free.height : nil))
        }
        let fitting = candidates.indices.filter { index in
            areas.contains { candidates[index].width <= $0.width + 0.5 && measured[index].height <= $0.height }
        }
        let complete = fitting.filter { !candidates[$0].truncates }
        let allowed = Set(complete.isEmpty ? fitting : complete)
        let largestFittingFont = candidates.enumerated().filter { index, candidate in
            areas.contains { candidate.width <= $0.width + 0.5 && measured[index].height <= $0.height }
        }.map { $0.element.fontSize }.max() ?? 1
        var bestScore = CGFloat.infinity
        var chosen = free
        var chosenIndex = 1
        for area in areas {
            for (index, candidate) in candidates.enumerated() {
                let textSize = measured[index]
                guard allowed.contains(index), candidate.width <= area.width + 0.5,
                      textSize.height <= area.height else { continue }
                let xRange = max(0, area.width - candidate.width)
                let yRange = max(0, area.height - textSize.height)
                for column in 0...(xRange > 1 ? 4 : 0) {
                    for row in 0...(yRange > 1 ? 16 : 0) {
                        let rect = CGRect(x: area.minX + xRange * CGFloat(column) / 4,
                                          y: area.minY + yRange * CGFloat(row) / 16,
                                          width: candidate.width, height: textSize.height)
                        let surrounding = rect.insetBy(dx: -3, dy: -3).intersection(area)
                        let overlap = grid.faceOverlap(in: rect)
                        let facePenalty: CGFloat = overlap > 0 ? 1000 + overlap * 100 : 0
                        let score = grid.ink(in: surrounding) * 3 + facePenalty
                            + (1 - candidate.fontSize / largestFittingFont) * 0.9
                            + abs(rect.midY - area.midY) / max(1, area.height) * 0.025
                            + CGFloat(column) * 0.002
                        if score < bestScore {
                            bestScore = score
                            chosen = rect
                            chosenIndex = index + 1
                        }
                    }
                }
            }
        }
        #if DEBUG
        if ProcessInfo.processInfo.arguments.contains("--widget-quiet-layout-qa") {
            let selected = candidates[chosenIndex - 1]
            WidgetQuoteLayoutDiagnostics.last = (selected.fontSize, selected.truncates)
        }
        #endif
        // Fixed-width candidates preserve wrapping during measurement; draw only the selected one.
        for index in 1..<subviews.count where index != chosenIndex {
            subviews[index].place(at: CGPoint(x: bounds.minX - size.width * 4, y: bounds.minY - size.height * 4),
                                  proposal: ProposedViewSize(width: candidates[index - 1].width, height: 1))
        }
        subviews[chosenIndex].place(at: CGPoint(x: bounds.minX + chosen.minX, y: bounds.minY + chosen.minY),
                          proposal: ProposedViewSize(width: chosen.width, height: chosen.height))
    }
}

func widgetArtworkColor(_ hex: String) -> Color {
    let value = UInt32(hex.dropFirst(), radix: 16) ?? 0
    return Color(red: Double((value >> 16) & 255) / 255,
                 green: Double((value >> 8) & 255) / 255, blue: Double(value & 255) / 255)
}

struct ArtworkWidgetView: View {
    @Environment(\.locale) private var locale
    private static let wideQuoteFraction: CGFloat = 2.0 / 3.0
    private static let mediumReferenceDayScale: CGFloat = 0.52
    private static let artworkOpacityBehindQuote = 0.78
    private static let lightQuoteHalo = widgetArtworkColor("#FFF4DC")
    private static let darkQuoteHalo = widgetArtworkColor("#26150F")

    let page: ArtworkPage
    let quote: String?
    let date: CalendarDate
    let family: WidgetFamily
    var display = DesktopWidgetDisplayPreferences()

    var paper: Color { widgetArtworkColor(page.paperColor) }
    private var accent: Color { widgetArtworkColor(page.dateColor) }
    private var lunarDate: String? { locale.calendarIsChinese && display.showsLunarDate ? WidgetArtworkDate.lunar(date) : nil }
    private var small: Bool { family == .systemSmall }
    private var medium: Bool { family == .systemMedium }
    // Use the target family, including when its iPad layout is previewed on iPhone.
    private var iPadWide: Bool { family == .systemExtraLarge }
    private var fitsHorizontalArtwork: Bool { medium || iPadWide }
    private var dateSizeIncrease: CGFloat { iPadWide ? 2 : 0 }
    private var metadataSizeIncrease: CGFloat { iPadWide ? 3 : 0 }
    private var quoteSizeIncrease: CGFloat { iPadWide ? 9 : 0 }
    private var leadingInsetIncrease: CGFloat { iPadWide ? 12 : 0 }

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .topLeading) {
                WidgetArtworkBackground(page: page, size: geometry.size, maxPixels: small ? 640 : 1200,
                                        fittingIllustration: fitsHorizontalArtwork)
                    .opacity(visibleQuote == nil ? 1 : Self.artworkOpacityBehindQuote)
                foreground(size: geometry.size)
            }
        }
        .background(paper)
        .clipped()
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilitySummary)
    }

    private var keepsPortraitLayout: Bool {
        if #available(iOS 27.0, *) { return family == .systemExtraLargePortrait }
        return false
    }

    @ViewBuilder
    private func foreground(size: CGSize) -> some View {
        if keepsPortraitLayout {
            topAlignedForeground(size: size)
        } else {
            adaptiveForeground(size: size)
        }
    }

    private func adaptiveForeground(size: CGSize) -> some View {
        let inset: CGFloat = small ? min(10, size.width * 0.06) : (medium ? 12 : 16)
        let leadingInset = inset + leadingInsetIncrease
        let availableWidth = max(1, size.width - leadingInset - inset)
        let quoteWidths: [CGFloat] = visibleQuote == nil ? []
            : (fitsHorizontalArtwork ? [CGFloat(1), 0.8, 0.64, 0.48, 0.36, 0.28] : [CGFloat(1), 0.8, 0.64, 0.48, 0.36])
                .map { availableWidth * $0 }.filter { $0 >= 88 || $0 == availableWidth }
        let mediumDaySize = min(63, size.height * 0.37)
        let daySize = small ? mediumDaySize * Self.mediumReferenceDayScale
            : (medium ? mediumDaySize : min(96, size.height * 0.25)) + dateSizeIncrease
        let quoteSize: CGFloat = iPadWide ? 42 : (small ? 13 : (medium ? 17 : 21))
        let minimumQuoteSize: CGFloat = iPadWide ? 36 : (small ? 11 : (medium ? 13 : 16))
        var candidates = quoteWidths.flatMap { width in
            stride(from: Int(quoteSize), through: Int(minimumQuoteSize), by: -1).map {
                WidgetQuoteCandidate(width: width, fontSize: CGFloat($0))
            }
        }
        if visibleQuote != nil {
            // Only used when no full quotation fits at the minimum readable size.
            candidates.append(WidgetQuoteCandidate(width: availableWidth, fontSize: minimumQuoteSize, truncates: true))
        }
        let bottomInset: CGFloat = medium ? 18 : inset
        let metadataSize = (small || medium ? 12 : 18) + metadataSizeIncrease

        let imageSize = WidgetArtworkImages.image(page, maxPixels: small ? 640 : 1200)?.size
            ?? CGSize(width: 1024, height: 1536)
        let crop = WidgetArtworkCrop(page: page, size: size, imageSize: imageSize, fittingIllustration: fitsHorizontalArtwork)
        return WidgetQuietQuoteLayout(size: size, crop: crop, composition: page.widgetComposition,
                                      region: page.illustrationRegion, inset: inset, leadingInset: leadingInset,
                                      bottomInset: bottomInset, gap: medium ? 6 : (small ? 8 : 12),
                                      hasHeader: display.showsDate || lunarDate != nil,
                                      // WidgetKit may underestimate the intrinsic date width on the Home Screen.
                                      minimumHeaderWidth: display.showsDate ? metadataSize * 9 : 0,
                                      artworkLeading: fitsHorizontalArtwork ? size.width / 3 : 0, candidates: candidates) {
            VStack(alignment: .leading, spacing: small || medium ? 3 : 6) {
                if display.showsDate {
                    dayLabel(size: daySize)
                    monthLabel(size: metadataSize)
                }
                lunarLabel(size: (small || medium ? 9 : 13) + metadataSizeIncrease)
            }
            .fixedSize(horizontal: false, vertical: true)
            ForEach(candidates.indices, id: \.self) { index in
                let candidate = candidates[index]
                if candidate.truncates {
                    readableQuoteFallback(visibleQuote ?? "", size: candidate.fontSize)
                        .frame(width: candidate.width, alignment: .leading)
                } else {
                    quoteLabel(visibleQuote ?? "", size: candidate.fontSize)
                        .frame(width: candidate.width, alignment: .leading)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }

    @ViewBuilder private func readableQuoteFallback(_ quote: String, size: CGFloat) -> some View {
        let ink = widgetArtworkColor(page.quoteColor)
        let halo = contrastingQuoteHalo(for: ink)
        let label = VStack(alignment: .leading, spacing: 2) {
            Text(verbatim: quote)
                .font(CalendarTypography.font(locale.calendarIsChinese ? .chineseQuote : .englishQuote, size: size))
                .truncationMode(.tail)
        }
            .foregroundStyle(ink)
            .shadow(color: halo, radius: 0.7)
            .shadow(color: halo.opacity(0.9), radius: max(1.3, size * 0.12))
        if #available(iOS 26, *), small || medium {
            label.lineHeight(.exact(points: size * 1.15))
        } else {
            label
        }
    }

    private func topAlignedForeground(size: CGSize) -> some View {
        let inset: CGFloat = small ? min(10, size.width * 0.06) : (medium ? 12 : 16)
        let leadingInset = inset + leadingInsetIncrease
        let availableWidth = max(1, size.width - leadingInset - inset)
        let textWidth: CGFloat
        switch family {
        case .systemMedium:
            textWidth = min(availableWidth, max(1, size.width * Self.wideQuoteFraction))
        case .systemExtraLarge:
            textWidth = availableWidth * Self.wideQuoteFraction
        default:
            textWidth = availableWidth
        }
        let mediumDaySize = min(63, size.height * 0.37)
        let adaptiveDaySize = (medium ? mediumDaySize : min(96, size.height * 0.25)) + dateSizeIncrease
        func daySize(_ scale: CGFloat = 1) -> CGFloat {
            small ? mediumDaySize * Self.mediumReferenceDayScale : adaptiveDaySize * scale
        }
        let quoteSize: CGFloat = (small ? 13 : (medium ? 14 : 21)) + quoteSizeIncrease
        let increase: CGFloat = medium ? 3 : (small ? 2 : 0)
        let bottomInset: CGFloat = display.showsQuote && (small || medium) ? (small ? 4 : 18) : inset
        return ViewThatFits(in: .vertical) {
            textStack(width: textWidth, daySize: daySize(), quoteSize: quoteSize + increase)
            if iPadWide {
                ForEach(1...8, id: \.self) { reduction in
                    textStack(width: textWidth, daySize: daySize(), quoteSize: quoteSize - CGFloat(reduction))
                }
            }
            textStack(width: textWidth, daySize: daySize(0.9), quoteSize: quoteSize * 0.9 + increase)
            textStack(width: textWidth, daySize: daySize(0.78), quoteSize: quoteSize * 0.8 + increase)
            textStack(width: textWidth, daySize: daySize(0.65), quoteSize: quoteSize * 0.72 + increase)
            textStack(width: textWidth, daySize: daySize(Self.mediumReferenceDayScale), quoteSize: quoteSize * 0.63 + increase)
            textStack(width: textWidth, daySize: daySize(0.45), quoteSize: quoteSize * 0.59 + increase, compact: true)
            textStack(width: textWidth, daySize: daySize(0.4), quoteSize: quoteSize * 0.55 + increase, compact: true)
            textStack(width: textWidth, daySize: daySize(0.4), quoteSize: quoteSize * 0.51 + increase, compact: true)
            if increase > 0 {
                // Keep the original compact fallback for exceptionally long quotations.
                textStack(width: textWidth, daySize: daySize(0.4), quoteSize: quoteSize * 0.51, compact: true)
            }
        }
        .frame(width: textWidth, height: max(1, size.height - inset - bottomInset), alignment: .topLeading)
        .padding(EdgeInsets(top: inset, leading: leadingInset, bottom: bottomInset, trailing: inset))
    }

    private func textStack(width: CGFloat, daySize: CGFloat, quoteSize: CGFloat, compact: Bool = false) -> some View {
        let compactDate = compact && !small
        return VStack(alignment: .leading, spacing: compactDate ? 2 : (small || medium ? 3 : 6)) {
            if display.showsDate {
                dayLabel(size: daySize)
                monthLabel(size: (compactDate ? 10 : (small || medium ? 12 : 18)) + metadataSizeIncrease)
            }
            lunarLabel(size: (compactDate ? 8 : (small || medium ? 9 : 13)) + metadataSizeIncrease)
            if let visibleQuote {
                quoteLabel(visibleQuote, size: small ? min(quoteSize, 13) : quoteSize)
                    .padding(.top, display.showsDate || lunarDate != nil ? (small || medium ? 5 : 12) : 0)
            }
        }
        // Give each candidate its final width before ViewThatFits measures its wrapped height.
        .frame(width: width, alignment: .leading)
        .fixedSize(horizontal: false, vertical: true)
    }

    private func dayLabel(size: CGFloat) -> some View {
        Text(String(date.day))
            .font(CalendarTypography.font(.date, size: size))
            .foregroundStyle(accent)
            .widgetAccentable()
            .fixedSize()
            .frame(height: size * 0.82, alignment: .top)
            .offset(y: -size * 0.15)
    }

    private func monthLabel(size: CGFloat) -> some View {
        Text(locale.calendarIsChinese ? "\(date.month)月 · \(weekday)" : date.displayDate(locale: locale, template: "MMMEEE"))
            .font(CalendarTypography.font(.chineseTitle, size: size))
            .foregroundStyle(accent)
            .lineLimit(1)
            .minimumScaleFactor(0.8)
    }

    @ViewBuilder
    private func lunarLabel(size: CGFloat) -> some View {
        if let lunarDate {
            Text(lunarDate)
                .font(CalendarTypography.font(.chineseBody, size: size))
                .foregroundStyle(accent)
                .shadow(color: .white.opacity(0.65), radius: 0.65, y: 0.5)
        }
    }

    private var visibleQuote: String? { display.showsQuote ? quote : nil }

    @ViewBuilder private func quoteLabel(_ quote: String, size: CGFloat) -> some View {
        let ink = widgetArtworkColor(page.quoteColor)
        let halo = contrastingQuoteHalo(for: ink)
        let label = artworkWidgetQuote(quote, size: size, locale: locale)
            .foregroundStyle(ink)
            .shadow(color: halo, radius: 0.7)
            .shadow(color: halo.opacity(0.9), radius: max(1.3, size * 0.12))
        if #available(iOS 26, *), small || medium {
            label.lineHeight(.exact(points: size * 1.15))
        } else {
            label
        }
    }

    private func contrastingQuoteHalo(for ink: Color) -> Color {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        UIColor(ink).getRed(&red, green: &green, blue: &blue, alpha: nil)
        let brightness = red * 0.2126 + green * 0.7152 + blue * 0.0722
        return brightness >= 0.5 ? Self.darkQuoteHalo : Self.lightQuoteHalo
    }

    private var weekday: String { date.displayDate(locale: locale, template: locale.calendarIsChinese ? "EEEE" : "EEE") }

    private var accessibilitySummary: String {
        var parts: [String] = []
        if display.showsDate { parts.append(date.displayDate(locale: locale, template: "yMMMEd")) }
        if let lunarDate { parts.append(lunarDate) }
        if let visibleQuote {
            parts.append(visibleQuote)
        }
        if parts.isEmpty { parts.append(locale.calendarText("日历插画", "Calendar artwork")) }
        return parts.joined(separator: "，")
    }
}

enum WidgetArtworkDate {
    static func lunar(_ date: CalendarDate) -> String? {
        ArtworkLunarDate.text(year: date.year, month: date.month, day: date.day)
    }
}

private func artworkWidgetQuote(_ quote: String, size: CGFloat, locale: Locale) -> some View {
    VStack(alignment: .leading, spacing: 3) {
        Text(verbatim: quote)
            .font(CalendarTypography.font(locale.calendarIsChinese ? .chineseQuote : .englishQuote, size: size))
            .lineLimit(nil)
            .fixedSize(horizontal: false, vertical: true)
    }
    .frame(maxWidth: .infinity, alignment: .leading)
}

struct ArtworkLockWidgetView: View {
    @Environment(\.locale) private var locale
    let page: ArtworkPage
    let date: CalendarDate
    let family: WidgetFamily

    private var inkMaskBrightness: Double {
        let value = UInt32(page.paperColor.dropFirst(), radix: 16) ?? 0
        let red = Double((value >> 16) & 255) / 255
        let green = Double((value >> 8) & 255) / 255
        let blue = Double(value & 255) / 255
        return (red * 0.2126 + green * 0.7152 + blue * 0.0722) * 0.67 - 0.5
    }

    private var lockArtwork: some View {
        GeometryReader { geometry in
            Rectangle().fill(Color.primary)
                .mask {
                    WidgetArtworkBackground(page: page, size: geometry.size, maxPixels: 640)
                        .saturation(0).colorInvert()
                        .brightness(inkMaskBrightness).contrast(8).luminanceToAlpha()
                }
                .opacity(0.18)
        }
        .accessibilityHidden(true)
    }

    var body: some View {
        Group {
            switch family {
            case .accessoryCircular:
                VStack(spacing: 0) {
                    Text(String(date.day)).font(CalendarTypography.font(.date, size: 28))
                    Text(locale.calendarMonth(date.month)).font(CalendarTypography.font(.chineseBody, size: 9))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background { lockArtwork.clipShape(Circle()) }
            case .accessoryRectangular:
                ViewThatFits(in: .vertical) {
                    HStack(spacing: 6) {
                        VStack(spacing: 0) {
                            Text(String(date.day)).font(CalendarTypography.font(.date, size: 28))
                            Text(locale.calendarMonth(date.month)).font(CalendarTypography.font(.chineseBody, size: 9))
                        }
                        artworkWidgetQuote(page.localizedQuote(locale: locale), size: 11, locale: locale)
                    }
                    artworkWidgetQuote(page.localizedQuote(locale: locale), size: 10, locale: locale)
                    artworkWidgetQuote(page.localizedQuote(locale: locale), size: 9, locale: locale)
                    artworkWidgetQuote(page.localizedQuote(locale: locale), size: 8, locale: locale)
                    artworkWidgetQuote(page.localizedQuote(locale: locale), size: 7, locale: locale)
                    artworkWidgetQuote(page.localizedQuote(locale: locale), size: 6.5, locale: locale)
                }
                .padding(.horizontal, 5)
                .padding(.vertical, 2)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background { lockArtwork }
            default:
                Text("\(date.displayDate(locale: locale, template: "MMMd")) · \(locale.calendarText("语录日历", "Mao Quotes"))")
                    .font(CalendarTypography.font(.chineseBody, size: 12))
            }
        }
        .widgetAccentable()
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(date.displayDate(locale: locale)), \(page.localizedAccessibleQuote(locale: locale))")
    }
}
#endif
