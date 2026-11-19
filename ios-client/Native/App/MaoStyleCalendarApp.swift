import CalendarCore
import SwiftUI

@main
struct MaoStyleCalendarApp: App {
    @StateObject private var settings = AppSettingsLibrary()
    #if os(iOS)
    @Environment(\.scenePhase) private var scenePhase
    #endif

    init() {
        AppAnalytics.start()
        // Remove the retired snapshot from existing installations.
        DesktopWidgetDisplayPreferences.sharedDefaults?.removeObject(forKey: "favorites.snapshot.v1")
    }

    var body: some Scene {
        WindowGroup {
            StartupView()
                .environmentObject(settings)
                #if os(iOS)
                .task(id: scenePhase) {
                    settings.startStoreKit()
                    if scenePhase == .active {
                        await settings.refreshFullAccess()
                    }
                }
                #endif
        }
    }
}
