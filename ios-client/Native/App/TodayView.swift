import SwiftUI
import CalendarCore

enum CalendarPalette {
    static let appBackground = Color(red: 0.965, green: 0.942, blue: 0.895)
    static let paper = Color(red: 0.985, green: 0.965, blue: 0.915)
    static let paperEdge = Color(red: 0.79, green: 0.73, blue: 0.63)
    static let vermilion = Color(red: 0.72, green: 0.07, blue: 0.065)
    static let ink = Color(red: 0.12, green: 0.105, blue: 0.085)
    static let secondaryInk = Color(red: 0.36, green: 0.28, blue: 0.20)
    static let overlay = Color(red: 0.23, green: 0.16, blue: 0.11)
}

private enum PaperVisualMetrics {
    static let cornerRadius: CGFloat = 4
}

private enum CalendarBindingMetrics {
    static let containerHeight: CGFloat = 48
    static let holeDiameter: CGFloat = 22
    static let holeVerticalOffset: CGFloat = 17
    static let ringWidth: CGFloat = 27
    static let ringHeight: CGFloat = 70
    static let ringOpticalHorizontalOffset: CGFloat = -0.7
    static let ringTopOffset: CGFloat = -23.5

    static var ringOffsetInsideContainer: CGFloat {
        ringTopOffset - ((containerHeight - ringHeight) / 2)
    }
}

struct CalendarPunchedHole: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(CalendarPalette.paperEdge.opacity(0.34))
            Circle()
                .fill(CalendarPalette.overlay.opacity(0.52))
                .padding(2.5)
            Circle()
                .stroke(CalendarPalette.paper.opacity(0.7), lineWidth: 0.7)
                .padding(0.6)
                .offset(x: -0.35, y: -0.45)
        }
        .frame(width: CalendarBindingMetrics.holeDiameter, height: CalendarBindingMetrics.holeDiameter)
        .shadow(color: .black.opacity(0.18), radius: 1.5, x: 0.5, y: 1.5)
        .accessibilityHidden(true)
    }
}

private struct CalendarMetalRing: View {
    let verticalOffset: CGFloat

    var body: some View {
        Image("CalendarCopperRingCandidateV3")
            .resizable()
            .scaledToFit()
            .frame(width: CalendarBindingMetrics.ringWidth, height: CalendarBindingMetrics.ringHeight)
            .offset(
                x: CalendarBindingMetrics.ringOpticalHorizontalOffset,
                y: verticalOffset
            )
            .accessibilityHidden(true)
    }
}

struct TodayView: View {
    @Environment(\.locale) private var locale
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    #if os(iOS)
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    #endif
    @Binding var selectedDate: Date
    let routeRevision: Int
    let dateAccess: TodayCardAccess
    let hasFullAccess: Bool
    let onDateLimit: (Date) -> Void
    var usesDuoSpread = false
    var fitsTabletCalendar = false
    var fitsDuoSingleCard = false
    #if DEBUG && os(iOS)
    @State private var didApplyReviewArguments = false
    #endif
    @State private var showsDetail = false
    @State private var dragOffset = CGSize.zero
    @State private var isDraggingDate = false
    @State private var isChangingDate = false
    @State private var backingDirection = 1
    @State private var backingCards: [CatalogItem?] = []
    @AccessibilityFocusState private var detailHeadingFocused: Bool

    private let repository = MockDailyContentRepository()
    private let allocator = AnnualContentAllocator()
    private static let backingOffsets: [(rotation: Double, x: CGFloat, y: CGFloat)] = [
        (0.06, 1, 3), (-0.17, -5, 7), (0.26, 5, 11), (-0.48, -8, 15)
    ]

    private var usesTallerCard: Bool {
        #if os(iOS)
        horizontalSizeClass == .compact
        #else
        false
        #endif
    }

    private var singleCardHeaderHeight: CGFloat { fitsDuoSingleCard ? 44 : 58 }

    var body: some View {
        GeometryReader { proxy in
            if usesDuoSpread {
                duoSpread(size: proxy.size)
            } else {
                let card = calendarCardSize(in: proxy.size)
                ZStack(alignment: .top) {
                    CalendarPalette.appBackground.ignoresSafeArea()

                    VStack(spacing: 26) {
                        todayHeader
                            .frame(height: singleCardHeaderHeight, alignment: fitsDuoSingleCard ? .top : .center)

                        calendarFront(cardWidth: card.width, cardHeight: card.height)
                    }
                    .frame(maxWidth: .infinity)
                    .blur(radius: showsDetail ? 3.5 : 0)
                    .accessibilityHidden(showsDetail)

                    if showsDetail {
                        CalendarPalette.overlay.opacity(0.52)
                            .ignoresSafeArea()
                            .contentShape(Rectangle())
                            .onTapGesture(perform: closeDetail)
                            .transition(.opacity)
                    }

                    VStack(spacing: 26) {
                        Color.clear.frame(height: singleCardHeaderHeight)
                        TodayDetailCard(
                            content: selectedContent,
                            close: closeDetail,
                            headingFocused: $detailHeadingFocused,
                            showsBinding: true,
                            showsBackingSheets: true
                        )
                        .frame(width: card.width, height: card.height)
                        .rotation3DEffect(
                            .degrees(reduceMotion ? 0 : (showsDetail ? 0 : -90)),
                            axis: (x: 0, y: 1, z: 0),
                            perspective: 0.72
                        )
                    }
                    .frame(maxWidth: .infinity)
                    .opacity(showsDetail ? 1 : 0)
                    .allowsHitTesting(showsDetail)
                    .accessibilityHidden(!showsDetail)
                }
            }
        }
        .animation(detailAnimation, value: showsDetail)
        .onChange(of: selectedDate) { _, _ in AppAnalytics.log(.dayChanged) }
        .onChange(of: selectedDate, initial: true) { _, _ in
            updateBackingCards(direction: 1)
        }
        .onChange(of: dateAccess) { _, _ in
            updateBackingCards(direction: backingDirection)
        }
        .onChange(of: hasFullAccess) { _, _ in
            updateBackingCards(direction: backingDirection)
        }
        #if DEBUG && os(iOS)
        .task {
            guard !didApplyReviewArguments else { return }
            didApplyReviewArguments = true
            if ProcessInfo.processInfo.arguments.contains("--daily-artwork-qa") {
                do { try await DailyArtworkQA.run() } catch { assertionFailure("Artwork QA: \(error)") }
            }
            if let argument = ProcessInfo.processInfo.arguments.first(where: { $0.hasPrefix("--review-pack=") }) {
                let id = String(argument.dropFirst("--review-pack=".count))
                let calendar = Calendar.current
                let year = calendar.component(.year, from: Date())
                let yearStart = calendar.date(from: DateComponents(year: year, month: 1, day: 1))!
                for offset in 0..<(CalendarDate.isLeapYear(year) ? 366 : 365) {
                    guard let value = calendar.date(byAdding: .day, value: offset, to: yearStart) else { continue }
                    if DailyArtworkCatalog.page(for: calendarDate(for: value))?.id == id {
                        selectedDate = value
                        break
                    }
                }
            }
        }
        #endif
        .onChange(of: routeRevision) { _, _ in
            showsDetail = false
            detailHeadingFocused = false
            dragOffset = .zero
            isDraggingDate = false
            isChangingDate = false
        }
    }

    private func calendarCardSize(in size: CGSize) -> CGSize {
        if fitsTabletCalendar || fitsDuoSingleCard {
            // Leave room for the header, the offset backing sheets, and their shadow.
            let horizontalInset: CGFloat = fitsDuoSingleCard ? 28 : 48
            let verticalInset: CGFloat = fitsDuoSingleCard ? singleCardHeaderHeight + 26 + 20 : 110
            let width = max(0, min(size.width - horizontalInset, (size.height - verticalInset) / 1.5))
            return CGSize(width: width, height: width * 1.5)
        }

        #if os(iOS)
        let width = min(max(size.width - 28, 0), 620, max(0, (size.height - 110) / 1.5))
        let height = min(max(0, size.height - 110), width * (usesTallerCard ? 1.67 : 1.5))
        #else
        let width = min(max(size.width - 28, 300), 620)
        let height = min(max(size.height - 110, 470), width * (usesTallerCard ? 1.67 : 1.56))
        #endif
        return CGSize(width: width, height: height)
    }

    private func calendarFront(cardWidth: CGFloat, cardHeight: CGFloat) -> some View {
        ZStack(alignment: .top) {
            ForEach(backingCards.indices.reversed(), id: \.self) { index in
                let offset = Self.backingOffsets[index]
                let settling = index == 0 ? 1 - swipeProgress(cardWidth: cardWidth) : 1
                Group {
                    if let card = backingCards[index] {
                        TodayFrontCard(
                            date: card.date, content: card.content, openDetail: {},
                            showsDetailEntry: false, fillsArtwork: usesTallerCard, showsDropShadow: !usesDuoSpread
                        )
                    } else {
                        PaperStack(showsBackingSheets: false)
                    }
                }
                .frame(width: cardWidth, height: cardHeight)
                .rotationEffect(.degrees(offset.rotation * Double(settling)))
                .offset(x: offset.x * settling, y: offset.y * settling)
                .allowsHitTesting(false)
                .accessibilityHidden(true)
            }

            TodayFrontCard(
                date: calendarDate,
                content: selectedContent,
                openDetail: openDetail,
                showsDetailEntry: !usesDuoSpread,
                fillsArtwork: usesTallerCard,
                showsDropShadow: !usesDuoSpread
            )
            .frame(width: cardWidth, height: cardHeight)
            .offset(dragOffset)
            .rotationEffect(.degrees(swipeRotation(cardWidth: cardWidth)))
            .scaleEffect(reduceMotion ? 1 : 1 - swipeProgress(cardWidth: cardWidth) * 0.018)
            .rotation3DEffect(
                .degrees(reduceMotion ? 0 : (showsDetail ? 90 : 0)),
                axis: (x: 0, y: 1, z: 0),
                perspective: 0.72
            )
            .opacity(showsDetail ? 0 : 1)
            .highPriorityGesture(changeDateGesture(cardWidth: cardWidth))
            .allowsHitTesting(!showsDetail && !isChangingDate)
            .zIndex(1)

            CalendarMetalRing(verticalOffset: CalendarBindingMetrics.ringTopOffset)
                .opacity(showsDetail ? 0 : 1)
                .allowsHitTesting(false)
                .zIndex(2)
        }
        .frame(width: cardWidth, height: cardHeight)
    }

    private func duoSpread(size: CGSize) -> some View {
        let pageWidth = max(1, min((size.width - 56) / 2, (size.height - 104) / 1.5))
        let pageHeight = pageWidth * 1.5
        return VStack(spacing: 26) {
            todayHeader.frame(height: 58)
            HStack(alignment: .top, spacing: 28) {
                calendarFront(cardWidth: pageWidth, cardHeight: pageHeight)
                    .padding(24)
                    .clipped()
                    .padding(-24)
                TodayDetailCard(
                    content: selectedContent,
                    close: {},
                    headingFocused: $detailHeadingFocused,
                    showsBinding: false,
                    showsBackingSheets: false,
                    showsClose: false,
                    showsDropShadow: false
                )
                .id(selectedDate)
                .frame(width: pageWidth, height: pageHeight)
            }
            .frame(maxWidth: .infinity)
            Spacer(minLength: 0)
        }
        .background(CalendarPalette.appBackground.ignoresSafeArea())
    }

    private var todayHeader: some View {
        VStack(spacing: 7) {
            Text(locale.calendarText("今日", "Today"))
                .font(CalendarTypography.font(.chineseTitle, size: 28))
                .foregroundStyle(CalendarPalette.ink)
            Rectangle()
                .fill(CalendarPalette.vermilion)
                .frame(width: 24, height: 1.5)
        }
    }

    private var calendarDate: CalendarDate {
        calendarDate(for: selectedDate)
    }

    private func calendarDate(for date: Date) -> CalendarDate {
        (try? CalendarDate.localDate(at: date, timeZone: .autoupdatingCurrent))
            ?? (try! CalendarDate(year: 2026, month: 1, day: 1))
    }

    private var selectedContent: DailyContentPack {
        selectedContent(for: selectedDate)
    }

    private func selectedContent(for date: Date) -> DailyContentPack {
        #if os(iOS)
        if let page = DailyArtworkCatalog.page(for: calendarDate(for: date)) { return page.content }
        #endif
        let fallback = try! repository.content(id: "mock-base-001")!
        let targetDate = calendarDate(for: date)
        guard let baseIDs = try? repository.baseContentIDs(),
              let leapID = try? repository.leapDayContentID(),
              let schedule = try? allocator.schedule(
                  year: targetDate.year,
                  contentIDs: baseIDs,
                  leapDayContentID: leapID
              ),
              let contentID = schedule[targetDate],
              let content = try? repository.content(id: contentID) else {
            return fallback
        }
        return content
    }

    private func changeDateGesture(cardWidth: CGFloat) -> some Gesture {
        DragGesture(minimumDistance: 8)
            .onChanged { value in
                guard !showsDetail, !isChangingDate else { return }
                isDraggingDate = true
                let translation = value.translation
                guard abs(translation.width) > abs(translation.height) * 0.72 else {
                    if dragOffset != .zero {
                        dragOffset = .zero
                    }
                    return
                }
                if abs(translation.width) > 0.5 {
                    let direction = translation.width < 0 ? 1 : -1
                    if direction != backingDirection { updateBackingCards(direction: direction) }
                }
                dragOffset = CGSize(
                    width: translation.width,
                    height: translation.height * 0.14
                )
            }
            .onEnded { value in
                guard !showsDetail, !isChangingDate else { return }
                let translation = value.translation
                let projectedWidth = value.predictedEndTranslation.width
                let isHorizontal = abs(translation.width) > abs(translation.height) * 0.72
                let crossedDistance = abs(translation.width) > cardWidth * 0.22
                let hasFlingVelocity = abs(projectedWidth) > cardWidth * 0.48

                guard isHorizontal, crossedDistance || hasFlingVelocity else {
                    returnCardToCenter()
                    return
                }

                let directionWidth = abs(projectedWidth) > abs(translation.width)
                    ? projectedWidth
                    : translation.width
                completeDateSwipe(
                    by: directionWidth < 0 ? 1 : -1,
                    cardWidth: cardWidth
                )
            }
    }

    private func updateBackingCards(direction: Int) {
        backingDirection = direction
        backingCards = (1...Self.backingOffsets.count).map { depth in
            guard let date = adjacentDate(for: direction * depth),
                  dateAccess.allows(date, hasFullAccess: hasFullAccess) else { return nil }
            return CatalogItem(date: calendarDate(for: date), content: selectedContent(for: date))
        }
    }

    private func adjacentDate(for dayOffset: Int) -> Date? {
        dateAccess.date(byAddingDays: dayOffset, to: selectedDate)
    }

    private func swipeProgress(cardWidth: CGFloat) -> CGFloat {
        min(abs(dragOffset.width) / max(cardWidth * 0.72, 1), 1)
    }

    private func swipeRotation(cardWidth: CGFloat) -> Double {
        guard !reduceMotion else { return 0 }
        return Double(dragOffset.width / max(cardWidth, 1)) * 8
    }

    private var detailAnimation: Animation {
        reduceMotion ? .easeOut(duration: 0.2) : .spring(duration: 0.55, bounce: 0.12)
    }

    private func completeDateSwipe(by days: Int, cardWidth: CGFloat) {
        guard let destination = adjacentDate(for: days) else {
            returnCardToCenter()
            return
        }
        guard TodayCardAccess().allows(destination, hasFullAccess: hasFullAccess) else {
            showDateLimit(for: destination)
            return
        }

        if reduceMotion {
            withAnimation(.easeOut(duration: 0.16), completionCriteria: .logicallyComplete) {
                selectedDate = destination
                dragOffset = .zero
            } completion: {
                isDraggingDate = false
            }
            return
        }

        if days != backingDirection { updateBackingCards(direction: days) }
        isChangingDate = true
        let origin = selectedDate
        let horizontalSign: CGFloat = days > 0 ? -1 : 1
        let exitOffset = CGSize(
            width: horizontalSign * (cardWidth + 150),
            height: dragOffset.height * 1.8
        )

        withAnimation(.easeIn(duration: 0.24), completionCriteria: .logicallyComplete) {
            dragOffset = exitOffset
        } completion: {
            guard isChangingDate, selectedDate == origin else { return }
            guard TodayCardAccess().allows(destination, hasFullAccess: hasFullAccess) else {
                showDateLimit(for: destination)
                return
            }
            var transaction = Transaction()
            transaction.disablesAnimations = true
            withTransaction(transaction) {
                selectedDate = destination
                dragOffset = .zero
                isDraggingDate = false
                isChangingDate = false
            }
        }
    }

    private func showDateLimit(for destination: Date) {
        dragOffset = .zero
        isDraggingDate = false
        isChangingDate = false
        onDateLimit(destination)
    }

    private func returnCardToCenter() {
        withAnimation(.spring(duration: 0.42, bounce: 0.22), completionCriteria: .logicallyComplete) {
            dragOffset = .zero
        } completion: {
            isDraggingDate = false
        }
    }

    private func openDetail() {
        guard !showsDetail, !isDraggingDate, !isChangingDate else { return }
        AppAnalytics.log(.detailOpened)
        if !usesDuoSpread { showsDetail = true }
        detailHeadingFocused = true
    }

    private func closeDetail() {
        showsDetail = false
        detailHeadingFocused = false
    }

}

struct TodayFrontCard: View {
    @Environment(\.locale) private var locale
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    let date: CalendarDate
    let content: DailyContentPack
    let openDetail: () -> Void
    var showsDetailEntry = true
    var fillsArtwork = false
    var showsDropShadow = true

    @ScaledMetric(relativeTo: .largeTitle) private var dateSize = 90.0
    @ScaledMetric(relativeTo: .title2) private var quoteSize = 25.0
    @ScaledMetric(relativeTo: .body) private var bodySize = 15.0

    var body: some View {
        Group {
            #if os(iOS)
            if let page = DailyArtworkCatalog.page(contentID: content.id) {
                ArtworkPageTodayFace(sample: page, date: date, fillsArtwork: fillsArtwork)
            } else {
                standardFace
            }
            #else
            standardFace
            #endif
        }
        .contentShape(RoundedRectangle(cornerRadius: PaperVisualMetrics.cornerRadius, style: .continuous))
        .shadow(color: showsDropShadow ? .black.opacity(0.2) : .clear, radius: 10, x: 0, y: 7)
        .onTapGesture { if showsDetailEntry { openDetail() } }
        .accessibilityActions {
            if showsDetailEntry {
                Button(locale.calendarText("查看本日语录详解", "Read today’s quote details"), action: openDetail)
            }
        }
    }

    private var standardFace: some View {
        ZStack(alignment: .top) {
            PaperStack(showsBackingSheets: false)
                .overlay(alignment: .top) {
                    CardArtworkBackground()
                }

            VStack(spacing: 0) {
                ZStack {
                    CalendarPunchedHole()
                        .offset(y: CalendarBindingMetrics.holeVerticalOffset)
                }
                .frame(height: CalendarBindingMetrics.containerHeight)

                HStack(alignment: .top, spacing: 8) {
                    VerticalQuoteView(
                        text: quoteText,
                        fontSize: min(quoteSize, 30),
                        maxCharacters: dynamicTypeSize.isAccessibilitySize ? 10 : 18
                    )
                        .frame(width: 132, alignment: .leading)

                    Spacer(minLength: 4)

                    VStack(spacing: 3) {
                        Text(String(date.day))
                            .font(CalendarTypography.font(.date, size: min(dateSize, 100)))
                            .minimumScaleFactor(0.58)
                            .lineLimit(1)
                        CardDateMetadata(date: date, monthSize: min(bodySize + 1, 19),
                                          lunarSize: min(bodySize - 1, 16), alignment: .center)
                        Rectangle()
                            .fill(CalendarPalette.vermilion)
                            .frame(width: 34, height: 1)
                            .padding(.top, 5)
                    }
                    .foregroundStyle(CalendarPalette.vermilion)
                    .frame(width: 126)
                }
                .frame(height: 212, alignment: .top)
                .padding(.horizontal, 26)

                Spacer(minLength: 0)
            }
        }
    }

    private var quoteText: String {
        content.localizedQuote(locale: locale)
    }
}

struct CardDateMetadata: View {
    @Environment(\.locale) private var locale
    let date: CalendarDate
    let monthSize: CGFloat
    let lunarSize: CGFloat
    var alignment: HorizontalAlignment = .leading

    var body: some View {
        VStack(alignment: alignment, spacing: 2) {
            Text(locale.calendarIsChinese
                 ? "\(date.month)月.\(date.displayDate(locale: locale, template: "EEEE"))"
                 : date.displayDate(locale: locale, template: "MMMEEE"))
                .font(CalendarTypography.font(.chineseTitle, size: monthSize))
                .frame(height: monthSize * 1.25, alignment: .top)
            if locale.language.languageCode?.identifier == "zh",
               let lunar = ArtworkLunarDate.text(year: date.year, month: date.month, day: date.day) {
                Text(lunar)
                    .font(CalendarTypography.font(.chineseBody, size: lunarSize))
                    .frame(height: lunarSize * 1.25, alignment: .top)
            }
        }
        .lineLimit(1)
        .minimumScaleFactor(0.8)
    }
}

struct TodayDetailCard: View {
    @Environment(\.locale) private var locale
    let content: DailyContentPack
    let close: () -> Void
    var headingFocused: AccessibilityFocusState<Bool>.Binding
    let showsBinding: Bool
    let showsBackingSheets: Bool
    var showsClose = true
    var showsDropShadow = true

    @ScaledMetric(relativeTo: .title) private var titleSize = 30.0

    var body: some View {
        ZStack(alignment: .top) {
            PaperStack(showsBackingSheets: showsBackingSheets)

            VStack(spacing: 0) {
                if showsBinding {
                    ZStack {
                        CalendarPunchedHole()
                            .offset(y: CalendarBindingMetrics.holeVerticalOffset)
                        CalendarMetalRing(verticalOffset: CalendarBindingMetrics.ringOffsetInsideContainer)
                    }
                    .frame(height: CalendarBindingMetrics.containerHeight)
                } else {
                    Color.clear.frame(height: 22)
                }

                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(locale.calendarText("语录详解", "Quote Details"))
                            .font(CalendarTypography.font(.chineseTitle, size: min(titleSize, 44)))
                            .foregroundStyle(CalendarPalette.ink)
                            .accessibilityAddTraits(.isHeader)
                            .accessibilityFocused(headingFocused)
                    }
                    Spacer()
                    if showsClose {
                        Button(action: close) {
                            Image(systemName: "xmark")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundStyle(CalendarPalette.secondaryInk)
                                .frame(width: 44, height: 44)
                                .overlay(Circle().stroke(CalendarPalette.paperEdge.opacity(0.7), lineWidth: 1))
                        }
                        .accessibilityLabel(locale.calendarText("关闭语录详解", "Close quote details"))
                    }
                }
                .padding(.horizontal, 28)
                .padding(.bottom, 10)

                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 0) {
                        ForEach(visibleEditorialSections) { section in
                            if let title = section.kind.detailTitle(locale: locale) {
                                DetailSection(title: title, body: section.body)
                            }
                        }
                    }
                    .padding(.horizontal, 28)
                    .padding(.bottom, 28)
                }
                .scrollIndicators(.hidden)
                .clipped()
            }
        }
        .contentShape(RoundedRectangle(cornerRadius: PaperVisualMetrics.cornerRadius, style: .continuous))
        .shadow(color: showsDropShadow ? .black.opacity(0.32) : .clear, radius: 16, x: 0, y: 9)
        .accessibilityElement(children: .contain)
    }

    private var visibleEditorialSections: [EditorialSection] {
        content.localizedEditorialSections(locale: locale)
            .filter {
                $0.kind != .originalContext || !content.sourceFragments.isEmpty
            }
            .sorted { $0.displayOrder < $1.displayOrder }
    }
}

private struct DetailSection: View {
    @Environment(\.locale) private var locale
    let title: String
    let text: String
    @ScaledMetric(relativeTo: .body) private var bodySize = 16.0

    init(title: String, body: String) {
        self.title = title
        text = body
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 9) {
            HStack(spacing: 9) {
                Rectangle()
                    .fill(CalendarPalette.vermilion)
                    .frame(width: 4, height: 21)
                Text(title)
                    .font(CalendarTypography.font(.chineseTitle, size: bodySize + 2))
                    .foregroundStyle(CalendarPalette.vermilion)
            }
            Text(text)
                .font(CalendarTypography.font(locale.calendarIsChinese ? .chineseBody : .englishQuote, size: bodySize))
                .foregroundStyle(CalendarPalette.ink)
                .lineSpacing(7)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.vertical, 14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(CalendarPalette.vermilion.opacity(0.48))
                .frame(height: 0.7)
        }
    }
}

private struct PaperPileBackdrop: View {
    var body: some View {
        ZStack {
            backingSheet(rotation: -0.48, x: -8, y: 15, shadowOpacity: 0.05, shadowX: -1)
            backingSheet(rotation: 0.26, x: 5, y: 11, shadowOpacity: 0.06, shadowX: 0.5)
            backingSheet(rotation: -0.17, x: -5, y: 7, shadowOpacity: 0.08, shadowX: -0.5)
            backingSheet(rotation: 0.06, x: 1, y: 3, shadowOpacity: 0.10, shadowX: 0)
        }
        .shadow(color: CalendarPalette.secondaryInk.opacity(0.16), radius: 10, x: -1, y: 7)
    }

    private func backingSheet(
        rotation: Double,
        x: CGFloat,
        y: CGFloat,
        shadowOpacity: Double,
        shadowX: CGFloat
    ) -> some View {
        PaperStack(showsBackingSheets: false)
            .rotationEffect(.degrees(rotation))
            .offset(x: x, y: y)
            .shadow(color: CalendarPalette.secondaryInk.opacity(shadowOpacity + 0.06), radius: 1.2, x: shadowX, y: 1.2)
    }
}

struct PaperStack: View {
    var showsBackingSheets = true

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                if showsBackingSheets {
                    PaperPileBackdrop()
                }

                Image(decorative: "CalendarPaperIvoryCandidate")
                    .resizable()
                    .scaledToFill()
                    .frame(width: proxy.size.width, height: proxy.size.height)
                    .clipped()
                    .contrast(1.16)
                    .overlay {
                        LinearGradient(colors: [.white.opacity(0.12), .clear, CalendarPalette.paperEdge.opacity(0.09)], startPoint: .topLeading, endPoint: .bottomTrailing)
                    }
                    .clipShape(RoundedRectangle(cornerRadius: PaperVisualMetrics.cornerRadius, style: .continuous))
                    .overlay {
                        RoundedRectangle(cornerRadius: PaperVisualMetrics.cornerRadius, style: .continuous)
                            .strokeBorder(CalendarPalette.paperEdge.opacity(0.48), lineWidth: 0.6)
                            .overlay {
                                RoundedRectangle(cornerRadius: PaperVisualMetrics.cornerRadius, style: .continuous)
                                    .inset(by: 0.7)
                                    .strokeBorder(.white.opacity(0.42), lineWidth: 0.6)
                            }
                    }
                    .accessibilityHidden(true)
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
        }
        .accessibilityHidden(true)
    }


}

struct VerticalQuoteView: View {
    @Environment(\.locale) private var locale
    let text: String
    let fontSize: CGFloat
    var maxCharacters = 18

    var body: some View {
        Group {
            if !locale.calendarIsChinese {
                Text(text)
                    .font(CalendarTypography.font(.englishQuote, size: fontSize))
                    .fixedSize(horizontal: false, vertical: true)
            } else {
                HStack(alignment: .top, spacing: 9) {
                    ForEach(Array(columns.enumerated()), id: \.offset) { _, column in
                        VStack(spacing: 2) {
                            ForEach(Array(column.enumerated()), id: \.offset) { _, character in
                                Text(String(character))
                                    .font(CalendarTypography.font(.chineseQuote, size: fontSize))
                                    .foregroundStyle(CalendarPalette.ink)
                            }
                        }
                    }
                }
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(text)
        .contentShape(Rectangle())
    }

    private var columns: [[Character]] {
        let allCharacters = Array(text.filter { !$0.isWhitespace })
        var visible = Array(allCharacters.prefix(maxCharacters))
        if allCharacters.count > maxCharacters, !visible.isEmpty {
            visible[visible.count - 1] = "…"
        }
        let split = max(1, Int(ceil(Double(visible.count) / 2)))
        let natural = stride(from: 0, to: visible.count, by: split).map {
            Array(visible[$0..<min($0 + split, visible.count)])
        }
        return natural.reversed()
    }
}

// One composition, uniformly scaled and center-cropped for each card's bounds.
// Replace the placeholder with the designer's independent illustration master.
struct CardArtworkBackground: View {
    var body: some View {
        GeometryReader { proxy in
            let scale = max(proxy.size.width / 360, proxy.size.height / 540)
            MockArtworkView()
                .frame(width: 360, height: 540)
                .scaleEffect(scale)
                .frame(width: proxy.size.width, height: proxy.size.height)
                .clipped()
                .overlay {
                    // Placeholder artwork has no designer-defined text safe area yet.
                    LinearGradient(
                        stops: [.init(color: CalendarPalette.paper.opacity(0.78), location: 0),
                                .init(color: .clear, location: 0.62)],
                        startPoint: .top, endPoint: .bottom
                    )
                }
                .overlay {
                    Image(decorative: "CalendarPaperIvoryCandidate")
                        .resizable().scaledToFill()
                        .frame(width: proxy.size.width, height: proxy.size.height)
                        .clipped()
                        .contrast(1.35)
                        .blendMode(.multiply)
                        .opacity(0.28)
                }
        }
        .clipShape(RoundedRectangle(cornerRadius: PaperVisualMetrics.cornerRadius))
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}

struct MockArtworkView: View {
    var body: some View {
        Canvas { context, size in
            let red = CalendarPalette.vermilion.opacity(0.72)
            let ink = CalendarPalette.ink.opacity(0.62)
            let wash = Color(red: 0.64, green: 0.62, blue: 0.52).opacity(0.22)

            var distantMountain = Path()
            distantMountain.move(to: CGPoint(x: 0, y: size.height * 0.58))
            distantMountain.addCurve(
                to: CGPoint(x: size.width, y: size.height * 0.48),
                control1: CGPoint(x: size.width * 0.24, y: size.height * 0.28),
                control2: CGPoint(x: size.width * 0.64, y: size.height * 0.72)
            )
            distantMountain.addLine(to: CGPoint(x: size.width, y: size.height))
            distantMountain.addLine(to: CGPoint(x: 0, y: size.height))
            context.fill(distantMountain, with: .color(wash))

            var ground = Path()
            ground.move(to: CGPoint(x: 0, y: size.height * 0.78))
            ground.addCurve(
                to: CGPoint(x: size.width, y: size.height * 0.72),
                control1: CGPoint(x: size.width * 0.35, y: size.height * 0.88),
                control2: CGPoint(x: size.width * 0.66, y: size.height * 0.60)
            )
            context.stroke(ground, with: .color(ink.opacity(0.45)), lineWidth: 1.2)

            var trunk = Path()
            trunk.move(to: CGPoint(x: size.width * 0.82, y: size.height * 0.75))
            trunk.addCurve(
                to: CGPoint(x: size.width * 0.76, y: size.height * 0.22),
                control1: CGPoint(x: size.width * 0.86, y: size.height * 0.53),
                control2: CGPoint(x: size.width * 0.70, y: size.height * 0.42)
            )
            trunk.move(to: CGPoint(x: size.width * 0.77, y: size.height * 0.37))
            trunk.addCurve(
                to: CGPoint(x: size.width * 0.56, y: size.height * 0.24),
                control1: CGPoint(x: size.width * 0.69, y: size.height * 0.28),
                control2: CGPoint(x: size.width * 0.62, y: size.height * 0.31)
            )
            context.stroke(trunk, with: .color(ink), style: StrokeStyle(lineWidth: 4, lineCap: .round))

            for index in 0..<20 {
                let x = size.width * (0.50 + Double((index * 37) % 40) / 100)
                let y = size.height * (0.13 + Double((index * 23) % 28) / 100)
                let radius = CGFloat(3 + (index % 4))
                context.fill(
                    Path(ellipseIn: CGRect(x: x, y: y, width: radius * 2, height: radius * 1.2)),
                    with: .color(index.isMultiple(of: 5) ? red : ink.opacity(0.72))
                )
            }

            let figureX = size.width * 0.53
            let figureY = size.height * 0.53
            context.fill(Path(ellipseIn: CGRect(x: figureX, y: figureY, width: 20, height: 20)), with: .color(ink))
            var figure = Path()
            figure.move(to: CGPoint(x: figureX + 9, y: figureY + 18))
            figure.addLine(to: CGPoint(x: figureX - 13, y: figureY + 78))
            figure.addLine(to: CGPoint(x: figureX + 43, y: figureY + 83))
            figure.addLine(to: CGPoint(x: figureX + 28, y: figureY + 25))
            figure.closeSubpath()
            context.fill(figure, with: .color(ink.opacity(0.78)))

            var book = Path()
            book.addRoundedRect(
                in: CGRect(x: figureX - 11, y: figureY + 30, width: 52, height: 23),
                cornerSize: CGSize(width: 2, height: 2)
            )
            context.fill(book, with: .color(CalendarPalette.paper.opacity(0.92)))
            context.stroke(book, with: .color(red), lineWidth: 1)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .clipped()
    }

}

extension CalendarDate {
    var foundationDate: Date? {
        var components = DateComponents()
        components.calendar = Calendar(identifier: .gregorian)
        components.timeZone = .autoupdatingCurrent
        components.year = year
        components.month = month
        components.day = day
        return components.date
    }
}

private extension EditorialSectionKind {
    func detailTitle(locale: Locale) -> String? {
        switch self {
        case .excerptNote, .translationNote: nil
        case .originalContext: locale.calendarText("原文与出处", "Original Text & Source")
        case .historicalBackground: locale.calendarText("历史背景", "Historical Context")
        case .plainLanguageInterpretation: locale.calendarText("当下解读", "Reading for Today")
        case .readingNote: locale.calendarText("阅读提示", "Reading Notes")
        }
    }
}
