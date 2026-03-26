import SwiftUI

/// Centralized color hex values and semantic mappings for GhostWriter.
struct ColorConstants {
    // MARK: - Raw Hex Values

    static let backgroundHex = "0A0A0A"
    static let cyanHex = "00D9FF"
    static let magentaHex = "FF00FF"
    static let emeraldHex = "00FF88"
    static let goldHex = "FFD700"
    static let textHex = "E8E8E8"

    // MARK: - Personality Colors

    /// Maps a personality identifier to its representative color.
    static let personalityColors: [String: Color] = [
        "mentor": .ghostCyan,
        "provocateur": .ghostMagenta,
        "collaborator": .ghostEmerald,
        "mystic": Color(hex: "A855F7"),
        "critic": Color(hex: "F97316"),
        "muse": .ghostGold,
    ]

    // MARK: - Mood Colors

    /// Maps a mood label to a display color.
    static let moodColors: [String: Color] = [
        "inspired": .ghostCyan,
        "focused": .ghostEmerald,
        "playful": .ghostMagenta,
        "contemplative": Color(hex: "A855F7"),
        "frustrated": Color(hex: "EF4444"),
        "neutral": .ghostText,
    ]

    // MARK: - Subscription Tier Colors

    /// Maps a subscription tier to its badge color.
    static let tierColors: [String: Color] = [
        "free": .ghostText,
        "pro": .ghostCyan,
        "premium": .ghostGold,
        "team": .ghostEmerald,
    ]
}
