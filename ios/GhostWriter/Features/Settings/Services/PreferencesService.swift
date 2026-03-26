import Foundation
import Observation

/// Manages user preferences backed by `UserDefaults`.
///
/// Provides a centralized interface for reading and writing app preferences
/// keyed by ``UserPreferences/Keys``, with support for export and import.
@Observable
final class PreferencesService: @unchecked Sendable {

    private let defaults: UserDefaults

    /// Whether haptic feedback is enabled.
    var enableHaptics: Bool {
        get { defaults.bool(forKey: UserPreferences.Keys.enableHaptics) }
        set { defaults.set(newValue, forKey: UserPreferences.Keys.enableHaptics) }
    }

    /// Whether push notifications are enabled.
    var notificationsEnabled: Bool {
        get { defaults.bool(forKey: UserPreferences.Keys.notificationsEnabled) }
        set { defaults.set(newValue, forKey: UserPreferences.Keys.notificationsEnabled) }
    }

    /// Whether dark mode is enabled.
    var darkModeEnabled: Bool {
        get { defaults.bool(forKey: UserPreferences.Keys.darkModeEnabled) }
        set { defaults.set(newValue, forKey: UserPreferences.Keys.darkModeEnabled) }
    }

    /// Whether the dyslexia-friendly font is enabled.
    var dyslexiaFontEnabled: Bool {
        get { defaults.bool(forKey: UserPreferences.Keys.dyslexiaFontEnabled) }
        set { defaults.set(newValue, forKey: UserPreferences.Keys.dyslexiaFontEnabled) }
    }

    /// Whether high-contrast mode is enabled.
    var highContrastEnabled: Bool {
        get { defaults.bool(forKey: UserPreferences.Keys.highContrastEnabled) }
        set { defaults.set(newValue, forKey: UserPreferences.Keys.highContrastEnabled) }
    }

    /// The user's preferred text size multiplier.
    var textSize: Double {
        get {
            let value = defaults.double(forKey: UserPreferences.Keys.textSize)
            return value > 0 ? value : 1.0
        }
        set { defaults.set(newValue, forKey: UserPreferences.Keys.textSize) }
    }

    /// Whether voice-first input mode is enabled.
    var voiceFirstMode: Bool {
        get { defaults.bool(forKey: UserPreferences.Keys.voiceFirstMode) }
        set { defaults.set(newValue, forKey: UserPreferences.Keys.voiceFirstMode) }
    }

    /// The creator's display username.
    var creatorUsername: String {
        get { defaults.string(forKey: UserPreferences.Keys.creatorUsername) ?? "" }
        set { defaults.set(newValue, forKey: UserPreferences.Keys.creatorUsername) }
    }

    /// Creates a preferences service backed by the given `UserDefaults` suite.
    ///
    /// - Parameter defaults: The defaults store. Defaults to `.standard`.
    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        registerDefaults()
    }

    /// Resets all preferences to their default values.
    func resetToDefaults() {
        let allKeys = [
            UserPreferences.Keys.enableHaptics,
            UserPreferences.Keys.notificationsEnabled,
            UserPreferences.Keys.darkModeEnabled,
            UserPreferences.Keys.dyslexiaFontEnabled,
            UserPreferences.Keys.highContrastEnabled,
            UserPreferences.Keys.textSize,
            UserPreferences.Keys.voiceFirstMode,
            UserPreferences.Keys.aiSuggestionsEnabled,
            UserPreferences.Keys.contentFilteringEnabled,
            UserPreferences.Keys.reportAndBlockEnabled,
            UserPreferences.Keys.age13OrOlderConfirmed,
            UserPreferences.Keys.parentalConsentProvided,
            UserPreferences.Keys.creatorUsername,
            UserPreferences.Keys.preferredPersonality
        ]

        for key in allKeys {
            defaults.removeObject(forKey: key)
        }

        registerDefaults()
        print("[Preferences] Reset to defaults")
    }

    /// Exports all preferences as a JSON-encoded `Data` blob.
    ///
    /// - Returns: A `Data` value containing serialized preferences.
    func exportPreferences() -> Data {
        let prefs: [String: Any] = [
            UserPreferences.Keys.enableHaptics: enableHaptics,
            UserPreferences.Keys.notificationsEnabled: notificationsEnabled,
            UserPreferences.Keys.darkModeEnabled: darkModeEnabled,
            UserPreferences.Keys.dyslexiaFontEnabled: dyslexiaFontEnabled,
            UserPreferences.Keys.highContrastEnabled: highContrastEnabled,
            UserPreferences.Keys.textSize: textSize,
            UserPreferences.Keys.voiceFirstMode: voiceFirstMode,
            UserPreferences.Keys.aiSuggestionsEnabled: defaults.bool(forKey: UserPreferences.Keys.aiSuggestionsEnabled),
            UserPreferences.Keys.contentFilteringEnabled: defaults.bool(forKey: UserPreferences.Keys.contentFilteringEnabled),
            UserPreferences.Keys.reportAndBlockEnabled: defaults.bool(forKey: UserPreferences.Keys.reportAndBlockEnabled),
            UserPreferences.Keys.age13OrOlderConfirmed: defaults.bool(forKey: UserPreferences.Keys.age13OrOlderConfirmed),
            UserPreferences.Keys.parentalConsentProvided: defaults.bool(forKey: UserPreferences.Keys.parentalConsentProvided),
            UserPreferences.Keys.creatorUsername: creatorUsername
        ]

        return (try? JSONSerialization.data(withJSONObject: prefs, options: .prettyPrinted)) ?? Data()
    }

    /// Imports preferences from a JSON-encoded `Data` blob.
    ///
    /// - Parameter data: The data to import.
    /// - Throws: An error if the data cannot be deserialized.
    func importPreferences(from data: Data) throws {
        guard let dict = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw NSError(domain: "PreferencesService", code: -1, userInfo: [
                NSLocalizedDescriptionKey: "Invalid preferences data format."
            ])
        }

        for (key, value) in dict {
            defaults.set(value, forKey: key)
        }

        print("[Preferences] Imported \(dict.count) preferences")
    }

    // MARK: - Private

    private func registerDefaults() {
        defaults.register(defaults: [
            UserPreferences.Keys.enableHaptics: true,
            UserPreferences.Keys.notificationsEnabled: true,
            UserPreferences.Keys.darkModeEnabled: false,
            UserPreferences.Keys.dyslexiaFontEnabled: false,
            UserPreferences.Keys.highContrastEnabled: false,
            UserPreferences.Keys.textSize: 1.0,
            UserPreferences.Keys.voiceFirstMode: false
            ,
            UserPreferences.Keys.aiSuggestionsEnabled: true,
            UserPreferences.Keys.contentFilteringEnabled: true,
            UserPreferences.Keys.reportAndBlockEnabled: true,
            UserPreferences.Keys.age13OrOlderConfirmed: true,
            UserPreferences.Keys.parentalConsentProvided: false
        ])
    }
}
