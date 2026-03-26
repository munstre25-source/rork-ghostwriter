import Foundation

/// App Store copy and submission-readiness metadata used by the app.
struct AppStoreMetadata {
    static let appName = "GhostWriter AI"
    static let subtitle = "Your Live Creative Partner"

    static let keywords: [String] = [
        "live brainstorming",
        "shareplay collaboration",
        "creative flow",
        "AI writing partner",
        "dynamic island app",
        "creative assistant",
        "personality ai",
        "live jam",
        "ghostclips",
        "creator app"
    ]

    static let reviewerDemoGuide: [String] = [
        "Start a creative session and type to trigger ghost suggestions.",
        "Open Live Jam and start a collaborative session.",
        "Capture a GhostClip and open the share sheet.",
        "Open Creator tab to review earnings and analytics.",
        "Browse Personality Marketplace and try or purchase a personality."
    ]

    static let privacyCommitments: [String] = [
        "Creative session text is processed on-device by default.",
        "Cloud sync is optional and user-controlled.",
        "AI suggestions show confidence and can be disabled.",
        "Safety filtering and report/block controls are enabled."
    ]
}
