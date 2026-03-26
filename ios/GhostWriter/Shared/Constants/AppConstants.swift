import Foundation

/// Central application constants for GhostWriter.
struct AppConstants {
    static let appName = "GhostWriter"

    static var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }

    // MARK: - Session Limits

    static let maxSessionDuration: TimeInterval = 3600
    static let maxFreeSessionDuration: TimeInterval = 300
    static let debounceInterval: TimeInterval = 0.5

    // MARK: - Flow

    static let flowStateThreshold: Double = 70

    // MARK: - Media

    static let maxClipDuration: Double = 30

    // MARK: - Network

    static let apiBaseURL = "https://api.ghostwriter.app"
    static let supportEmail = "support@ghostwriter.app"
}
