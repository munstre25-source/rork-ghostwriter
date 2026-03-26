import SwiftUI
import SwiftData

// MARK: - Navigation

enum AppDestination: Hashable {
    case creativeSession(sessionId: UUID)
    case personalityEditor(personalityId: UUID?)
    case creatorProfile(userId: UUID)
    case ghostClipEditor(clipId: UUID)
    case leaderboard
    case personalityMarketplace
    case subscriptionView
    case weeklyChallenge(challengeId: UUID)
}

@Observable
final class NavigationCoordinator: @unchecked Sendable {
    var path = NavigationPath()

    func navigate(to destination: AppDestination) {
        path.append(destination)
    }

    func popToRoot() {
        path.removeLast(path.count)
    }

    func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }
}

// MARK: - Content View

struct ContentView: View {
    @State private var coordinator = NavigationCoordinator()
    @State private var selectedTab = 0

    var body: some View {
        NavigationStack(path: $coordinator.path) {
            TabView(selection: $selectedTab) {
                Tab("Live", systemImage: "sparkles", value: 0) {
                    CreativeSessionView()
                }

                Tab("Discover", systemImage: "globe", value: 1) {
                    DiscoverView()
                }

                Tab("Clips", systemImage: "play.rectangle.fill", value: 2) {
                    GhostClipsListView()
                }

                Tab("Creator", systemImage: "person.circle.fill", value: 3) {
                    CreatorProfileView()
                }

                Tab("Settings", systemImage: "gearshape.fill", value: 4) {
                    SettingsView()
                }
            }
            .tint(Color.ghostCyan)
            .navigationDestination(for: AppDestination.self) { destination in
                navigationView(for: destination)
            }
        }
        .environment(coordinator)
    }

    @ViewBuilder
    private func navigationView(for destination: AppDestination) -> some View {
        switch destination {
        case .creativeSession(let sessionId):
            CreativeSessionDetailView(sessionId: sessionId)
        case .personalityEditor(let personalityId):
            PersonalityEditorView(personalityId: personalityId)
        case .creatorProfile(let userId):
            CreatorProfileView(userId: userId)
        case .ghostClipEditor(let clipId):
            GhostClipEditorView(clipId: clipId)
        case .leaderboard:
            LeaderboardView()
        case .personalityMarketplace:
            PersonalityMarketplaceView()
        case .subscriptionView:
            SubscriptionView()
        case .weeklyChallenge(let challengeId):
            WeeklyChallengeDetailView(challengeId: challengeId)
        }
    }
}

// MARK: - Session Detail View

struct CreativeSessionDetailView: View {
    let sessionId: UUID

    @Query private var sessions: [CreativeSession]
    @Query private var suggestions: [GhostSuggestion]
    @Environment(\.dismiss) private var dismiss

    private var session: CreativeSession? {
        sessions.first { $0.id == sessionId }
    }

    private var sessionSuggestions: [GhostSuggestion] {
        suggestions.filter { $0.sessionId == sessionId }
            .sorted { $0.timestamp > $1.timestamp }
    }

    var body: some View {
        ZStack {
            Color.ghostBackground.ignoresSafeArea()

            if let session {
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        sessionHeaderSection(session)
                        metricsSection(session)
                        inputLogSection(session)
                        suggestionsSection
                    }
                    .padding()
                    .padding(.bottom, 32)
                }
            } else {
                ErrorView(
                    icon: "doc.questionmark",
                    message: "Session not found."
                )
            }
        }
        .navigationTitle(session?.title ?? "Session Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }

    private func sessionHeaderSection(_ session: CreativeSession) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: session.type.icon)
                        .font(.system(size: 14, weight: .semibold))
                    Text(session.type.displayName)
                        .font(.system(size: 14, weight: .semibold))
                }
                .foregroundStyle(Color.ghostCyan)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.ghostCyan.opacity(0.15))
                .clipShape(Capsule())

                Spacer()

                if session.isLive {
                    HStack(spacing: 5) {
                        Circle().fill(Color.ghostEmerald).frame(width: 7, height: 7)
                        Text("Live").font(.system(size: 12, weight: .bold))
                    }
                    .foregroundStyle(Color.ghostEmerald)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color.ghostEmerald.opacity(0.15))
                    .clipShape(Capsule())
                }
            }

            if let title = session.title {
                Text(title)
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.ghostText)
            }

            HStack(spacing: 16) {
                Label(session.startTime.formatted(date: .abbreviated, time: .shortened),
                      systemImage: "clock")
                if let endTime = session.endTime {
                    Label(formatDuration(from: session.startTime, to: endTime),
                          systemImage: "timer")
                }
            }
            .font(.system(size: 13))
            .foregroundStyle(Color.ghostText.opacity(0.6))
        }
    }

    private func metricsSection(_ session: CreativeSession) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("METRICS")
                .font(.system(size: 11, weight: .bold, design: .monospaced))
                .foregroundStyle(Color.ghostText.opacity(0.4))

            LazyVGrid(columns: [
                GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())
            ], spacing: 12) {
                metricTile(value: "\(session.wordCount)", label: "Words", icon: "text.word.spacing", color: .ghostCyan)
                metricTile(value: "\(session.ideaCount)", label: "Ideas", icon: "lightbulb.fill", color: .ghostGold)
                metricTile(value: "\(Int(session.flowScore))%", label: "Flow", icon: "flame.fill", color: session.flowScore > 70 ? .ghostMagenta : .ghostCyan)
            }
        }
    }

    private func metricTile(value: String, label: String, icon: String, color: Color) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundStyle(color)
            Text(value)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(Color.ghostText)
            Text(label)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(Color.ghostText.opacity(0.5))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .strokeBorder(color.opacity(0.15), lineWidth: 1)
        )
    }

    private func inputLogSection(_ session: CreativeSession) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("SESSION TEXT")
                .font(.system(size: 11, weight: .bold, design: .monospaced))
                .foregroundStyle(Color.ghostText.opacity(0.4))

            let fullText = session.rawInputLog.joined()
            if fullText.isEmpty {
                Text("No text recorded.")
                    .font(.system(size: 14))
                    .foregroundStyle(Color.ghostText.opacity(0.4))
                    .italic()
            } else {
                Text(fullText)
                    .font(.system(size: 15, weight: .regular, design: .serif))
                    .foregroundStyle(Color.ghostText.opacity(0.85))
                    .lineSpacing(4)
                    .padding(16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
        }
    }

    private var suggestionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("SUGGESTIONS (\(sessionSuggestions.count))")
                .font(.system(size: 11, weight: .bold, design: .monospaced))
                .foregroundStyle(Color.ghostText.opacity(0.4))

            if sessionSuggestions.isEmpty {
                Text("No suggestions generated.")
                    .font(.system(size: 14))
                    .foregroundStyle(Color.ghostText.opacity(0.4))
                    .italic()
            } else {
                ForEach(sessionSuggestions) { suggestion in
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(suggestion.type.displayName.uppercased())
                                .font(.system(size: 10, weight: .bold, design: .monospaced))
                                .foregroundStyle(colorForSuggestionType(suggestion.type))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(colorForSuggestionType(suggestion.type).opacity(0.15))
                                .clipShape(Capsule())

                            Spacer()

                            Text("\(Int(suggestion.confidenceScore * 100))%")
                                .font(.system(size: 12, weight: .semibold, design: .monospaced))
                                .foregroundStyle(Color.ghostText.opacity(0.6))

                            if let accepted = suggestion.accepted {
                                Image(systemName: accepted ? "checkmark.circle.fill" : "xmark.circle.fill")
                                    .font(.system(size: 14))
                                    .foregroundStyle(accepted ? Color.ghostEmerald : Color.ghostMagenta)
                            }
                        }

                        Text(suggestion.content)
                            .font(.system(size: 14))
                            .foregroundStyle(Color.ghostText.opacity(0.8))
                            .lineSpacing(2)
                    }
                    .padding(12)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                }
            }
        }
    }

    private func colorForSuggestionType(_ type: SuggestionType) -> Color {
        switch type {
        case .continuation: .ghostCyan
        case .challenge:    .ghostMagenta
        case .summary:      .ghostGold
        case .reframe:      .ghostEmerald
        case .expand:       .ghostCyan
        }
    }

    private func formatDuration(from start: Date, to end: Date) -> String {
        let seconds = Int(end.timeIntervalSince(start))
        let minutes = seconds / 60
        if minutes < 60 {
            return "\(minutes)m"
        }
        return "\(minutes / 60)h \(minutes % 60)m"
    }
}

// MARK: - Weekly Challenge Detail View

struct WeeklyChallengeDetailView: View {
    let challengeId: UUID

    @Query private var challenges: [WeeklyChallenge]
    @Environment(\.dismiss) private var dismiss

    private var challenge: WeeklyChallenge? {
        challenges.first { $0.id == challengeId }
    }

    var body: some View {
        ZStack {
            Color.ghostBackground.ignoresSafeArea()

            if let challenge {
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        challengeHeader(challenge)
                        targetsSection(challenge)
                        participantsSection(challenge)
                        statusSection(challenge)
                    }
                    .padding()
                    .padding(.bottom, 32)
                }
            } else {
                ErrorView(
                    icon: "trophy.fill",
                    message: "Challenge not found."
                )
            }
        }
        .navigationTitle("Challenge")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }

    private func challengeHeader(_ challenge: WeeklyChallenge) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "trophy.fill")
                    .font(.system(size: 28))
                    .foregroundStyle(
                        .linearGradient(
                            colors: [.ghostGold, .orange],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                Spacer()

                if challenge.isActive {
                    Text("ACTIVE")
                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                        .foregroundStyle(Color.ghostEmerald)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color.ghostEmerald.opacity(0.15))
                        .clipShape(Capsule())
                } else {
                    Text("ENDED")
                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                        .foregroundStyle(Color.ghostText.opacity(0.5))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color.white.opacity(0.06))
                        .clipShape(Capsule())
                }
            }

            Text(challenge.title)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundStyle(Color.ghostText)

            Text(challenge.challengeDescription)
                .font(.system(size: 15))
                .foregroundStyle(Color.ghostText.opacity(0.7))
                .lineSpacing(3)

            HStack(spacing: 16) {
                Label(challenge.startDate.formatted(date: .abbreviated, time: .omitted),
                      systemImage: "calendar")
                Text("→")
                Label(challenge.endDate.formatted(date: .abbreviated, time: .omitted),
                      systemImage: "flag.checkered")
            }
            .font(.system(size: 13))
            .foregroundStyle(Color.ghostText.opacity(0.5))
        }
    }

    private func targetsSection(_ challenge: WeeklyChallenge) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("TARGETS")
                .font(.system(size: 11, weight: .bold, design: .monospaced))
                .foregroundStyle(Color.ghostText.opacity(0.4))

            HStack(spacing: 12) {
                if let wordTarget = challenge.targetWordCount {
                    targetCard(value: "\(wordTarget)", label: "Words", icon: "text.word.spacing", color: .ghostCyan)
                }
                if let sessionTarget = challenge.targetSessionCount {
                    targetCard(value: "\(sessionTarget)", label: "Sessions", icon: "clock.fill", color: .ghostMagenta)
                }
                if let amount = challenge.sponsorAmount {
                    targetCard(value: "$\(Int(amount))", label: "Prize Pool", icon: "dollarsign.circle.fill", color: .ghostGold)
                }
            }
        }
    }

    private func targetCard(value: String, label: String, icon: String, color: Color) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundStyle(color)
            Text(value)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(Color.ghostText)
            Text(label)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(Color.ghostText.opacity(0.5))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .strokeBorder(color.opacity(0.15), lineWidth: 1)
        )
    }

    private func participantsSection(_ challenge: WeeklyChallenge) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("PARTICIPANTS")
                .font(.system(size: 11, weight: .bold, design: .monospaced))
                .foregroundStyle(Color.ghostText.opacity(0.4))

            HStack(spacing: 12) {
                Image(systemName: "person.3.fill")
                    .font(.system(size: 20))
                    .foregroundStyle(Color.ghostCyan)

                Text("\(challenge.participantCount) creators joined")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(Color.ghostText)

                Spacer()
            }
            .padding(16)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
    }

    private func statusSection(_ challenge: WeeklyChallenge) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            if challenge.isActive {
                Button {
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 16))
                        Text("Join Challenge")
                            .font(.system(size: 17, weight: .bold))
                    }
                    .foregroundStyle(Color.ghostBackground)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.ghostGold)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
            }

            if challenge.personalityRequired != nil {
                HStack(spacing: 8) {
                    Image(systemName: "person.crop.circle.badge.checkmark")
                        .foregroundStyle(Color.ghostMagenta)
                    Text("Requires a specific personality")
                        .font(.system(size: 13))
                        .foregroundStyle(Color.ghostText.opacity(0.6))
                }
            }
        }
    }
}

#Preview {
    ContentView()
        .environment(CoreMLService())
        .environment(AudioService())
        .environment(HapticService())
        .environment(AnalyticsService())
        .environment(ErrorHandler())
        .environment(ProfileService())
        .environment(ClipService())
        .environment(PersonalityService())
        .environment(DiscoveryService())
        .environment(CreatorAnalyticsService())
        .environment(PaymentService())
        .environment(SubscriptionService())
}
