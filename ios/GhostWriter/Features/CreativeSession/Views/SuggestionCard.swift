import SwiftUI

// MARK: - SuggestionCard

/// A glass-material card displaying a single AI suggestion with
/// confidence scoring, accept/reject actions, and swipe gestures.
struct SuggestionCard: View {
    let suggestion: GhostSuggestion
    let onAccept: () -> Void
    let onReject: () -> Void
    let onRate: (Int) -> Void

    @State private var offset: CGFloat = 0
    @State private var appeared = false

    private let cardWidth: CGFloat = 280

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            header
            content
            footer
        }
        .padding(14)
        .frame(width: cardWidth, alignment: .leading)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .strokeBorder(borderColor.opacity(0.25), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.35), radius: 12, y: 6)
        .offset(x: offset)
        .gesture(swipeGesture)
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 20)
        .onAppear {
            withAnimation(.spring(duration: 0.45, bounce: 0.3)) {
                appeared = true
            }
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack {
            typeBadge
            Spacer()
            ConfidenceIndicator(score: suggestion.confidenceScore)
        }
    }

    private var typeBadge: some View {
        Text(suggestion.type.displayName.uppercased())
            .font(.system(size: 10, weight: .bold, design: .monospaced))
            .foregroundStyle(accentColor)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(accentColor.opacity(0.15))
            .clipShape(Capsule())
    }

    // MARK: - Content

    private var content: some View {
        Text(suggestion.content)
            .font(.system(size: 14, weight: .regular))
            .foregroundStyle(Color.ghostText)
            .lineLimit(3)
            .lineSpacing(2)
    }

    // MARK: - Footer (Accept / Reject)

    private var footer: some View {
        HStack(spacing: 16) {
            Button {
                triggerHaptic(.light)
                onReject()
            } label: {
                Image(systemName: "hand.thumbsdown")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(Color.ghostText.opacity(0.5))
                    .frame(width: 36, height: 36)
                    .background(Color.white.opacity(0.06))
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)

            Button {
                triggerHaptic(.light)
                onRate(1)
            } label: {
                Image(systemName: "hand.thumbsup")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(Color.ghostText.opacity(0.5))
                    .frame(width: 36, height: 36)
                    .background(Color.white.opacity(0.06))
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)

            Spacer()

            Button {
                triggerHaptic(.medium)
                onAccept()
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 13))
                    Text("Accept")
                        .font(.system(size: 12, weight: .semibold))
                }
                .foregroundStyle(Color.ghostBackground)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(accentColor)
                .clipShape(Capsule())
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Swipe Gesture

    private var swipeGesture: some Gesture {
        DragGesture(minimumDistance: 30)
            .onChanged { value in
                offset = value.translation.width
            }
            .onEnded { value in
                let threshold: CGFloat = 100
                if value.translation.width > threshold {
                    triggerHaptic(.medium)
                    withAnimation(.easeOut(duration: 0.25)) { offset = 400 }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) { onAccept() }
                } else if value.translation.width < -threshold {
                    triggerHaptic(.light)
                    withAnimation(.easeOut(duration: 0.25)) { offset = -400 }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) { onReject() }
                } else {
                    withAnimation(.spring(duration: 0.3)) { offset = 0 }
                }
            }
    }

    // MARK: - Styling Helpers

    private var accentColor: Color {
        switch suggestion.type {
        case .continuation: .ghostCyan
        case .challenge:    .ghostMagenta
        case .summary:      .ghostGold
        case .reframe:      .ghostEmerald
        case .expand:       .ghostCyan
        }
    }

    private var borderColor: Color {
        if offset > 50 { return .ghostEmerald }
        if offset < -50 { return .ghostMagenta }
        return accentColor
    }

    private func triggerHaptic(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        UIImpactFeedbackGenerator(style: style).impactOccurred()
    }
}

// MARK: - ConfidenceIndicator

private struct ConfidenceIndicator: View {
    let score: Double

    private var color: Color {
        switch score {
        case 0.8...1.0: .ghostEmerald
        case 0.6..<0.8: .ghostCyan
        case 0.4..<0.6: .ghostGold
        default:         .ghostMagenta
        }
    }

    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(color)
                .frame(width: 6, height: 6)
                .shadow(color: color, radius: 3)

            Text("\(Int(score * 100))%")
                .font(.system(size: 11, weight: .semibold, design: .monospaced))
                .foregroundStyle(color)
        }
    }
}

// MARK: - Previews

#Preview("Continuation") {
    ZStack {
        Color.ghostBackground.ignoresSafeArea()
        SuggestionCard(
            suggestion: GhostSuggestion(
                sessionId: UUID(),
                personalityId: UUID(),
                content: "Consider expanding on this thought with a concrete example that grounds the abstract idea in reality...",
                type: .continuation,
                confidenceScore: 0.87
            ),
            onAccept: {},
            onReject: {},
            onRate: { _ in }
        )
        .padding()
    }
    .preferredColorScheme(.dark)
}

#Preview("Challenge") {
    ZStack {
        Color.ghostBackground.ignoresSafeArea()
        SuggestionCard(
            suggestion: GhostSuggestion(
                sessionId: UUID(),
                personalityId: UUID(),
                content: "What if you approached this from the opposite perspective entirely?",
                type: .challenge,
                confidenceScore: 0.72
            ),
            onAccept: {},
            onReject: {},
            onRate: { _ in }
        )
        .padding()
    }
    .preferredColorScheme(.dark)
}

#Preview("Card Row") {
    ZStack {
        Color.ghostBackground.ignoresSafeArea()
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                SuggestionCard(
                    suggestion: GhostSuggestion(
                        sessionId: UUID(),
                        personalityId: UUID(),
                        content: "Consider building on the metaphor of light and shadow to create contrast...",
                        type: .expand,
                        confidenceScore: 0.91
                    ),
                    onAccept: {},
                    onReject: {},
                    onRate: { _ in }
                )
                SuggestionCard(
                    suggestion: GhostSuggestion(
                        sessionId: UUID(),
                        personalityId: UUID(),
                        content: "Here's a brief summary of the key themes so far...",
                        type: .summary,
                        confidenceScore: 0.65
                    ),
                    onAccept: {},
                    onReject: {},
                    onRate: { _ in }
                )
                SuggestionCard(
                    suggestion: GhostSuggestion(
                        sessionId: UUID(),
                        personalityId: UUID(),
                        content: "Try reframing the narrative from the antagonist's point of view.",
                        type: .reframe,
                        confidenceScore: 0.78
                    ),
                    onAccept: {},
                    onReject: {},
                    onRate: { _ in }
                )
            }
            .padding()
        }
    }
    .preferredColorScheme(.dark)
}
