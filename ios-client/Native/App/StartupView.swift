import SwiftUI
#if os(iOS)
import UIKit
#endif

struct StartupView: View {
    #if os(iOS)
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.accessibilityVoiceOverEnabled) private var voiceOverEnabled
    @State private var showsOpening = true
    @EnvironmentObject private var settings: AppSettingsLibrary
    @AppStorage("onboarding.hasPresented.v1") private var hasPresentedOnboarding = false
    @State private var showsOnboarding = false
    @State private var requestsOnboarding = false
    @State private var evaluatedOnboarding = false
    #endif

    var body: some View {
        RootTabView()
            #if os(iOS)
            .accessibilityHidden(presentsOpening)
            .allowsHitTesting(!presentsOpening)
            .overlay {
                if presentsOpening {
                    BrandOpeningView()
                        .contentShape(Rectangle())
                        .onTapGesture(perform: dismissOpening)
                        .transition(reduceMotion ? .identity : .opacity)
                }
            }
            .task(id: presentsOpening && scenePhase == .active) {
                guard presentsOpening, scenePhase == .active else { return }
                #if DEBUG
                if ProcessInfo.processInfo.arguments.contains("--review-brand-opening") { return }
                #endif
                guard (try? await Task.sleep(for: .seconds(1.4))) != nil else { return }
                dismissOpening()
            }
            .onChange(of: scenePhase) { _, phase in
                if phase == .background { showsOpening = false }
            }
            .fullScreenCover(isPresented: $showsOnboarding) {
                OnboardingView(initialPage: reviewPage, onPresented: {
                    hasPresentedOnboarding = true
                }, onFinished: {
                    showsOnboarding = false
                })
                .allowsHitTesting(true)
                .accessibilityHidden(false)
                .interactiveDismissDisabled()
            }
            .onChange(of: presentsOpening) { _, opening in
                if !opening { presentRequestedOnboarding() }
            }
            .task {
                guard !evaluatedOnboarding else { return }
                evaluatedOnboarding = true
                requestsOnboarding = !hasPresentedOnboarding
                #if DEBUG
                let arguments = ProcessInfo.processInfo.arguments
                if arguments.contains("--review-onboarding-language=en") { settings.debugLanguage = .english }
                if arguments.contains("--review-onboarding-language=zh") { settings.debugLanguage = .chinese }
                requestsOnboarding = !hasPresentedOnboarding || settings.alwaysShowsOnboarding ||
                    arguments.contains("--review-onboarding") || reviewPage > 0
                #endif
                if !presentsOpening { presentRequestedOnboarding() }
            }
            #endif
    }

    #if os(iOS)
    private var presentsOpening: Bool {
        showsOpening && !voiceOverEnabled
    }

    private func presentRequestedOnboarding() {
        guard requestsOnboarding else { return }
        requestsOnboarding = false
        showsOnboarding = true
    }

    private var reviewPage: Int {
        #if DEBUG
        let prefix = "--review-onboarding-page="
        guard let value = ProcessInfo.processInfo.arguments.first(where: { $0.hasPrefix(prefix) }),
              let page = Int(value.dropFirst(prefix.count)) else { return 0 }
        return min(3, max(0, page))
        #else
        return 0
        #endif
    }

    private func dismissOpening() {
        withAnimation(reduceMotion ? nil : .easeOut(duration: 0.18)) {
            showsOpening = false
        }
    }
    #endif
}
