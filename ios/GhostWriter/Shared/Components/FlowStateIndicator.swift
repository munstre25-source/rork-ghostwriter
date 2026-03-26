import SwiftUI

/// Displays a flow-state level (0–100) with a progress bar and flame icon when in flow.
///
/// Color transitions from cool blue through warm orange to hot red as the
/// score increases. A subtle pulse animation activates when in flow (> 70).
///
/// ```swift
/// FlowStateIndicator(score: 85)
/// ```
struct FlowStateIndicator: View {
    /// Flow state score from 0 to 100.
    var score: Double

    @State private var animatedScore: Double = 0
    @State private var isPulsing = false

    private var normalizedScore: Double {
        min(max(animatedScore, 0), 100) / 100
    }

    private var barColor: Color {
        switch animatedScore {
        case 70...: return .red
        case 50..<70: return .orange
        default: return .ghostCyan
        }
    }

    private var gradientColors: [Color] {
        switch animatedScore {
        case 70...: return [.orange, .red]
        case 50..<70: return [.ghostCyan, .orange]
        default: return [Color(hex: "4A90D9"), .ghostCyan]
        }
    }

    private var isInFlow: Bool { animatedScore > 70 }

    var body: some View {
        HStack(spacing: 10) {
            // Flame icon
            Image(systemName: isInFlow ? "flame.fill" : "flame")
                .font(.system(size: 18))
                .foregroundStyle(isInFlow ? barColor : .ghostText.opacity(0.4))
                .symbolEffect(.pulse, isActive: isInFlow)
                .scaleEffect(isPulsing ? 1.15 : 1.0)

            VStack(alignment: .leading, spacing: 4) {
                // Label
                Text(flowLabel)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(Color.ghostText.opacity(0.7))

                // Progress bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.white.opacity(0.1))
                            .frame(height: 6)

                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: gradientColors,
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geometry.size.width * normalizedScore, height: 6)
                    }
                }
                .frame(height: 6)
            }

            Text("\(Int(animatedScore))")
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundStyle(barColor)
                .frame(width: 30, alignment: .trailing)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .liquidGlass(cornerRadius: 12)
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                animatedScore = score
            }
            if score > 70 {
                withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                    isPulsing = true
                }
            }
        }
        .onChange(of: score) { _, newValue in
            withAnimation(.easeOut(duration: 0.5)) {
                animatedScore = newValue
            }
            if newValue > 70 && !isPulsing {
                withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                    isPulsing = true
                }
            } else if newValue <= 70 {
                isPulsing = false
            }
        }
    }

    private var flowLabel: String {
        switch animatedScore {
        case 90...: return "In The Zone"
        case 70..<90: return "Flowing"
        case 50..<70: return "Warming Up"
        default: return "Building Flow"
        }
    }
}

// MARK: - Previews

#Preview("High Flow") {
    ZStack {
        Color.ghostBackground.ignoresSafeArea()
        FlowStateIndicator(score: 92)
            .padding()
    }
}

#Preview("Medium Flow") {
    ZStack {
        Color.ghostBackground.ignoresSafeArea()
        FlowStateIndicator(score: 55)
            .padding()
    }
}

#Preview("Low Flow") {
    ZStack {
        Color.ghostBackground.ignoresSafeArea()
        FlowStateIndicator(score: 20)
            .padding()
    }
}

#Preview("All Levels") {
    ZStack {
        Color.ghostBackground.ignoresSafeArea()
        VStack(spacing: 16) {
            FlowStateIndicator(score: 15)
            FlowStateIndicator(score: 55)
            FlowStateIndicator(score: 78)
            FlowStateIndicator(score: 95)
        }
        .padding()
    }
}
