import SwiftUI

/// A `ViewModifier` that applies a glassmorphism / liquid-glass effect using `.ultraThinMaterial`.
///
/// Apply via the convenience extension:
/// ```swift
/// Text("Hello")
///     .liquidGlass(cornerRadius: 16)
/// ```
struct LiquidGlassModifier: ViewModifier {
    /// Corner radius for the rounded rectangle clip shape.
    var cornerRadius: CGFloat

    /// Whether to show a subtle white border.
    var showBorder: Bool

    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(.ultraThinMaterial)
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(
                        showBorder ? Color.white.opacity(0.1) : Color.clear,
                        lineWidth: 0.5
                    )
            )
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .shadow(color: .black.opacity(0.25), radius: 10, x: 0, y: 4)
    }
}
