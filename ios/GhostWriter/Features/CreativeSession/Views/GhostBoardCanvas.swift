import SwiftUI

// MARK: - GhostBoardCanvas

/// The fluid creative writing canvas at the heart of every session.
///
/// Wraps a `TextEditor` with GhostWriter's dark-neon styling, a placeholder
/// when empty, a word-count badge, and a subtle edge glow when the user
/// enters flow state.
struct GhostBoardCanvas: View {
    @Binding var text: String
    let wordCount: Int
    let isInFlowState: Bool

    @FocusState private var isFocused: Bool
    @State private var glowPhase: CGFloat = 0

    var body: some View {
        ZStack(alignment: .topLeading) {
            canvas
            if text.isEmpty { placeholder }
            wordCountOverlay
        }
        .overlay(flowGlow)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.white.opacity(0.03))
        )
        .onAppear { isFocused = true }
    }

    // MARK: - Canvas

    private var canvas: some View {
        TextEditor(text: $text)
            .focused($isFocused)
            .font(.system(size: 18, weight: .regular, design: .serif))
            .foregroundStyle(Color.ghostText)
            .scrollContentBackground(.hidden)
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 40)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .tint(Color.ghostCyan)
    }

    // MARK: - Placeholder

    private var placeholder: some View {
        Text("Start writing… your ghost is listening")
            .font(.system(size: 18, weight: .regular, design: .serif))
            .foregroundStyle(Color.ghostText.opacity(0.25))
            .padding(.horizontal, 21)
            .padding(.top, 24)
            .allowsHitTesting(false)
    }

    // MARK: - Word Count Badge

    private var wordCountOverlay: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                HStack(spacing: 4) {
                    Image(systemName: "character.cursor.ibeam")
                        .font(.system(size: 10))
                    Text("\(wordCount) words")
                        .font(.system(size: 11, weight: .medium, design: .monospaced))
                        .contentTransition(.numericText())
                }
                .foregroundStyle(Color.ghostText.opacity(0.45))
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(.ultraThinMaterial)
                .clipShape(Capsule())
                .padding(10)
            }
        }
    }

    // MARK: - Flow Glow

    private var flowGlow: some View {
        RoundedRectangle(cornerRadius: 16, style: .continuous)
            .strokeBorder(
                AngularGradient(
                    colors: isInFlowState
                        ? [.ghostCyan, .ghostMagenta, .ghostEmerald, .ghostCyan]
                        : [.clear],
                    center: .center,
                    startAngle: .degrees(glowPhase * 360),
                    endAngle: .degrees(glowPhase * 360 + 360)
                ),
                lineWidth: isInFlowState ? 1.5 : 0
            )
            .opacity(isInFlowState ? 0.7 : 0)
            .shadow(color: .ghostCyan.opacity(isInFlowState ? 0.3 : 0), radius: 12)
            .animation(.easeInOut(duration: 0.6), value: isInFlowState)
            .onAppear {
                withAnimation(.linear(duration: 4).repeatForever(autoreverses: false)) {
                    glowPhase = 1
                }
            }
    }
}

// MARK: - Preview

#Preview("Empty Canvas") {
    ZStack {
        Color.ghostBackground.ignoresSafeArea()
        GhostBoardCanvas(text: .constant(""), wordCount: 0, isInFlowState: false)
            .frame(height: 400)
            .padding()
    }
    .preferredColorScheme(.dark)
}

#Preview("With Text") {
    ZStack {
        Color.ghostBackground.ignoresSafeArea()
        GhostBoardCanvas(
            text: .constant("The rain hammered the tin roof like a thousand tiny fists, each drop carrying a memory of somewhere else. She sat at the window, watching the world dissolve into watercolor streaks of gray and silver."),
            wordCount: 34,
            isInFlowState: false
        )
        .frame(height: 400)
        .padding()
    }
    .preferredColorScheme(.dark)
}

#Preview("Flow State Active") {
    ZStack {
        Color.ghostBackground.ignoresSafeArea()
        GhostBoardCanvas(
            text: .constant("Words poured out like light through a prism, each one splitting into a spectrum of meaning that painted the page with color and intent."),
            wordCount: 24,
            isInFlowState: true
        )
        .frame(height: 400)
        .padding()
    }
    .preferredColorScheme(.dark)
}
