import CalendarCore
import Combine
import SwiftUI
import WebKit
import WidgetKit
#if os(iOS)
import StoreKit
import UIKit
#if DEBUG
import ImageIO
#endif
#endif

@MainActor
final class AppSettingsLibrary: ObservableObject {
    fileprivate let legalPages = LocalLegalPageCache()
    #if os(iOS)
    private static let fullAccessProductID = "com.ideaboxapps.maostylecalendar.fullaccess"

    @Published private(set) var fullAccessProduct: Product?
    @Published private(set) var isFullAccessProductUnavailable = false
    @Published private(set) var isStoreOperationInProgress = false
    @Published private(set) var isRestoringFullAccess = false
    @Published private(set) var verifiedFullAccess: Bool?
    private var isLoadingFullAccessProduct = false
    private var transactionListener: Task<Void, Never>?
    private var entitlementRefresh: Task<Bool, Never>?
    private var restoreRequest: Task<Void, Never>?
    private var restoreWaitTimeout: Task<Void, Never>?
    private var restoreWaitID: UUID?
    private var restoreWaiter: CheckedContinuation<FullAccessResult, Never>?
    #endif
    #if DEBUG
    // The widget shares these overrides until the app starts a new Debug session.
    @Published var debugLanguage: ContentLanguagePreference? {
        didSet { refreshWidgetSettings() }
    }
    @Published var mockIAP = false {
        didSet {
            #if os(iOS)
            if mockIAP && !oldValue { enableDailyArtworkAfterUnlock() }
            #endif
            refreshWidgetSettings()
        }
    }
    @Published var alwaysShowsOnboarding = UserDefaults.standard.bool(forKey: "debug.onboarding.always") {
        didSet { UserDefaults.standard.set(alwaysShowsOnboarding, forKey: "debug.onboarding.always") }
    }
    #endif

    init() {
        refreshWidgetSettings()
    }

    #if os(iOS)
    deinit {
        transactionListener?.cancel()
    }

    func startStoreKit() {
        guard transactionListener == nil else { return }
        transactionListener = Task { [weak self] in
            for await result in StoreKit.Transaction.updates {
                guard let self else { return }
                _ = await self.processFullAccessTransaction(result)
            }
        }
    }

    @discardableResult
    func refreshFullAccess() async -> Bool {
        // Queue reads so a scan started before a transaction update cannot overwrite a newer result.
        let previous = entitlementRefresh
        let refresh = Task { [weak self] in
            _ = await previous?.value
            guard let self else { return false }
            var ownsFullAccess = false
            for await result in StoreKit.Transaction.currentEntitlements {
                if case .verified(let transaction) = result,
                   Self.isFullAccess(transaction), transaction.revocationDate == nil {
                    ownsFullAccess = true
                    break
                }
            }
            let wasUnlocked = self.verifiedFullAccess ??
                (DesktopWidgetDisplayPreferences.sharedDefaults?.bool(
                    forKey: DesktopWidgetDisplayPreferences.verifiedFullAccessKey) ?? false)
            if ownsFullAccess && !wasUnlocked {
                self.enableDailyArtworkAfterUnlock()
            }
            if self.verifiedFullAccess != ownsFullAccess {
                self.verifiedFullAccess = ownsFullAccess
                self.refreshWidgetSettings()
            }
            return ownsFullAccess
        }
        entitlementRefresh = refresh
        return await refresh.value
    }

    func loadFullAccessProduct() async {
        guard fullAccessProduct == nil, !isLoadingFullAccessProduct else { return }
        isLoadingFullAccessProduct = true
        isFullAccessProductUnavailable = false
        defer { isLoadingFullAccessProduct = false }
        do {
            fullAccessProduct = try await Product.products(for: [Self.fullAccessProductID])
                .first { $0.id == Self.fullAccessProductID && $0.type == .nonConsumable }
        } catch is CancellationError {
            return
        } catch {
            isFullAccessProductUnavailable = true
            return
        }
        isFullAccessProductUnavailable = fullAccessProduct == nil
    }

    func purchaseFullAccess() async -> FullAccessResult {
        guard !isRestoringFullAccess else { return .restorePending }
        guard !isStoreOperationInProgress, let fullAccessProduct else { return .cancelled }
        AppAnalytics.log(.purchaseStarted)
        isStoreOperationInProgress = true
        defer { isStoreOperationInProgress = false }
        if await refreshFullAccess() {
            AppAnalytics.log(.purchaseAlreadyOwned)
            return .unlocked
        }
        do {
            switch try await fullAccessProduct.purchase() {
            case .success(let result):
                let unlocked = await processFullAccessTransaction(result)
                AppAnalytics.log(unlocked ? .purchaseSucceeded : .purchaseVerificationFailed)
                return unlocked ? .unlocked : .verificationFailed
            case .pending:
                AppAnalytics.log(.purchasePending)
                return .pending
            case .userCancelled:
                AppAnalytics.log(.purchaseCancelled)
                return .cancelled
            @unknown default:
                AppAnalytics.log(.purchaseFailed)
                return .purchaseFailed
            }
        } catch StoreKitError.userCancelled {
            AppAnalytics.log(.purchaseCancelled)
            return .cancelled
        } catch {
            AppAnalytics.log(.purchaseFailed)
            return .purchaseFailed
        }
    }

    func restoreFullAccess() async -> FullAccessResult {
        guard !isStoreOperationInProgress else { return .cancelled }
        isStoreOperationInProgress = true
        defer { isStoreOperationInProgress = false }
        let waitID = UUID()
        return await withTaskCancellationHandler {
            await withCheckedContinuation { continuation in
                guard !Task.isCancelled else {
                    continuation.resume(returning: .cancelled)
                    return
                }
                restoreWaitID = waitID
                restoreWaiter = continuation
                restoreWaitTimeout = Task { [weak self] in
                    do { try await Task.sleep(for: .seconds(30)) } catch { return }
                    self?.finishRestoreWait(id: waitID, result: .restorePending)
                }
                // A retry waits on the existing Apple request, including a request whose UI timed out.
                if restoreRequest == nil {
                    AppAnalytics.log(.restoreStarted)
                    isRestoringFullAccess = true
                    restoreRequest = Task {
                        let result = await performRestore()
                        isRestoringFullAccess = false
                        restoreRequest = nil
                        if let id = restoreWaitID {
                            finishRestoreWait(id: id, result: result)
                        }
                    }
                }
            }
        } onCancel: {
            Task { @MainActor [weak self] in
                self?.finishRestoreWait(id: waitID, result: .cancelled)
            }
        }
    }

    private func finishRestoreWait(id: UUID, result: FullAccessResult) {
        guard restoreWaitID == id else { return }
        let waiter = restoreWaiter
        restoreWaiter = nil
        restoreWaitID = nil
        restoreWaitTimeout?.cancel()
        restoreWaitTimeout = nil
        waiter?.resume(returning: result)
    }

    private func performRestore() async -> FullAccessResult {
        do {
            try await AppStore.sync()
            let unlocked = await refreshFullAccess()
            AppAnalytics.log(unlocked ? .restoreSucceeded : .restoreNotFound)
            return unlocked ? .unlocked : .nothingToRestore
        } catch StoreKitError.userCancelled {
            AppAnalytics.log(.restoreCancelled)
            return .cancelled
        } catch {
            AppAnalytics.log(.restoreFailed)
            return .restoreFailed
        }
    }

    private func processFullAccessTransaction(_ result: VerificationResult<StoreKit.Transaction>) async -> Bool {
        guard case .verified(let transaction) = result, Self.isFullAccess(transaction) else { return false }
        let ownsFullAccess = await refreshFullAccess()
        if ownsFullAccess || transaction.revocationDate != nil {
            await transaction.finish()
        }
        return ownsFullAccess
    }

    private static func isFullAccess(_ transaction: StoreKit.Transaction) -> Bool {
        transaction.productID == fullAccessProductID && transaction.productType == .nonConsumable
    }
    #endif

    var languageCode: String {
        #if DEBUG
        if let debugLanguage { return debugLanguage.resolvedLanguage() }
        #endif
        return ContentLanguagePreference.system.resolvedLanguage()
    }

    var hasFullAccess: Bool {
        #if DEBUG
        if mockIAP { return true }
        #endif
        #if os(iOS)
        return verifiedFullAccess == true
        #else
        return false
        #endif
    }

    func text(_ chinese: String, _ english: String) -> String {
        languageCode == "zh-Hans" ? chinese : english
    }

    // Refresh system language after returning from Settings; ignore legacy saved preferences.
    func reload() {
        refreshWidgetSettings()
        objectWillChange.send()
    }

    private func enableDailyArtworkAfterUnlock() {
        guard let defaults = DesktopWidgetDisplayPreferences.sharedDefaults,
              !defaults.bool(forKey: DesktopWidgetDisplayPreferences.followsDailyArtworkKey) else { return }
        defaults.set(true, forKey: DesktopWidgetDisplayPreferences.followsDailyArtworkKey)
        WidgetCenter.shared.reloadTimelines(ofKind: DesktopWidgetDisplayPreferences.widgetKind)
    }

    private func refreshWidgetSettings() {
        guard let defaults = DesktopWidgetDisplayPreferences.sharedDefaults else { return }
        let language = ContentLanguagePreference.system.resolvedLanguage()
        var needsRefresh = false
        if defaults.string(forKey: DesktopWidgetDisplayPreferences.languageCodeKey) != language {
            defaults.set(language, forKey: DesktopWidgetDisplayPreferences.languageCodeKey)
            needsRefresh = true
        }
        #if os(iOS)
        if let verifiedFullAccess,
           defaults.bool(forKey: DesktopWidgetDisplayPreferences.verifiedFullAccessKey) != verifiedFullAccess {
            defaults.set(verifiedFullAccess, forKey: DesktopWidgetDisplayPreferences.verifiedFullAccessKey)
            needsRefresh = true
        }
        #endif
        #if DEBUG
        let languageOverride = debugLanguage?.resolvedLanguage()
        if defaults.string(forKey: DesktopWidgetDisplayPreferences.debugLanguageKey) != languageOverride {
            defaults.set(languageOverride, forKey: DesktopWidgetDisplayPreferences.debugLanguageKey)
            needsRefresh = true
        }
        if defaults.bool(forKey: DesktopWidgetDisplayPreferences.mockFullAccessKey) != mockIAP {
            defaults.set(mockIAP, forKey: DesktopWidgetDisplayPreferences.mockFullAccessKey)
            needsRefresh = true
        }
        #endif
        if needsRefresh {
            WidgetCenter.shared.reloadTimelines(ofKind: DesktopWidgetDisplayPreferences.widgetKind)
        }
    }
}

struct AppSettingsView: View {
    private static let unlockRowInset: CGFloat = 8

    @EnvironmentObject private var settings: AppSettingsLibrary
    #if os(iOS)
    @ScaledMetric(relativeTo: .body) private var widgetDisplayFontSize = 16
    #endif
    @State private var showsPaywall = false
    @State private var pendingWidgetChange: (() -> Void)?
    @AppStorage(DesktopWidgetDisplayPreferences.showsDateKey, store: DesktopWidgetDisplayPreferences.sharedDefaults)
    private var showsWidgetDate = true
    @AppStorage(DesktopWidgetDisplayPreferences.showsLunarDateKey, store: DesktopWidgetDisplayPreferences.sharedDefaults)
    private var showsWidgetLunarDate = DesktopWidgetDisplayPreferences.defaultShowsLunarDate
    @AppStorage(DesktopWidgetDisplayPreferences.showsQuoteKey, store: DesktopWidgetDisplayPreferences.sharedDefaults)
    private var showsWidgetQuote = true
    @AppStorage(DesktopWidgetDisplayPreferences.followsDailyArtworkKey, store: DesktopWidgetDisplayPreferences.sharedDefaults)
    private var followsDailyArtwork = false

    var body: some View {
        VStack(spacing: ScreenTitle.contentSpacing - Self.unlockRowInset) {
            ScreenTitle(title: settings.text("设置", "Settings"))
            settingsList
        }
        .background(CalendarPalette.appBackground)
        #if os(iOS)
        .toolbar(.hidden, for: .navigationBar)
        .fullScreenCover(isPresented: $showsPaywall, onDismiss: finishWidgetChange) {
            NavigationStack { paywall }
        }
        #else
        .sheet(isPresented: $showsPaywall) {
            NavigationStack { V2LifetimePaywallView() }
        }
        #endif
        .task(id: settings.languageCode) {
            await Task.yield()
            guard !Task.isCancelled else { return }
            settings.legalPages.prepare(language: settings.languageCode)
        }
        .tint(CalendarPalette.vermilion)
    }

    @ViewBuilder
    private var paywall: some View {
        #if DEBUG
        if pendingWidgetChange != nil {
            V2LifetimePaywallView(scene: .widgetDisplay, onMockPurchase: { simulateWidgetPurchase() })
        } else {
            V2LifetimePaywallView()
        }
        #else
        V2LifetimePaywallView(scene: pendingWidgetChange == nil ? .settings : .widgetDisplay)
        #endif
    }

    private var settingsList: some View {
        List {
            Section {
                Button { showsPaywall = true } label: {
                    Label(settings.hasFullAccess ? settings.text("已永久解锁", "Full Access Unlocked") : settings.text("永久解锁", "Unlock Full Access"),
                          systemImage: settings.hasFullAccess ? "checkmark.seal.fill" : "crown.fill")
                        .font(CalendarTypography.font(.chineseTitle, size: 20))
                        .frame(maxWidth: .infinity, minHeight: 72)
                        .foregroundStyle(.white)
                        .background(CalendarPalette.vermilion, in: RoundedRectangle(cornerRadius: 8))
                }
                .buttonStyle(.plain)
                .listRowInsets(EdgeInsets(top: Self.unlockRowInset, leading: 8,
                                          bottom: Self.unlockRowInset, trailing: 8))
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
            }

            widgetSettingsSection

            Section(settings.text("信息", "Info")) {
                ForEach(LegalDocument.allCases) { document in
                    NavigationLink {
                        LegalDocumentPage(document: document)
                    } label: {
                        Label(document.title(settings), systemImage: document.icon)
                    }
                }
                NavigationLink {
                    LegalDocumentPage(document: nil)
                } label: {
                    Label(settings.text("苹果标准许可协议（EULA）", "Apple Standard EULA"), systemImage: "doc.badge.gearshape")
                }
                valueRow(settings.text("版本号", "Version"), icon: "info.circle", value: version)
            }

            #if DEBUG
            Section(settings.text("调试", "Debug")) {
                #if os(iOS)
                Toggle(isOn: $settings.alwaysShowsOnboarding) {
                    Label(settings.text("始终显示首次引导", "Always Show Onboarding"), systemImage: "sparkles.rectangle.stack")
                }
                .accessibilityIdentifier("debug.alwaysShowOnboarding")
                NavigationLink {
                    WidgetPreviewGallery()
                } label: {
                    Label(settings.text("Widget 全类型预览", "All Widget Previews"), systemImage: "rectangle.3.group")
                }
                .accessibilityIdentifier("debug.widgetPreviews")
                #endif
                Picker(selection: Binding(
                    get: { settings.debugLanguage ?? (settings.languageCode == "zh-Hans" ? .chinese : .english) },
                    set: { settings.debugLanguage = $0 }
                )) {
                    Label("中文", systemImage: "character.bubble").tag(ContentLanguagePreference.chinese)
                    Label("English", systemImage: "a.square").tag(ContentLanguagePreference.english)
                } label: {
                    Label(settings.text("语言", "Language"), systemImage: "globe")
                }
                Toggle(isOn: $settings.mockIAP) {
                    Label(settings.text("模拟 IAP 已支付", "Mock IAP Purchase"), systemImage: "creditcard")
                }
            }
            #endif


        }
        .font(CalendarTypography.font(.chineseBody, size: 16))
        .scrollContentBackground(.hidden)
        .contentMargins(.top, 0, for: .scrollContent)
    }

    private var version: String {
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "—"
        let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "—"
        return "\(version) (\(build))"
    }

    @ViewBuilder
    private var widgetSettingsSection: some View {
        #if os(iOS)
        if UIDevice.current.userInterfaceIdiom == .phone {
            Section(settings.text("小组件", "Widgets")) {
                NavigationLink {
                    widgetDisplaySettings
                } label: {
                    Label(settings.text("显示设置", "Display Settings"), systemImage: "slider.horizontal.3")
                }
                widgetGuideLink(.homeScreen(locale: Locale(identifier: settings.languageCode)))
                widgetGuideLink(.lockScreen(locale: Locale(identifier: settings.languageCode)))
            }
        } else {
            desktopWidgetSection
        }
        #else
        desktopWidgetSection
        #endif
    }

    private var desktopWidgetSection: some View {
        Section(settings.text("桌面小组件", "Home Screen Widgets")) {
            widgetDisplayToggles
        }
    }

    #if os(iOS)
    private var widgetDisplaySettings: some View {
        List {
            Section {
                widgetDisplayToggles
            } header: {
                Text(settings.text("桌面小组件", "Home Screen Widgets"))
            } footer: {
                Text(settings.text("选择桌面小组件中要显示的内容。", "Choose what your Home Screen widgets show."))
            }
        }
        .font(CalendarTypography.font(.chineseBody, size: widgetDisplayFontSize))
        .scrollContentBackground(.hidden)
        .background(CalendarPalette.appBackground.ignoresSafeArea())
        .settingsInlineNavigation(title: settings.text("显示设置", "Display Settings"))
        .toolbar(.visible, for: .navigationBar)
    }

    private func widgetGuideLink(_ guide: WidgetSetupGuide) -> some View {
        NavigationLink {
            WidgetSetupGuideView(guide: guide)
        } label: {
            Label(settings.text(guide.title, guide.englishTitle), systemImage: guide.icon)
        }
    }
    #endif

    @ViewBuilder
    private var widgetDisplayToggles: some View {
        #if os(iOS)
        widgetDisplayToggle("每日换插画", "Change Artwork Daily", isOn: $followsDailyArtwork, freeValue: false)
        #endif
        widgetDisplayToggle("显示日期", "Show Date", isOn: $showsWidgetDate, freeValue: true)
        if settings.languageCode == "zh-Hans" {
            widgetDisplayToggle("显示农历", "Show Lunar Date", isOn: $showsWidgetLunarDate, freeValue: false)
        }
        widgetDisplayToggle("显示语录", "Show Quote", isOn: $showsWidgetQuote, freeValue: true)
    }

    private var canCustomizeWidgets: Bool {
        #if os(iOS)
        settings.hasFullAccess
        #else
        true
        #endif
    }

    private func widgetDisplayToggle(_ chinese: String, _ english: String, isOn: Binding<Bool>, freeValue: Bool) -> some View {
        Toggle(settings.text(chinese, english), isOn: Binding(
            get: { canCustomizeWidgets ? isOn.wrappedValue : freeValue },
            set: { value in
                let apply = {
                    isOn.wrappedValue = value
                    WidgetCenter.shared.reloadTimelines(ofKind: DesktopWidgetDisplayPreferences.widgetKind)
                }
                if canCustomizeWidgets {
                    apply()
                } else if value != freeValue {
                    pendingWidgetChange = apply
                    showsPaywall = true
                }
            }
        ))
    }

    private func finishWidgetChange() {
        let change = pendingWidgetChange
        pendingWidgetChange = nil
        if settings.hasFullAccess { change?() }
    }

    #if DEBUG
    private func simulateWidgetPurchase() {
        settings.mockIAP = true
        finishWidgetChange()
    }
    #endif

    private func valueRow(_ title: String, icon: String, value: String) -> some View {
        HStack {
            Label(title, systemImage: icon)
            Spacer()
            Text(value).foregroundStyle(.secondary).multilineTextAlignment(.trailing)
        }
        .accessibilityElement(children: .combine)
    }


}

#if os(iOS)
private struct WidgetSetupGuide {
    struct Step {
        let icon: String
        let title: String
        let detail: String

        init(_ icon: String, _ title: String, _ detail: String) {
            self.icon = icon
            self.title = title
            self.detail = detail
        }
    }

    let title: String
    let englishTitle: String
    let icon: String
    let heading: String
    let introduction: String
    let steps: [Step]

    static func homeScreen(locale: Locale) -> Self { Self(
        title: "桌面小组件",
        englishTitle: "Home Screen Widgets",
        icon: "iphone",
        heading: locale.calendarText("将日历添加到主屏幕", "Add the Calendar to Your Home Screen"),
        introduction: locale.calendarText("在桌面查看当天的手绘插画、日期和语录。", "See today’s hand-drawn artwork, date, and quote on your Home Screen."),
        steps: [
            .init("hand.tap", locale.calendarText("进入编辑模式", "Enter Edit Mode"), locale.calendarText("回到 iPhone 主屏幕，长按空白处，直到 App 图标开始晃动。", "On your iPhone Home Screen, touch and hold an empty area until the app icons jiggle.")),
            .init("plus.circle", locale.calendarText("打开小组件列表", "Open the Widget Gallery"), locale.calendarText("轻点左上角的「编辑」，再选「添加小组件」。如果左上角直接显示「＋」，轻点「＋」即可。", "Tap Edit at the top left, then Add Widget. If you see a + button instead, tap it.")),
            .init("magnifyingglass", locale.calendarText("找到毛选日历", "Find Mao Quotes"), locale.calendarText("在小组件列表中搜索「毛选日历」，或向下滚动找到它并轻点打开。", "Search for Mao Quotes in the widget gallery, or scroll down and tap it.")),
            .init("rectangle.on.rectangle", locale.calendarText("选择尺寸并添加", "Choose a Size and Add"), locale.calendarText("左右滑动浏览「每日语录日历」的尺寸预览，选好后轻点「添加小组件」。", "Swipe through the Daily Quote Calendar sizes, then tap Add Widget.")),
            .init("checkmark.circle", locale.calendarText("调整位置并完成", "Position It and Finish"), locale.calendarText("将小组件拖到想放的位置，再轻点「完成」。", "Drag the widget to your preferred position, then tap Done."))
        ]
    ) }

    static func lockScreen(locale: Locale) -> Self { Self(
        title: "锁屏小组件",
        englishTitle: "Lock Screen Widgets",
        icon: "lock.rectangle",
        heading: locale.calendarText("将日历添加到锁屏", "Add the Calendar to Your Lock Screen"),
        introduction: locale.calendarText("点亮屏幕，就能看到当天的日历内容。", "Wake your screen to see today’s calendar."),
        steps: [
            .init("hand.tap", locale.calendarText("打开锁屏编辑", "Edit Your Lock Screen"), locale.calendarText("点亮 iPhone，在锁屏上长按空白处。系统要求验证时，使用面容 ID、触控 ID 或密码。", "Wake your iPhone, then touch and hold an empty area on the Lock Screen. Authenticate with Face ID, Touch ID, or your passcode if asked.")),
            .init("slider.horizontal.3", locale.calendarText("自定义锁屏", "Customize the Lock Screen"), locale.calendarText("找到想编辑的锁屏，轻点下方的「自定义」。如果出现「锁屏」和「主屏幕」两个选项，选择「锁屏」。", "Find the Lock Screen you want to edit and tap Customize. If asked to choose between Lock Screen and Home Screen, choose Lock Screen.")),
            .init("plus.circle", locale.calendarText("选择小组件区域", "Choose a Widget Area"), locale.calendarText("轻点时钟下方的「添加小组件」或现有小组件区域，可选圆形或矩形样式。要添加单行样式，轻点时钟上方的日期区域。", "Tap Add Widgets or the existing widget area below the clock for circular or rectangular styles. For an inline widget, tap the date above the clock.")),
            .init("magnifyingglass", locale.calendarText("找到并添加毛选日历", "Find and Add Mao Quotes"), locale.calendarText("在列表中找到「毛选日历」，轻点可用的「日历锁屏」样式。如果空间不足，可先移除一个现有小组件。", "Find Mao Quotes in the list and tap a Lock Screen Calendar style. Remove an existing widget first if there is not enough room.")),
            .init("checkmark.circle", locale.calendarText("保存锁屏", "Save Your Lock Screen"), locale.calendarText("关闭小组件选择面板，轻点右上角的「完成」，再轻点刚编辑的锁屏返回。", "Close the widget picker, tap Done at the top right, then tap your edited Lock Screen to return."))
        ]
    ) }
}

private struct WidgetSetupGuideView: View {
    @EnvironmentObject private var settings: AppSettingsLibrary
    let guide: WidgetSetupGuide
    @ScaledMetric(relativeTo: .title2) private var headingSize = 26
    @ScaledMetric(relativeTo: .body) private var introductionSize = 15
    @ScaledMetric(relativeTo: .headline) private var stepTitleSize = 17
    @ScaledMetric(relativeTo: .footnote) private var stepBodySize = 13
    @ScaledMetric(relativeTo: .headline) private var badgeSize = 34

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                VStack(spacing: 12) {
                    Image(systemName: guide.icon)
                        .font(.system(size: 40, weight: .medium))
                        .foregroundStyle(CalendarPalette.vermilion)
                        .accessibilityHidden(true)
                    Text(guide.heading)
                        .font(CalendarTypography.font(.chineseTitle, size: headingSize))
                        .foregroundStyle(CalendarPalette.ink)
                        .accessibilityAddTraits(.isHeader)
                    Text(guide.introduction)
                        .font(CalendarTypography.font(.chineseBody, size: introductionSize))
                        .foregroundStyle(CalendarPalette.vermilion.opacity(0.85))
                }
                .multilineTextAlignment(.center)
                .padding(.vertical, 12)

                ForEach(guide.steps.indices, id: \.self) { index in
                    stepCard(guide.steps[index], number: index + 1)
                }
            }
            .frame(maxWidth: 520)
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .frame(maxWidth: .infinity)
        }
        .background(CalendarPalette.appBackground.ignoresSafeArea())
        .settingsInlineNavigation(title: settings.text(guide.title, guide.englishTitle))
        .toolbar(.visible, for: .navigationBar)
        .toolbar(.hidden, for: .tabBar)
    }

    private func stepCard(_ step: WidgetSetupGuide.Step, number: Int) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Text(number, format: .number)
                .font(CalendarTypography.font(.date, size: stepTitleSize))
                .foregroundStyle(CalendarPalette.vermilion)
                .frame(width: badgeSize, height: badgeSize)
                .background(CalendarPalette.vermilion.opacity(0.10), in: Circle())
                .accessibilityLabel(settings.text("第\(number)步", "Step \(number)"))
            VStack(alignment: .leading, spacing: 6) {
                HStack(alignment: .firstTextBaseline, spacing: 6) {
                    Image(systemName: step.icon)
                        .foregroundStyle(CalendarPalette.vermilion)
                        .accessibilityHidden(true)
                    Text(step.title)
                }
                .font(CalendarTypography.font(.chineseTitle, size: stepTitleSize))
                .foregroundStyle(CalendarPalette.ink)
                Text(step.detail)
                    .font(CalendarTypography.font(.chineseBody, size: stepBodySize))
                    .foregroundStyle(CalendarPalette.ink)
                    .lineSpacing(3)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(14)
        .background(CalendarPalette.paper, in: RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(CalendarPalette.vermilion.opacity(0.20), lineWidth: 1))
        .accessibilityElement(children: .combine)
    }
}
#endif

enum FullAccessPaywallScene {
    case settings, widgetDisplay, todayCardLimit, yearbookLimit, wallpaperLimit
}

#if os(iOS)
enum FullAccessResult: String, Identifiable {
    case unlocked, pending, cancelled, nothingToRestore, verificationFailed, purchaseFailed, restoreFailed, restorePending

    var id: Self { self }
}
#endif

// Uses v2 typography and materials; the purchase area leads per the 2026-11-02 revision.
struct V2LifetimePaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var settings: AppSettingsLibrary
    @ScaledMetric(relativeTo: .title) private var headingSize = 36
    #if os(iOS)
    @State private var storeFeedback: FullAccessResult?
    @State private var restoreWaitTask: Task<Void, Never>?
    #else
    @State private var showsAvailability = false
    #endif
    var scene: FullAccessPaywallScene = .settings
    #if DEBUG
    var onMockPurchase: (() -> Void)?
    #endif

    private var isChinese: Bool { settings.languageCode == "zh-Hans" }

    private var scenePrompt: String? {
        switch scene {
        case .todayCardLimit:
            settings.text("永久解锁，可翻阅所有卡片。", "Unlock for life to browse all cards.")
        case .yearbookLimit:
            settings.text("永久解锁，可查看完整年度册。", "Unlock for life to browse the full yearbook.")
        case .wallpaperLimit:
            settings.text("永久解锁，可查看所有壁纸、切换排版并高清导出。",
                          "Unlock for life to view all wallpapers, change layouts, and export in HD.")
        case .settings, .widgetDisplay:
            nil
        }
    }

    @State private var hasOpenHinge = false

    var body: some View {
        GeometryReader { geometry in
            if hasOpenHinge && geometry.size.width >= 800 {
                duoPages(size: geometry.size)
            } else {
                ScrollView {
                    VStack(spacing: 26) {
                        VStack(spacing: 12) {
                            introduction
                            purchaseControls
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 24)
                        .frame(maxWidth: .infinity)
                        .background(CalendarPalette.paper.opacity(0.55))
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(CalendarPalette.vermilion, lineWidth: 1))
                        benefits
                        purchaseLinks
                    }
                    .frame(maxWidth: 520)
                    .padding(.horizontal, 20)
                    .padding(.top, 4)
                    .padding(.bottom, 24)
                    .frame(maxWidth: .infinity)
                }
            }
        }
        #if os(iOS)
        .background {
            if #available(iOS 27.1, *) {
                DuoHingeObserver { hasOpenHinge = $0 }
                    .allowsHitTesting(false)
            }
        }
        #endif
        .background {
            ZStack {
                CalendarPalette.paper
                Image(decorative: "CalendarPaperIvoryCandidate")
                    .resizable().scaledToFill().opacity(0.48)
            }
            .ignoresSafeArea()
        }
        .onAppear { AppAnalytics.log(.paywallViewed) }
        .navigationTitle("")
        .settingsInlineNavigation(title: "")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button { dismiss() } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 21, weight: .regular))
                        .foregroundStyle(CalendarPalette.secondaryInk)
                        .frame(width: 44, height: 44)
                }
                .accessibilityLabel(settings.text("关闭付费墙", "Close Paywall"))
                .disabled(preventsClosingPaywall)
            }
        }
        .tint(CalendarPalette.secondaryInk)
        #if os(iOS)
        .onDisappear {
            restoreWaitTask?.cancel()
            restoreWaitTask = nil
        }
        .onChange(of: settings.hasFullAccess, initial: true) { _, ownsFullAccess in
            if ownsFullAccess {
                storeFeedback = nil
            } else {
                Task { await settings.loadFullAccessProduct() }
            }
        }
        .alert(item: $storeFeedback) { result in
            Alert(title: Text(feedbackTitle(for: result)),
                  dismissButton: .default(Text(settings.text("好", "OK"))))
        }
        #else
        .alert(settings.text("购买暂未开放", "Purchases Unavailable"), isPresented: $showsAvailability) {
            Button(settings.text("好", "OK"), role: .cancel) {}
        } message: {
            Text(settings.text("当前版本尚未接入 App Store 购买，不会产生扣费。", "App Store purchasing is not connected in this version. You will not be charged."))
        }
        #endif
    }

    private var isStoreBusy: Bool {
        #if os(iOS)
        settings.isStoreOperationInProgress
        #else
        false
        #endif
    }

    private var preventsClosingPaywall: Bool {
        #if os(iOS)
        isStoreBusy && !settings.isRestoringFullAccess
        #else
        isStoreBusy
        #endif
    }

    private var displayedPrice: String {
        if settings.hasFullAccess { return settings.text("已解锁", "Unlocked") }
        #if os(iOS)
        if let product = settings.fullAccessProduct { return product.displayPrice }
        if settings.isFullAccessProductUnavailable {
            return settings.text("暂时无法获取价格", "Price unavailable")
        }
        return settings.text("正在获取价格…", "Loading price…")
        #else
        return settings.text("价格待定", "Price to be confirmed")
        #endif
    }

    private var purchaseButtonTitle: String {
        if settings.hasFullAccess { return settings.text("完成", "Done") }
        #if os(iOS)
        if isStoreBusy {
            return settings.isRestoringFullAccess
                ? settings.text("正在恢复购买…", "Restoring Purchases…")
                : settings.text("正在处理…", "Processing…")
        }
        if settings.isFullAccessProductUnavailable { return settings.text("重试", "Retry") }
        if settings.fullAccessProduct != nil { return settings.text("永久解锁", "Full Access") }
        #endif
        return settings.text("永久解锁", "Unlock for Life")
    }

    private var canUsePurchaseButton: Bool {
        if isStoreBusy { return false }
        #if os(iOS)
        if settings.isRestoringFullAccess { return settings.hasFullAccess }
        return settings.hasFullAccess || settings.isFullAccessProductUnavailable ||
            (settings.verifiedFullAccess != nil && settings.fullAccessProduct != nil)
        #else
        return !showsAvailability
        #endif
    }

    private func usePurchaseButton() {
        if settings.hasFullAccess {
            dismiss()
            return
        }
        #if os(iOS)
        Task {
            if settings.fullAccessProduct == nil {
                await settings.loadFullAccessProduct()
            } else {
                handleStoreResult(await settings.purchaseFullAccess())
            }
        }
        #else
        showsAvailability = true
        #endif
    }

    private func restorePurchases() {
        #if os(iOS)
        guard restoreWaitTask == nil else { return }
        restoreWaitTask = Task {
            let result = await settings.restoreFullAccess()
            guard !Task.isCancelled else { return }
            restoreWaitTask = nil
            handleStoreResult(result)
        }
        #else
        showsAvailability = true
        #endif
    }

    #if os(iOS)
    private func handleStoreResult(_ result: FullAccessResult) {
        switch result {
        case .unlocked: dismiss()
        case .cancelled: break
        default: storeFeedback = result
        }
    }

    private func feedbackTitle(for result: FullAccessResult) -> String {
        switch result {
        case .pending:
            settings.text("购买待批准，完成后将自动解锁。", "Purchase pending. Full Access unlocks once approved.")
        case .nothingToRestore:
            settings.text("未找到可恢复的购买。", "No purchase was found to restore.")
        case .verificationFailed:
            settings.text("暂时无法确认购买权益。", "Your purchase could not be verified.")
        case .purchaseFailed:
            settings.text("购买未能完成，请重试。", "The purchase could not be completed. Please try again.")
        case .restoreFailed:
            settings.text("恢复购买失败，请重试。", "Purchases could not be restored. Please try again.")
        case .restorePending:
            settings.text("Apple 仍在同步购买记录。你可以先关闭此页，完成后会自动更新解锁状态。",
                          "Apple is still syncing purchases. You can close this page. Full Access will update when the sync completes.")
        case .unlocked, .cancelled:
            ""
        }
    }
    #endif

    private var introduction: some View {
        VStack(spacing: 12) {
        Image("CalendarIcon-calendar-Candidate")
            .renderingMode(.template)
            .resizable().scaledToFit()
            .frame(width: 42, height: 42)
            .foregroundStyle(CalendarPalette.vermilion)
            .accessibilityHidden(true)
        (
            Text(settings.text("解锁", "Unlock ")).foregroundColor(CalendarPalette.ink)
            + Text(settings.text("完整日历", "Your Full Calendar")).foregroundColor(CalendarPalette.vermilion)
        )
        .font(CalendarTypography.font(isChinese ? .chineseTitle : .englishQuote, size: headingSize))
        .multilineTextAlignment(.center)
        .fixedSize(horizontal: false, vertical: true)
        Text(settings.text("一次买断，永久使用", "One purchase. Yours for life."))
            .font(CalendarTypography.font(.chineseTitle, size: 19))
            .foregroundStyle(CalendarPalette.secondaryInk)
        if let scenePrompt {
            Text(scenePrompt)
                .font(CalendarTypography.font(isChinese ? .chineseTitle : .englishQuote, size: 18))
                .foregroundStyle(CalendarPalette.vermilion)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
        }
    }

    private var purchaseControls: some View {
        VStack(spacing: 12) {
        Text(displayedPrice)
            .font(CalendarTypography.font(isChinese ? .chineseTitle : .englishQuote, size: isChinese ? 34 : 24))
            .multilineTextAlignment(.center)
            .foregroundStyle(CalendarPalette.ink)
        Button(action: usePurchaseButton) {
            PaywallPurchaseButtonLabel(title: purchaseButtonTitle, unlocked: settings.hasFullAccess)
        }
        .buttonStyle(PaywallPurchaseButtonStyle(emphasized: !settings.hasFullAccess && canUsePurchaseButton))
        .disabled(!canUsePurchaseButton)
        }
    }

    private var benefits: some View {
        VStack(spacing: 12) {
            ForEach(FullAccessBenefit.all) { item in
                benefit(item.chinese, item.english, icon: item.icon)
            }
        }
        .padding(.horizontal, 14)
    }

    private var purchaseLinks: some View {
        VStack(spacing: 20) {
            #if DEBUG
            if let onMockPurchase, !settings.hasFullAccess {
                Button(settings.text("模拟购买成功", "Simulate Successful Purchase")) {
                    onMockPurchase()
                    dismiss()
                }
                .font(CalendarTypography.font(.chineseBody, size: 15))
                .disabled(isStoreBusy)
            }
            #endif
            HStack(spacing: 14) {
                if !settings.hasFullAccess {
                    Button(action: restorePurchases) {
                        Text(settings.text("恢复购买", "Restore Purchases"))
                            .frame(minHeight: 44)
                    }
                    .disabled(isStoreBusy)
                }
                NavigationLink { LegalDocumentPage(document: .purchase) } label: {
                    Text(settings.text("购买协议", "Purchase Terms"))
                        .frame(minHeight: 44)
                }
                NavigationLink { LegalDocumentPage(document: .privacy) } label: {
                    Text(settings.text("隐私政策", "Privacy Policy"))
                        .frame(minHeight: 44)
                }
            }
            .font(CalendarTypography.font(isChinese ? .chineseBody : .englishQuote, size: 12))
            .lineLimit(1)
            .minimumScaleFactor(0.8)
            .buttonStyle(.plain)
        }
        .foregroundStyle(CalendarPalette.secondaryInk)
    }

    private func duoPages(size: CGSize) -> some View {
        let pageWidth = min((size.width - 72) / 2, 440)
        let pageHeight = max(1, size.height - 40)
        return HStack(alignment: .top, spacing: 24) {
            paywallPage(width: pageWidth, height: pageHeight) {
                VStack(spacing: 34) {
                    introduction
                    benefits
                }
            }
            paywallPage(width: pageWidth, height: pageHeight) {
                VStack(spacing: 32) {
                    purchaseControls
                    purchaseLinks
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func paywallPage<Content: View>(width: CGFloat, height: CGFloat, @ViewBuilder content: () -> Content) -> some View {
        ScrollView {
            content()
                .padding(28)
                .frame(maxWidth: .infinity)
                .frame(minHeight: height)
        }
        .scrollIndicators(.hidden)
        .frame(width: width, height: height)
        .background { PaperStack(showsBackingSheets: false) }
        .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
        .shadow(color: CalendarPalette.secondaryInk.opacity(0.2), radius: 10, x: 0, y: 6)
    }

    private func benefit(_ chinese: String, _ english: String, icon: String) -> some View {
        HStack(spacing: 16) {
            Image("CalendarIcon-\(icon)-Candidate")
                .renderingMode(.template)
                .resizable().scaledToFit()
                .frame(width: 30, height: 34)
                .foregroundStyle(CalendarPalette.vermilion)
                .accessibilityHidden(true)
            Rectangle().fill(CalendarPalette.secondaryInk.opacity(0.55))
                .frame(width: 0.5, height: 26)
                .accessibilityHidden(true)
            Text(settings.text(chinese, english))
                .font(CalendarTypography.font(isChinese ? .chineseTitle : .englishQuote, size: 16))
                .foregroundStyle(CalendarPalette.ink)
                .frame(maxWidth: .infinity, alignment: .leading)
                .fixedSize(horizontal: false, vertical: true)
        }
        .accessibilityElement(children: .combine)
    }
}

struct PaywallPurchaseButtonLabel: View {
    let title: String
    let unlocked: Bool
    var isProcessing = false

    var body: some View {
        HStack(spacing: 16) {
            if isProcessing { ProgressView().tint(.white) }
            Text(title)
            PaywallPurchaseIndicator(unlocked: unlocked)
        }
        .font(CalendarTypography.font(.chineseTitle, size: 25))
        .foregroundStyle(.white)
        .frame(maxWidth: .infinity, minHeight: 58)
        .background {
            GeometryReader { geometry in
                ZStack {
                    CalendarPalette.vermilion
                    Image(decorative: "CalendarPrintVermilionCandidate")
                        .resizable().scaledToFill().opacity(0.3)
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .clipped()
                }
                .clipShape(RoundedRectangle(cornerRadius: 7))
            }
        }
        .contentShape(RoundedRectangle(cornerRadius: 7))
    }
}

private struct PurchaseArrowProgressKey: EnvironmentKey {
    static let defaultValue: Double = 0
}

private extension EnvironmentValues {
    var purchaseArrowProgress: Double {
        get { self[PurchaseArrowProgressKey.self] }
        set { self[PurchaseArrowProgressKey.self] = newValue }
    }
}

private struct PaywallPurchaseIndicator: View {
    @Environment(\.purchaseArrowProgress) private var progress
    let unlocked: Bool

    var body: some View {
        Image(systemName: unlocked ? "checkmark" : "arrow.right")
            .offset(x: unlocked ? 0 : 7 * progress)
            .scaleEffect(unlocked ? 1 : 1 + 0.12 * progress)
            .accessibilityHidden(true)
    }
}

// The button and arrow share one two-second clock without changing layout bounds.
struct PaywallPurchaseButtonStyle: ButtonStyle {
    let emphasized: Bool

    func makeBody(configuration: Configuration) -> some View {
        PurchaseButtonMotion(label: configuration.label, isPressed: configuration.isPressed, emphasized: emphasized)
    }
}

private struct PurchaseButtonMotion<Label: View>: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.scenePhase) private var scenePhase
    @State private var visible = false
    @State private var cycleStart = Date()
    let label: Label
    let isPressed: Bool
    let emphasized: Bool

    private var animates: Bool {
        emphasized && visible && scenePhase == .active && !reduceMotion && !isPressed
    }

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 30, paused: !animates)) { timeline in
            let phase = max(0, timeline.date.timeIntervalSince(cycleStart)).truncatingRemainder(dividingBy: 2)
            let breath = animates ? (1 - cos(phase * .pi)) / 2 : 0
            let sweep = (phase - 0.25) / 1.15
            let shines = animates && sweep > 0 && sweep < 1
            label
                .environment(\.purchaseArrowProgress, breath)
                .overlay {
                    GeometryReader { geometry in
                        LinearGradient(
                            colors: [.clear, .white.opacity(0.30), .clear],
                            startPoint: .leading, endPoint: .trailing
                        )
                        .frame(width: geometry.size.width * 0.34, height: geometry.size.height * 2)
                        .rotationEffect(.degrees(18))
                        .offset(x: geometry.size.width * (sweep * 1.6 - 0.4), y: -geometry.size.height * 0.5)
                        .opacity(shines ? 1 : 0)
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 7))
                    .allowsHitTesting(false)
                    .accessibilityHidden(true)
                }
                .shadow(color: CalendarPalette.vermilion.opacity(0.18 + 0.24 * breath), radius: 5 + 9 * breath, y: 3)
                .scaleEffect(reduceMotion ? 1 : (isPressed ? 0.975 : 1 + 0.035 * breath))
                .opacity(isPressed ? 0.9 : 1)
                .animation(reduceMotion ? nil : .easeOut(duration: 0.14), value: isPressed)
        }
        .onAppear {
            cycleStart = Date()
            visible = true
        }
        .onDisappear { visible = false }
        .onChange(of: animates) { _, enabled in
            if enabled { cycleStart = Date() }
        }
    }
}

enum LegalDocument: String, CaseIterable, Identifiable {
    case privacy, terms, purchase
    var id: String { rawValue }
    @MainActor func title(_ settings: AppSettingsLibrary) -> String {
        switch self {
        case .privacy: settings.text("隐私政策", "Privacy Policy")
        case .terms: settings.text("用户协议", "Terms of Use")
        case .purchase: settings.text("购买协议", "Purchase Terms")
        }
    }
    var icon: String {
        switch self {
        case .privacy: "hand.raised"
        case .terms: "doc.text"
        case .purchase: "creditcard"
        }
    }
}

struct LegalDocumentPage: View {
    @EnvironmentObject private var settings: AppSettingsLibrary
    let document: LegalDocument?

    var body: some View {
        Group {
            if let document {
                if let url = Bundle.main.url(forResource: "\(document.rawValue)-\(settings.languageCode)", withExtension: "html", subdirectory: "Legal") {
                    SettingsBrowser(session: settings.legalPages.session(for: url))
                } else {
                    ContentUnavailableView(settings.text("文档暂不可用", "Document Unavailable"), systemImage: "doc.questionmark")
                }
            } else {
                RemoteLegalBrowser()
            }
        }
        .settingsInlineNavigation(title: document?.title(settings) ?? settings.text("苹果标准许可协议", "Apple Standard EULA"))

    }
}

// Cache only the three bundled documents in the current language, for this app session.
@MainActor
private final class LocalLegalPageCache {
    private var pages: [URL: SettingsWebSession] = [:]

    func prepare(language: String) {
        let urls = LegalDocument.allCases.compactMap {
            Bundle.main.url(forResource: "\($0.rawValue)-\(language)", withExtension: "html", subdirectory: "Legal")
        }
        pages = pages.filter { urls.contains($0.key) }
        for url in urls { _ = session(for: url) }
    }

    func session(for url: URL) -> SettingsWebSession {
        precondition(url.isFileURL)
        if let existing = pages[url] { return existing }
        let page = SettingsWebSession(url: url)
        pages[url] = page
        return page
    }
}

@MainActor
private final class SettingsWebSession: ObservableObject {
    let navigation: SettingsWebNavigation
    let view: WKWebView

    init(url: URL) {
        navigation = SettingsWebNavigation(source: url)
        view = makeSettingsWebView(url: url, delegate: navigation)
    }

    func retry() {
        navigation.failed = false
        navigation.isLoading = true
        let url = navigation.source
        if url.isFileURL {
            view.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
        } else {
            view.load(URLRequest(url: url))
        }
    }
}

private struct RemoteLegalBrowser: View {
    @StateObject private var session = SettingsWebSession(
        url: URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!
    )
    var body: some View { SettingsBrowser(session: session) }
}

private struct SettingsBrowser: View {
    @EnvironmentObject private var settings: AppSettingsLibrary
    @ObservedObject private var navigation: SettingsWebNavigation
    let session: SettingsWebSession

    init(session: SettingsWebSession) {
        self.session = session
        _navigation = ObservedObject(wrappedValue: session.navigation)
    }

    var body: some View {
        ZStack {
            SettingsWebView(session: session)
            if navigation.isLoading && !navigation.source.isFileURL {
                ProgressView(settings.text("正在加载", "Loading"))
            }
            if navigation.failed {
                VStack(spacing: 16) {
                    Label(settings.text("页面加载失败", "Unable to Load Page"),
                          systemImage: navigation.source.isFileURL ? "doc.badge.ellipsis" : "wifi.exclamationmark")
                    Button(settings.text("重试", "Try Again")) { session.retry() }
                }
                .font(CalendarTypography.font(.chineseBody, size: 16))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(CalendarPalette.appBackground)
            }
        }
    }
}

// Local documents may only navigate within their own resource directory.
// EULA requests are limited to Apple's HTTPS site; scripts and popups are disabled.
@MainActor
private final class SettingsWebNavigation: NSObject, ObservableObject, WKNavigationDelegate {
    @Published var isLoading = true
    @Published var failed = false
    let source: URL
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) { isLoading = false }
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        guard (error as NSError).code != NSURLErrorCancelled else { return }
        failed = true
        isLoading = false
    }
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        guard (error as NSError).code != NSURLErrorCancelled else { return }
        failed = true
        isLoading = false
    }
    func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
        failed = true
        isLoading = false
    }
    init(source: URL) { self.source = source }
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction,
                 decisionHandler: @escaping @MainActor @Sendable (WKNavigationActionPolicy) -> Void) {
        guard let destination = navigationAction.request.url else { decisionHandler(.cancel); return }
        if source.isFileURL {
            decisionHandler(destination.isFileURL && destination.standardizedFileURL.path.hasPrefix(source.deletingLastPathComponent().standardizedFileURL.path + "/") ? .allow : .cancel)
        } else {
            decisionHandler(destination.scheme == "https" && destination.host == "www.apple.com" ? .allow : .cancel)
        }
    }
}

@MainActor
private func makeSettingsWebView(url: URL, delegate: SettingsWebNavigation) -> WKWebView {
    let configuration = WKWebViewConfiguration()
    configuration.websiteDataStore = .nonPersistent()
    configuration.defaultWebpagePreferences.allowsContentJavaScript = false
    let view = WKWebView(frame: CGRect(x: 0, y: 0, width: 390, height: 700), configuration: configuration)
    view.navigationDelegate = delegate
    if url.isFileURL {
        view.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
    } else {
        view.load(URLRequest(url: url))
    }
    return view
}

#if os(iOS)
private struct SettingsWebView: UIViewRepresentable {
    let session: SettingsWebSession
    func makeUIView(context: Context) -> WKWebView { session.view }
    func updateUIView(_ view: WKWebView, context: Context) {}
}
#else
private struct SettingsWebView: NSViewRepresentable {
    let session: SettingsWebSession
    func makeNSView(context: Context) -> WKWebView { session.view }
    func updateNSView(_ view: WKWebView, context: Context) {}
}
#endif

private extension View {
    @ViewBuilder func settingsInlineNavigation(title: String) -> some View {
        #if os(iOS)
        navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(title)
                        .font(CalendarTypography.font(.chineseTitle, size: 18))
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }
            }
        #else
        navigationTitle(title)
        #endif
    }
}

#if DEBUG && os(iOS)
private struct WidgetPreviewSpec: Identifiable {
    let id: String
    let title: String
    let family: WidgetFamily
    let size: CGSize
    var lockScreen = false
    var standby = false

    static func all(locale: Locale) -> [Self] {
        var result: [Self] = [
            .init(id: "small", title: locale.calendarText("桌面 · 小号", "Home Screen · Small"), family: .systemSmall, size: .init(width: 170, height: 170)),
            .init(id: "medium", title: locale.calendarText("桌面 · 中号", "Home Screen · Medium"), family: .systemMedium, size: .init(width: 364, height: 170)),
            .init(id: "large", title: locale.calendarText("桌面 · 大号", "Home Screen · Large"), family: .systemLarge, size: .init(width: 364, height: 382)),
            .init(id: "extra-large", title: locale.calendarText("桌面 · 横向超大", "Home Screen · Extra Large"), family: .systemExtraLarge, size: .init(width: 720, height: 350))
        ]
        if #available(iOS 27.0, *) {
            result.append(.init(id: "duo-portrait", title: locale.calendarText("Duo · 竖向超大", "Duo · Extra Large Portrait"), family: .systemExtraLargePortrait,
                                size: .init(width: 364, height: 622)))
        }
        result += [
            .init(id: "lock-circular", title: locale.calendarText("锁屏 · 圆形", "Lock Screen · Circular"), family: .accessoryCircular,
                  size: .init(width: 76, height: 76), lockScreen: true),
            .init(id: "lock-rectangular", title: locale.calendarText("锁屏 · 矩形", "Lock Screen · Rectangular"), family: .accessoryRectangular,
                  size: .init(width: 172, height: 76), lockScreen: true),
            .init(id: "lock-inline", title: locale.calendarText("锁屏 · 行内", "Lock Screen · Inline"), family: .accessoryInline,
                  size: .init(width: 260, height: 26), lockScreen: true),
            .init(id: "standby", title: locale.calendarText("待机 · 小号组件", "StandBy · Small Widget"), family: .systemSmall,
                  size: .init(width: 220, height: 220), standby: true)
        ]
        return result
    }

    func previewSize(compact: Bool) -> CGSize {
        guard compact else { return size }
        switch id {
        case "small": return .init(width: 141, height: 141)
        case "medium": return .init(width: 292, height: 141)
        default: return size
        }
    }
}

private struct WidgetPreviewGallery: View {
    @Environment(\.locale) private var locale
    // Local preview controls deliberately do not write App Group preferences.
    @State private var selectedID = DailyArtworkCatalog.defaultWidgetArtworkID
    @State private var date = Date()
    @State private var showsDate = true
    @State private var showsLunar = true
    @State private var showsQuote = true
    private var display: DesktopWidgetDisplayPreferences {
        .init(showsDate: showsDate, showsLunarDate: showsLunar, showsQuote: showsQuote, followsDailyArtwork: true)
    }
    @State private var compact = false
    @State private var showsBackgrounds = false
    @State private var expanded: WidgetPreviewSpec?
    private let pages = DailyArtworkCatalog.pages
    private var backgrounds: [ArtworkPage] {
        var seen = Set<String>()
        return pages.filter { seen.insert($0.filename).inserted }
    }
    private var page: ArtworkPage? { DailyArtworkCatalog.page(contentID: selectedID) }
    private var calendarDate: CalendarDate {
        (try? CalendarDate.localDate(at: date)) ?? (try! CalendarDate(year: 2026, month: 11, day: 11))
    }
    private var index: Int { backgrounds.firstIndex { $0.filename == page?.filename } ?? 0 }

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 22) {
                controls
                if let page {
                    ForEach(WidgetPreviewSpec.all(locale: locale)) { spec in
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Text(spec.title).font(CalendarTypography.font(.chineseTitle, size: 18))
                                Spacer()
                                Button(locale.calendarText("原尺寸", "Actual Size")) { expanded = spec }
                                    .font(CalendarTypography.font(.chineseBody, size: 13))
                            }
                            let size = spec.previewSize(compact: compact)
                            GeometryReader { geometry in
                                let scale = min(1, geometry.size.width / size.width)
                                preview(page: page, spec: spec)
                                    .scaleEffect(scale, anchor: .topLeading)
                                    .frame(width: size.width * scale, height: size.height * scale, alignment: .topLeading)
                            }
                            .frame(height: fittedHeight(size))
                            Text("\(Int(size.width)) × \(Int(size.height)) pt" + (spec.lockScreen ? locale.calendarText(" · 使用锁屏组件实际内容", " · Actual Lock Screen widget content") : spec.id == "extra-large" ? locale.calendarText(" · iPad 布局", " · iPad layout") : ""))
                                .font(CalendarTypography.font(.chineseBody, size: 12))
                                .foregroundStyle(.secondary)
                        }
                        .padding(14)
                        .background(.white.opacity(0.45), in: RoundedRectangle(cornerRadius: 16))
                        .accessibilityIdentifier("widgetPreview.\(spec.id)")
                    }
                }
                if #unavailable(iOS 27.0) {
                    Text(locale.calendarText("Duo 竖向超大组件需在 iOS 27 或更新系统中预览。", "The Duo extra large portrait widget requires iOS 27 or later to preview."))
                        .font(CalendarTypography.font(.chineseBody, size: 13))
                }
                Text(locale.calendarText("此页复用实际 Widget 内容；桌面开关仅影响本页预览，锁屏使用独立布局。圆角、尺寸、待机夜间着色及系统渲染效果以实际设备为准。横向超大用于其他支持设备。", "These previews use the actual widget views. The controls affect Home Screen previews here; Lock Screen widgets use a separate layout. Corner shapes, sizing, StandBy night colors, and system rendering depend on the device. Extra Large is available on supported devices."))
                    .font(CalendarTypography.font(.chineseBody, size: 13))
                    .foregroundStyle(.secondary)
            }
            .padding(16)
        }
        .background(CalendarPalette.appBackground.ignoresSafeArea())
        .settingsInlineNavigation(title: locale.calendarText("Widget 预览", "Widget Preview"))
        .toolbar(.visible, for: .navigationBar)
        .sheet(isPresented: $showsBackgrounds) { backgroundPicker }
        .sheet(item: $expanded) { spec in
            NavigationStack {
                ScrollView([.horizontal, .vertical]) {
                    if let page { preview(page: page, spec: spec).padding(24) }
                }
                .background(CalendarPalette.appBackground)
                .navigationTitle(spec.title)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar { ToolbarItem(placement: .confirmationAction) { Button(locale.calendarText("完成", "Done")) { expanded = nil } } }
            }
        }
    }

    @MainActor static func renderQA() async throws {
        let folder = URL.cachesDirectory.appendingPathComponent("WidgetGalleryQA", isDirectory: true)
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        let gallery = WidgetPreviewGallery()
        if let scene = UIApplication.shared.connectedScenes.compactMap({ $0 as? UIWindowScene }).first {
            let window = UIWindow(windowScene: scene)
            window.rootViewController = UIHostingController(rootView: NavigationStack { gallery }
                .tint(CalendarPalette.vermilion))
            window.windowLevel = .normal + 1
            WidgetGalleryQAHost.window = window
            window.makeKeyAndVisible()
            try await Task.sleep(for: .milliseconds(300))
            window.layoutIfNeeded()
            let image = UIGraphicsImageRenderer(bounds: window.bounds).image { _ in
                window.drawHierarchy(in: window.bounds, afterScreenUpdates: true)
            }
            try image.pngData()!.write(to: folder.appendingPathComponent("gallery.png"))
        }
        var records: [[String: Any]] = []
        for page in gallery.backgrounds {
            for spec in WidgetPreviewSpec.all(locale: .current) {
                await Task.yield()
                try autoreleasepool {
                    let renderer = ImageRenderer(content: gallery.preview(page: page, spec: spec))
                    renderer.scale = 1
                    renderer.proposedSize = ProposedViewSize(spec.size)
                    guard let image = renderer.uiImage,
                          image.size == spec.size else { throw CocoaError(.coderInvalidValue) }
                    records.append(["background": page.filename, "type": spec.id,
                                    "width": image.size.width, "height": image.size.height])
                    if ["pack-0011", "pack-0021", "pack-0077"].contains(page.id) {
                        try image.pngData()!.write(to: folder.appendingPathComponent("\(page.id)-\(spec.id).png"))
                    }
                }
            }
        }
        try JSONSerialization.data(withJSONObject: records, options: [.prettyPrinted, .sortedKeys])
            .write(to: folder.appendingPathComponent("report.json"))
    }

    // Match the card's actual available width, including its internal padding.
    @State private var availableWidth: CGFloat = 320
    private func fittedHeight(_ size: CGSize) -> CGFloat { size.height * min(1, availableWidth / size.width) }

    private var controls: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(locale.calendarText("全部 \(backgrounds.count) 张背景 · \(WidgetPreviewSpec.all(locale: locale).count) 种预览", "\(backgrounds.count) backgrounds · \(WidgetPreviewSpec.all(locale: locale).count) previews"))
                .font(CalendarTypography.font(.chineseTitle, size: 18))
            HStack {
                Button { move(-1) } label: { Image(systemName: "chevron.left") }.accessibilityLabel(locale.calendarText("上一张背景", "Previous background"))
                Spacer()
                Button { showsBackgrounds = true } label: {
                    Text(locale.calendarText("选择背景 \(index + 1)/\(backgrounds.count)", "Choose Background \(index + 1)/\(backgrounds.count)")).underline()
                }
                .accessibilityIdentifier("widgetPreview.chooseBackground")
                Spacer()
                Button { move(1) } label: { Image(systemName: "chevron.right") }.accessibilityLabel(locale.calendarText("下一张背景", "Next background"))
            }
            if let page {
                Text("\(page.id) · \(page.localizedTitle(locale: locale))").font(CalendarTypography.font(.chineseBody, size: 13)).foregroundStyle(.secondary)
            }
            DatePicker(locale.calendarText("预览日期", "Preview Date"), selection: $date, displayedComponents: .date)
            Toggle(locale.calendarText("显示日期与星期", "Show Date and Weekday"), isOn: $showsDate)
            Toggle(locale.calendarText("显示农历", "Show Lunar Date"), isOn: $showsLunar)
            Toggle(locale.calendarText("显示语录", "Show Quote"), isOn: $showsQuote)
            Toggle(locale.calendarText("小号 / 中号使用紧凑尺寸", "Use Compact Small / Medium Sizes"), isOn: $compact)
        }
        .font(CalendarTypography.font(.chineseBody, size: 15))
        .padding(14)
        .background(.white.opacity(0.45), in: RoundedRectangle(cornerRadius: 16))
        .background {
            GeometryReader { geometry in
                Color.clear.onAppear { availableWidth = max(1, geometry.size.width - 28) }
                    .onChange(of: geometry.size.width) { _, width in availableWidth = max(1, width - 28) }
            }
        }
    }

    @ViewBuilder private func preview(page: ArtworkPage, spec: WidgetPreviewSpec) -> some View {
        let size = spec.previewSize(compact: compact)
        Group {
            if spec.lockScreen {
                ArtworkLockWidgetView(page: page, date: calendarDate, family: spec.family)
                    .foregroundStyle(.white)
                    .background(Color.black.opacity(0.8))
            } else {
                ArtworkWidgetView(page: page, quote: page.localizedQuote(locale: locale), date: calendarDate, family: spec.family, display: display)
            }
        }
        .frame(width: size.width, height: size.height)
        .clipShape(RoundedRectangle(cornerRadius: spec.lockScreen ? (spec.family == .accessoryCircular ? size.height / 2 : 8) : 24))
        .environment(\.colorScheme, spec.lockScreen || spec.standby ? .dark : .light)
    }

    private func move(_ delta: Int) {
        guard !backgrounds.isEmpty else { return }
        let target = (index + delta + backgrounds.count) % backgrounds.count
        selectedID = backgrounds[target].id
    }

    private var backgroundPicker: some View {
        NavigationStack {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVGrid(columns: [.init(.adaptive(minimum: 94))], spacing: 14) {
                        ForEach(backgrounds) { item in
                            Button {
                                selectedID = item.id
                                showsBackgrounds = false
                            } label: {
                                VStack(spacing: 5) {
                                    WidgetPreviewThumbnail(page: item)
                                        .aspectRatio(2 / 3, contentMode: .fit)
                                        .clipShape(RoundedRectangle(cornerRadius: 6))
                                        .overlay(RoundedRectangle(cornerRadius: 6).stroke(
                                            item.filename == page?.filename ? CalendarPalette.vermilion : .clear, lineWidth: 2))
                                    Text(item.id).font(CalendarTypography.font(.chineseBody, size: 12))
                                }
                            }
                            .buttonStyle(.plain)
                            .id(item.id)
                            .accessibilityLabel(locale.calendarText("背景 \(item.id)", "Background \(item.id)"))
                        }
                    }
                    .padding(16)
                }
                .onAppear { if !backgrounds.isEmpty { proxy.scrollTo(backgrounds[index].id, anchor: .center) } }
            }
            .navigationTitle(locale.calendarText("全部插画背景", "All Artwork Backgrounds"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .confirmationAction) { Button(locale.calendarText("完成", "Done")) { showsBackgrounds = false } } }
        }
    }
}
#endif

#if DEBUG && os(iOS)
private struct WidgetPreviewThumbnail: View {
    let page: ArtworkPage
    @State private var image: UIImage?
    var body: some View {
        Group {
            if let image { Image(uiImage: image).resizable() }
            else { Rectangle().fill(CalendarPalette.appBackground).overlay { ProgressView() } }
        }
        .task(id: page.filename) {
            guard let url = DailyArtworkCatalog.directory?.appendingPathComponent(page.filename),
                  let decoded = await WidgetPreviewThumbnailDecoder.shared.image(url), !Task.isCancelled else { return }
            image = UIImage(cgImage: decoded)
        }
        .onDisappear { image = nil }
    }
}

private actor WidgetPreviewThumbnailDecoder {
    static let shared = WidgetPreviewThumbnailDecoder()
    private let cache: NSCache<NSURL, CGImage> = {
        let cache = NSCache<NSURL, CGImage>()
        cache.totalCostLimit = 4 * 1024 * 1024
        return cache
    }()
    func image(_ url: URL) -> CGImage? {
        guard !Task.isCancelled else { return nil }
        if let image = cache.object(forKey: url as NSURL) { return image }
        guard let source = CGImageSourceCreateWithURL(url as CFURL, nil),
              let image = CGImageSourceCreateThumbnailAtIndex(source, 0, [
                kCGImageSourceCreateThumbnailFromImageAlways: true,
                kCGImageSourceCreateThumbnailWithTransform: true,
                kCGImageSourceThumbnailMaxPixelSize: 200,
                kCGImageSourceShouldCacheImmediately: true
              ] as CFDictionary), !Task.isCancelled else { return nil }
        cache.setObject(image, forKey: url as NSURL, cost: image.bytesPerRow * image.height)
        return image
    }
}
#endif

#if DEBUG && os(iOS)
@MainActor private enum WidgetGalleryQAHost { static var window: UIWindow? }

@MainActor func renderWidgetGalleryQA() async throws {
    try await WidgetPreviewGallery.renderQA()
}
#endif
