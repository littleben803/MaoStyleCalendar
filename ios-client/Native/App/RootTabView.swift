import SwiftUI
import Accessibility
import CalendarCore
#if os(iOS)
import UIKit
#endif

struct RootTabView: View {
    @Environment(\.scenePhase) private var scenePhase
    #if os(iOS)
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    #endif
    @State private var selection: AppTab = .today
    @State private var hingeIsOpen = false
    @State private var duoDetailItem: CatalogItem?
    @State private var duoWallpaperLayout: WallpaperLayout = .original
    @State private var wallpaperPosition = 0
    @State private var todayAccess = TodayCardAccess()
    @State private var selectedTodayDate = TodayCardAccess().today
    @State private var routeRevision = 0
    @State private var showsTodayPaywall = false
    @State private var pendingTodayDate: Date?
    @EnvironmentObject private var settings: AppSettingsLibrary

    private var canBrowseAllTodayCards: Bool {
        #if DEBUG && os(iOS)
        if ProcessInfo.processInfo.arguments.contains(where: { $0.hasPrefix("--review-pack=") }) {
            return true // Keep the developer artwork review route available.
        }
        #endif
        return settings.hasFullAccess
    }

    var body: some View {
        Group {
            #if os(macOS)
            wideNavigation
            #else
            GeometryReader { geometry in
                if hingeIsOpen {
                    duoNavigation(size: geometry.size)
                } else if UIDevice.current.userInterfaceIdiom == .pad && horizontalSizeClass == .regular {
                    iPadNavigation
                } else if horizontalSizeClass == .regular {
                    wideNavigation
                } else {
                    compactTabs
                }
            }
            .background {
                if #available(iOS 27.1, *) {
                    DuoHingeObserver { hingeIsOpen = $0 }
                        .allowsHitTesting(false)
                }
            }
            #endif
        }
        .onChange(of: scenePhase, initial: true) { _, phase in
            if phase == .active {
                settings.reload()
                refreshTodayAccess()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .NSCalendarDayChanged)) { _ in refreshTodayAccess() }
        .onReceive(NotificationCenter.default.publisher(for: .NSSystemTimeZoneDidChange)) { _ in refreshTodayAccess() }
        .onChange(of: canBrowseAllTodayCards) { _, _ in refreshTodayAccess() }
        .onChange(of: selection, initial: true) { _, tab in
            AppAnalytics.screen(String(describing: tab))
        }
        .onOpenURL(perform: openRoute)
        #if os(iOS)
        .fullScreenCover(isPresented: $showsTodayPaywall, onDismiss: finishTodayPaywall) {
            NavigationStack { todayPaywall }
        }
        #else
        .sheet(isPresented: $showsTodayPaywall, onDismiss: finishTodayPaywall) {
            NavigationStack { todayPaywall }
        }
        #endif
        .environmentObject(settings)
        .environment(\.locale, Locale(identifier: settings.languageCode))
        .preferredColorScheme(.light)
        #if DEBUG && os(iOS)
        .task {
            if ProcessInfo.processInfo.arguments.contains("--widget-artwork-qa") {
                do { try await WidgetArtworkQA.run() } catch { assertionFailure("Widget QA: \(error)") }
            }
            if ProcessInfo.processInfo.arguments.contains("--localization-qa") {
                do { try await DailyArtworkQA.runLocalization() } catch { assertionFailure("Localization QA: \(error)") }
            }
            if ProcessInfo.processInfo.arguments.contains("--yearbook-thumbnail-qa") {
                DailyArtworkQA.runYearbookThumbnails()
            }
            if ProcessInfo.processInfo.arguments.contains("--wallpaper-qa") {
                do { try await DailyArtworkQA.run() } catch { assertionFailure("Wallpaper QA: \(error)") }
            }
            if let argument = ProcessInfo.processInfo.arguments.first(where: { $0.hasPrefix("--review-tab=") }) {
                switch argument.dropFirst("--review-tab=".count) {
                case "yearbook": selection = .yearbook
                case "wallpaper": selection = .wallpaper
                default: break
                }
            }
        }
        #endif
    }

    private var compactTabs: some View {
        TabView(selection: $selection) {
            todayPage()
                .tag(AppTab.today)
                .tabItem { Label(AppTab.today.title(locale: Locale(identifier: settings.languageCode)), image: AppTab.today.image) }
            YearbookView()
                .tag(AppTab.yearbook)
                .tabItem { Label(AppTab.yearbook.title(locale: Locale(identifier: settings.languageCode)), image: AppTab.yearbook.image) }
            WallpaperWorkshopView(position: $wallpaperPosition, isActive: selection == .wallpaper)
                .tag(AppTab.wallpaper)
                .tabItem { Label(AppTab.wallpaper.title(locale: Locale(identifier: settings.languageCode)), image: AppTab.wallpaper.image) }
            settingsPage
                .tag(AppTab.settings)
                .tabItem { Label(AppTab.settings.title(locale: Locale(identifier: settings.languageCode)), image: AppTab.settings.image) }
        }
        .tint(CalendarPalette.vermilion)
        .calendarTabBarBackground()
        .frame(minWidth: 360, minHeight: 640)
    }

    #if os(iOS)
    private var iPadNavigation: some View {
        HStack(spacing: 8) {
            capsuleTabs
            selectedPage(usesTabletLayout: true)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .padding(.leading, 16)
        .background(CalendarPalette.appBackground.ignoresSafeArea())
    }

    private var capsuleTabs: some View {
        VStack(spacing: 0) {
            ForEach(AppTab.allCases) { tab in
                Button { selection = tab } label: {
                    Image(tab.image)
                        .renderingMode(.template)
                        .resizable().scaledToFit()
                        .frame(width: 27, height: 27)
                        .foregroundStyle(selection == tab ? CalendarPalette.vermilion : CalendarPalette.ink)
                        .frame(width: 52, height: 56)
                        .background {
                            if selection == tab {
                                Capsule().fill(CalendarPalette.paperEdge.opacity(0.22))
                            }
                        }
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel(tab.title(locale: Locale(identifier: settings.languageCode)))
                .accessibilityAddTraits(selection == tab ? .isSelected : [])
            }
        }
        .padding(4)
        .background(CalendarPalette.paper.opacity(0.82), in: Capsule())
        .overlay(Capsule().strokeBorder(CalendarPalette.paperEdge.opacity(0.65), lineWidth: 0.7))
    }

    private func duoNavigation(size: CGSize) -> some View {
        let usesDuoSpread = size.width >= 800
        return HStack(spacing: 8) {
            capsuleTabs
                .padding(.top, 18)
                .padding(.leading, 12)
                .frame(maxHeight: .infinity, alignment: .top)
            Group {
                if selection == .today {
                    todayPage(usesDuoSpread: usesDuoSpread, fitsDuoSingleCard: !usesDuoSpread)
                    .id(usesDuoSpread) // Reset the card flip when switching layouts.
                } else if selection == .yearbook {
                    YearbookView(duoDetail: $duoDetailItem)
                } else if selection == .wallpaper {
                    WallpaperWorkshopView(
                        position: $wallpaperPosition,
                        duoLayout: $duoWallpaperLayout,
                        expandsPreview: size.height > size.width
                    )
                } else {
                    selectedPage()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .background(CalendarPalette.appBackground.ignoresSafeArea())
        .accessibilityHidden(duoDetailItem != nil)
        .allowsHitTesting(duoDetailItem == nil)
        .overlay {
            if let item = duoDetailItem {
                CatalogDetailOverlay(
                    item: item,
                    close: { duoDetailItem = nil },
                    preservesCardAspectRatio: true
                )
                .ignoresSafeArea()
                .transition(.opacity)
                .zIndex(1)
            }
        }
        .animation(.easeInOut(duration: 0.25), value: duoDetailItem?.id)
        .onDisappear { duoDetailItem = nil }
    }
    #endif

    private var wideNavigation: some View {
        NavigationSplitView {
            List {
                ForEach(AppTab.allCases) { tab in
                    Button {
                        selection = tab
                    } label: {
                        Label(tab.title(locale: Locale(identifier: settings.languageCode)), image: tab.image)
                            .font(CalendarTypography.font(.chineseBody, size: 17))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.vertical, 5)
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(selection == tab ? CalendarPalette.vermilion : CalendarPalette.secondaryInk)
                    .listRowBackground(
                        selection == tab ? CalendarPalette.vermilion.opacity(0.08) : Color.clear
                    )
                }
            }
            .navigationTitle(settings.text("日历", "Calendar"))
            .navigationSplitViewColumnWidth(min: 190, ideal: 220, max: 280)
            .scrollContentBackground(.hidden)
            .background(CalendarPalette.appBackground)
        } detail: {
            selectedPage()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(CalendarPalette.appBackground)
        }
        .navigationSplitViewStyle(.balanced)
        .tint(CalendarPalette.vermilion)
    }

    @ViewBuilder
    private func selectedPage(usesTabletLayout: Bool = false) -> some View {
        switch selection {
        case .today:
            todayPage(fitsTabletCalendar: usesTabletLayout)
        case .yearbook: YearbookView()
        case .wallpaper: WallpaperWorkshopView(position: $wallpaperPosition, expandsPreview: usesTabletLayout)
        case .settings: settingsPage
        }
    }

    private var settingsPage: some View {
        NavigationStack { AppSettingsView() }
    }

    private func todayPage(usesDuoSpread: Bool = false, fitsTabletCalendar: Bool = false,
                           fitsDuoSingleCard: Bool = false) -> TodayView {
        TodayView(
            selectedDate: $selectedTodayDate,
            routeRevision: routeRevision,
            dateAccess: todayAccess,
            hasFullAccess: canBrowseAllTodayCards,
            onDateLimit: requestTodayPaywall,
            usesDuoSpread: usesDuoSpread,
            fitsTabletCalendar: fitsTabletCalendar,
            fitsDuoSingleCard: fitsDuoSingleCard
        )
    }

    private var todayPaywall: some View {
        #if DEBUG
        V2LifetimePaywallView(scene: .todayCardLimit, onMockPurchase: {
            settings.mockIAP = true
            finishTodayPaywall()
        })
        #else
        V2LifetimePaywallView(scene: .todayCardLimit)
        #endif
    }

    private func requestTodayPaywall(for date: Date) {
        pendingTodayDate = date
        showsTodayPaywall = true
    }

    private func finishTodayPaywall() {
        let destination = pendingTodayDate
        pendingTodayDate = nil
        if settings.hasFullAccess, let destination {
            showTodayDate(destination)
        }
    }

    private func refreshTodayAccess() {
        let access = TodayCardAccess()
        if todayAccess != access { todayAccess = access }
        if !access.allows(selectedTodayDate, hasFullAccess: canBrowseAllTodayCards) {
            showTodayDate(access.today)
        }
    }

    private func openRoute(_ url: URL) {
        guard case let .date(date) = AppRoute(url: url),
              let destination = foundationDate(for: date)
        else {
            return
        }

        selection = .today
        refreshTodayAccess()
        if todayAccess.allows(destination, hasFullAccess: canBrowseAllTodayCards) {
            pendingTodayDate = nil
            showsTodayPaywall = false
            showTodayDate(destination)
        } else {
            requestTodayPaywall(for: destination)
        }
    }

    private func showTodayDate(_ date: Date) {
        selectedTodayDate = date
        routeRevision &+= 1
    }

    private func foundationDate(for date: CalendarDate) -> Date? {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = .autoupdatingCurrent
        let noon = calendar.date(from: DateComponents(
            year: date.year,
            month: date.month,
            day: date.day,
            hour: 12
        ))
        return noon.map(calendar.startOfDay(for:))
    }
}

private enum AppTab: Hashable, CaseIterable, Identifiable {
    case today, yearbook, wallpaper, settings
    var id: Self { self }
    func title(locale: Locale) -> String {
        switch self {
        case .today: locale.calendarText("今日", "Today")
        case .yearbook: locale.calendarText("年度册", "Yearbook")
        case .wallpaper: locale.calendarText("壁纸", "Wallpapers")
        case .settings: locale.calendarText("设置", "Settings")
        }
    }
    var image: String {
        switch self {
        case .today: "CalendarIcon-calendar-Candidate"
        case .yearbook: "CalendarIcon-annual-books-Candidate"
        case .wallpaper: "CalendarIcon-wallpaper-Candidate"
        case .settings: "CalendarIcon-settings-Candidate"
        }
    }
}

struct CatalogItem: Identifiable {
    let date: CalendarDate
    let content: DailyContentPack
    var id: String { "\(date.year)-\(date.month)-\(date.day)-\(content.id)" }
}

enum AppCatalog {
    private static let repository = MockDailyContentRepository()

    static var wallpaperContents: [DailyContentPack] {
        #if os(iOS)
        return DailyArtworkCatalog.pages.map(\.content)
        #else
        return (try? MockDailyContentRepository().allContent()) ?? []
        #endif
    }

    static func items(year: Int) -> [CatalogItem] {
        entries(year: year).compactMap { item(for: $0) }
    }

    static func entries(year: Int) -> [AnnualContentAllocator.Entry] {
        let allocator = AnnualContentAllocator()
        #if os(iOS)
        if !DailyArtworkCatalog.pages.isEmpty {
            return (try? allocator.schedule(
                year: year, contentIDs: DailyArtworkCatalog.pages.map(\.id),
                leapDayContentID: MockDailyContentRepository.leapDayID
            ))?.entries ?? []
        }
        #endif
        guard let baseIDs = try? repository.baseContentIDs(),
              let leapID = try? repository.leapDayContentID()
        else { return [] }
        return (try? allocator.schedule(year: year, contentIDs: baseIDs, leapDayContentID: leapID))?.entries ?? []
    }

    static func item(for entry: AnnualContentAllocator.Entry) -> CatalogItem? {
        #if os(iOS)
        if let page = DailyArtworkCatalog.page(contentID: entry.contentID) {
            return CatalogItem(date: entry.date, content: page.content)
        }
        #endif
        guard let content = try? repository.content(id: entry.contentID) else { return nil }
        return CatalogItem(date: entry.date, content: content)
    }
}

struct ScreenTitle: View {
    static let contentSpacing: CGFloat = 14

    let title: String
    var body: some View {
        VStack(spacing: 7) {
            Text(title)
                .font(CalendarTypography.font(.chineseTitle, size: 28))
                .foregroundStyle(CalendarPalette.ink)
            Rectangle().fill(CalendarPalette.vermilion).frame(width: 24, height: 1.5)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 58)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isHeader)
    }
}

private struct YearbookView: View {
    @Environment(\.locale) private var locale
    private enum Action {
        case chooseYear
        case showMonth(Int)
        case openDetail(CatalogItem)
    }

    var duoDetail: Binding<CatalogItem?>? = nil
    @EnvironmentObject private var settings: AppSettingsLibrary
    @Environment(\.scenePhase) private var scenePhase
    @State private var currentDate = try! CalendarDate.localDate()
    @State private var selectedYear: Int?
    @State private var selectedMonth: Int?
    @State private var selectedItem: CatalogItem?
    @State private var showsYearPicker = false
    @State private var showsPaywall = false
    @State private var pendingAction: Action?

    private var year: Int { (settings.hasFullAccess ? selectedYear : nil) ?? currentDate.year }
    private var month: Int { (settings.hasFullAccess ? selectedMonth : nil) ?? currentDate.month }

    var body: some View {
        GeometryReader { viewport in
            page(isLandscape: viewport.size.width > viewport.size.height)
        }
        .onChange(of: scenePhase, initial: true) { _, phase in
            if phase == .active { refreshCurrentDate() }
        }
        .onReceive(NotificationCenter.default.publisher(for: .NSCalendarDayChanged)) { _ in refreshCurrentDate() }
        .onReceive(NotificationCenter.default.publisher(for: .NSSystemTimeZoneDidChange)) { _ in refreshCurrentDate() }
        .onChange(of: settings.hasFullAccess) { _, _ in refreshCurrentDate() }
        #if os(iOS)
        .fullScreenCover(isPresented: $showsPaywall, onDismiss: finishPaywall) {
            NavigationStack { paywall }
        }
        #else
        .sheet(isPresented: $showsPaywall, onDismiss: finishPaywall) {
            NavigationStack { paywall }
        }
        #endif
    }

    private func page(isLandscape: Bool) -> some View {
        let landscapeColumns = duoDetail != nil ? 3 : 4
        return ZStack {
            CalendarPalette.appBackground.ignoresSafeArea()
            VStack(spacing: ScreenTitle.contentSpacing) {
                ScreenTitle(title: locale.calendarText("年度册", "Yearbook"))
                picker
                YearbookMonthGrid(year: year, month: month, columnCount: isLandscape ? landscapeColumns : 2,
                                  isDetailUnlocked: isDetailUnlocked) { item in
                    request(.openDetail(item))
                }
                // Each month starts at the top with a fresh lazy layout.
                .id("\(year)-\(month)")
            }
            if let selectedItem {
                CatalogDetailOverlay(item: selectedItem) { self.selectedItem = nil }
                    .transition(.opacity).zIndex(4)
            }
        }
        .animation(.easeInOut(duration: 0.22), value: selectedItem?.id)
    }

    private var picker: some View {
        HStack(spacing: 14) {
            Button { request(.chooseYear) } label: {
                HStack(spacing: 9) {
                    Text(locale.calendarText("\(String(year))年", String(year)))
                        .font(CalendarTypography.font(.chineseTitle, size: 17))
                    Image(systemName: settings.hasFullAccess ? "chevron.down" : "lock.fill")
                        .font(.system(size: 10, weight: .medium))
                }
                .foregroundStyle(CalendarPalette.ink)
                .padding(.horizontal, 13)
                .frame(height: 38)
                .overlay(Capsule().stroke(CalendarPalette.paperEdge.opacity(0.8), lineWidth: 1))
                .frame(minHeight: 44)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .fixedSize()
            .accessibilityLabel(locale.calendarText("选择年份，当前\(String(year))年", "Choose year, current year \(year)"))
            .accessibilityHint(settings.hasFullAccess ? "" : settings.text("打开解锁选项", "Opens unlock options"))
            .popover(isPresented: $showsYearPicker) { yearPicker }
            Rectangle().fill(CalendarPalette.paperEdge.opacity(0.8)).frame(width: 1, height: 22)
            ScrollViewReader { reader in
                ScrollView(.horizontal) {
                    HStack(spacing: 18) {
                        ForEach(1...12, id: \.self) { value in
                            Button { request(.showMonth(value)) } label: {
                                VStack(spacing: 5) {
                                    Text(locale.calendarMonth(value)).font(CalendarTypography.font(.chineseTitle, size: 17))
                                    Rectangle().fill(value == month ? CalendarPalette.vermilion : .clear).frame(width: 25, height: 1.5)
                                }
                                .foregroundStyle(value == month ? CalendarPalette.vermilion : CalendarPalette.secondaryInk)
                                .frame(minWidth: 38, minHeight: 44)
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)
                            .accessibilityAddTraits(value == month ? .isSelected : [])
                            .id(value)
                        }
                    }
                    .padding(.horizontal, 2)
                }
                .scrollIndicators(.hidden)
                .onAppear { reader.scrollTo(month, anchor: .center) }
                .onChange(of: year) { _, _ in reader.scrollTo(month, anchor: .center) }
                .onChange(of: month) { _, value in
                    withAnimation(.easeOut(duration: 0.18)) { reader.scrollTo(value, anchor: .center) }
                }
            }
            .frame(height: 44)
        }
        .padding(.horizontal, 18)
        .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
    }

    private var yearPicker: some View {
        ScrollViewReader { reader in
            ScrollView {
                VStack(spacing: 0) {
                    ForEach((currentDate.year - 10)...(currentDate.year + 10), id: \.self) { value in
                        Button {
                            selectedYear = value
                            showsYearPicker = false
                        } label: {
                            HStack {
                                Text(locale.calendarText("\(String(value))年", String(value)))
                                Spacer()
                                if value == year { Image(systemName: "checkmark") }
                            }
                            .foregroundStyle(value == year ? CalendarPalette.vermilion : CalendarPalette.ink)
                            .frame(minHeight: 44)
                            .padding(.horizontal, 16)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .accessibilityAddTraits(value == year ? .isSelected : [])
                        .id(value)
                    }
                }
            }
            .frame(width: 176, height: 308)
            .onAppear { reader.scrollTo(year, anchor: .center) }
        }
        #if os(iOS)
        .presentationCompactAdaptation(.popover)
        #endif
    }

    private var paywall: some View {
        #if DEBUG
        V2LifetimePaywallView(scene: .yearbookLimit, onMockPurchase: { settings.mockIAP = true })
        #else
        V2LifetimePaywallView(scene: .yearbookLimit)
        #endif
    }

    private func isDetailUnlocked(_ date: CalendarDate) -> Bool {
        settings.hasFullAccess || (date.year == currentDate.year && date.month == currentDate.month && date.day <= 2)
    }

    private func request(_ action: Action) {
        refreshCurrentDate()
        switch action {
        case .showMonth(let value) where value == month:
            return
        case .openDetail(let item) where isDetailUnlocked(item.date):
            perform(action)
        default:
            if settings.hasFullAccess {
                perform(action)
            } else {
                pendingAction = action
                showsPaywall = true
            }
        }
    }

    private func finishPaywall() {
        let action = pendingAction
        pendingAction = nil
        if settings.hasFullAccess, let action { perform(action) }
    }

    private func perform(_ action: Action) {
        switch action {
        case .chooseYear:
            showsYearPicker = true
        case .showMonth(let value):
            selectedMonth = value
        case .openDetail(let item):
            AppAnalytics.log(.detailOpened)
            if let duoDetail {
                duoDetail.wrappedValue = item
            } else {
                selectedItem = item
            }
        }
    }

    private func refreshCurrentDate() {
        if let date = try? CalendarDate.localDate(), date != currentDate { currentDate = date }
        if !settings.hasFullAccess {
            showsYearPicker = false
            if let item = duoDetail?.wrappedValue ?? selectedItem, !isDetailUnlocked(item.date) {
                duoDetail?.wrappedValue = nil
                selectedItem = nil
            }
        }
    }
}

private struct YearbookMonthGrid: View {
    let year: Int
    let month: Int
    let columnCount: Int
    let isDetailUnlocked: (CalendarDate) -> Bool
    let openDetail: (CatalogItem) -> Void

    @EnvironmentObject private var settings: AppSettingsLibrary
    @State private var items: [CatalogItem] = []

    var body: some View {
        GeometryReader { geometry in
            let count = max(1, columnCount)
            let width = max(1, (geometry.size.width - 36 - CGFloat(count - 1) * 16) / CGFloat(count))
            ScrollView {
                HStack(alignment: .top, spacing: 16) {
                    ForEach(0..<count, id: \.self) { column in
                        LazyVStack(spacing: 14) {
                            ForEach(stride(from: column, to: items.count, by: count).map { items[$0] }) { item in
                                let locked = !isDetailUnlocked(item.date)
                                Button { openDetail(item) } label: {
                                    card(for: item, width: width, locked: locked)
                                }
                                .buttonStyle(.plain)
                                .accessibilityElement(children: .ignore)
                                .accessibilityLabel(cardLabel(for: item.date, locked: locked))
                                .accessibilityAddTraits(.isButton)
                                .accessibilitySortPriority(Double(32 - item.date.day))
                            }
                        }
                        .frame(width: width)
                    }
                }
                .padding(.horizontal, 18)
                .padding(.top, 16)
                .padding(.bottom, 8)
            }
            .scrollIndicators(.hidden)
            // Keep the cards in place while moving the clip edge above their shadows.
            .padding(.top, -12)
        }
        .task {
            guard items.isEmpty else { return }
            items = AppCatalog.entries(year: year)
                .filter { $0.date.month == month }
                .compactMap { AppCatalog.item(for: $0) }
        }
    }

    @ViewBuilder
    private func card(for item: CatalogItem, width: CGFloat, locked: Bool) -> some View {
        let card = CatalogCard(item: item, isToday: false, height: nil, showsBinding: false,
                               contentScale: min(1.1, max(0.85, width / 180)))
        Group {
            if locked {
                card.modifier(LockedCardPreview(cornerRadius: 4))
                    .contentShape(Rectangle())
            } else {
                card
            }
        }
        .background {
            RoundedRectangle(cornerRadius: 4, style: .continuous)
                .fill(CalendarPalette.paper)
                .shadow(color: CalendarPalette.ink.opacity(0.12), radius: 0.8, x: 0, y: 0.6)
                .shadow(color: CalendarPalette.ink.opacity(0.09), radius: 4, x: 0, y: 2.5)
                .allowsHitTesting(false)
        }
    }

    private func cardLabel(for date: CalendarDate, locked: Bool) -> String {
        if locked {
            return settings.text("\(date.month)月\(date.day)日，已锁定，打开解锁选项",
                                 "\(date.month)/\(date.day), Locked, open unlock options")
        }
        return settings.text("\(date.month)月\(date.day)日，打开语录详解",
                             "\(date.month)/\(date.day), Open quote details")
    }

}

private struct CatalogCard: View {
    @Environment(\.locale) private var locale
    let item: CatalogItem
    let isToday: Bool
    var height: CGFloat? = 280
    var showsBinding = true
    var contentScale: CGFloat = 1
    #if os(iOS)
    @State private var artwork: (image: UIImage?, isLoaded: Bool) = (nil, false)
    #endif

    var body: some View {
        Group {
            #if os(iOS)
            if let page = DailyArtworkCatalog.page(contentID: item.content.id) {
                Group {
                    if artwork.isLoaded {
                        ArtworkPageSurface(sample: page, date: item.date, isThumbnail: height == nil,
                                           imageOverride: { artwork.image })
                    } else {
                        artworkColor(page.paperColor)
                    }
                }
                .aspectRatio(2.0 / 3.0, contentMode: .fit)
                .frame(height: height)
                .clipShape(RoundedRectangle(cornerRadius: 4))
                .task(id: page.id) {
                    guard !artwork.isLoaded else { return }
                    let image = await ArtworkPageImages.previewImage(page)
                    guard !Task.isCancelled else { return }
                    artwork = (image, true)
                }
                .onDisappear { artwork = (nil, false) }
            } else { standardCard }
            #else
            standardCard
            #endif
        }
    }

    private var standardCard: some View {
        ZStack(alignment: .top) {
            PaperStack(showsBackingSheets: false)
                .overlay { CardArtworkBackground() }
            VStack(spacing: 0) {
                if showsBinding {
                    ZStack {
                        Circle().fill(Color.black.opacity(0.18)).frame(width: 22, height: 22).offset(y: 13)
                        Image("CalendarCopperRingCandidateV3").resizable().scaledToFit().frame(width: 23, height: 58).offset(y: -8)
                    }
                    .frame(height: 34)
                } else {
                    Color.clear.frame(height: 16)
                }
                HStack(alignment: .top, spacing: 5) {
                    VerticalQuoteView(text: quote, fontSize: 15 * contentScale, maxCharacters: 8)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    VStack(spacing: 6 * contentScale) {
                        Text(String(format: "%02d", item.date.day))
                            .font(CalendarTypography.font(.date, size: 48 * contentScale))
                        CardDateMetadata(date: item.date, monthSize: 10 * contentScale,
                                         lunarSize: 9 * contentScale, alignment: .center)
                    }
                    .foregroundStyle(CalendarPalette.vermilion).frame(width: 72 * contentScale)
                }
                .padding(.horizontal, 10)
                .frame(height: showsBinding ? 92 * contentScale : nil, alignment: .top)
                .padding(.bottom, showsBinding ? 0 : 8)

            }
            if isToday {
                Text(locale.calendarText("今日", "Today"))
                    .font(CalendarTypography.font(.chineseTitle, size: 11)).foregroundStyle(CalendarPalette.vermilion)
                    .padding(.horizontal, 8).padding(.vertical, 3)
                    .overlay(RoundedRectangle(cornerRadius: 5).stroke(CalendarPalette.vermilion, lineWidth: 1))
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing).padding(10)
            }
        }
        .aspectRatio(height == nil ? 2.0 / 3.0 : nil, contentMode: .fit)
        .frame(height: height)
        .dynamicTypeSize(...(showsBinding ? DynamicTypeSize.accessibility5 : DynamicTypeSize.xxxLarge))
        .contentShape(RoundedRectangle(cornerRadius: 7, style: .continuous))
        .shadow(color: .black.opacity(0.16), radius: 5, x: 0, y: 4)
    }

    private var quote: String { item.content.localizedQuote(locale: locale) }
}

private struct LockedCardPreview: ViewModifier {
    let cornerRadius: CGFloat

    func body(content: Content) -> some View {
        content.blur(radius: 3)
            .overlay { CalendarPalette.paper.opacity(0.4) }
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay {
                Image(systemName: "lock.fill")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(CalendarPalette.vermilion)
                    .frame(width: 32, height: 32)
                    .background(CalendarPalette.paper, in: Circle())
                    .overlay(Circle().strokeBorder(CalendarPalette.paperEdge, lineWidth: 0.75))
                    .accessibilityHidden(true)
            }
    }
}

private struct WallpaperWorkshopView: View {
    @Environment(\.locale) private var locale
    private enum Action {
        case layout(WallpaperLayout)
        case export(DailyContentPack, WallpaperLayout)
        case preview(position: Int, returnPosition: Int?)
    }

    // Position zero is the session anchor. Only lookup indices wrap.
    @Binding var position: Int
    var duoLayout: Binding<WallpaperLayout>? = nil
    var isActive = true
    var expandsPreview = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @EnvironmentObject private var settings: AppSettingsLibrary
    @State private var showsPaywall = false
    @State private var pendingAction: Action?
    @State private var phoneLayout: WallpaperLayout = .original
    private var layout: WallpaperLayout {
        get { settings.hasFullAccess ? (duoLayout?.wrappedValue ?? phoneLayout) : .original }
        nonmutating set {
            if let duoLayout { duoLayout.wrappedValue = newValue }
            else { phoneLayout = newValue }
        }
    }
    @State private var scrollTarget: Int? = 0
    @State private var isScrolling = false
    @GestureState private var isDragging = false
    @State private var centeredTarget: Int?
    @State private var isChangingLayout = false
    @State private var layoutAnimationRevision = 0
    @State private var toastMessage: String?
    @State private var toastRevision = 0
    @State private var showsMockExportNotice = false
    @State private var isExporting = false
    @State private var exportError: String?
    #if os(iOS)
    @State private var shareRequest: ShareRequest?
    #endif
    // Browse paired illustration/quote content directly, independent of calendar allocation.
    @State private var items: [DailyContentPack] = AppCatalog.wallpaperContents
    private var selectedIndex: Int { items.isEmpty ? 0 : wrappedIndex(position) }

    var body: some View {
        ZStack {
            CalendarPalette.appBackground.ignoresSafeArea()
            VStack(spacing: ScreenTitle.contentSpacing) {
                ScreenTitle(title: locale.calendarText("壁纸工坊", "Wallpapers"))
                layoutPicker
                carousel
                    .padding(.bottom, expandsPreview && duoLayout == nil ? 24 : 0)
                Button(action: exportWallpaper) {
                    Group {
                        if isExporting {
                            ProgressView()
                                .tint(.white)
                                .accessibilityLabel(locale.calendarText("正在生成高清壁纸", "Generating HD wallpaper"))
                        } else {
                            Text(locale.calendarText("导出高清壁纸", "Export HD Wallpaper"))
                                .font(CalendarTypography.font(.chineseTitle, size: 20))
                        }
                    }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity, minHeight: 54)
                        .background {
                            Image(decorative: "CalendarPrintVermilionCandidate").resizable().scaledToFill()
                                .overlay(CalendarPalette.vermilion.opacity(0.32))
                                .allowsHitTesting(false)
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 24)
                .padding(.bottom, 10)
            }
        }
        .onChange(of: settings.hasFullAccess, initial: true) { _, hasFullAccess in
            if !hasFullAccess, !(-2...2).contains(position), pendingAction == nil {
                position = 0
            }
        }
        #if os(iOS)
        .fullScreenCover(isPresented: $showsPaywall, onDismiss: finishPaywall) {
            NavigationStack { paywall }
        }
        #else
        .sheet(isPresented: $showsPaywall, onDismiss: finishPaywall) {
            NavigationStack { paywall }
        }
        #endif
        .overlay(alignment: .bottom) {
            if let toastMessage {
                Text(toastMessage)
                    .font(CalendarTypography.font(.chineseBody, size: 14))
                    .foregroundStyle(CalendarPalette.paper)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 12)
                    .background(CalendarPalette.ink.opacity(0.90), in: Capsule())
                    .padding(.horizontal, 24)
                    .padding(.bottom, 80)
                    .transition(.opacity)
                    .allowsHitTesting(false)
            }
        }
        .task(id: toastRevision) {
            guard toastMessage != nil else { return }
            do { try await Task.sleep(for: .seconds(2)) } catch { return }
            withAnimation(reduceMotion ? nil : .easeOut(duration: 0.15)) { toastMessage = nil }
        }
        #if os(iOS)
        .sheet(item: $shareRequest) { request in
            ActivityShareSheet(activityItems: request.activityItems) {
                showToast(settings.text("已保存到相册", "Saved to Photos"))
            }
        }
        .alert(locale.calendarText("导出失败", "Export Failed"), isPresented: exportErrorBinding) {
            Button(locale.calendarText("知道了", "OK"), role: .cancel) {}
        } message: {
            Text(exportError ?? locale.calendarText("无法生成高清壁纸", "Unable to generate the wallpaper"))
        }
        #else
        .alert(locale.calendarText("Mock 阶段暂不生成文件", "Export Unavailable in Mock Preview"), isPresented: $showsMockExportNotice) {
            Button(locale.calendarText("知道了", "OK"), role: .cancel) {}
        } message: {
            Text(locale.calendarText("当前里程碑只实现普通 iPhone 导出；Mac 文件导出将在后续平台阶段单独验收。", "Wallpaper export is currently available on iPhone. Mac export will be reviewed in a later milestone."))
        }
        #endif
    }

    private func showToast(_ message: String) {
        toastMessage = message
        toastRevision += 1
        AccessibilityNotification.Announcement(message).post()
    }

    private func exportWallpaper() {
        guard !isScrolling, !isChangingLayout else {
            showToast(locale.calendarText("画面调整中，请稍候再导出", "Adjusting the layout. Please try exporting again shortly."))
            return
        }
        guard !isExporting else {
            showToast(locale.calendarText("壁纸正在生成，请稍候", "Generating your wallpaper. Please wait."))
            return
        }
        guard items.indices.contains(selectedIndex) else {
            showToast(locale.calendarText("暂无可导出的壁纸", "No wallpaper is available to export."))
            return
        }
        let item = items[selectedIndex]
        let exportLayout = layout
        if settings.hasFullAccess {
            performExport(item, layout: exportLayout)
        } else {
            requestPaywall(.export(item, exportLayout))
        }
    }

    private func performExport(_ item: DailyContentPack, layout exportLayout: WallpaperLayout) {
        #if os(iOS)
        isExporting = true
        exportError = nil
        Task { @MainActor in
            await Task.yield()
            defer { isExporting = false }
            do {
                let url = try WallpaperExporter.export(content: item, layout: exportLayout, locale: locale)
                AppAnalytics.log(.wallpaperExported)
                shareRequest = ShareRequest(activityItems: [url])
            } catch {
                exportError = (error as? WallpaperExportError)?.message(locale: locale) ?? error.localizedDescription
            }
        }
        #else
        showsMockExportNotice = true
        #endif
    }

    #if os(iOS)
    private var exportErrorBinding: Binding<Bool> {
        Binding(
            get: { exportError != nil },
            set: { isPresented in
                if !isPresented { exportError = nil }
            }
        )
    }
    #endif

    @ViewBuilder private var carousel: some View {
        if items.isEmpty {
            ContentUnavailableView(locale.calendarText("暂无壁纸内容", "No Wallpapers Available"), systemImage: "photo")
        } else {
            GeometryReader { proxy in
                let ratio = WallpaperPreview.screenAspectRatio
                let maximumWidth = if expandsPreview {
                    proxy.size.width * 0.80
                } else {
                    min(360, proxy.size.width * (duoLayout != nil ? 0.46 : 0.70))
                }
                let width = max(1, min(maximumWidth, (proxy.size.height - 28) * ratio))
                let height = width / ratio
                trackScrollActivity(
                    ScrollView(.horizontal) {
                        LazyHStack(spacing: 14) {
                            ForEach(scrollPositions, id: \.self) { target in
                                trackAlignment(
                                    carouselCard(at: target, relativeIndex: target - position)
                                        .frame(width: width, height: height)
                                        .shadow(color: CalendarPalette.secondaryInk.opacity(0.24), radius: 3, x: 0, y: 2)
                                        .shadow(color: CalendarPalette.secondaryInk.opacity(0.18), radius: 9, x: 0, y: 7),
                                    target: target, viewportWidth: proxy.size.width
                                )
                                .id(target)
                            }
                        }
                        .scrollTargetLayout()
                        .padding(.vertical, 14)
                    }
                    .contentMargins(.horizontal, (proxy.size.width - width) / 2, for: .scrollContent)
                    .scrollTargetBehavior(.viewAligned(limitBehavior: .never))
                    .scrollPosition(id: $scrollTarget, anchor: .center)
                    .scrollIndicators(.hidden)
                    // Let the card shadows fade into the shared page background.
                    .scrollClipDisabled()
                    .coordinateSpace(name: "wallpaper-scroll")
                )
                .onChange(of: position, initial: true) { _, target in
                    if scrollTarget != target { scrollTarget = target }
                }
                .accessibilityElement(children: duoLayout != nil || !settings.hasFullAccess ? .contain : .ignore)
                .accessibilityLabel(locale.calendarText("壁纸预览，\(layout.title(locale: locale))，内容 \(items[selectedIndex].id)", "Wallpaper preview, \(layout.title(locale: locale)), content \(items[selectedIndex].id)"))
                .accessibilityValue(locale.calendarText("第 \(selectedIndex + 1) 张，共 \(items.count) 张", "\(selectedIndex + 1) of \(items.count)"))
                .accessibilityHint(locale.calendarText("向上或向下轻扫切换壁纸", "Swipe up or down to change wallpapers"))
                .accessibilityAdjustableAction { direction in
                    moveCarousel(to: position + (direction == .increment ? 1 : -1))
                }
                .accessibilityAction(named: Text(locale.calendarText("上一张壁纸", "Previous wallpaper"))) {
                    moveCarousel(to: position - 1)
                }
                .accessibilityAction(named: Text(locale.calendarText("下一张壁纸", "Next wallpaper"))) {
                    moveCarousel(to: position + 1)
                }
            }
            .frame(minHeight: 240)
            // Keep overflowing previews inside the carousel, away from tablet navigation.
            // The existing vertical inset preserves room for the card shadows.
            .clipped()
        }
    }

    private var scrollPositions: Range<Int> {
        // Keep the data fixed throughout a gesture. Extra cycles preserve backwards browsing.
        // One locked neighbour beyond each paywall boundary keeps both edges populated.
        // The free range and paywall threshold remain -2...2 in finishScrolling().
        settings.hasFullAccess ? (-items.count)..<(items.count * 2) : -4..<5
    }

    @ViewBuilder
    private func trackScrollActivity<Content: View>(_ content: Content) -> some View {
        if #available(iOS 18, macOS 15, *) {
            content.onScrollPhaseChange { _, phase in
                isScrolling = phase != .idle
                if phase == .idle { finishScrolling() }
            }
        } else {
            // iOS 17 exposes no scroll phases. Observe alignment and touch state only;
            // native ScrollView continues to own all movement and deceleration.
            content
                .simultaneousGesture(DragGesture(minimumDistance: 0)
                    .updating($isDragging) { _, dragging, _ in dragging = true }
                    .onChanged { _ in
                        if !isScrolling { isScrolling = true }
                    })
                .task(id: isDragging ? nil : centeredTarget) {
                    guard let target = centeredTarget, !isDragging else { return }
                    do { try await Task.sleep(for: .milliseconds(150)) } catch { return }
                    guard !isDragging, centeredTarget == target else { return }
                    finishScrolling()
                }
        }
    }

    @ViewBuilder
    private func trackAlignment<Content: View>(_ content: Content, target: Int, viewportWidth: CGFloat) -> some View {
        if #available(iOS 18, macOS 15, *) {
            content
        } else {
            content.onGeometryChange(for: Bool.self) { proxy in
                abs(proxy.frame(in: .named("wallpaper-scroll")).midX - viewportWidth / 2) < 1
            } action: { centered in
                if centered { centeredTarget = target }
                else if centeredTarget == target { centeredTarget = nil }
            }
        }
    }

    private func wrappedIndex(_ index: Int) -> Int {
        (index % items.count + items.count) % items.count
    }

    @ViewBuilder
    private func carouselCard(at target: Int, relativeIndex: Int) -> some View {
        let card = preview(for: items[wrappedIndex(target)])
        if settings.hasFullAccess {
            if duoLayout != nil, target != position {
                Button { moveCarousel(to: target) } label: { card }
                    .buttonStyle(.plain)
                    .accessibilityLabel(target < position ? locale.calendarText("将左侧壁纸移到中央", "Move the left wallpaper to the center") : locale.calendarText("将右侧壁纸移到中央", "Move the right wallpaper to the center"))
            } else {
                card
            }
        } else {
            Button {
                requestPaywall(.preview(position: target, returnPosition: nil))
            } label: {
                Color.clear
                    .contentShape(Rectangle())
                    .background {
                        card.modifier(LockedCardPreview(cornerRadius: 18))
                            .accessibilityHidden(true)
                    }
            }
            .buttonStyle(.plain)
            .accessibilityLabel(lockedPreviewLabel(relativeIndex))
            .accessibilityHint(settings.text("打开解锁选项", "Opens unlock options"))
        }
    }

    private func lockedPreviewLabel(_ relativeIndex: Int) -> String {
        switch relativeIndex {
        case ..<0: settings.text("左侧壁纸，已锁定", "Left wallpaper, locked")
        case 0: settings.text("当前壁纸，已锁定", "Current wallpaper, locked")
        default: settings.text("右侧壁纸，已锁定", "Right wallpaper, locked")
        }
    }

    private func preview(for content: DailyContentPack) -> some View {
        WallpaperPreview(content: content, layout: layout, isActive: isActive)
            .equatable()
    }

    private func moveCarousel(to target: Int) {
        guard !showsPaywall, !isChangingLayout, scrollPositions.contains(target) else { return }
        guard scrollTarget != target else {
            position = target
            return
        }
        isScrolling = true
        withAnimation(reduceMotion ? nil : .smooth(duration: 0.25)) {
            scrollTarget = target
        }
        if reduceMotion { finishScrolling() }
    }

    private func finishScrolling() {
        guard let target = scrollTarget else { return }
        let origin = position
        isScrolling = false
        position = target
        if !settings.hasFullAccess, !(-2...2).contains(target), pendingAction == nil {
            requestPaywall(.preview(position: target, returnPosition: origin))
        } else if settings.hasFullAccess,
                  target <= -items.count + 2 || target >= items.count * 2 - 3 {
            // Recenter equivalent content only at the distant cycle boundary, after scrolling stops.
            let equivalent = wrappedIndex(target)
            var transaction = Transaction()
            transaction.disablesAnimations = true
            withTransaction(transaction) {
                position = equivalent
                scrollTarget = equivalent
            }
        }
    }

    private var paywall: some View {
        #if DEBUG
        V2LifetimePaywallView(scene: .wallpaperLimit, onMockPurchase: { settings.mockIAP = true })
        #else
        V2LifetimePaywallView(scene: .wallpaperLimit)
        #endif
    }

    private func requestPaywall(_ action: Action) {
        guard !showsPaywall, !isScrolling else { return }
        pendingAction = action
        showsPaywall = true
    }

    private func finishPaywall() {
        guard let action = pendingAction else { return }
        pendingAction = nil
        if settings.hasFullAccess {
            switch action {
            case .layout(let candidate): selectLayout(candidate)
            case .export(let content, let layout): performExport(content, layout: layout)
            case .preview(let target, _): moveCarousel(to: target)
            }
        } else if case .preview(_, let previous?) = action {
            moveCarousel(to: previous)
        }
    }

    private func selectLayout(_ candidate: WallpaperLayout) {
        guard candidate != layout else { return }
        layoutAnimationRevision += 1
        let revision = layoutAnimationRevision
        guard !reduceMotion else {
            layout = candidate
            isChangingLayout = false
            return
        }
        isChangingLayout = true
        withAnimation(.easeOut(duration: 0.18), completionCriteria: .removed) {
            layout = candidate
        } completion: {
            if layoutAnimationRevision == revision { isChangingLayout = false }
        }
    }

    private var layoutPicker: some View {
        Picker(locale.calendarText("壁纸内容", "Wallpaper Content"), selection: Binding(get: { layout }, set: selectLayout)) {
            ForEach(WallpaperLayout.allCases) { candidate in
                Text(candidate.title(locale: locale)).tag(candidate)
            }
        }
        .pickerStyle(.segmented)
        .allowsHitTesting(settings.hasFullAccess)
        .accessibilityHidden(!settings.hasFullAccess)
        .overlay {
            if !settings.hasFullAccess {
                HStack(spacing: 0) {
                    ForEach(WallpaperLayout.allCases) { candidate in
                        Button {
                            requestPaywall(.layout(candidate))
                        } label: {
                            Color.clear
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel(candidate.title(locale: locale))
                        .accessibilityAddTraits(candidate == layout ? .isSelected : [])
                    }
                }
            }
        }
        .padding(.horizontal, 24)
        .frame(maxWidth: 440)
    }
}

enum WallpaperLayout: String, CaseIterable, Identifiable {
    case original, artworkOnly
    var id: String { rawValue }
    func title(locale: Locale) -> String { self == .original ? locale.calendarText("原稿排版", "Original Layout") : locale.calendarText("仅插画", "Artwork Only") }
    // Used only by the retained Mock composition on platforms without delivered artwork.
    var alignment: Alignment { .topLeading }
    var isVertical: Bool { false }
}

#if os(iOS)
private struct DecodedWallpaperPreview {
    let image: UIImage?
}
#endif

private struct WallpaperPreview: View, Equatable {
    static var screenAspectRatio: CGFloat {
        #if os(iOS)
        let size = WallpaperExporter.outputPixelSize
        return size.width / size.height
        #else
        return 9.0 / 19.5
        #endif
    }
    let content: DailyContentPack
    let layout: WallpaperLayout
    var isActive = true
    #if os(iOS)
    @State private var decodedArtwork: DecodedWallpaperPreview?
    #endif

    nonisolated static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.content == rhs.content && lhs.layout == rhs.layout && lhs.isActive == rhs.isActive
    }

    var body: some View {
        canvas
            .aspectRatio(Self.screenAspectRatio, contentMode: .fit)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .strokeBorder(.white.opacity(0.85), lineWidth: 1.2)
            }
            .overlay {
                RoundedRectangle(cornerRadius: 17, style: .continuous)
                    .strokeBorder(CalendarPalette.paperEdge.opacity(0.3), lineWidth: 0.5)
                    .padding(1.5)
            }
            #if os(iOS)
            .task(id: isActive) {
                guard isActive else {
                    decodedArtwork = nil
                    return
                }
                guard decodedArtwork == nil,
                      let page = DailyArtworkCatalog.page(contentID: content.id) else { return }
                let image = await ArtworkPageImages.previewImage(page)
                guard !Task.isCancelled else { return }
                decodedArtwork = DecodedWallpaperPreview(image: image)
            }
            .onDisappear { decodedArtwork = nil }
            #endif
    }

    @ViewBuilder private var canvas: some View {
        #if os(iOS)
        if let page = DailyArtworkCatalog.page(contentID: content.id) {
            if let decodedArtwork {
                ArtworkWallpaperCanvas(page: page, image: decodedArtwork.image, showsQuote: layout == .original)
            } else {
                artworkColor(page.paperColor)
            }
        } else {
            WallpaperCompositionCanvas(content: content, layout: layout)
        }
        #else
        WallpaperCompositionCanvas(content: content, layout: layout)
        #endif
    }
}

// Use one fixed design coordinate space for the preview and native-pixel export.
// In particular, MockArtworkView contains point-sized drawing details that must scale together.
struct WallpaperCompositionCanvas: View {
    @Environment(\.locale) private var locale
    let content: DailyContentPack
    let layout: WallpaperLayout

    var body: some View {
        Group {
            #if os(iOS)
            if let page = DailyArtworkCatalog.page(contentID: content.id) {
                ArtworkWallpaperCanvas(page: page, image: ArtworkPageImages.image(page), showsQuote: layout == .original)
            } else { mockCanvas }
            #else
            mockCanvas
            #endif
        }
    }

    private var mockCanvas: some View {
        GeometryReader { proxy in
            let designWidth: CGFloat = 360
            let scale = proxy.size.width / designWidth
            let height = proxy.size.height / max(scale, 0.001)
            composition(height: height)
                .frame(width: designWidth, height: height)
                .scaleEffect(scale, anchor: .topLeading)
        }
        .clipped()
    }

    private func composition(height: CGFloat) -> some View {
        ZStack {
            CalendarPalette.paper
            Image(decorative: "CalendarPaperIvoryCandidate")
                .resizable().scaledToFill()
                .frame(width: 360, height: height).clipped()
            CardArtworkBackground()
                .frame(width: 360, height: height)
            if layout != .artworkOnly {
                quote(height: height)
                    .padding(.horizontal, 28)
                    .padding(.top, height * 0.11)
                    .padding(.bottom, height * 0.10)
                    .frame(width: 360, height: height, alignment: layout.alignment)
            }
        }
    }

    @ViewBuilder private func quote(height: CGFloat) -> some View {
        let text = content.localizedQuote(locale: locale)
        if layout.isVertical {
            verticalQuote(text: text, availableHeight: height * 0.74)
        } else {
            Text(text)
                .font(CalendarTypography.font(.chineseQuote, size: 20))
                .foregroundStyle(CalendarPalette.ink)
                .lineSpacing(6)
                .multilineTextAlignment(.leading)
                .frame(width: 304, alignment: .leading)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private func verticalQuote(text: String, availableHeight: CGFloat) -> some View {
        let characters = Array(text.filter { !$0.isWhitespace })
        let capacity = max(1, Int(availableHeight / 30))
        let columnCount = max(1, Int(ceil(Double(characters.count) / Double(capacity))))
        let rows = max(1, Int(ceil(Double(characters.count) / Double(columnCount))))
        let columns = stride(from: 0, to: characters.count, by: rows).map {
            Array(characters[$0..<min($0 + rows, characters.count)])
        }
        return HStack(alignment: .top, spacing: 7) {
            ForEach(Array(columns.reversed().enumerated()), id: \.offset) { _, column in
                VStack(spacing: 2) {
                    ForEach(Array(column.enumerated()), id: \.offset) { _, character in
                        Text(String(character))
                            .font(CalendarTypography.font(.chineseQuote, size: 18))
                            .foregroundStyle(CalendarPalette.ink)
                            .frame(width: 22, height: 28)
                    }
                }
            }
        }
        .fixedSize()
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(text)
    }

}

private struct CatalogDetailOverlay: View {
    let item: CatalogItem
    let close: () -> Void
    var preservesCardAspectRatio = false
    @AccessibilityFocusState private var headingFocused: Bool

    var body: some View {
        GeometryReader { proxy in
            let width = preservesCardAspectRatio
                ? max(1, min(proxy.size.width - 48, (proxy.size.height - 48) * 2 / 3))
                : min(max(proxy.size.width - 28, 300), 620)
            let height = preservesCardAspectRatio
                ? width * 3 / 2
                : min(max(proxy.size.height - 44, 470), width * 1.56)
            ZStack {
                CalendarPalette.overlay.opacity(0.62).ignoresSafeArea().contentShape(Rectangle()).onTapGesture(perform: close)
                TodayDetailCard(
                    content: item.content, close: close,
                    headingFocused: $headingFocused,
                    showsBinding: false,
                    showsBackingSheets: false
                )
                .frame(width: width, height: height)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .onAppear { headingFocused = true }
    }
}

private extension View {
    @ViewBuilder func calendarTabBarBackground() -> some View {
        #if os(iOS)
        self.toolbarBackground(CalendarPalette.appBackground, for: .tabBar).toolbarBackground(.visible, for: .tabBar)
        #else
        self
        #endif
    }
}

#if os(iOS)
/// Observe the window's public hinge signal; ordinary phones never opt into the spread.
@available(iOS 27.1, *)
struct DuoHingeObserver: UIViewRepresentable {
    var update: (Bool) -> Void

    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.addInteraction(UIHingeInteraction { _, change in
            let status = change.hinge?.status
            let isOpen = status == .fullyOpen || status == .partiallyOpen
            DispatchQueue.main.async { update(isOpen) }
        })
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}
#endif
