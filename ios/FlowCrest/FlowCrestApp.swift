import SwiftUI
import SwiftData

@main
struct FlowCrestApp: App {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            FocusBlock.self,
            BioMetricSample.self,
            FocusScore.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    init() {
        BackgroundScheduler.shared.registerTasks()
    }

    var body: some Scene {
        WindowGroup {
            RootView(hasCompletedOnboarding: $hasCompletedOnboarding)
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)) { _ in
                    BackgroundScheduler.shared.scheduleAppRefresh()
                    BackgroundScheduler.shared.scheduleProcessingTask()
                }
        }
        .modelContainer(sharedModelContainer)
    }
}

struct RootView: View {
    @Binding var hasCompletedOnboarding: Bool
    @State private var healthService = HealthKitService()
    @State private var eventKitService = EventKitService()

    var body: some View {
        if hasCompletedOnboarding {
            ContentView()
        } else {
            OnboardingView(
                healthService: healthService,
                eventKitService: eventKitService,
                onComplete: {
                    withAnimation(.smooth(duration: 0.5)) {
                        hasCompletedOnboarding = true
                    }
                }
            )
        }
    }
}
