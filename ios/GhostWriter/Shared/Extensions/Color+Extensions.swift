import SwiftUI

extension Color {
    // MARK: - GhostWriter Palette

    /// Dark background for the GhostWriter app.
    static let ghostBackground = Color(hex: "0A0A0A")

    /// Neon cyan accent color.
    static let ghostCyan = Color(hex: "00D9FF")

    /// Magenta accent color.
    static let ghostMagenta = Color(hex: "FF00FF")

    /// Emerald accent color.
    static let ghostEmerald = Color(hex: "00FF88")

    /// Gold accent color.
    static let ghostGold = Color(hex: "FFD700")

    /// Primary text color.
    static let ghostText = Color(hex: "E8E8E8")

    // MARK: - Hex Initializer

    /// Creates a `Color` from a hexadecimal string.
    /// - Parameter hex: A hex string (with or without `#` prefix). Supports 6-character RGB and 8-character ARGB formats.
    init(hex: String) {
        let sanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0
        Scanner(string: sanitized).scanHexInt64(&rgb)

        let r, g, b, a: Double
        switch sanitized.count {
        case 6:
            r = Double((rgb >> 16) & 0xFF) / 255.0
            g = Double((rgb >> 8) & 0xFF) / 255.0
            b = Double(rgb & 0xFF) / 255.0
            a = 1.0
        case 8:
            a = Double((rgb >> 24) & 0xFF) / 255.0
            r = Double((rgb >> 16) & 0xFF) / 255.0
            g = Double((rgb >> 8) & 0xFF) / 255.0
            b = Double(rgb & 0xFF) / 255.0
        default:
            r = 0; g = 0; b = 0; a = 1.0
        }

        self.init(.sRGB, red: r, green: g, blue: b, opacity: a)
    }
}
