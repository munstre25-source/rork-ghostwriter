import SwiftUI

struct StreakView: View {

    @State private var viewModel = StreakViewModel()
    @State private var showJoinAlert = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.ghostBackground.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        if viewModel.isLoading {
                            loadingState
                        } else {
                            streakHero
                            statsRow
                            calendarSection
                            challengeCard
                            milestonesSection
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 32)
                }
                .refreshable {
                    await viewModel.loadStreak()
                    await viewModel.loadActiveChallenge()
                }
            }
            .navigationTitle("Creative Streak")
            .navigationBarTitleDisplayMode(.large)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .task {
                await viewModel.loadStreak()
                await viewModel.loadActiveChallenge()
            }
            .alert("Joined!", isPresented: $showJoinAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("You've joined the challenge. Keep writing to compete!")
            }
        }
    }

    // MARK: - Streak Hero

    private var streakHero: some View {
        VStack(spacing: 8) {
            Image(systemName: "flame.fill")
                .font(.system(size: 48))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.ghostGold, .orange, .red],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .ghostGlow(color: .orange, intensity: 0.5, animated: true)

            Text("\(viewModel.currentStreak?.currentStreak ?? 0)")
                .font(.system(size: 64, weight: .bold, design: .rounded))
                .foregroundStyle(.ghostText)

            Text("Day Streak")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(.ghostText.opacity(0.6))

            ProgressView(value: viewModel.streakPercentOfLongest)
                .tint(.ghostEmerald)
                .padding(.horizontal, 40)
                .padding(.top, 4)

            Text("Longest: \(viewModel.currentStreak?.longestStreak ?? 0) days")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(.ghostText.opacity(0.4))
        }
        .padding(.vertical, 24)
        .frame(maxWidth: .infinity)
        .liquidGlass(cornerRadius: 20)
    }

    // MARK: - Stats Row

    private var statsRow: some View {
        HStack(spacing: 12) {
            statCard(
                icon: "doc.text.fill",
                value: "\(viewModel.currentStreak?.totalSessionsInStreak ?? 0)",
                label: "Sessions"
            )
            statCard(
                icon: "character.cursor.ibeam",
                value: formattedWords,
                label: "Words"
            )
            statCard(
                icon: "calendar",
                value: streakStartLabel,
                label: "Started"
            )
        }
    }

    private func statCard(icon: String, value: String, label: String) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundStyle(.ghostCyan)

            Text(value)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(.ghostText)

            Text(label)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(.ghostText.opacity(0.5))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .liquidGlass(cornerRadius: 14)
    }

    // MARK: - Calendar

    private var calendarSection: some View {
        StreakCalendarView(
            sessionDates: viewModel.streakCalendarDates,
            streakStartDate: viewModel.currentStreak?.streakStartDate
        )
    }

    // MARK: - Challenge Card

    @ViewBuilder
    private var challengeCard: some View {
        if let challenge = viewModel.activeChallenge {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "trophy.fill")
                        .foregroundStyle(.ghostGold)
                    Text("Active Challenge")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.ghostGold)
                    Spacer()
                    if challenge.isActive {
                        Text("LIVE")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(.ghostEmerald)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(Capsule().fill(Color.ghostEmerald.opacity(0.2)))
                    }
                }

                Text(challenge.title)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(.ghostText)

                Text(challenge.challengeDescription)
                    .font(.system(size: 14))
                    .foregroundStyle(.ghostText.opacity(0.7))
                    .lineLimit(3)

                HStack(spacing: 16) {
                    if let words = challenge.targetWordCount {
                        Label("\(words) words", systemImage: "text.word.spacing")
                    }
                    if let sessions = challenge.targetSessionCount {
                        Label("\(sessions) sessions", systemImage: "square.stack.fill")
                    }
                    Label("\(challenge.participantCount) joined", systemImage: "person.2.fill")
                }
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(.ghostText.opacity(0.5))

                if let prize = challenge.sponsorAmount {
                    HStack(spacing: 4) {
                        Image(systemName: "dollarsign.circle.fill")
                            .foregroundStyle(.ghostGold)
                        Text("$\(Int(prize)) Prize Pool")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.ghostGold)
                    }
                }

                if !viewModel.hasJoinedChallenge {
                    Button {
                        Task {
                            try? await viewModel.joinChallenge()
                            showJoinAlert = true
                        }
                    } label: {
                        Text("Join Challenge")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundStyle(.ghostBackground)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
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
                } else {
                    Text("You're in! Keep writing.")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.ghostEmerald)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                }
            }
            .padding(16)
            .liquidGlass(cornerRadius: 16)
        }
    }

    // MARK: - Milestones

    private var milestonesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Milestones")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(.ghostText)

            ForEach(viewModel.milestones, id: \.days) { milestone in
                HStack(spacing: 14) {
                    Image(systemName: milestone.icon)
                        .font(.system(size: 20))
                        .foregroundStyle(milestone.achieved ? .ghostGold : .ghostText.opacity(0.25))
                        .frame(width: 32)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(milestone.label)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(milestone.achieved ? .ghostText : .ghostText.opacity(0.4))
                        Text("\(milestone.days) day streak")
                            .font(.system(size: 12))
                            .foregroundStyle(.ghostText.opacity(0.35))
                    }

                    Spacer()

                    if milestone.achieved {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.ghostEmerald)
                    } else {
                        Image(systemName: "circle")
                            .foregroundStyle(.ghostText.opacity(0.2))
                    }
                }
                .padding(.vertical, 10)
                .padding(.horizontal, 14)
                .liquidGlass(cornerRadius: 12)
            }
        }
    }

    // MARK: - Loading

    private var loadingState: some View {
        VStack(spacing: 16) {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.ultraThinMaterial)
                .frame(height: 200)
                .shimmer()
            HStack(spacing: 12) {
                ForEach(0..<3, id: \.self) { _ in
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(.ultraThinMaterial)
                        .frame(height: 90)
                        .shimmer()
                }
            }
        }
    }

    // MARK: - Helpers

    private var formattedWords: String {
        let words = viewModel.currentStreak?.totalWordsInStreak ?? 0
        if words >= 1_000 {
            return String(format: "%.1fK", Double(words) / 1_000)
        }
        return "\(words)"
    }

    private var streakStartLabel: String {
        guard let date = viewModel.currentStreak?.streakStartDate else { return "—" }
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: date)
    }
}

#Preview {
    StreakView()
        .preferredColorScheme(.dark)
}
