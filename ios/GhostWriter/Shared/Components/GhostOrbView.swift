import SwiftUI

/// Activity state of the Ghost AI orb.
enum GhostOrbActivity: String, CaseIterable {
    case idle
    case thinking
    case suggesting
}

/// An animated aura orb representing the Ghost AI.
///
/// The orb pulsates with a breathing effect, changes color based on the
/// ghost personality, and scales to reflect activity state.
///
/// ```swift
/// GhostOrbView(color: .ghostCyan, activity: .thinking, size: 80)
/// ```
struct GhostOrbView: View {
    /// Personality accent color.
    var color: Color
    /// Current activity state.
    var activity: GhostOrbActivity
    /// Diameter of the orb.
    var size: CGFloat

    @State private var breathScale: CGFloat = 1.0
    @State private var glowOpacity: Double = 0.4

    private var activityScale: CGFloat {
        switch activity {
        case .idle: return 1.0
        case .thinking: return 1.15
        case .suggesting: return 1.25
        }
    }

    private var animationSpeed: Double {
        switch activity {
        case .idle: return 3.0
        case .thinking: return 1.2
        case .suggesting: return 1.8
        }
    }

    var body: some View {
        ZStack {
            // Outer aura
            Circle()
                .fill(
                    RadialGradient(
                        colors: [color.opacity(0.3), color.opacity(0)],
                        center: .center,
                        startRadius: size * 0.25,
                        endRadius: size * 0.7
                    )
                )
                .frame(width: size * 1.6, height: size * 1.6)
                .scaleEffect(breathScale * activityScale)

            // Glass backing
            Circle()
                .fill(.ultraThinMaterial)
                .frame(width: size, height: size)

            // Core glow
            Circle()
                .fill(
                    RadialGradient(
                        colors: [color.opacity(0.8), color.opacity(0.2)],
                        center: .center,
                        startRadius: 0,
                        endRadius: size * 0.45
                    )
                )
                .frame(width: size * 0.8, height: size * 0.8)
                .blur(radius: 6)
                .opacity(glowOpacity)
                .scaleEffect(breathScale)

            // Inner bright point
            Circle()
                .fill(color)
                .frame(width: size * 0.25, height: size * 0.25)
                .blur(radius: 2)
                .scaleEffect(breathScale)
        }
        .ghostGlow(color: color, intensity: activity == .idle ? 0.3 : 0.7, animated: true)
        .onAppear { startBreathing() }
        .onChange(of: activity) { _, _ in startBreathing() }
    }

    private func startBreathing() {
        withAnimation(
            .easeInOut(duration: animationSpeed)
            .repeatForever(autoreverses: true)
        ) {
            breathScale = 1.08
            glowOpacity = 0.7
        }
    }
}

// MARK: - Previews

#Preview("Idle") {
    ZStack {
        Color.ghostBackground.ignoresSafeArea()
        GhostOrbView(color: .ghostCyan, activity: .idle, size: 80)
    }
}

#Preview("Thinking") {
    ZStack {
        Color.ghostBackground.ignoresSafeArea()
        GhostOrbView(color: .ghostMagenta, activity: .thinking, size: 100)
    }
}

#Preview("Suggesting") {
    ZStack {
        Color.ghostBackground.ignoresSafeArea()
        GhostOrbView(color: .ghostEmerald, activity: .suggesting, size: 120)
    }
}

#Preview("All States") {
    ZStack {
        Color.ghostBackground.ignoresSafeArea()
        HStack(spacing: 40) {
            ForEach(GhostOrbActivity.allCases, id: \.self) { state in
                VStack {
                    GhostOrbView(color: .ghostCyan, activity: state, size: 60)
                    Text(state.rawValue.capitalized)
                        .font(.caption)
                        .foregroundStyle(Color.ghostText)
                }
            }
        }
    }
}
