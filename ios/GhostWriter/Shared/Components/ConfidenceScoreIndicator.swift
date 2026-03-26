import SwiftUI

/// A circular progress ring that visualises an AI confidence score (0–1).
///
/// The ring color transitions from red (low) through yellow (mid) to green (high).
///
/// ```swift
/// ConfidenceScoreIndicator(score: 0.85, size: 60)
/// ```
struct ConfidenceScoreIndicator: View {
    /// Confidence score in the 0…1 range.
    var score: Double
    /// Outer diameter of the ring.
    var size: CGFloat = 60
    /// Stroke width.
    var lineWidth: CGFloat = 6

    @State private var animatedScore: Double = 0

    private var ringColor: Color {
        switch animatedScore {
        case ..<0.3: return .red
        case 0.3..<0.7: return .yellow
        default: return .ghostEmerald
        }
    }

    private var gradientColors: [Color] {
        switch animatedScore {
        case ..<0.3: return [.red, .orange]
        case 0.3..<0.7: return [.orange, .yellow]
        default: return [.ghostEmerald, .ghostCyan]
        }
    }

    var body: some View {
        ZStack {
            // Track
            Circle()
                .stroke(Color.white.opacity(0.1), lineWidth: lineWidth)

            // Filled ring
            Circle()
                .trim(from: 0, to: animatedScore)
                .stroke(
                    AngularGradient(
                        colors: gradientColors,
                        center: .center,
                        startAngle: .degrees(0),
                        endAngle: .degrees(360 * animatedScore)
                    ),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))

            // Percentage label
            Text("\(Int(animatedScore * 100))%")
                .font(.system(size: size * 0.25, weight: .bold, design: .rounded))
                .foregroundStyle(ringColor)
        }
        .frame(width: size, height: size)
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                animatedScore = min(max(score, 0), 1)
            }
        }
        .onChange(of: score) { _, newValue in
            withAnimation(.easeOut(duration: 0.5)) {
                animatedScore = min(max(newValue, 0), 1)
            }
        }
    }
}

// MARK: - Previews

#Preview("High Confidence") {
    ZStack {
        Color.ghostBackground.ignoresSafeArea()
        ConfidenceScoreIndicator(score: 0.92)
    }
}

#Preview("Medium Confidence") {
    ZStack {
        Color.ghostBackground.ignoresSafeArea()
        ConfidenceScoreIndicator(score: 0.55, size: 80)
    }
}

#Preview("Low Confidence") {
    ZStack {
        Color.ghostBackground.ignoresSafeArea()
        ConfidenceScoreIndicator(score: 0.15)
    }
}

#Preview("All Levels") {
    ZStack {
        Color.ghostBackground.ignoresSafeArea()
        HStack(spacing: 24) {
            ConfidenceScoreIndicator(score: 0.15, size: 50)
            ConfidenceScoreIndicator(score: 0.50, size: 50)
            ConfidenceScoreIndicator(score: 0.85, size: 50)
        }
    }
}
