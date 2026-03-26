import SwiftUI

/// A `ViewModifier` that applies ambient visual effects based on a flow score (0–100).
///
/// - Score > 50: subtle ambient glow
/// - Score > 70: enhanced glow with pulse
/// - Score > 90: full "in the zone" effect
///
/// Apply via the convenience extension:
/// ```swift
/// EditorView()
///     .flowStateEffect(score: 85)
/// ```
struct FlowStateModifier: ViewModifier {
    /// Flow state score from `0` to `100`.
    var score: Double

    @State private var isPulsing = false

    private var flowColor: Color {
        switch score {
        case 90...: return .ghostMagenta
        case 70..<90: return .ghostGold
        case 50..<70: return .ghostCyan
        default: return .clear
        }
    }

    private var glowRadius: CGFloat {
        switch score {
        case 90...: return 24
        case 70..<90: return 16
        case 50..<70: return 8
        default: return 0
        }
    }

    func body(content: Content) -> some View {
        content
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(flowColor.opacity(score > 50 ? 0.3 : 0), lineWidth: 1)
                    .blur(radius: isPulsing ? glowRadius * 1.2 : glowRadius)
                    .animation(
                        score > 70
                            ? .easeInOut(duration: 1.5).repeatForever(autoreverses: true)
                            : .default,
                        value: isPulsing
                    )
            )
            .shadow(
                color: flowColor.opacity(score > 50 ? 0.15 : 0),
                radius: glowRadius,
                x: 0,
                y: 0
            )
            .onAppear {
                if score > 70 {
                    isPulsing = true
                }
            }
            .onChange(of: score) { _, newValue in
                isPulsing = newValue > 70
            }
    }
}
