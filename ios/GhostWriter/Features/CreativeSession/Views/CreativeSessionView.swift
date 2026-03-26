import SwiftUI

// MARK: - CreativeSessionView

/// The main "Live" tab — the GhostBoard creative canvas.
///
/// Hosts session-type selection, the writing canvas, real-time flow
/// indicators, AI suggestion cards, and floating action controls.
struct CreativeSessionView: View {
    @State private var viewModel = CreativeSessionViewModel()
    @State private var showEndConfirmation = false
    @State private var timerTick: Date = .now
    @Environment(\.dismiss) private var dismiss

    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            Color.ghostBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                sessionHeader
                ghostBoardArea
                suggestionsArea
            }

            floatingControls
            ghostOrbOverlay
        }
        .task {
            await viewModel.startSession(
                type: viewModel.selectedSessionType,
                personalityId: viewModel.currentPersonalityId ?? UUID()
            )
        }
        .onReceive(timer) { timerTick = $0 }
        .confirmationDialog(
            "End Session?",
            isPresented: $showEndConfirmation,
            titleVisibility: .visible
        ) {
            Button("End Session", role: .destructive) {
                Task { await viewModel.endSession() }
                triggerHaptic(.heavy)
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Your session has \(viewModel.wordCount) words. Are you sure?")
        }
        .preferredColorScheme(.dark)
    }

    // MARK: - Session Header

    private var sessionHeader: some View {
        VStack(spacing: 12) {
            HStack {
                sessionTimerBadge
                Spacer()
                flowIndicator
                Spacer()
                wordCountBadge
            }
            .padding(.horizontal)

            sessionTypeSelector
        }
        .padding(.top, 8)
    }

    private var sessionTypeSelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(SessionType.allCases) { type in
                    Button {
                        triggerHaptic(.light)
                        withAnimation(.snappy(duration: 0.3)) {
                            viewModel.selectedSessionType = type
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: type.icon)
                                .font(.system(size: 13, weight: .semibold))
                            Text(type.displayName)
                                .font(.system(size: 13, weight: .medium))
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(
                            viewModel.selectedSessionType == type
                                ? AnyShapeStyle(Color.ghostCyan.opacity(0.25))
                                : AnyShapeStyle(.ultraThinMaterial)
                        )
                        .foregroundStyle(
                            viewModel.selectedSessionType == type
                                ? Color.ghostCyan
                                : Color.ghostText.opacity(0.7)
                        )
                        .clipShape(Capsule())
                        .overlay(
                            Capsule()
                                .strokeBorder(
                                    viewModel.selectedSessionType == type
                                        ? Color.ghostCyan.opacity(0.6)
                                        : Color.white.opacity(0.08),
                                    lineWidth: 1
                                )
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal)
        }
    }

    private var sessionTimerBadge: some View {
        HStack(spacing: 5) {
            Circle()
                .fill(viewModel.isPaused ? Color.ghostGold : Color.ghostEmerald)
                .frame(width: 7, height: 7)
                .shadow(color: viewModel.isPaused ? .ghostGold : .ghostEmerald, radius: 4)

            Text(viewModel.formattedDuration)
                .font(.system(size: 14, weight: .semibold, design: .monospaced))
                .foregroundStyle(Color.ghostText)
                .contentTransition(.numericText())
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(.ultraThinMaterial)
        .clipShape(Capsule())
    }

    private var wordCountBadge: some View {
        HStack(spacing: 4) {
            Image(systemName: "text.word.spacing")
                .font(.system(size: 11))
            Text("\(viewModel.wordCount)")
                .font(.system(size: 13, weight: .semibold, design: .monospaced))
                .contentTransition(.numericText())
        }
        .foregroundStyle(Color.ghostText.opacity(0.8))
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(.ultraThinMaterial)
        .clipShape(Capsule())
    }

    private var flowIndicator: some View {
        HStack(spacing: 5) {
            if viewModel.isInFlowState {
                Image(systemName: "flame.fill")
                    .font(.system(size: 14))
                    .foregroundStyle(
                        .linearGradient(
                            colors: [.orange, .ghostMagenta],
                            startPoint: .bottom,
                            endPoint: .top
                        )
                    )
                    .symbolEffect(.pulse, isActive: true)
                Text("Flow")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(Color.ghostMagenta)
            } else {
                Image(systemName: "wind")
                    .font(.system(size: 13))
                    .foregroundStyle(Color.ghostText.opacity(0.4))
                Text("\(Int(viewModel.flowScore))%")
                    .font(.system(size: 12, weight: .medium, design: .monospaced))
                    .foregroundStyle(Color.ghostText.opacity(0.4))
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(
            viewModel.isInFlowState
                ? AnyShapeStyle(Color.ghostMagenta.opacity(0.15))
                : AnyShapeStyle(.ultraThinMaterial)
        )
        .clipShape(Capsule())
        .animation(.easeInOut(duration: 0.5), value: viewModel.isInFlowState)
    }

    // MARK: - GhostBoard Canvas

    private var ghostBoardArea: some View {
        GhostBoardCanvas(
            text: $viewModel.sessionText,
            wordCount: viewModel.wordCount,
            isInFlowState: viewModel.isInFlowState
        )
        .padding(.horizontal)
        .padding(.top, 12)
    }

    // MARK: - Suggestions

    private var suggestionsArea: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 12) {
                ForEach(viewModel.suggestions) { suggestion in
                    SuggestionCard(
                        suggestion: suggestion,
                        onAccept: {
                            triggerHaptic(.medium)
                            Task { await viewModel.acceptSuggestion(suggestion) }
                        },
                        onReject: {
                            triggerHaptic(.light)
                            Task { await viewModel.rejectSuggestion(suggestion) }
                        },
                        onRate: { rating in
                            triggerHaptic(.light)
                            Task { await viewModel.rateSuggestion(suggestion, rating: rating) }
                        }
                    )
                    .transition(.asymmetric(
                        insertion: .move(edge: .bottom).combined(with: .opacity),
                        removal: .move(edge: .trailing).combined(with: .opacity)
                    ))
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 10)
        }
        .frame(height: viewModel.suggestions.isEmpty ? 0 : 170)
        .animation(.spring(duration: 0.4), value: viewModel.suggestions.count)
    }

    // MARK: - Floating Controls

    private var floatingControls: some View {
        VStack {
            Spacer()

            HStack(spacing: 16) {
                FloatingActionButton(
                    icon: viewModel.isPaused ? "play.fill" : "pause.fill",
                    color: .ghostGold
                ) {
                    triggerHaptic(.medium)
                    viewModel.togglePause()
                }

                FloatingActionButton(
                    icon: "camera.viewfinder",
                    color: .ghostCyan
                ) {
                    triggerHaptic(.medium)
                }

                FloatingActionButton(
                    icon: "stop.circle.fill",
                    color: .ghostMagenta
                ) {
                    triggerHaptic(.heavy)
                    showEndConfirmation = true
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(.regularMaterial)
            .clipShape(Capsule())
            .shadow(color: .black.opacity(0.4), radius: 16, y: 8)
            .padding(.bottom, 24)
        }
        .ignoresSafeArea(.keyboard)
    }

    // MARK: - Ghost Orb

    private var ghostOrbOverlay: some View {
        VStack {
            HStack {
                Spacer()
                GhostOrb(isThinking: viewModel.isLoading, flowScore: viewModel.flowScore)
                    .frame(width: 48, height: 48)
                    .padding(.trailing, 16)
                    .padding(.top, 8)
            }
            Spacer()
        }
    }

    // MARK: - Haptics

    private func triggerHaptic(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        UIImpactFeedbackGenerator(style: style).impactOccurred()
    }
}

// MARK: - FloatingActionButton

private struct FloatingActionButton: View {
    let icon: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(color)
                .frame(width: 44, height: 44)
                .contentShape(Circle())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - GhostOrb

private struct GhostOrb: View {
    let isThinking: Bool
    let flowScore: Double

    @State private var phase: CGFloat = 0

    private var orbColor: Color {
        if isThinking { return .ghostCyan }
        if flowScore > 70 { return .ghostMagenta }
        return .ghostText.opacity(0.3)
    }

    var body: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [orbColor.opacity(0.6), orbColor.opacity(0.0)],
                        center: .center,
                        startRadius: 4,
                        endRadius: 24
                    )
                )
                .scaleEffect(isThinking ? 1.3 : 1.0)
                .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: isThinking)

            Circle()
                .fill(orbColor)
                .frame(width: 14, height: 14)
                .shadow(color: orbColor, radius: isThinking ? 12 : 4)

            if isThinking {
                Circle()
                    .stroke(orbColor.opacity(0.4), lineWidth: 2)
                    .frame(width: 28, height: 28)
                    .rotationEffect(.degrees(phase * 360))
                    .onAppear {
                        withAnimation(.linear(duration: 2).repeatForever(autoreverses: false)) {
                            phase = 1
                        }
                    }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    CreativeSessionView()
}

#Preview("With Flow State") {
    CreativeSessionView()
}
