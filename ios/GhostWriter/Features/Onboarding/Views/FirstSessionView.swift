import SwiftUI

struct FirstSessionView: View {

    @Bindable var viewModel: OnboardingViewModel
    @State private var timeRemaining: Int = 180
    @State private var timerActive = false
    @State private var showSuggestions = false
    @State private var acceptedSuggestions: Set<Int> = []
    @State private var flowScore: Double = 0
    @State private var showCelebration = false
    @State private var pulseAvatar = false

    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    private let suggestions = [
        "What if you started with a vivid sensory detail? Describe what you see, hear, or feel right now.",
        "Try writing without stopping for 30 seconds — let your thoughts flow freely.",
        "Take your last sentence and flip the perspective. What would the opposite look like?",
    ]

    var body: some View {
        VStack(spacing: 16) {
            header
            personalityAvatar
            textEditor
            suggestionCards
            bottomStats

            if showCelebration {
                celebrationOverlay
            }
        }
        .padding(.horizontal, 20)
        .onReceive(timer) { _ in
            guard timerActive, timeRemaining > 0 else {
                if timerActive && timeRemaining <= 0 {
                    completeSession()
                }
                return
            }
            timeRemaining -= 1
            updateFlowScore()

            if timeRemaining == 150 || timeRemaining == 100 || timeRemaining == 50 {
                withAnimation(.easeInOut(duration: 0.4)) {
                    showSuggestions = true
                }
            }
        }
        .onAppear {
            timerActive = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                withAnimation { showSuggestions = true }
            }
        }
    }

    // MARK: - Header

    private var header: some View {
        VStack(spacing: 6) {
            Text("Your First Session")
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(.ghostText)

            Text(formattedTime)
                .font(.system(size: 36, weight: .bold, design: .monospaced))
                .foregroundStyle(timeRemaining <= 30 ? .ghostGold : .ghostCyan)
                .contentTransition(.numericText())
                .animation(.easeInOut(duration: 0.2), value: timeRemaining)
        }
    }

    // MARK: - Personality Avatar

    private var personalityAvatar: some View {
        HStack(spacing: 12) {
            if let personality = viewModel.matchedPersonality {
                PersonalityAvatarView(
                    name: personality.name,
                    color: .ghostCyan,
                    icon: "brain.head.profile",
                    isActive: true,
                    size: 40
                )
                .scaleEffect(pulseAvatar ? 1.08 : 1.0)
                .animation(
                    .easeInOut(duration: 1.5).repeatForever(autoreverses: true),
                    value: pulseAvatar
                )
                .onAppear { pulseAvatar = true }

                VStack(alignment: .leading, spacing: 2) {
                    Text(personality.name)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.ghostCyan)
                    Text("is guiding your session")
                        .font(.system(size: 12))
                        .foregroundStyle(.ghostText.opacity(0.5))
                }
            }

            Spacer()

            FlowStateIndicator(score: flowScore)
                .frame(width: 130)
        }
    }

    // MARK: - Text Editor

    private var textEditor: some View {
        ZStack(alignment: .topLeading) {
            if viewModel.firstSessionText.isEmpty {
                Text("Start writing... let your thoughts flow freely.")
                    .font(.system(size: 16))
                    .foregroundStyle(.ghostText.opacity(0.25))
                    .padding(.top, 16)
                    .padding(.horizontal, 16)
            }

            TextEditor(text: $viewModel.firstSessionText)
                .font(.system(size: 16))
                .foregroundStyle(.ghostText)
                .scrollContentBackground(.hidden)
                .padding(12)
                .frame(minHeight: 160, maxHeight: 220)
        }
        .liquidGlass(cornerRadius: 16)
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(
                    flowScore > 70
                        ? Color.ghostEmerald.opacity(0.3)
                        : Color.white.opacity(0.08),
                    lineWidth: 1
                )
                .animation(.easeInOut(duration: 0.5), value: flowScore > 70)
        )
    }

    // MARK: - Suggestion Cards

    @ViewBuilder
    private var suggestionCards: some View {
        if showSuggestions {
            VStack(spacing: 8) {
                ForEach(Array(suggestions.enumerated()), id: \.offset) { index, suggestion in
                    if !acceptedSuggestions.contains(index) {
                        suggestionCard(text: suggestion, index: index)
                            .transition(.asymmetric(
                                insertion: .move(edge: .bottom).combined(with: .opacity),
                                removal: .scale.combined(with: .opacity)
                            ))
                    }
                }
            }
        }
    }

    private func suggestionCard(text: String, index: Int) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "lightbulb.fill")
                .font(.system(size: 14))
                .foregroundStyle(.ghostGold)

            Text(text)
                .font(.system(size: 13))
                .foregroundStyle(.ghostText.opacity(0.8))
                .lineLimit(2)

            Spacer(minLength: 8)

            HStack(spacing: 8) {
                Button {
                    acceptSuggestion(index: index)
                } label: {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 22))
                        .foregroundStyle(.ghostEmerald)
                }
                .hapticFeedback(.light)

                Button {
                    rejectSuggestion(index: index)
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 22))
                        .foregroundStyle(.ghostText.opacity(0.3))
                }
                .hapticFeedback(.light)
            }
        }
        .padding(12)
        .liquidGlass(cornerRadius: 12)
    }

    // MARK: - Bottom Stats

    private var bottomStats: some View {
        HStack(spacing: 20) {
            HStack(spacing: 6) {
                Image(systemName: "character.cursor.ibeam")
                    .font(.system(size: 12))
                    .foregroundStyle(.ghostCyan)
                Text("\(viewModel.firstSessionWordCount) words")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(.ghostText.opacity(0.6))
            }

            Spacer()

            if !timerActive || timeRemaining <= 0 {
                Button {
                    completeSession()
                } label: {
                    Text("Continue")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.ghostBackground)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(
                            Capsule().fill(
                                LinearGradient(
                                    colors: [.ghostCyan, .ghostEmerald],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                        )
                }
                .hapticFeedback(.medium)
            }
        }
    }

    // MARK: - Celebration

    private var celebrationOverlay: some View {
        VStack(spacing: 16) {
            Image(systemName: "party.popper.fill")
                .font(.system(size: 48))
                .foregroundStyle(.ghostGold)
                .ghostGlow(color: .ghostGold, intensity: 0.6)

            Text("Amazing First Session!")
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(.ghostText)

            Text("\(viewModel.firstSessionWordCount) words written")
                .font(.system(size: 14))
                .foregroundStyle(.ghostText.opacity(0.6))
        }
        .padding(24)
        .liquidGlass(cornerRadius: 20)
        .transition(.scale.combined(with: .opacity))
    }

    // MARK: - Helpers

    private var formattedTime: String {
        let minutes = timeRemaining / 60
        let seconds = timeRemaining % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    private func updateFlowScore() {
        let wordProgress = min(Double(viewModel.firstSessionWordCount) / 50.0, 1.0)
        let timeProgress = 1.0 - (Double(timeRemaining) / 180.0)
        flowScore = min(100, (wordProgress * 60 + timeProgress * 40))
    }

    private func acceptSuggestion(index: Int) {
        withAnimation(.easeOut(duration: 0.3)) {
            acceptedSuggestions.insert(index)
        }
    }

    private func rejectSuggestion(index: Int) {
        withAnimation(.easeOut(duration: 0.3)) {
            acceptedSuggestions.insert(index)
        }
    }

    private func completeSession() {
        timerActive = false
        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
            showCelebration = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation {
                showCelebration = false
            }
            viewModel.advanceStep()
        }
    }
}

#Preview {
    ZStack {
        Color.ghostBackground.ignoresSafeArea()
        FirstSessionView(viewModel: {
            let vm = OnboardingViewModel()
            vm.matchedPersonality = GhostPersonality.theMuse()
            return vm
        }())
    }
    .preferredColorScheme(.dark)
}
