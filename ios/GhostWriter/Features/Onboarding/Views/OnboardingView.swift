import SwiftUI

struct OnboardingView: View {

    @State private var viewModel = OnboardingViewModel()
    @State private var firstSparkClip: GhostClip?
    @State private var showFirstSparkShareSheet = false
    @State private var showSubscriptionSheet = false
    var onComplete: (() -> Void)?

    var body: some View {
        ZStack {
            Color.ghostBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                progressBar

                TabView(selection: $viewModel.currentStep) {
                    welcomeStep
                        .tag(OnboardingStep.welcome)

                    PersonalityQuizView(viewModel: viewModel)
                        .tag(OnboardingStep.personalityQuiz)

                    FirstSessionView(viewModel: viewModel)
                        .tag(OnboardingStep.firstSession)

                    firstSparkStep
                        .tag(OnboardingStep.firstSpark)

                    monetizationStep
                        .tag(OnboardingStep.monetizationMoment)

                    socialProofStep
                        .tag(OnboardingStep.socialProof)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut(duration: 0.35), value: viewModel.currentStep)

                bottomBar
            }
        }
        .onChange(of: viewModel.currentStep) { _, newStep in
            if newStep == .complete {
                onComplete?()
            }
        }
        .alert("Skip Onboarding?", isPresented: $viewModel.showSkipConfirmation) {
            Button("Continue Setup", role: .cancel) {}
            Button("Skip") {
                viewModel.skipOnboarding()
                onComplete?()
            }
        } message: {
            Text("You can always adjust your personality and preferences in Settings.")
        }
        .sheet(isPresented: $showFirstSparkShareSheet) {
            if let firstSparkClip {
                GhostClipShareSheet(clip: firstSparkClip)
            }
        }
        .sheet(isPresented: $showSubscriptionSheet) {
            SubscriptionView()
        }
    }

    // MARK: - Progress

    private var progressBar: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.white.opacity(0.08))
                    .frame(height: 4)

                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [.ghostCyan, .ghostMagenta],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: geometry.size.width * viewModel.progress, height: 4)
                    .animation(.easeInOut(duration: 0.3), value: viewModel.progress)
            }
        }
        .frame(height: 4)
        .padding(.horizontal)
        .padding(.top, 8)
    }

    // MARK: - Bottom Bar

    private var bottomBar: some View {
        HStack {
            if viewModel.canGoBack {
                Button {
                    viewModel.goBack()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.ghostText.opacity(0.6))
                        .frame(width: 44, height: 44)
                }
                .hapticFeedback(.light)
            } else {
                Color.clear.frame(width: 44, height: 44)
            }

            Spacer()

            Button {
                viewModel.showSkipConfirmation = true
            } label: {
                Text("Skip")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.ghostText.opacity(0.4))
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 8)
    }

    // MARK: - Step 1: Welcome

    private var welcomeStep: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "hand.wave.fill")
                .font(.system(size: 64))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.ghostCyan, .ghostMagenta],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .ghostGlow(color: .ghostCyan, intensity: 0.5, animated: true)

            VStack(spacing: 10) {
                Text("GhostWriter")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundStyle(.ghostText)

                Text("Your AI Creative Partner")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.ghostCyan, .ghostMagenta],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
            }

            Text("Write with an AI ghost that learns your style, suggests ideas in real-time, and turns your sessions into shareable GhostClips.")
                .font(.system(size: 15))
                .foregroundStyle(.ghostText.opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            ghostClipPreview

            Spacer()

            Button {
                viewModel.advanceStep()
            } label: {
                Text("Get Started")
                    .font(.system(size: 17, weight: .bold))
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
            .padding(.horizontal, 32)
        }
        .padding(.bottom, 20)
    }

    private var ghostClipPreview: some View {
        VStack(spacing: 8) {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(.ultraThinMaterial)
                .frame(width: 200, height: 110)
                .overlay(
                    VStack(spacing: 6) {
                        Image(systemName: "play.rectangle.fill")
                            .font(.system(size: 28))
                            .foregroundStyle(.ghostCyan)
                        Text("GhostClip Preview")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(.ghostText.opacity(0.6))
                    }
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(Color.ghostCyan.opacity(0.2), lineWidth: 1)
                )

            Text("See your writing come alive")
                .font(.system(size: 12))
                .foregroundStyle(.ghostText.opacity(0.4))
        }
    }

    // MARK: - Step 4: First Spark

    private var firstSparkStep: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "sparkles")
                .font(.system(size: 56))
                .foregroundStyle(.ghostGold)
                .ghostGlow(color: .ghostGold, intensity: 0.6, animated: true)

            Text("Feel the Spark")
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(.ghostText)

            if !viewModel.firstSessionText.isEmpty {
                VStack(spacing: 12) {
                    Text(viewModel.firstSessionText.prefix(200))
                        .font(.system(size: 14))
                        .foregroundStyle(.ghostText.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(16)
                        .liquidGlass(cornerRadius: 14)
                        .padding(.horizontal, 24)

                    Text("Your first creation as a GhostClip")
                        .font(.system(size: 13))
                        .foregroundStyle(.ghostText.opacity(0.5))
                }
            } else {
                Text("Your first GhostClip is ready to share!")
                    .font(.system(size: 15))
                    .foregroundStyle(.ghostText.opacity(0.6))
            }

            HStack(spacing: 16) {
                Button {
                    firstSparkClip = buildFirstSparkClip()
                    showFirstSparkShareSheet = firstSparkClip != nil
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "square.and.arrow.up")
                        Text("Share Clip")
                    }
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(.ghostBackground)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 14)
                    .background(
                        Capsule().fill(
                            LinearGradient(
                                colors: [.ghostCyan, .ghostMagenta],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                    )
                }
                .hapticFeedback(.medium)

                Button {
                    viewModel.advanceStep()
                } label: {
                    Text("Skip")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(.ghostText.opacity(0.5))
                        .padding(.horizontal, 20)
                        .padding(.vertical, 14)
                }
            }

            Spacer()
        }
    }

    // MARK: - Step 5: Monetization

    private var monetizationStep: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "dollarsign.circle.fill")
                .font(.system(size: 56))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.ghostGold, .ghostEmerald],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .ghostGlow(color: .ghostGold, intensity: 0.4)

            Text("Turn Creativity into Income")
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(.ghostText)
                .multilineTextAlignment(.center)

            VStack(alignment: .leading, spacing: 12) {
                proFeatureRow(icon: "infinity", text: "Unlimited creative sessions")
                proFeatureRow(icon: "wand.and.stars", text: "Custom AI personalities")
                proFeatureRow(icon: "chart.line.uptrend.xyaxis", text: "Advanced analytics & insights")
                proFeatureRow(icon: "dollarsign.arrow.circlepath", text: "Monetize your GhostClips")
                proFeatureRow(icon: "person.3.fill", text: "Live Jam collaboration")
            }
            .padding(20)
            .liquidGlass(cornerRadius: 16)
            .padding(.horizontal, 24)

            Button {
                showSubscriptionSheet = true
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "gift.fill")
                    Text("Try Pro Free for 7 Days")
                }
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(.ghostBackground)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    Capsule().fill(
                        LinearGradient(
                            colors: [.ghostGold, .ghostEmerald],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                )
            }
            .hapticFeedback(.medium)
            .padding(.horizontal, 32)

            Button {
                viewModel.advanceStep()
            } label: {
                Text("Maybe later")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.ghostText.opacity(0.4))
            }

            Spacer()
        }
    }

    private func buildFirstSparkClip() -> GhostClip {
        let text = viewModel.firstSessionText.trimmingCharacters(in: .whitespacesAndNewlines)
        let titleSource = text.isEmpty ? "My First Spark" : text
        return GhostClip(
            sessionId: UUID(),
            creatorId: UUID(),
            videoURL: URL(string: "https://ghostwriter.app/onboarding/\(UUID().uuidString).mp4")!,
            duration: 30,
            title: String(titleSource.prefix(60)),
            clipDescription: "My first GhostWriter spark.",
            personalityUsed: viewModel.matchedPersonality?.name ?? "The Muse"
        )
    }

    private func proFeatureRow(icon: String, text: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundStyle(.ghostGold)
                .frame(width: 24)
            Text(text)
                .font(.system(size: 15))
                .foregroundStyle(.ghostText.opacity(0.85))
        }
    }

    // MARK: - Step 6: Social Proof

    private var socialProofStep: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "person.3.fill")
                .font(.system(size: 48))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.ghostCyan, .ghostEmerald],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .ghostGlow(color: .ghostEmerald, intensity: 0.4)

            Text("Join the Community")
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(.ghostText)

            Text("Thousands of creators are already writing with their ghosts.")
                .font(.system(size: 15))
                .foregroundStyle(.ghostText.opacity(0.6))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            HStack(spacing: 20) {
                communityStatCard(value: "12.5K", label: "Creators", icon: "person.fill")
                communityStatCard(value: "89K", label: "GhostClips", icon: "play.rectangle.fill")
                communityStatCard(value: "2.1M", label: "Words", icon: "text.justify.left")
            }
            .padding(.horizontal, 20)

            VStack(spacing: 8) {
                Text("Trending Now")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.ghostText.opacity(0.6))

                ForEach(0..<3, id: \.self) { index in
                    trendingClipRow(index: index)
                }
            }
            .padding(.horizontal, 20)

            Spacer()

            Button {
                viewModel.completeOnboarding()
            } label: {
                Text("Let's Create!")
                    .font(.system(size: 17, weight: .bold))
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
            .padding(.horizontal, 32)
        }
        .padding(.bottom, 20)
    }

    private func communityStatCard(value: String, label: String, icon: String) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundStyle(.ghostCyan)
            Text(value)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(.ghostText)
            Text(label)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(.ghostText.opacity(0.5))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .liquidGlass(cornerRadius: 12)
    }

    private func trendingClipRow(index: Int) -> some View {
        let clips = [
            ("luna_writes", "Midnight Poetry Session", "2.3K"),
            ("creative_storm", "Stream of Consciousness", "1.8K"),
            ("mind_architect", "Structured Brainstorm", "1.2K"),
        ]
        let clip = clips[index % clips.count]

        return HStack(spacing: 12) {
            Circle()
                .fill(.ultraThinMaterial)
                .frame(width: 32, height: 32)
                .overlay(
                    Text(String(clip.0.prefix(1)).uppercased())
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(.ghostCyan)
                )

            VStack(alignment: .leading, spacing: 2) {
                Text(clip.1)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.ghostText)
                Text(clip.0)
                    .font(.system(size: 11))
                    .foregroundStyle(.ghostText.opacity(0.5))
            }

            Spacer()

            HStack(spacing: 4) {
                Image(systemName: "eye.fill")
                    .font(.system(size: 10))
                Text(clip.2)
                    .font(.system(size: 11, weight: .medium))
            }
            .foregroundStyle(.ghostText.opacity(0.4))
        }
        .padding(10)
        .liquidGlass(cornerRadius: 10)
    }
}

#Preview {
    OnboardingView()
        .preferredColorScheme(.dark)
}
