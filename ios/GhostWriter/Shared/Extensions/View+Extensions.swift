import SwiftUI
import UIKit

extension View {
    /// Applies a glassmorphism / liquid-glass background using `.ultraThinMaterial`.
    /// - Parameters:
    ///   - cornerRadius: Corner radius of the glass shape. Default is `16`.
    ///   - showBorder: Whether to render a subtle white border. Default is `true`.
    /// - Returns: The modified view.
    func liquidGlass(cornerRadius: CGFloat = 16, showBorder: Bool = true) -> some View {
        modifier(LiquidGlassModifier(cornerRadius: cornerRadius, showBorder: showBorder))
    }

    /// Applies a neon glow effect around the view.
    /// - Parameters:
    ///   - color: Glow color. Default is `.ghostCyan`.
    ///   - intensity: Glow intensity from 0 to 1. Default is `0.6`.
    ///   - animated: Whether the glow pulses continuously. Default is `false`.
    /// - Returns: The modified view.
    func ghostGlow(color: Color = .ghostCyan, intensity: Double = 0.6, animated: Bool = false) -> some View {
        modifier(GhostGlowModifier(color: color, intensity: intensity, animated: animated))
    }

    /// Triggers haptic feedback on tap.
    /// - Parameter style: The `UIImpactFeedbackGenerator.FeedbackStyle` to use.
    /// - Returns: The modified view.
    func hapticFeedback(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) -> some View {
        modifier(HapticModifier(style: style))
    }

    /// Applies ambient visual effects scaled to a flow-state score.
    /// - Parameter score: Flow score from 0 to 100.
    /// - Returns: The modified view.
    func flowStateEffect(score: Double) -> some View {
        modifier(FlowStateModifier(score: score))
    }

    /// Adds a loading shimmer animation to the view.
    /// - Returns: The modified view with a shimmer overlay.
    func shimmer() -> some View {
        modifier(ShimmerModifier())
    }
}

// MARK: - Shimmer

private struct ShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = -1

    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geometry in
                    LinearGradient(
                        colors: [
                            .clear,
                            Color.white.opacity(0.12),
                            .clear,
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: geometry.size.width * 0.6)
                    .offset(x: phase * geometry.size.width)
                    .onAppear {
                        withAnimation(
                            .linear(duration: 1.5)
                            .repeatForever(autoreverses: false)
                        ) {
                            phase = 1.5
                        }
                    }
                }
            )
            .clipped()
    }
}
