import Foundation
#if os(iOS)
import FirebaseCore
import FirebaseAnalytics
#endif

/// Coarse product actions in both Debug and Release iOS builds.
/// No content, dates, or transaction data are accepted.
@MainActor
enum AppAnalytics {
    enum Event: String {
        case dayChanged = "calendar_day_changed"
        case detailOpened = "quote_detail_opened"
        case wallpaperExported = "wallpaper_export_prepared"
        case paywallViewed = "paywall_viewed"
        case purchaseStarted = "full_access_purchase_started"
        case restoreStarted = "full_access_restore_started"
        case purchaseSucceeded = "full_access_purchase_succeeded"
        case purchaseFailed = "full_access_purchase_failed"
        case purchaseCancelled = "full_access_purchase_cancelled"
        case purchasePending = "full_access_purchase_pending"
        case purchaseAlreadyOwned = "full_access_purchase_already_owned"
        case purchaseVerificationFailed = "full_access_purchase_verification_failed"
        case restoreSucceeded = "full_access_restore_succeeded"
        case restoreNotFound = "full_access_restore_not_found"
        case restoreFailed = "full_access_restore_failed"
        case restoreCancelled = "full_access_restore_cancelled"
    }

    static func start() {
        #if os(iOS)
        if FirebaseApp.app() == nil {
            guard let path = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist"),
                  let options = FirebaseOptions(contentsOfFile: path),
                  options.projectID == "maostylecalendar",
                  options.bundleID == Bundle.main.bundleIdentifier else {
                // Missing or mismatched configuration must never break the calendar.
                return
            }
            FirebaseApp.configure(options: options)
        }
        Analytics.setConsent([
            .analyticsStorage: .granted,
            .adStorage: .denied,
            .adUserData: .denied,
            .adPersonalization: .denied
        ])
        Analytics.setAnalyticsCollectionEnabled(true)
        #endif
    }

    static func log(_ event: Event) {
        #if os(iOS)
        guard FirebaseApp.app() != nil else { return }
        Analytics.logEvent(event.rawValue, parameters: nil)
        #endif
    }

    static func screen(_ name: String) {
        #if os(iOS)
        guard FirebaseApp.app() != nil else { return }
        Analytics.logEvent(AnalyticsEventScreenView, parameters: [AnalyticsParameterScreenName: name])
        #endif
    }
}
