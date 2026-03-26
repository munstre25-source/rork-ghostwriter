import SwiftUI

/// A badge displaying the user's creative writing streak count.
///
/// Different milestone levels (7, 30, 100 days) show distinct colors.
/// Active streaks have a glow effect.
///
/// ```swift
/// CreativeStreakBadge(days: 42, isActive: true)
/// ```
struct CreativeStreakBadge: View {
    /// Number of consecutive days in the streak.
    var days: Int
    /// Whether the streak is currently active (wrote today).
    var isActive: Bool

    @State private var isGlowing = false

    private var streakColor: Color {
        switch days {
        case 100...: return .ghostGold
        case 30..<100: return .ghostMagenta
        case 7..<30: return .ghostCyan
        default: return .ghostText
        }
    }

    private var milestoneIcon: String {
        switch days {
        case 100...: return "flame.fill"
        case 30..<100: return "flame.fill"
        case 7..<30: return "flame"
        default: return "flame"
        }
    }

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: milestoneIcon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(streakColor)
                .scaleEffect(isGlowing ? 1.15 : 1.0)

            Text("\(days)")
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundStyle(streakColor)

            Text(days == 1 ? "day" : "days")
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(Color.ghostText.opacity(0.6))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            Capsule()
                .fill(.ultraThinMaterial)
        )
        .overlay(
            Capsule()
                .stroke(
                    isActive ? streakColor.opacity(0.4) : Color.clear,
                    lineWidth: 1
                )
        )
        .ghostGlow(
            color: isActive ? streakColor : .clear,
            intensity: isActive ? 0.5 : 0,
            animated: isActive
        )
        .onAppear {
            guard isActive else { return }
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                isGlowing = true
            }
        }
    }
}

// MARK: - Previews

#Preview("Short Streak") {
    ZStack {
        Color.ghostBackground.ignoresSafeArea()
        CreativeStreakBadge(days: 3, isActive: true)
    }
}

#Preview("Week Streak") {
    ZStack {
        Color.ghostBackground.ignoresSafeArea()
        CreativeStreakBadge(days: 12, isActive: true)
    }
}

#Preview("Month Streak") {
    ZStack {
        Color.ghostBackground.ignoresSafeArea()
        CreativeStreakBadge(days: 42, isActive: true)
    }
}

#Preview("Century Streak") {
    ZStack {
        Color.ghostBackground.ignoresSafeArea()
        CreativeStreakBadge(days: 150, isActive: true)
    }
}

#Preview("Inactive") {
    ZStack {
        Color.ghostBackground.ignoresSafeArea()
        CreativeStreakBadge(days: 5, isActive: false)
    }
}

#Preview("All Milestones") {
    ZStack {
        Color.ghostBackground.ignoresSafeArea()
        VStack(spacing: 16) {
            CreativeStreakBadge(days: 3, isActive: true)
            CreativeStreakBadge(days: 14, isActive: true)
            CreativeStreakBadge(days: 42, isActive: true)
            CreativeStreakBadge(days: 120, isActive: true)
            CreativeStreakBadge(days: 5, isActive: false)
        }
    }
}
