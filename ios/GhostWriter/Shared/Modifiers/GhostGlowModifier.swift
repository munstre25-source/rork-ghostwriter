import SwiftUI

/// A `ViewModifier` that wraps the view in a neon glow effect.
///
/// Apply via the convenience extension:
/// ```swift
/// Circle()
///     .ghostGlow(color: .ghostCyan, intensity: 0.8)
/// ```
struct GhostGlowModifier: ViewModifier {
    /// The glow color.
    var color: Color
    /// Glow intensity from `0` (none) to `1` (full).
    var intensity: Double
    /// When `true`, the glow pulses continuously.
    var animated: Bool

    @State private var isPulsing = false

    func body(content: Content) -> some View {
        content
            .shadow(
                color: color.opacity(intensity * (animated && isPulsing ? 0.4 : 0.6)),
                radius: 8 * intensity
            )
            .shadow(
                color: color.opacity(intensity * (animated && isPulsing ? 0.2 : 0.35)),
                radius: 16 * intensity
            )
            .shadow(
                color: color.opacity(intensity * (animated && isPulsing ? 0.1 : 0.15)),
                radius: 32 * intensity
            )
            .onAppear {
                guard animated else { return }
                withAnimation(
                    .easeInOut(duration: AnimationConstants.breathDuration)
                    .repeatForever(autoreverses: true)
                ) {
                    isPulsing = true
                }
            }
    }
}
