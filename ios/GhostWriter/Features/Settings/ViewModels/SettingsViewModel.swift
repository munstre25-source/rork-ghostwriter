import Foundation
import SwiftUI
import Observation

@Observable
final class SettingsViewModel {

    @ObservationIgnored
    @AppStorage(UserPreferences.Keys.creatorUsername) var username: String = ""

    @ObservationIgnored
    @AppStorage(UserPreferences.Keys.enableHaptics) var enableHaptics: Bool = true

    @ObservationIgnored
    @AppStorage(UserPreferences.Keys.notificationsEnabled) var notificationsEnabled: Bool = true

    @ObservationIgnored
    @AppStorage(UserPreferences.Keys.darkModeEnabled) var darkModeEnabled: Bool = true

    @ObservationIgnored
    @AppStorage(UserPreferences.Keys.dyslexiaFontEnabled) var dyslexiaFontEnabled: Bool = false

    @ObservationIgnored
    @AppStorage(UserPreferences.Keys.highContrastEnabled) var highContrastEnabled: Bool = false

    @ObservationIgnored
    @AppStorage(UserPreferences.Keys.textSize) var textSize: Double = 1.0

    @ObservationIgnored
    @AppStorage(UserPreferences.Keys.voiceFirstMode) var voiceFirstMode: Bool = false

    @ObservationIgnored
    @AppStorage(UserPreferences.Keys.preferredPersonality) var preferredPersonality: String = ""

    var showDeleteConfirmation: Bool = false
    var showExportSheet: Bool = false
    var exportedURL: URL?
    var isExporting: Bool = false
    var currentTier: SubscriptionTier = .free

    var appVersion: String {
        AppConstants.appVersion
    }

    func resetToDefaults() {
        username = ""
        enableHaptics = true
        notificationsEnabled = true
        darkModeEnabled = true
        dyslexiaFontEnabled = false
        highContrastEnabled = false
        textSize = 1.0
        voiceFirstMode = false
        preferredPersonality = ""
    }

    func exportData() async throws -> URL {
        isExporting = true
        defer { isExporting = false }

        try await Task.sleep(for: .seconds(1))

        let data: [String: Any] = [
            "username": username,
            "enableHaptics": enableHaptics,
            "notificationsEnabled": notificationsEnabled,
            "darkModeEnabled": darkModeEnabled,
            "dyslexiaFontEnabled": dyslexiaFontEnabled,
            "highContrastEnabled": highContrastEnabled,
            "textSize": textSize,
            "voiceFirstMode": voiceFirstMode,
            "exportDate": ISO8601DateFormatter().string(from: .now),
        ]

        let jsonData = try JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)

        let tempDir = FileManager.default.temporaryDirectory
        let fileURL = tempDir.appendingPathComponent("ghostwriter_export.json")
        try jsonData.write(to: fileURL)

        exportedURL = fileURL
        return fileURL
    }

    func deleteAccount() async throws {
        try await Task.sleep(for: .seconds(1.5))
        resetToDefaults()
    }
}
