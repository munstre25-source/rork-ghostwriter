import SwiftUI
import SwiftData

@main
struct GhostWriterApp: App {
    let coreMLService = CoreMLService()
    let audioService = AudioService()
    let hapticService = HapticService()
    let analyticsService = AnalyticsService()
    let errorHandler = ErrorHandler()
    let profileService = ProfileService()
    let clipService = ClipService()
    let personalityService = PersonalityService()
    let discoveryService = DiscoveryService()
    let creatorAnalyticsService = CreatorAnalyticsService()
    let paymentService = PaymentService()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(coreMLService)
                .environment(audioService)
                .environment(hapticService)
                .environment(analyticsService)
                .environment(errorHandler)
                .environment(profileService)
                .environment(clipService)
                .environment(personalityService)
                .environment(discoveryService)
                .environment(creatorAnalyticsService)
                .environment(paymentService)
                .preferredColorScheme(.dark)
        }
        .modelContainer(for: [
            CreativeSession.self,
            GhostPersonality.self,
            GhostSuggestion.self,
            GhostClip.self,
            CreatorProfile.self,
            CreativeStreak.self,
            WeeklyChallenge.self,
            UserAnalytics.self,
            LiveJamSession.self,
            CreatorEarnings.self
        ])
    }
}

struct RootView: View {
    @AppStorage("onboardingComplete") private var onboardingComplete = false

    var body: some View {
        if onboardingComplete {
            ContentView()
        } else {
            OnboardingView()
        }
    }
}
