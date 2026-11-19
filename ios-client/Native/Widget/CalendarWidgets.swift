import SwiftUI
import WidgetKit
import CalendarCore

struct CalendarEntry: TimelineEntry {
    let date: Date
    let calendarDate: CalendarDate
    let contentID: String
    let quote: String?
    let display: DesktopWidgetDisplayPreferences
    var languageCode = ContentLanguagePreference.system.resolvedLanguage()
}

struct CalendarProvider: TimelineProvider {
    func placeholder(in context: Context) -> CalendarEntry { entry(at: Date()) }

    func getSnapshot(in context: Context, completion: @escaping (CalendarEntry) -> Void) {
        completion(entry(at: Date()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<CalendarEntry>) -> Void) {
        let now = Date()
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = .autoupdatingCurrent
        let nextDay = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: now))
            ?? now.addingTimeInterval(3600)
        completion(Timeline(entries: [entry(at: now)], policy: .after(nextDay)))
    }

    private func entry(at instant: Date) -> CalendarEntry {
        let fallbackDate = try! CalendarDate(year: 2026, month: 1, day: 1)
        let localDate = (try? CalendarDate.localDate(at: instant)) ?? fallbackDate
        let defaults = DesktopWidgetDisplayPreferences.sharedDefaults
        let preferences = DesktopWidgetDisplayPreferences(defaults: defaults)
        var languageCode = defaults?.string(forKey: DesktopWidgetDisplayPreferences.languageCodeKey)
            ?? ContentLanguagePreference.system.resolvedLanguage()
        #if os(macOS)
        let hasFullAccess = true // Preserve the existing macOS display controls.
        #else
        let verifiedFullAccess = defaults?.bool(forKey: DesktopWidgetDisplayPreferences.verifiedFullAccessKey) ?? false
        #if DEBUG
        let hasFullAccess = verifiedFullAccess || (defaults?.bool(forKey: DesktopWidgetDisplayPreferences.mockFullAccessKey) ?? false)
        #else
        let hasFullAccess = verifiedFullAccess
        #endif
        #endif
        #if DEBUG
        languageCode = defaults?.string(forKey: DesktopWidgetDisplayPreferences.debugLanguageKey) ?? languageCode
        #endif
        let display = preferences.resolved(hasFullAccess: hasFullAccess, languageCode: languageCode)
        #if os(iOS)
        if let page = DailyArtworkCatalog.page(for: localDate) {
            return CalendarEntry(date: instant, calendarDate: localDate, contentID: page.id,
                                 quote: page.localizedQuote(locale: Locale(identifier: languageCode)), display: display, languageCode: languageCode)
        }
        #endif
        let repository = MockDailyContentRepository()
        let allocator = AnnualContentAllocator()

        guard let baseIDs = try? repository.baseContentIDs(),
              let leapID = try? repository.leapDayContentID(),
              let schedule = try? allocator.schedule(
                  year: localDate.year,
                  contentIDs: baseIDs,
                  leapDayContentID: leapID
              ),
              let contentID = schedule[localDate],
              let content = try? repository.content(id: contentID)
        else {
            return CalendarEntry(
                date: instant,
                calendarDate: localDate,
                contentID: "mock-unavailable",
                quote: nil,
                display: display, languageCode: languageCode
            )
        }

        let quote = content.quoteTexts.first { $0.languageTag.hasPrefix(languageCode == "zh-Hans" ? "zh" : "en") && $0.kind != .mockPlaceholder }?.text
        return CalendarEntry(
            date: instant,
            calendarDate: localDate,
            contentID: contentID,
            quote: quote,
            display: display, languageCode: languageCode
        )
    }
}

private enum WidgetPalette {
    static let paper = Color(red: 0.985, green: 0.965, blue: 0.915)
    static let darkPaper = Color(red: 0.16, green: 0.13, blue: 0.105)
    static let vermilion = Color(red: 0.72, green: 0.07, blue: 0.065)
    static let ink = Color(red: 0.12, green: 0.105, blue: 0.085)
    static let warmWhite = Color(red: 0.96, green: 0.92, blue: 0.84)
}

private enum WidgetLayout {
    static let dateToMonthSpacing: CGFloat = 4
    static let metadataLineSpacing: CGFloat = 0
    static let compactMetadataFontSize: CGFloat = 13
    static let contentInset: CGFloat = 14
    static let leadingContentInset: CGFloat = 18
    static let artworkSize = CGSize(width: 360, height: 540)
    static let mediumArtworkFraction: CGFloat = 2.0 / 3.0

    static func contentInsets(scale: CGFloat = 1) -> EdgeInsets {
        EdgeInsets(top: contentInset * scale, leading: leadingContentInset * scale,
                   bottom: contentInset * scale, trailing: contentInset * scale)
    }

    // Libre Bodoni has a deep line box below numerals. All families use the
    // same optical trimming, rather than compensating with per-family padding.
    static func dayHeight(_ fontSize: CGFloat) -> CGFloat { fontSize * 50 / 62 }
    static func dayOffset(_ fontSize: CGFloat) -> CGFloat { -fontSize * 10 / 62 }
    static func metadataOffset(_ fontSize: CGFloat) -> CGFloat { -fontSize * 3 / 62 }
}

private struct WidgetDateBlock<Metadata: View>: View {
    let day: Int
    let fontSize: CGFloat
    var alignment: HorizontalAlignment = .leading
    var showsDay = true
    @ViewBuilder let metadata: () -> Metadata

    var body: some View {
        VStack(alignment: alignment, spacing: WidgetLayout.dateToMonthSpacing) {
            if showsDay {
                Text(String(day))
                    .font(CalendarTypography.font(.date, size: fontSize))
                    .widgetAccentable()
                    .fixedSize()
                    .frame(height: WidgetLayout.dayHeight(fontSize), alignment: .top)
                    .offset(y: WidgetLayout.dayOffset(fontSize))
            }
            metadata()
                .offset(y: showsDay ? WidgetLayout.metadataOffset(fontSize) : 0)
        }
    }
}

struct CalendarWidgetView: View {
    @Environment(\.locale) private var locale
    let entry: CalendarEntry

    @Environment(\.widgetFamily) private var family
    @Environment(\.colorScheme) private var colorScheme
    private var display: DesktopWidgetDisplayPreferences { entry.display }

    var body: some View {
        Group {
            #if os(iOS)
            if let page = backgroundArtwork {
                ArtworkWidgetView(page: page, quote: entry.quote, date: entry.calendarDate,
                                  family: family, display: display)
                    .containerBackground(for: .widget) { widgetArtworkColor(page.paperColor) }
                    .widgetURL(AppRoute.date(entry.calendarDate).url)
            } else { legacyBody }
            #else
            legacyBody
            #endif
        }
    }

    #if os(iOS)
    private var backgroundArtwork: ArtworkPage? {
        if display.followsDailyArtwork, let page = DailyArtworkCatalog.page(contentID: entry.contentID) {
            return page
        }
        return DailyArtworkCatalog.page(contentID: DailyArtworkCatalog.defaultWidgetArtworkID)
    }
    #endif

    private var legacyBody: some View {
        Group {
            if isExtraLargePortrait {
                extraLargePortrait
            } else {
            switch family {
            case .systemSmall:
                small
            case .systemMedium:
                medium
            case .systemLarge:
                large
            case .systemExtraLarge:
                extraLarge
            default:
                small
            }
            }
        }
        .foregroundStyle(primaryInk)
        .containerBackground(for: .widget) {
            background.overlay {
                if !isExtraLargePortrait {
                GeometryReader { proxy in
                    let artworkWidth = family == .systemMedium
                        ? proxy.size.width * WidgetLayout.mediumArtworkFraction : proxy.size.width
                    let scale = max(artworkWidth / WidgetLayout.artworkSize.width,
                                    proxy.size.height / WidgetLayout.artworkSize.height)
                    WidgetArtwork()
                        .frame(width: WidgetLayout.artworkSize.width, height: WidgetLayout.artworkSize.height)
                        .scaleEffect(scale)
                        .frame(width: artworkWidth, height: proxy.size.height)
                        .clipped()
                        .overlay {
                            if family == .systemMedium {
                                LinearGradient(
                                    stops: [.init(color: paperColor, location: 0),
                                            .init(color: .clear, location: 0.18)],
                                    startPoint: .leading, endPoint: .trailing
                                )
                            } else {
                                LinearGradient(
                                    colors: [paperColor.opacity(0.8), .clear],
                                    startPoint: .top, endPoint: .bottom
                                )
                            }
                        }
                        .frame(width: proxy.size.width, height: proxy.size.height, alignment: .trailing)
                }
                }
            }
        }
        .widgetURL(AppRoute.date(entry.calendarDate).url)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilitySummary)
    }

    private var small: some View {
        GeometryReader { proxy in
            let scale = min(proxy.size.width, proxy.size.height) / 170

            VStack(alignment: .leading, spacing: 0) {
                if display.showsDate {
                    WidgetDateBlock(day: entry.calendarDate.day, fontSize: 62 * scale) {
                        VStack(alignment: .leading, spacing: WidgetLayout.metadataLineSpacing) {
                            Text(locale.calendarMonth(entry.calendarDate.month))
                                .frame(height: 18 * scale, alignment: .top)
                            Text(weekday)
                                .frame(height: 18 * scale, alignment: .top)
                        }
                        .font(CalendarTypography.font(.chineseTitle, size: WidgetLayout.compactMetadataFontSize * scale))
                    }
                    .foregroundStyle(accent)
                }
                lunarLabel(size: 9 * scale)
                if let quote = visibleQuote {
                    if showsCalendarText {
                        Rectangle()
                            .fill(accent)
                            .frame(width: 22 * scale, height: 1 * scale)
                            .padding(.top, 5 * scale)
                            .padding(.bottom, 7 * scale)
                    }
                    Text(quote)
                        .font(CalendarTypography.font(.chineseQuote, size: 14 * scale))
                        .lineLimit(2)
                        .minimumScaleFactor(0.82)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(width: 98 * scale, alignment: .leading)
                }
            }
            .padding(WidgetLayout.contentInsets(scale: scale))
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
    }

    private var medium: some View {
        GeometryReader { proxy in
            let scale = proxy.size.height / 170
            let textWidth = proxy.size.width * (1 - WidgetLayout.mediumArtworkFraction)
                - WidgetLayout.leadingContentInset * scale
            VStack(alignment: .leading, spacing: 0) {
                if display.showsDate {
                    WidgetDateBlock(day: entry.calendarDate.day, fontSize: 62 * scale) {
                        Text(locale.calendarIsChinese ? "\(entry.calendarDate.month)月 · \(weekday)" : entry.calendarDate.displayDate(locale: locale, template: "MMMEEE"))
                            .font(CalendarTypography.font(.chineseTitle, size: WidgetLayout.compactMetadataFontSize * scale))
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                    }
                    .foregroundStyle(accent)
                }
                lunarLabel(size: 11.5 * scale)
                if let quote = visibleQuote {
                    if showsCalendarText {
                        Rectangle().fill(accent)
                            .frame(width: 22 * scale, height: scale)
                            .padding(.top, 6 * scale)
                            .padding(.bottom, 7 * scale)
                    }
                    Text(quote)
                        .font(CalendarTypography.font(.chineseQuote, size: 15 * scale))
                        .lineLimit(2)
                        .minimumScaleFactor(0.80)
                }
            }
            .frame(width: max(1, textWidth), alignment: .leading)
            .padding(WidgetLayout.contentInsets(scale: scale))
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
    }

    private var large: some View {
        GeometryReader { proxy in
            let scale = min(proxy.size.width / 330, proxy.size.height / 350)
            let availableWidth = proxy.size.width
                - (WidgetLayout.leadingContentInset + WidgetLayout.contentInset) * scale
            let dateWidth = availableWidth * 0.36
            HStack(alignment: .top, spacing: 12) {
                if let quote = visibleQuote {
                    Text(quote)
                        .font(CalendarTypography.font(.chineseQuote, size: 24 * scale))
                        .lineSpacing(2 * scale)
                        .lineLimit(2)
                        .minimumScaleFactor(0.8)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 6 * scale)
                }
                if showsCalendarText {
                    WidgetDateBlock(day: entry.calendarDate.day, fontSize: 78 * scale,
                                    alignment: .trailing, showsDay: display.showsDate) {
                        VStack(alignment: .trailing, spacing: WidgetLayout.metadataLineSpacing) {
                            if display.showsDate {
                                Text(entry.calendarDate.displayDate(locale: locale, template: "yMMM"))
                                    .font(CalendarTypography.font(.chineseTitle, size: 14 * scale))
                                Text(weekday)
                                    .font(CalendarTypography.font(.chineseTitle, size: 14 * scale))
                            }
                            lunarLabel(size: 12 * scale)
                        }
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                    }
                    .foregroundStyle(accent)
                    .frame(width: dateWidth, alignment: .trailing)
                }
            }
            .padding(WidgetLayout.contentInsets(scale: scale))
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
        }
    }

    private var extraLarge: some View {
        GeometryReader { geometry in
            #if os(iOS)
            let daySize: CGFloat = 80
            let metadataSize: CGFloat = 20
            let quoteSize: CGFloat = 31
            let leadingInsetIncrease: CGFloat = 12
            #else
            let daySize: CGFloat = 78
            let metadataSize: CGFloat = 17
            let quoteSize: CGFloat = 22
            let leadingInsetIncrease: CGFloat = 0
            #endif
            let contentWidth = max(1, geometry.size.width - WidgetLayout.leadingContentInset - leadingInsetIncrease - WidgetLayout.contentInset)
            VStack(alignment: .leading, spacing: 14) {
                if display.showsDate {
                    WidgetDateBlock(day: entry.calendarDate.day, fontSize: daySize) {
                        VStack(alignment: .leading, spacing: WidgetLayout.metadataLineSpacing) {
                            Text(entry.calendarDate.displayDate(locale: locale, template: "yMMM"))
                            Text(weekday)
                        }
                        .font(CalendarTypography.font(.chineseTitle, size: metadataSize))
                    }
                    .foregroundStyle(accent)
                }
                lunarLabel(size: metadataSize - 4)
                if let quote = visibleQuote {
                    if showsCalendarText {
                        Rectangle().fill(accent).frame(width: 36, height: 1)
                    }
                    Text(quote)
                        .font(CalendarTypography.font(.chineseQuote, size: quoteSize))
                        .lineLimit(4)
                        .frame(width: contentWidth * 2 / 3, alignment: .leading)
                }
            }
            .padding(WidgetLayout.contentInsets())
            .padding(.leading, leadingInsetIncrease)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
    }

    private var isExtraLargePortrait: Bool {
        if #available(iOS 27.0, macOS 27.0, *) {
            return family == .systemExtraLargePortrait
        }
        return false
    }

    // Today's paper-card composition, without the App's action bar.
    private var extraLargePortrait: some View {
        GeometryReader { proxy in
            let scale = min(proxy.size.width / 330, proxy.size.height / 550)
            ZStack(alignment: .top) {
                GeometryReader { artwork in
                    let artScale = max(artwork.size.width / WidgetLayout.artworkSize.width,
                                       artwork.size.height / WidgetLayout.artworkSize.height)
                    WidgetArtwork()
                        .frame(width: WidgetLayout.artworkSize.width, height: WidgetLayout.artworkSize.height)
                        .scaleEffect(artScale)
                        .frame(width: artwork.size.width, height: artwork.size.height)
                        .clipped()
                        .overlay {
                            LinearGradient(
                                stops: [.init(color: paperColor.opacity(0.88), location: 0),
                                        .init(color: paperColor.opacity(0.45), location: 0.35),
                                        .init(color: .clear, location: 0.65)],
                                startPoint: .top, endPoint: .bottom
                            )
                        }
                }
                HStack(alignment: .top, spacing: 8 * scale) {
                    if let quote = visibleQuote {
                        HStack(alignment: .top, spacing: 8 * scale) {
                            ForEach(Array(portraitQuoteColumns(quote).enumerated()), id: \.offset) { _, column in
                                VStack(spacing: 5 * scale) {
                                    ForEach(Array(column.enumerated()), id: \.offset) { _, character in
                                        Text(String(character))
                                            .font(CalendarTypography.font(.chineseQuote, size: 24 * scale))
                                            .frame(width: 26 * scale, height: 29 * scale)
                                    }
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    if showsCalendarText {
                        VStack(spacing: 4 * scale) {
                            if display.showsDate {
                                Text(String(entry.calendarDate.day))
                                    .font(CalendarTypography.font(.date, size: 100 * scale))
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.65)
                                Text(entry.calendarDate.displayDate(locale: locale, template: "yMMM"))
                                    .font(CalendarTypography.font(.chineseTitle, size: 16 * scale))
                                Text(weekday)
                                    .font(CalendarTypography.font(.chineseTitle, size: 16 * scale))
                            }
                            lunarLabel(size: 13 * scale)
                                .padding(.top, 2 * scale)
                            if visibleQuote != nil {
                                Rectangle().fill(accent)
                                    .frame(width: 34 * scale, height: scale)
                                    .padding(.top, 5 * scale)
                            }
                        }
                        .foregroundStyle(accent)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                        .frame(width: 126 * scale)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding(.horizontal, 24 * scale)
                .padding(.top, 44 * scale)
            }
        }
    }

    private func portraitQuoteColumns(_ quote: String) -> [[Character]] {
        let characters = Array(quote.filter { !$0.isWhitespace })
        var visible = Array(characters.prefix(18))
        if characters.count > 18 { visible[17] = "…" }
        let split = max(1, Int(ceil(Double(visible.count) / 2)))
        return stride(from: 0, to: visible.count, by: split).map {
            Array(visible[$0..<min($0 + split, visible.count)])
        }.reversed()
    }

    private var background: some View {
        Group {
            if colorScheme == .dark { WidgetPalette.darkPaper } else { WidgetPalette.paper }
        }
    }

    private var paperColor: Color { colorScheme == .dark ? WidgetPalette.darkPaper : WidgetPalette.paper }

    private var lunarDate: String? {
        guard locale.calendarIsChinese && display.showsLunarDate else { return nil }
        let date = entry.calendarDate
        return ArtworkLunarDate.text(year: date.year, month: date.month, day: date.day)
    }

    private var showsCalendarText: Bool { display.showsDate || lunarDate != nil }

    @ViewBuilder
    private func lunarLabel(size: CGFloat) -> some View {
        if let lunarDate {
            Text(lunarDate)
                .font(CalendarTypography.font(.chineseBody, size: size))
                .foregroundStyle(accent)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
    }

    private var accent: Color { colorScheme == .dark ? WidgetPalette.warmWhite : WidgetPalette.vermilion }
    private var primaryInk: Color { colorScheme == .dark ? WidgetPalette.warmWhite : WidgetPalette.ink }

    private var visibleQuote: String? { display.showsQuote ? entry.quote : nil }

    private var weekday: String { entry.calendarDate.displayDate(locale: locale, template: locale.calendarIsChinese ? "EEEE" : "EEE") }

    private var accessibilitySummary: String {
        var parts: [String] = []
        if display.showsDate {
            parts.append(entry.calendarDate.displayDate(locale: locale, template: "yMMMEd"))
        }
        if let lunarDate { parts.append(lunarDate) }
        if let quote = visibleQuote { parts.append(quote) }
        if parts.isEmpty { parts.append(locale.calendarText("日历插画", "Calendar artwork")) }
        return parts.joined(separator: "，")
    }
}

private struct WidgetArtwork: View {
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        Canvas { context, size in
            let ink = colorScheme == .dark ? WidgetPalette.warmWhite.opacity(0.68) : WidgetPalette.ink.opacity(0.60)
            let red = WidgetPalette.vermilion
            let wash = ink.opacity(0.10)

            var mountain = Path()
            mountain.move(to: CGPoint(x: 0, y: size.height * 0.62))
            mountain.addCurve(
                to: CGPoint(x: size.width, y: size.height * 0.48),
                control1: CGPoint(x: size.width * 0.28, y: size.height * 0.32),
                control2: CGPoint(x: size.width * 0.62, y: size.height * 0.74)
            )
            mountain.addLine(to: CGPoint(x: size.width, y: size.height))
            mountain.addLine(to: CGPoint(x: 0, y: size.height))
            context.fill(mountain, with: .color(wash))

            var ground = Path()
            ground.move(to: CGPoint(x: 0, y: size.height * 0.80))
            ground.addCurve(
                to: CGPoint(x: size.width, y: size.height * 0.74),
                control1: CGPoint(x: size.width * 0.36, y: size.height * 0.91),
                control2: CGPoint(x: size.width * 0.68, y: size.height * 0.61)
            )
            context.stroke(ground, with: .color(ink.opacity(0.42)), lineWidth: 1.1)

            var trunk = Path()
            trunk.move(to: CGPoint(x: size.width * 0.80, y: size.height * 0.82))
            trunk.addCurve(
                to: CGPoint(x: size.width * 0.73, y: size.height * 0.18),
                control1: CGPoint(x: size.width * 0.87, y: size.height * 0.57),
                control2: CGPoint(x: size.width * 0.65, y: size.height * 0.39)
            )
            trunk.move(to: CGPoint(x: size.width * 0.74, y: size.height * 0.35))
            trunk.addCurve(
                to: CGPoint(x: size.width * 0.46, y: size.height * 0.22),
                control1: CGPoint(x: size.width * 0.65, y: size.height * 0.25),
                control2: CGPoint(x: size.width * 0.54, y: size.height * 0.29)
            )
            context.stroke(trunk, with: .color(ink), style: StrokeStyle(lineWidth: max(2, size.width * 0.018), lineCap: .round))

            for index in 0..<18 {
                let x = size.width * (0.42 + Double((index * 37) % 50) / 100)
                let y = size.height * (0.10 + Double((index * 23) % 30) / 100)
                let radius = max(2, size.width * CGFloat(0.010 + Double(index % 3) * 0.003))
                context.fill(
                    Path(ellipseIn: CGRect(x: x, y: y, width: radius * 2, height: radius * 1.25)),
                    with: .color(index.isMultiple(of: 5) ? red.opacity(0.75) : ink.opacity(0.72))
                )
            }

            let figureWidth = max(18, size.width * 0.10)
            let figureX = size.width * 0.50
            let figureY = size.height * 0.56
            context.fill(
                Path(ellipseIn: CGRect(x: figureX, y: figureY, width: figureWidth * 0.42, height: figureWidth * 0.42)),
                with: .color(ink)
            )
            var figure = Path()
            figure.move(to: CGPoint(x: figureX + figureWidth * 0.20, y: figureY + figureWidth * 0.38))
            figure.addLine(to: CGPoint(x: figureX - figureWidth * 0.28, y: figureY + figureWidth * 1.45))
            figure.addLine(to: CGPoint(x: figureX + figureWidth * 0.82, y: figureY + figureWidth * 1.55))
            figure.addLine(to: CGPoint(x: figureX + figureWidth * 0.58, y: figureY + figureWidth * 0.50))
            figure.closeSubpath()
            context.fill(figure, with: .color(ink.opacity(0.78)))
        }
        .clipped()
        .accessibilityHidden(true)
    }
}

struct DesktopCalendarWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: DesktopWidgetDisplayPreferences.widgetKind, provider: CalendarProvider()) {
            CalendarWidgetView(entry: $0)
                .environment(\.locale, Locale(identifier: $0.languageCode))
        }
        .configurationDisplayName(Text(Locale.current.calendarText("每日语录日历", "Daily Quote Calendar")))
        .description(Text(Locale.current.calendarText("查看当天日期、手绘插画与语录。", "Today’s date, hand-drawn artwork, and a quote.")))
        .supportedFamilies(desktopFamilies)
        .contentMarginsDisabled()
    }

    private var desktopFamilies: [WidgetFamily] {
        var families: [WidgetFamily] = [.systemSmall, .systemMedium, .systemLarge]
        #if os(iOS)
        if UIDevice.current.userInterfaceIdiom != .phone {
            families.append(.systemExtraLarge)
        }
        #else
        families.append(.systemExtraLarge)
        #endif
        if #available(iOS 27.0, macOS 27.0, *) {
            families.append(.systemExtraLargePortrait)
        }
        return families
    }

}

#if os(iOS)
struct LockScreenCalendarWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "Calendar.LockScreen", provider: CalendarProvider()) { entry in
            LockScreenEntryView(entry: entry)
                .environment(\.locale, Locale(identifier: entry.languageCode))
        }
        .configurationDisplayName(Text(Locale.current.calendarText("日历锁屏", "Lock Screen Calendar")))
        .description(Text(Locale.current.calendarText("以单色日期、插画与语录显示当天内容。", "Today’s date, artwork, and quote in monochrome.")))
        .supportedFamilies([.accessoryCircular, .accessoryRectangular, .accessoryInline])
    }
}

private struct LockScreenEntryView: View {
    @Environment(\.locale) private var locale
    let entry: CalendarEntry
    @Environment(\.widgetFamily) private var family

    var body: some View {
        Group {
            #if os(iOS)
            if let page = DailyArtworkCatalog.page(contentID: entry.contentID) {
                ArtworkLockWidgetView(page: page, date: entry.calendarDate, family: family)
                    .widgetURL(AppRoute.date(entry.calendarDate).url)
            } else { legacyBody }
            #else
            legacyBody
            #endif
        }
    }

    private var legacyBody: some View {
        Group {
            switch family {
            case .accessoryCircular:
                VStack(spacing: -2) {
                    WidgetDateBlock(day: entry.calendarDate.day, fontSize: 30, alignment: .center) {
                        Text(locale.calendarMonth(entry.calendarDate.month))
                            .font(CalendarTypography.font(.chineseBody, size: 10))
                    }
                }
            case .accessoryRectangular:
                HStack(spacing: 8) {
                    WidgetDateBlock(day: entry.calendarDate.day, fontSize: 28, alignment: .center) {
                        Text(locale.calendarMonth(entry.calendarDate.month))
                            .font(CalendarTypography.font(.chineseBody, size: 9))
                    }
                    if let quote = entry.quote {
                        Rectangle().fill(.primary.opacity(0.45)).frame(width: 1)
                        Text(quote)
                            .font(CalendarTypography.font(.chineseBody, size: 12))
                            .lineLimit(2)
                    }
                }
            case .accessoryInline:
                Text(entry.calendarDate.displayDate(locale: locale, template: "MMMd"))
                    .font(CalendarTypography.font(.chineseBody, size: 12))
                    .lineLimit(1)
            default:
                Text(String(entry.calendarDate.day))
            }
        }
        .widgetAccentable()
        .widgetURL(AppRoute.date(entry.calendarDate).url)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(entry.calendarDate.displayDate(locale: locale, template: "MMMd"))
    }
}
#endif

@main
struct CalendarWidgetBundle: WidgetBundle {
    @WidgetBundleBuilder var body: some Widget {
        DesktopCalendarWidget()
        #if os(iOS)
        LockScreenCalendarWidget()
        #endif
    }
}
