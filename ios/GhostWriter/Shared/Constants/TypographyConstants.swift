import SwiftUI

/// Typography scale and font definitions for GhostWriter.
struct TypographyConstants {
    // MARK: - Display Font (Space Grotesk approximation)

    static func display(size: CGFloat, weight: Font.Weight = .bold) -> Font {
        .system(size: size, weight: weight, design: .rounded)
    }

    // MARK: - Body Font (Inter approximation)

    static func body(size: CGFloat, weight: Font.Weight = .regular) -> Font {
        .system(size: size, weight: weight, design: .default)
    }

    // MARK: - Font Sizes

    static let largeTitle: CGFloat = 34
    static let title1: CGFloat = 28
    static let title2: CGFloat = 22
    static let title3: CGFloat = 20
    static let headline: CGFloat = 17
    static let bodySize: CGFloat = 17
    static let callout: CGFloat = 16
    static let subheadline: CGFloat = 15
    static let footnote: CGFloat = 13
    static let caption1: CGFloat = 12
    static let caption2: CGFloat = 11

    // MARK: - Line Spacing

    static let tightLineSpacing: CGFloat = 2
    static let defaultLineSpacing: CGFloat = 4
    static let relaxedLineSpacing: CGFloat = 8
    static let looseLineSpacing: CGFloat = 12
}
