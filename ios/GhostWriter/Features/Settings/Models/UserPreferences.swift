import Foundation

/// Constants for `AppStorage` keys used throughout the app.
///
/// Use these keys with SwiftUI's `@AppStorage` property wrapper to persist
/// lightweight user preferences without SwiftData overhead.
///
/// ```swift
/// @AppStorage(UserPreferences.Keys.enableHaptics) private var haptics = true
/// ```
struct UserPreferences: Sendable {

    private init() {}

    /// `AppStorage` key strings for user preference values.
    struct Keys: Sendable {

        private init() {}

        /// The creator's chosen display username.
        static let creatorUsername = "user_pref_creator_username"

        /// Whether haptic feedback is enabled.
        static let enableHaptics = "user_pref_enable_haptics"

        /// The ID of the user's preferred ghost personality.
        static let preferredPersonality = "user_pref_preferred_personality"

        /// Whether push notifications are enabled.
        static let notificationsEnabled = "user_pref_notifications_enabled"

        /// Whether the app uses dark mode.
        static let darkModeEnabled = "user_pref_dark_mode_enabled"

        /// Whether the dyslexia-friendly font is enabled.
        static let dyslexiaFontEnabled = "user_pref_dyslexia_font_enabled"

        /// Whether high-contrast mode is enabled.
        static let highContrastEnabled = "user_pref_high_contrast_enabled"

        /// The user's preferred text size multiplier.
        static let textSize = "user_pref_text_size"

        /// Whether voice-first input mode is enabled.
        static let voiceFirstMode = "user_pref_voice_first_mode"

        /// Whether AI suggestions are enabled.
        static let aiSuggestionsEnabled = "user_pref_ai_suggestions_enabled"

        /// Whether on-device content filtering is enabled for safety guardrails.
        static let contentFilteringEnabled = "user_pref_content_filtering_enabled"

        /// Whether users can report public content and creators in discovery.
        static let reportAndBlockEnabled = "user_pref_report_and_block_enabled"

        /// Age-gate confirmation used for COPPA compliance.
        static let age13OrOlderConfirmed = "user_pref_age_13_or_older_confirmed"

        /// Whether parental consent is provided when the user is under 13.
        static let parentalConsentProvided = "user_pref_parental_consent_provided"
    }
}
