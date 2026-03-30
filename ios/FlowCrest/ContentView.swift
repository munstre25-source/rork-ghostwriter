import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var healthService = HealthKitService()
    @State private var eventKitService = EventKitService()
    @State private var engine = BioAdaptiveEngine()
    @State private var featureFlags = FeatureFlags.shared
    @State private var scheduleViewModel = ScheduleViewModel()
    @State private var selectedTab = 0

    private var dashboardViewModel: DashboardViewModel {
        DashboardViewModel(
            healthService: healthService,
            eventKitService: eventKitService,
            engine: engine,
            featureFlags: featureFlags
        )
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("Dashboard", systemImage: "brain.head.profile.fill", value: 0) {
                NavigationStack {
                    DashboardView(viewModel: dashboardViewModel)
                }
            }

            Tab("Schedule", systemImage: "calendar", value: 1) {
                NavigationStack {
                    ScheduleView(viewModel: scheduleViewModel)
                }
            }

            Tab("Insights", systemImage: "chart.xyaxis.line", value: 2) {
                NavigationStack {
                    InsightsView()
                }
            }

            Tab("Settings", systemImage: "gearshape.fill", value: 3) {
                NavigationStack {
                    SettingsView(
                        healthService: healthService,
                        eventKitService: eventKitService
                    )
                }
            }
        }
    }
}
