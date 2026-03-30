import SwiftUI

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

// MARK: - Placeholder Detail Views

struct CreativeSessionDetailView: View {
    let sessionId: UUID
    var body: some View {
        Text("Session Detail: \(sessionId.uuidString.prefix(8))")
            .foregroundColor(.ghostText)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.ghostBackground)
    }
}

struct WeeklyChallengeDetailView: View {
    let challengeId: UUID
    var body: some View {
        Text("Challenge: \(challengeId.uuidString.prefix(8))")
            .foregroundColor(.ghostText)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.ghostBackground)
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
}
