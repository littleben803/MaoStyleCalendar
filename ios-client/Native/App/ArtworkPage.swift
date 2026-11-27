#if os(iOS)
import SwiftUI
import UIKit
import ImageIO
import CoreText
import CalendarCore

func artworkColor(_ hex: String) -> Color {
    let value = UInt32(hex.dropFirst(), radix: 16) ?? 0
    return Color(red: Double((value >> 16) & 255) / 255,
                 green: Double((value >> 8) & 255) / 255,
                 blue: Double(value & 255) / 255)
}

struct ArtworkPageSurface: View {
    @Environment(\.locale) private var locale
    let sample: ArtworkPage
    var date: CalendarDate? = nil
    var showsQuote = true
    var fillsHeight = false
    var isThumbnail = false
    var showsSolarTerm = false
    var imageOverride: (() -> UIImage?)? = nil
    var artworkEdgeFade: LinearGradient? = nil

    var body: some View {
        GeometryReader { geometry in
            let scale = min(geometry.size.width / 360, geometry.size.height / 540)
            let height = fillsHeight && scale > 0 ? max(540, geometry.size.height / scale) : 540
            let image = if let imageOverride { imageOverride() } else { ArtworkPageImages.image(sample) }
            ZStack(alignment: .topLeading) {
                if let image {
                    let illustration = Image(uiImage: image).resizable().scaledToFill()
                        .frame(width: 360, height: height)
                        .clipped()
                    if let artworkEdgeFade {
                        illustration.mask(artworkEdgeFade)
                    } else {
                        illustration
                    }
                } else {
                    Color.clear.overlay { Text(locale.calendarText("插画未能加载", "Unable to load artwork")) }
                }
                if showsQuote { quote(width: 360, height: height) }
                if let date { dateOverlay(date, width: 360, height: height) }
            }
            .frame(width: 360, height: height)
            .scaleEffect(scale, anchor: .center)
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
        .background(artworkEdgeFade == nil ? artworkColor(sample.paperColor) : Color.clear)
        .clipped()
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilitySummary)
    }

    private var accessibilitySummary: String {
        var parts: [String] = []
        if let date {
            parts.append(date.displayDate(locale: locale))
            if showsSolarTerm, locale.calendarIsChinese,
               let lunar = ArtworkLunarDate.text(year: date.year, month: date.month, day: date.day) {
                let term = ArtworkSolarTerm.name(year: date.year, month: date.month, day: date.day)
                parts.append(term.map { "\(lunar) · \($0)" } ?? lunar)
            }
        }
        parts.append(showsQuote ? sample.localizedAccessibleQuote(locale: locale)
                                : locale.calendarText("仅插画", "Artwork Only"))
        return parts.joined(separator: "，")
    }

    @ViewBuilder private func quote(width: CGFloat, height: CGFloat) -> some View {
        let size = width * sample.fontSize
        if !locale.calendarIsChinese {
            let placement = EnglishArtworkLayout.placement(page: sample, height: height, hasDate: date != nil,
                                                            isThumbnail: isThumbnail)
            VStack(alignment: .leading, spacing: 6) {
                Text(placement.text)
                    .font(CalendarTypography.font(.englishQuote, size: placement.fontSize))
                    .lineSpacing(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .foregroundStyle(artworkColor(sample.quoteColor))
            .shadow(color: artworkColor(sample.paperColor).opacity(0.95), radius: 1)
            .frame(width: placement.rect.width, alignment: .topLeading)
            .offset(x: placement.rect.minX, y: placement.rect.minY)
        } else if sample.direction == "horizontal" {
            ForEach(Array(sample.segments.enumerated()), id: \.offset) { index, line in
                Text(line)
                    .font(CalendarTypography.font(.chineseQuote, size: size))
                    .foregroundStyle(artworkColor(sample.quoteColor))
                    .fixedSize()
                    .offset(x: width * sample.x, y: height * (sample.y + Double(index) * sample.step))
            }
        } else {
            ForEach(Array(sample.segments.enumerated()), id: \.offset) { column, segment in
                VStack(spacing: 0) {
                    ForEach(Array(segment.enumerated()), id: \.offset) { _, character in
                        if character == "。", sample.punctuationExtraGap > 0 {
                            Color.clear.frame(height: size * sample.punctuationExtraGap)
                        }
                        Text(verticalGlyph(character))
                            .font(CalendarTypography.font(.chineseQuote, size: size))
                            .foregroundStyle(artworkColor(sample.quoteColor))
                            .frame(width: size, height: width * sample.step, alignment: .top)
                    }
                }
                .fixedSize()
                .offset(x: width * (sample.x - Double(column) * sample.columnSpacing) - size / 2,
                        y: height * sample.y)
            }
        }
    }

    private func verticalGlyph(_ character: Character) -> String {
        switch character { case "，": "︐"; case "。": "︒"; case "；": "︔"; default: String(character) }
    }

    @ViewBuilder private func dateOverlay(_ date: CalendarDate, width: CGFloat, height: CGFloat) -> some View {
        let color = artworkColor(sample.dateColor)
        let day = String(format: "%02d", date.day)
        let daySize = width * 0.19
        let monthSize = width * 0.048 + 2
        let lunarSize = width * 0.023 + 2
        let isTopRight = sample.datePosition == "topRight"
        let isTopLeft = sample.datePosition == "topLeft"
        let isTop = isTopLeft || isTopRight
        let quoteStartsNearTop = isTopLeft && sample.y < 0.24
        let dayOpticalOffset = daySize * 0.12
        let topInset = quoteStartsNearTop ? height * 0.010 : height * 0.025 + dayOpticalOffset
        let alignment: Alignment = isTopRight ? .topTrailing : (isTopLeft ? .topLeading : .bottomLeading)
        let textAlignment: HorizontalAlignment = isTopRight ? .trailing : .leading

        VStack(alignment: textAlignment, spacing: 12) {
            Text(day)
                .font(CalendarTypography.font(.date, size: daySize))
                .fixedSize()
                .frame(height: daySize * 0.82, alignment: .top)
                .offset(y: -dayOpticalOffset)
            CardDateMetadata(date: date, monthSize: monthSize, lunarSize: lunarSize,
                             alignment: textAlignment, showsSolarTerm: showsSolarTerm)
        }
        .foregroundStyle(color)
        .frame(width: width * 0.30, alignment: isTopRight ? .trailing : .leading)
        .padding(.leading, isTopRight ? 0 : width * 0.055)
        .padding(.trailing, isTopRight ? width * 0.05 : 0)
        .padding(.top, isTop ? topInset : 0)
        .padding(.bottom, isTop ? 0 : height * 0.025)
        .frame(width: width, height: height, alignment: alignment)
    }

}

// English uses a horizontal text block fitted to low-ink space in the same artwork.
// Candidate selection excludes the date and protected faces; Chinese coordinates stay intact.
@MainActor
enum EnglishArtworkLayout {
    struct Placement { let rect: CGRect; let fontSize: CGFloat; let text: String; var usedFallback = false }
    private static var cache: [String: Placement] = [:]

    static func placement(page: ArtworkPage, height: CGFloat, hasDate: Bool,
                          isThumbnail: Bool = false) -> Placement {
        let key = "\(page.id)-\(Int(height))-\(hasDate)-\(isThumbnail)"
        if let result = cache[key] { return result }
        let fullText = page.localizedQuote(locale: Locale(identifier: "en"))
        _ = CalendarTypography.font(.englishQuote, size: 18)
        let dateRect: CGRect
        if !hasDate { dateRect = .null }
        else if page.datePosition == "topRight" { dateRect = CGRect(x: 226, y: 0, width: 134, height: 132) }
        else if page.datePosition == "topLeft" { dateRect = CGRect(x: 0, y: 0, width: 134, height: 132) }
        else { dateRect = CGRect(x: 0, y: height - 128, width: 136, height: 128) }
        let atlas = page.widgetComposition
        let imageScale = max(360.0 / 1024, height / 1536)
        let imageWidth = 1024 * imageScale
        let imageHeight = 1536 * imageScale
        func imageRect(_ region: ArtworkIllustrationRegion) -> CGRect {
            CGRect(x: region.x * imageWidth - (imageWidth - 360) / 2,
                   y: region.y * imageHeight - (imageHeight - height) / 2,
                   width: region.width * imageWidth, height: region.height * imageHeight)
        }
        let faces = atlas?.protectedRegions.map { imageRect($0).insetBy(dx: -5, dy: -5) } ?? []
        let paragraph = NSMutableParagraphStyle(); paragraph.lineSpacing = 2
        func fittedPlacement(for text: String, minimumSize: Double) -> Placement? {
            var best: Placement?
            var bestScore = -Double.infinity
            var measuredHeights: [String: CGFloat] = [:]
            for width: CGFloat in [312, 276, 228, 192, 168] {
            for left: CGFloat in [24, 360 - width - 24] {
                for top: CGFloat in [38, 72, 112, 142, 180, 220, 270] {
                    for boxHeight: CGFloat in [96, 138, 180, 228, 282] {
                        let rect = CGRect(x: left, y: top, width: width, height: boxHeight)
                        guard rect.maxY <= height - 24, !rect.intersects(dateRect),
                              !(!isThumbnail && hasDate && rect.intersects(CGRect(x: 157, y: 0, width: 46, height: 72))),
                              !faces.contains(where: { rect.intersects($0) }) else { continue }
                        var ink = 0.0
                        var cells = 0
                        if let atlas {
                            for row in 0..<atlas.rows {
                                for column in 0..<atlas.columns {
                                    let point = CGPoint(x: (Double(column) + 0.5) / Double(atlas.columns) * imageWidth - (imageWidth - 360) / 2,
                                                        y: (Double(row) + 0.5) / Double(atlas.rows) * imageHeight - (imageHeight - height) / 2)
                                    if rect.contains(point) { ink += Double(atlas.weights[row * atlas.columns + column]); cells += 1 }
                                }
                            }
                        }
                        let averageInk = cells > 0 ? ink / Double(cells) : 0
                        for fontSize in stride(from: 23.0, through: minimumSize, by: -0.5) {
                            let measureKey = "\(width)-\(fontSize)"
                            let measuredHeight: CGFloat
                            if let cached = measuredHeights[measureKey] { measuredHeight = cached }
                            else {
                            let descriptor = UIFontDescriptor(fontAttributes: [.name: "SourceSerif4Roman-ExtraLight",
                                UIFontDescriptor.AttributeName(rawValue: kCTFontVariationAttribute as String): [NSNumber(value: 2003265652): 600, NSNumber(value: 1869640570): fontSize]])
                            let font = UIFont(descriptor: descriptor, size: fontSize)
                            let bounds = (text as NSString).boundingRect(with: CGSize(width: width, height: .greatestFiniteMagnitude),
                                options: [.usesLineFragmentOrigin, .usesFontLeading],
                                attributes: [.font: font, .paragraphStyle: paragraph], context: nil)
                            measuredHeight = ceil(bounds.height)
                            measuredHeights[measureKey] = measuredHeight
                            }
                            guard measuredHeight + 24 <= boxHeight else { continue }
                            let score = fontSize * 4 - averageInk * 2.0 - abs(top / height - page.y) * 5
                            if score > bestScore { bestScore = score; best = Placement(rect: rect, fontSize: fontSize, text: text) }
                            break
                        }
                    }
                }
            }
        }
            return best
        }
        let fallback = Placement(rect: CGRect(x: 24, y: hasDate ? 142 : 38, width: 312, height: 210),
                                 fontSize: isThumbnail ? 23 : 12,
                                 text: isThumbnail ? excerpt(fullText, maxCharacters: 15) : fullText,
                                 usedFallback: true)
        if isThumbnail {
            let excerpts = [fullText, excerpt(fullText, maxCharacters: 90),
                            excerpt(fullText, maxCharacters: 70), excerpt(fullText, maxCharacters: 50),
                            excerpt(fullText, maxCharacters: 35), excerpt(fullText, maxCharacters: 25),
                            excerpt(fullText, maxCharacters: 15)]
            for text in excerpts {
                if let result = fittedPlacement(for: text, minimumSize: 23) {
                    cache[key] = result
                    return result
                }
            }
        }
        let best = isThumbnail ? fallback : (fittedPlacement(for: fullText, minimumSize: 10) ?? fallback)
        cache[key] = best
        return best
    }

    private static func excerpt(_ text: String, maxCharacters: Int) -> String {
        guard text.count > maxCharacters else { return text }
        let prefix = String(text.prefix(maxCharacters))
        let words = prefix.split(separator: " ")
        return (words.count > 1 ? words.dropLast().joined(separator: " ") : prefix)
            .trimmingCharacters(in: .punctuationCharacters) + "…"
    }
}

struct ArtworkPageTodayFace: View {
    let sample: ArtworkPage
    let date: CalendarDate
    let fillsArtwork: Bool

    var body: some View {
        ArtworkPageSurface(sample: sample, date: date, fillsHeight: fillsArtwork, showsSolarTerm: true)
            .overlay(alignment: .top) {
                CalendarPunchedHole().offset(y: 30)
            }
            .background { PaperStack(showsBackingSheets: false) }
            .clipShape(RoundedRectangle(cornerRadius: 4))
    }
}
#endif
