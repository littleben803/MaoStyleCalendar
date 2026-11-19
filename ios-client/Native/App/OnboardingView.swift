import SwiftUI

// Shared with the existing paywall so both entry points describe identical rights.
struct FullAccessBenefit: Identifiable {
    let chinese: String
    let english: String
    let icon: String
    var id: String { icon }

    static let all = [
        FullAccessBenefit(chinese: "所有插画和语录自由翻阅", english: "Browse all illustrations and quotes", icon: "open-book"),
        FullAccessBenefit(chinese: "桌面小组件插画每日更新", english: "Daily artwork updates for Home Screen widgets", icon: "calendar-grid"),
        FullAccessBenefit(chinese: "桌面小组件自定义显示", english: "Customize Home Screen widget display", icon: "settings"),
        FullAccessBenefit(chinese: "所有壁纸自由浏览", english: "Browse all wallpapers", icon: "wallpaper"),
        FullAccessBenefit(chinese: "自定义壁纸排版方式", english: "Choose your wallpaper layout", icon: "grid"),
        FullAccessBenefit(chinese: "所有壁纸高清导出和分享", english: "Export and share all wallpapers in HD", icon: "share")
    ]
}

#if os(iOS)
import UIKit

struct OnboardingView: View {
    @EnvironmentObject private var settings: AppSettingsLibrary
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @ScaledMetric(relativeTo: .largeTitle) private var headingSize: CGFloat = 42
    @ScaledMetric(relativeTo: .body) private var navigationSize: CGFloat = 17
    @ScaledMetric(relativeTo: .body) private var modeSize: CGFloat = 16
    @State private var page: Int
    @State private var artworkOnly = false
    @State private var todayDetailInFront = false
    let onPresented: () -> Void
    let onFinished: () -> Void

    init(initialPage: Int = 0, onPresented: @escaping () -> Void, onFinished: @escaping () -> Void) {
        _page = State(initialValue: min(3, max(0, initialPage)))
        #if DEBUG
        _todayDetailInFront = State(initialValue: ProcessInfo.processInfo.arguments.contains("--review-onboarding-detail-front"))
        #endif
        self.onPresented = onPresented
        self.onFinished = onFinished
    }

    private var isChinese: Bool { settings.languageCode == "zh-Hans" }
    private var canLeave: Bool { !settings.isStoreOperationInProgress || settings.isRestoringFullAccess }
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                VStack(spacing: 0) {
                    navigation
                    if page == 3 {
                        OnboardingFullAccessPage(onFinished: onFinished)
                            .contentShape(Rectangle())
                            .simultaneousGesture(DragGesture(minimumDistance: 35).onEnded { value in
                                guard value.translation.width > 35,
                                      value.translation.width > abs(value.translation.height) * 1.4 else { return }
                                move(to: 2)
                            })
                    } else {
                        portraitIntroduction(in: geometry.size)
                            .id("\(page)-\(settings.languageCode)")
                    }
                }
                .frame(maxWidth: 560)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .background { OnboardingPaper() }
            .toolbar(.hidden, for: .navigationBar)
            .tint(CalendarPalette.vermilion)
        }
        .preferredColorScheme(.light)
        .environment(\.locale, Locale(identifier: settings.languageCode))
        .onAppear(perform: onPresented)
        .onChange(of: page) { _, _ in todayDetailInFront = false }
        #if DEBUG
        .task(id: page) {
            guard page == 2, ProcessInfo.processInfo.arguments.contains("--review-onboarding-wallpaper-switch") else { return }
            do {
                try await Task.sleep(for: .seconds(3))
                guard !Task.isCancelled else { return }
                selectWallpaperMode(onlyArt: true)
                try await Task.sleep(for: .seconds(6))
                guard !Task.isCancelled else { return }
                selectWallpaperMode(onlyArt: false)
            } catch { return }
        }
        #endif
    }

    private var navigation: some View {
        HStack {
            Button { move(to: page - 1) } label: {
                Image(systemName: "chevron.left").frame(width: 44, height: 44)
            }
            .opacity(page == 0 ? 0 : 1)
            .disabled(page == 0 || !canLeave)
            .accessibilityLabel(settings.text("上一页", "Previous Page"))
            .accessibilityIdentifier("onboarding.back")
            Spacer()
            Button(settings.text("跳过", "Skip"), action: onFinished)
                .font(CalendarTypography.font(isChinese ? .chineseBody : .englishQuote, size: navigationSize))
                .frame(minWidth: 64, minHeight: 44)
                .disabled(!canLeave)
                .accessibilityIdentifier("onboarding.skip")
        }
        .foregroundStyle(CalendarPalette.ink)
        .padding(.horizontal, 12)
        .padding(.top, 12)
        .fixedSize(horizontal: false, vertical: true)
        .layoutPriority(1)
    }

    private func portraitIntroduction(in size: CGSize) -> some View {
        ScrollView {
            VStack(spacing: 12) {
                heading()
                hero
                    .frame(height: heroHeight(in: size))
            }
            .padding(.horizontal, 12)
            .padding(.bottom, 8)
            .frame(maxWidth: .infinity)
        }
        .scrollIndicators(.hidden)
        .safeAreaInset(edge: .bottom, spacing: 0) {
            VStack(spacing: 15) {
                if page == 2 { wallpaperModes() }
                OnboardingProgress(page: page)
                nextButton
            }
            .padding(.horizontal, 24)
            .padding(.top, 12)
            .padding(.bottom, 12)
            .background { OnboardingPaper() }
        }
    }

    private var hero: some View {
        OnboardingHero(page: page, language: isChinese ? "zh" : "en", artworkOnly: artworkOnly,
                       detailInFront: $todayDetailInFront)
            .contentShape(Rectangle())
            .accessibilityLabel(heroDescription)
            .accessibilityElement(children: page == 1 ? .contain : .ignore)
            .simultaneousGesture(DragGesture(minimumDistance: 35).onEnded { value in
                guard abs(value.translation.width) > abs(value.translation.height) * 1.4 else { return }
                move(to: page + (value.translation.width < 0 ? 1 : -1))
            })
            .accessibilityAction(named: Text(settings.text("下一页", "Next Page"))) { move(to: page + 1) }
    }

    private var nextButton: some View {
        Button(settings.text("继续", "Next")) { move(to: page + 1) }
            .buttonStyle(OnboardingPrimaryButton())
            .accessibilityIdentifier("onboarding.next")
    }

    private func heading() -> some View {
        let titles = [
            ("把值得读的话", "放在桌面", "Worth reading", "Within reach"),
            ("每天一页", "值得细读", "A page a day", "Worth exploring"),
            ("把喜欢的一页", "留在屏幕上", "Your favorite page", "On your screen")
        ]
        let title = titles[page]
        return VStack(spacing: 2) {
            Text(isChinese ? title.0 : title.2).foregroundStyle(CalendarPalette.ink)
            Text(isChinese ? title.1 : title.3).foregroundStyle(CalendarPalette.vermilion)
        }
        .font(CalendarTypography.font(isChinese ? .chineseTitle : .englishTitle,
                                      size: headingSize * (isChinese ? 1 : 0.83)))
        .multilineTextAlignment(.center)
        .fixedSize(horizontal: false, vertical: true)
        .padding(.top, 2)
        .accessibilityAddTraits(.isHeader)
        .accessibilityIdentifier("onboarding.heading")
    }

    private func heroHeight(in size: CGSize) -> CGFloat {
        if dynamicTypeSize.isAccessibilitySize { return min(340, size.width * 1.15) }
        let available = size.height - 44 - 120 - (page == 2 ? 72 : 0) - 124
        return max(240, min(size.width * 1.38, available))
    }

    private func wallpaperModes() -> some View {
        HStack(spacing: 0) {
            modeButton(onlyArt: false, chinese: "原稿排版", english: "Original Layout")
            modeButton(onlyArt: true, chinese: "仅插画", english: "Artwork Only")
        }
        .padding(3)
        .overlay(Capsule().stroke(CalendarPalette.secondaryInk.opacity(0.4), lineWidth: 0.7))
        .fixedSize(horizontal: false, vertical: true)
        .padding(.horizontal, 35)
    }

    private func modeButton(onlyArt: Bool, chinese: String, english: String) -> some View {
        Button {
            selectWallpaperMode(onlyArt: onlyArt)
        } label: {
            Text(settings.text(chinese, english))
                .font(CalendarTypography.font(isChinese ? .chineseTitle : .englishQuote, size: modeSize))
                .fixedSize(horizontal: false, vertical: true)
                .foregroundStyle(artworkOnly == onlyArt ? Color.white : CalendarPalette.ink)
                .frame(maxWidth: .infinity, minHeight: 38)
                .background(artworkOnly == onlyArt ? CalendarPalette.vermilion : .clear, in: Capsule())
        }
        .accessibilityAddTraits(artworkOnly == onlyArt ? .isSelected : [])
        .accessibilityIdentifier(onlyArt ? "onboarding.artworkOnly" : "onboarding.originalLayout")
    }

    private func selectWallpaperMode(onlyArt: Bool) {
        guard artworkOnly != onlyArt else { return }
        withAnimation(reduceMotion ? nil : .spring(response: 0.48, dampingFraction: 0.86)) {
            artworkOnly = onlyArt
        }
    }

    private var heroDescription: String {
        switch page {
        case 0: settings.text("多种尺寸的插画语录桌面小组件", "Illustrated quote widgets in different sizes")
        case 1: settings.text("铜环纸页日历与语录详解", "A paper calendar with a copper ring and quote details")
        default: settings.text("带语录的锁屏壁纸与仅插画的主屏壁纸", "A Lock Screen wallpaper with a quote and an artwork-only Home Screen wallpaper")
        }
    }

    private func move(to next: Int) {
        guard (0...3).contains(next), canLeave else { return }
        if next == 2 {
            withTransaction(Transaction(animation: nil)) { artworkOnly = false }
        }
        withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.22)) { page = next }
    }
}

private struct OnboardingHero: View {
    let page: Int
    let language: String
    let artworkOnly: Bool
    @Binding var detailInFront: Bool

    var body: some View {
        GeometryReader { geometry in
            let w = geometry.size.width
            let h = geometry.size.height
            ZStack {
                if page == 0 {
                    layer("widget-cards", width: w * 0.9, height: h * 0.96, delay: 0.2, x: 20)
                        .position(x: w * 0.61, y: h * 0.49)
                    layer("widget-phone", width: w * 0.74, height: h, delay: 0, x: 0)
                        .position(x: w * 0.34, y: h * 0.51)
                } else if page == 1 {
                    OnboardingTodayCards(language: language, detailInFront: $detailInFront)
                } else {
                    layer("wallpaper-lock", width: w * (artworkOnly ? 0.60 : 0.66), height: h * 1.02,
                          delay: 0, x: -18)
                        .position(x: w * 0.26, y: h * 0.52)
                    layer("wallpaper-home", width: w * (artworkOnly ? 0.79 : 0.73), height: h * 1.16,
                          delay: 0.2, x: 20)
                        .position(x: w * 0.63, y: h * 0.50)
                }
            }
        }
    }

    private func layer(_ name: String, width: CGFloat, height: CGFloat, delay: Double, x: CGFloat) -> some View {
        OnboardingLayer(name: "\(name)-\(language)", delay: delay, initialX: x)
            .frame(width: width, height: height)
            .opacity(name == "wallpaper-lock" && artworkOnly ? 0.5 : 1)
            .shadow(color: CalendarPalette.ink.opacity(name == "wallpaper-home" && artworkOnly ? 0.20 : 0),
                    radius: 14, x: 0, y: 7)
            .zIndex(name == "wallpaper-home" ? (artworkOnly ? 2 : 1) : 0)
    }
}

private struct OnboardingTodayCards: View {
    let language: String
    private let detailImage: UIImage?
    private let calendarImage: UIImage?
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Binding private var detailInFront: Bool
    @State private var separation: CGFloat = 0
    @State private var isSwitching = false

    init(language: String, detailInFront: Binding<Bool>) {
        self.language = language
        _detailInFront = detailInFront
        detailImage = Self.loadImage("today-detail-\(language)")
        calendarImage = Self.loadImage("today-front-\(language)")
    }

    var body: some View {
        GeometryReader { geometry in
            let w = geometry.size.width
            let h = geometry.size.height
            // Leave room around the full sheet so the soft shadow is never cut at the footer.
            let baseDetailWidth = min(w * 0.86, h * 0.90 * detailAspectRatio)
            let detailWidth = baseDetailWidth
            let calendarWidth = min(w * 0.72, baseDetailWidth / detailAspectRatio * 0.74 * calendarAspectRatio)
            ZStack {
                Button { bringForward(detail: true) } label: {
                    cardImage(detailImage, delay: 0.2, initialX: 18)
                        .frame(width: detailWidth, height: detailWidth / detailAspectRatio)
                        .shadow(color: CalendarPalette.ink.opacity(detailInFront ? 0.20 : 0.14),
                                radius: 2.5, x: 0, y: 1.5)
                        .shadow(color: CalendarPalette.secondaryInk.opacity(detailInFront ? 0.28 : 0.21),
                                radius: detailInFront ? 16 : 11, x: 1, y: detailInFront ? 9 : 5)
                        .contentShape(RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(.plain)
                .rotationEffect(.degrees(detailInFront ? -1 + separation * 3 : 1.5 + separation * 3))
                .scaleEffect(1 - separation * 0.025)
                .position(x: w * (detailInFront ? 0.46 : 0.63) + separation * w * 0.25, y: h * 0.48)
                .zIndex(detailInFront ? 2 : 0)
                .accessibilityLabel(language == "zh" ? "语录详解" : "Quote Details")
                .accessibilityValue(detailInFront ? (language == "zh" ? "已在前面" : "In front") : (language == "zh" ? "在日历后面" : "Behind calendar"))
                .accessibilityHint(language == "zh" ? "轻点将详情卡切到前面" : "Tap to bring the detail card forward")
                .accessibilityIdentifier("onboarding.today.detail")

                Button { bringForward(detail: false) } label: {
                    cardImage(calendarImage, delay: 0, initialX: 0)
                        .frame(width: calendarWidth, height: calendarWidth / calendarAspectRatio)
                        .shadow(color: CalendarPalette.secondaryInk.opacity(detailInFront ? 0.08 : 0.13),
                                radius: detailInFront ? 6 : 9, x: 0, y: 4)
                        .contentShape(RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(.plain)
                .rotationEffect(.degrees(detailInFront ? 3 - separation * 3 : -1 - separation * 3))
                .scaleEffect(detailInFront ? 0.96 : 1)
                .position(x: w * (detailInFront ? 0.67 : 0.28) - separation * w * 0.25, y: h * 0.39)
                .zIndex(detailInFront ? 0 : 2)
                .accessibilityLabel(language == "zh" ? "今日日历" : "Today's Calendar")
                .accessibilityValue(detailInFront ? (language == "zh" ? "在详情卡后面" : "Behind details") : (language == "zh" ? "已在前面" : "In front"))
                .accessibilityHint(language == "zh" ? "轻点将日历切到前面" : "Tap to bring the calendar forward")
                .accessibilityIdentifier("onboarding.today.calendar")
            }
            .allowsHitTesting(!isSwitching)
        }
        #if DEBUG
        .task {
            // Debug-only review uses the same transition as either card's button.
            guard ProcessInfo.processInfo.arguments.contains("--review-onboarding-card-switch") else { return }
            do {
                try await Task.sleep(for: .seconds(2))
                bringForward(detail: true)
                try await Task.sleep(for: .seconds(6))
                bringForward(detail: false)
            } catch { return }
        }
        #endif
    }

    private var detailAspectRatio: CGFloat { aspectRatio(of: detailImage) }
    private var calendarAspectRatio: CGFloat { aspectRatio(of: calendarImage) }

    private static func loadImage(_ name: String) -> UIImage? {
        guard let url = Bundle.main.url(forResource: name, withExtension: "heic", subdirectory: "OnboardingPreview") else { return nil }
        return UIImage(contentsOfFile: url.path)
    }

    private func aspectRatio(of image: UIImage?) -> CGFloat {
        guard let image else { return 2 / 3 }
        return image.size.width / image.size.height
    }

    private func cardImage(_ image: UIImage?, delay: Double, initialX: CGFloat) -> some View {
        Group {
            if let image { Image(uiImage: image).resizable().scaledToFit() }
        }
        .modifier(OnboardingEntrance(delay: delay, initialX: initialX))
        .accessibilityHidden(true)
    }

    private func bringForward(detail: Bool) {
        guard detail != detailInFront, !isSwitching else { return }
        guard !reduceMotion else {
            withTransaction(Transaction(animation: nil)) { detailInFront = detail }
            return
        }
        isSwitching = true
        // Separate the sheets before swapping their order, then settle the new stack.
        withAnimation(.easeInOut(duration: 0.2), completionCriteria: .logicallyComplete) {
            separation = 1
        } completion: {
            withAnimation(.spring(response: 0.46, dampingFraction: 0.86), completionCriteria: .logicallyComplete) {
                detailInFront = detail
                separation = 0
            } completion: {
                isSwitching = false
            }
        }
    }
}

private struct OnboardingLayer: View {
    let name: String
    let delay: Double
    let initialX: CGFloat

    private var image: UIImage? {
        guard let url = Bundle.main.url(forResource: name, withExtension: "heic", subdirectory: "OnboardingPreview") else { return nil }
        return UIImage(contentsOfFile: url.path)
    }

    var body: some View {
        Group {
            if let image {
                Image(uiImage: image).resizable().scaledToFit()
            }
        }
        .modifier(OnboardingEntrance(delay: delay, initialX: initialX))
        .accessibilityHidden(true)
    }
}

private struct OnboardingEntrance: ViewModifier {
    let delay: Double
    var initialX: CGFloat = 0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var appeared = false

    func body(content: Content) -> some View {
        content
        .opacity(appeared ? 1 : 0)
        .offset(x: appeared || reduceMotion ? 0 : initialX, y: appeared || reduceMotion ? 0 : 22)
        .scaleEffect(appeared || reduceMotion ? 1 : 0.97)
        .task {
            if !reduceMotion {
                do { try await Task.sleep(for: .seconds(delay)) } catch { return }
            }
            guard !Task.isCancelled else { return }
            withAnimation(.easeOut(duration: reduceMotion ? 0.15 : 0.7)) { appeared = true }
        }
    }
}

private struct OnboardingFullAccessPage: View {
    @EnvironmentObject private var settings: AppSettingsLibrary
    @ScaledMetric(relativeTo: .largeTitle) private var headingSize: CGFloat = 30
    @ScaledMetric(relativeTo: .body) private var benefitSize: CGFloat = 15
    @State private var feedback: FullAccessResult?
    @State private var operation: Task<Void, Never>?
    let onFinished: () -> Void
    private var isChinese: Bool { settings.languageCode == "zh-Hans" }
    private var canLeave: Bool { !settings.isStoreOperationInProgress || settings.isRestoringFullAccess }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView { content }
                .frame(maxHeight: .infinity)
            purchaseArea
                .fixedSize(horizontal: false, vertical: true)
                .layoutPriority(1)
        }
        .frame(minHeight: 0, maxHeight: .infinity, alignment: .top)
        .scrollIndicators(.hidden)
        .task { await settings.loadFullAccessProduct() }
        .onChange(of: settings.hasFullAccess) { _, owns in
            if owns { onFinished() }
        }
        .onDisappear {
            operation?.cancel()
            operation = nil
        }
        .alert(item: $feedback) { result in
            Alert(title: Text(result.onboardingMessage(settings)), dismissButton: .default(Text(settings.text("好", "OK"))))
        }
    }

    private var content: some View {
        VStack(spacing: 12) {
            introductionHeader
            benefits
        }
        .padding(.horizontal, 30)
        .padding(.vertical, 10)
    }

    @ViewBuilder private var introductionHeader: some View {
        Image("CalendarIcon-calendar-Candidate")
            .renderingMode(.template).resizable().scaledToFit()
            .foregroundStyle(CalendarPalette.vermilion)
            .frame(width: 26, height: 26)
            .accessibilityHidden(true)
        VStack(spacing: 2) {
            Text(settings.text("解锁", "Unlock")).foregroundStyle(CalendarPalette.ink)
            Text(settings.text("完整日历", "Your full calendar")).foregroundStyle(CalendarPalette.vermilion)
        }
        .font(CalendarTypography.font(isChinese ? .chineseTitle : .englishTitle, size: headingSize * (isChinese ? 1 : 0.8)))
        .multilineTextAlignment(.center)
        .fixedSize(horizontal: false, vertical: true)
        .accessibilityAddTraits(.isHeader)
        .modifier(OnboardingEntrance(delay: 0))
        Text(settings.text("一次买断，永久使用", "One purchase. Yours for life."))
            .font(CalendarTypography.font(isChinese ? .chineseTitle : .englishQuote, size: 17))
            .foregroundStyle(CalendarPalette.secondaryInk)
            .multilineTextAlignment(.center)
    }


    private var benefits: some View {
        VStack(alignment: .leading, spacing: 10) {
            ForEach(Array(FullAccessBenefit.all.enumerated()), id: \.element.id) { index, item in
                HStack(spacing: 14) {
                    Image("CalendarIcon-\(item.icon)-Candidate")
                        .renderingMode(.template).resizable().scaledToFit()
                        .frame(width: 25, height: 25)
                        .foregroundStyle(CalendarPalette.vermilion)
                        .accessibilityHidden(true)
                    Text(settings.text(item.chinese, item.english))
                        .font(CalendarTypography.font(isChinese ? .chineseTitle : .englishQuote, size: benefitSize))
                        .foregroundStyle(CalendarPalette.ink)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .modifier(OnboardingEntrance(delay: 0.08 * Double(index)))
            }
        }
        .padding(.top, 4)
    }


    private var purchaseArea: some View {
        VStack(spacing: 6) {
            Text(settings.text("永久解锁", "Full Access"))
                .font(CalendarTypography.font(isChinese ? .chineseBody : .englishQuote, size: 14))
                .foregroundStyle(CalendarPalette.secondaryInk)
            Text(price)
                .font(CalendarTypography.font(settings.fullAccessProduct == nil ? (isChinese ? .chineseBody : .englishQuote) : .date,
                                              size: settings.fullAccessProduct == nil ? 18 : 40))
                .foregroundStyle(CalendarPalette.ink)
                .multilineTextAlignment(.center)
                .accessibilityIdentifier("onboarding.price")
            Button(action: purchase) {
                PaywallPurchaseButtonLabel(title: purchaseTitle, unlocked: settings.hasFullAccess,
                                          isProcessing: settings.isStoreOperationInProgress)
            }
            .buttonStyle(PaywallPurchaseButtonStyle(emphasized: !settings.hasFullAccess &&
                !settings.isStoreOperationInProgress &&
                (settings.fullAccessProduct != nil || settings.isFullAccessProductUnavailable)))
            .disabled(settings.isStoreOperationInProgress ||
                      (!settings.hasFullAccess && settings.fullAccessProduct == nil && !settings.isFullAccessProductUnavailable))
            .accessibilityIdentifier("onboarding.purchase")
            if !settings.hasFullAccess {
                Button(settings.text("先免费使用", "Continue for Free"), action: onFinished)
                    .font(CalendarTypography.font(isChinese ? .chineseTitle : .englishQuote, size: 21))
                    .foregroundStyle(CalendarPalette.ink)
                    .frame(maxWidth: .infinity, minHeight: 44)
                    .disabled(!canLeave)
                    .accessibilityIdentifier("onboarding.free")
            }
            ViewThatFits(in: .horizontal) {
                HStack(spacing: 14) { links }
                VStack(spacing: 8) { links }
            }
            .font(CalendarTypography.font(isChinese ? .chineseBody : .englishQuote, size: 12))
            .foregroundStyle(CalendarPalette.secondaryInk)
        }
        .padding(.horizontal, 24)
        .padding(.top, 12)
        .padding(.bottom, 8)
        .background { OnboardingPaper() }
    }

    @ViewBuilder private var links: some View {
        Button(action: restore) {
            Text(settings.text("恢复购买", "Restore Purchases"))
                .frame(minHeight: 44)
        }
            .disabled(settings.isStoreOperationInProgress)
            .accessibilityIdentifier("onboarding.restore")
        NavigationLink {
            LegalDocumentPage(document: .purchase).toolbar(.visible, for: .navigationBar)
        } label: { Text(settings.text("购买协议", "Purchase Terms")).frame(minHeight: 44) }
        NavigationLink {
            LegalDocumentPage(document: .privacy).toolbar(.visible, for: .navigationBar)
        } label: { Text(settings.text("隐私政策", "Privacy Policy")).frame(minHeight: 44) }
    }

    private var price: String {
        if settings.hasFullAccess { return settings.text("已永久解锁", "Full Access Unlocked") }
        if let product = settings.fullAccessProduct { return product.displayPrice }
        return settings.text(settings.isFullAccessProductUnavailable ? "暂时无法获取价格" : "正在获取价格…",
                             settings.isFullAccessProductUnavailable ? "Price unavailable" : "Loading price…")
    }

    private var purchaseTitle: String {
        if settings.hasFullAccess { return settings.text("开始使用", "Get Started") }
        if settings.isStoreOperationInProgress {
            return settings.text(settings.isRestoringFullAccess ? "正在恢复购买…" : "正在处理…",
                                 settings.isRestoringFullAccess ? "Restoring…" : "Processing…")
        }
        if settings.isFullAccessProductUnavailable { return settings.text("重试", "Retry") }
        return settings.text("永久解锁", "Unlock for Life")
    }

    private func purchase() {
        guard operation == nil, !settings.isStoreOperationInProgress else { return }
        if settings.hasFullAccess { onFinished(); return }
        operation = Task {
            if settings.fullAccessProduct == nil {
                await settings.loadFullAccessProduct()
            } else {
                handle(await settings.purchaseFullAccess())
            }
            operation = nil
        }
    }

    private func restore() {
        guard operation == nil, !settings.isStoreOperationInProgress else { return }
        operation = Task {
            let result = await settings.restoreFullAccess()
            guard !Task.isCancelled else { return }
            operation = nil
            handle(result)
        }
    }

    private func handle(_ result: FullAccessResult) {
        switch result {
        case .unlocked: onFinished()
        case .cancelled: break
        default: feedback = result
        }
    }
}

private extension FullAccessResult {
    @MainActor
    func onboardingMessage(_ settings: AppSettingsLibrary) -> String {
        switch self {
        case .pending: settings.text("购买待批准，完成后将自动解锁。", "Purchase pending. Full Access unlocks once approved.")
        case .nothingToRestore: settings.text("未找到可恢复的购买。", "No purchase was found to restore.")
        case .verificationFailed: settings.text("暂时无法确认购买权益。", "Your purchase could not be verified.")
        case .purchaseFailed: settings.text("购买未能完成，请重试。", "The purchase could not be completed. Please try again.")
        case .restoreFailed: settings.text("恢复购买失败，请重试。", "Purchases could not be restored. Please try again.")
        case .restorePending: settings.text("Apple 仍在同步购买记录。你可以先进入 App，权益将在完成后更新。", "Apple is still syncing purchases. You can continue to the app while it finishes.")
        case .unlocked, .cancelled: ""
        }
    }
}

private struct OnboardingProgress: View {
    let page: Int
    var body: some View {
        HStack(spacing: 10) {
            ForEach(0..<4) { index in
                Circle().fill(index == page ? CalendarPalette.vermilion : CalendarPalette.secondaryInk.opacity(0.27))
                    .frame(width: 8, height: 8)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text("\(page + 1) / 4"))
    }
}

private struct OnboardingPrimaryButton: ButtonStyle {
    @EnvironmentObject private var settings: AppSettingsLibrary
    @Environment(\.isEnabled) private var isEnabled
    @ScaledMetric(relativeTo: .headline) private var titleSize: CGFloat = 23
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(CalendarTypography.font(settings.languageCode == "zh-Hans" ? .chineseTitle : .englishQuote, size: titleSize))
            .multilineTextAlignment(.center)
            .foregroundStyle(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity, minHeight: 52)
            .background(CalendarPalette.vermilion.opacity(configuration.isPressed ? 0.8 : 1), in: Capsule())
            .opacity(isEnabled ? 1 : 0.55)
    }
}

private struct OnboardingPaper: View {
    var body: some View {
        Color("LaunchPaper").overlay {
            Image(decorative: "CalendarPaperIvoryCandidate").resizable().scaledToFill().opacity(0.16)
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }
}


#endif
