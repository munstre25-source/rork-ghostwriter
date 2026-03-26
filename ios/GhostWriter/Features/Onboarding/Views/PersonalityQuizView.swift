import SwiftUI

struct PersonalityQuizView: View {

    @Bindable var viewModel: OnboardingViewModel
    @State private var currentQuestion = 0
    @State private var showResult = false
    @State private var resultScale: CGFloat = 0.5
    @State private var resultOpacity: Double = 0

    private let questions: [(question: String, optionA: String, optionB: String, keyA: String, keyB: String)] = [
        (
            "How do you prefer to create?",
            "Messy & free-flowing",
            "Structured & precise",
            "creative flow free explore",
            "structure organize plan outline logic"
        ),
        (
            "What's your ideal pace?",
            "Fast & spontaneous",
            "Thoughtful & deliberate",
            "creative inspire flow free",
            "data analyze research evidence detail"
        ),
        (
            "What motivates you most?",
            "Encouragement & positivity",
            "Honest feedback & challenge",
            "creative inspire flow vision bold dream",
            "improve edit critique quality polish"
        ),
        (
            "How do you like to work?",
            "Solo deep dives",
            "Collaborative brainstorms",
            "data analyze research structure organize",
            "vision bold dream future imagine creative"
        ),
    ]

    var body: some View {
        VStack(spacing: 0) {
            if showResult {
                resultView
            } else {
                quizContent
            }
        }
        .padding(.horizontal, 20)
    }

    // MARK: - Quiz Content

    private var quizContent: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "theatermasks.fill")
                .font(.system(size: 44))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.ghostCyan, .ghostMagenta],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .ghostGlow(color: .ghostMagenta, intensity: 0.4)

            Text("Find Your Ghost")
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(.ghostText)

            Text("Question \(currentQuestion + 1) of \(questions.count)")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(.ghostText.opacity(0.4))

            questionProgressDots

            let q = questions[currentQuestion]

            Text(q.question)
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(.ghostText)
                .multilineTextAlignment(.center)
                .padding(.top, 8)
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))
                .id("question_\(currentQuestion)")

            VStack(spacing: 12) {
                answerCard(text: q.optionA) {
                    selectAnswer(key: q.keyA)
                }

                answerCard(text: q.optionB) {
                    selectAnswer(key: q.keyB)
                }
            }
            .transition(.asymmetric(
                insertion: .move(edge: .trailing).combined(with: .opacity),
                removal: .move(edge: .leading).combined(with: .opacity)
            ))
            .id("answers_\(currentQuestion)")

            Spacer()
            Spacer()
        }
    }

    private var questionProgressDots: some View {
        HStack(spacing: 8) {
            ForEach(0..<questions.count, id: \.self) { index in
                Circle()
                    .fill(index <= currentQuestion ? Color.ghostCyan : Color.white.opacity(0.15))
                    .frame(width: 8, height: 8)
                    .scaleEffect(index == currentQuestion ? 1.3 : 1.0)
                    .animation(.easeInOut(duration: 0.2), value: currentQuestion)
            }
        }
    }

    private func answerCard(text: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(text)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.ghostText)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                .liquidGlass(cornerRadius: 16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                )
        }
        .hapticFeedback(.light)
    }

    // MARK: - Result View

    private var resultView: some View {
        VStack(spacing: 24) {
            Spacer()

            if let personality = viewModel.matchedPersonality {
                Image(systemName: "sparkles")
                    .font(.system(size: 56))
                    .foregroundStyle(.ghostGold)
                    .ghostGlow(color: .ghostGold, intensity: 0.6, animated: true)
                    .scaleEffect(resultScale)
                    .opacity(resultOpacity)

                VStack(spacing: 8) {
                    Text("Your Ghost Is...")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(.ghostText.opacity(0.6))

                    Text(personality.name)
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.ghostCyan, .ghostMagenta],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                }
                .scaleEffect(resultScale)
                .opacity(resultOpacity)

                Text(personality.personalityDescription)
                    .font(.system(size: 15))
                    .foregroundStyle(.ghostText.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                    .opacity(resultOpacity)

                HStack(spacing: 8) {
                    ForEach(personality.traits, id: \.self) { trait in
                        Text(trait)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(.ghostCyan)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(
                                Capsule().fill(Color.ghostCyan.opacity(0.15))
                            )
                    }
                }
                .opacity(resultOpacity)
            }

            Spacer()

            Button {
                viewModel.advanceStep()
            } label: {
                Text("Start Writing with \(viewModel.matchedPersonality?.name ?? "Your Ghost")")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.ghostBackground)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
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
            .padding(.horizontal, 12)
            .opacity(resultOpacity)
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                resultScale = 1.0
            }
            withAnimation(.easeIn(duration: 0.5)) {
                resultOpacity = 1.0
            }
        }
    }

    // MARK: - Actions

    private func selectAnswer(key: String) {
        let q = questions[currentQuestion]
        viewModel.answerQuiz(question: q.question, answer: key)

        if currentQuestion < questions.count - 1 {
            withAnimation(.easeInOut(duration: 0.3)) {
                currentQuestion += 1
            }
        } else {
            viewModel.matchPersonality()
            withAnimation(.easeInOut(duration: 0.4)) {
                showResult = true
            }
        }
    }
}

#Preview {
    ZStack {
        Color.ghostBackground.ignoresSafeArea()
        PersonalityQuizView(viewModel: OnboardingViewModel())
    }
    .preferredColorScheme(.dark)
}
