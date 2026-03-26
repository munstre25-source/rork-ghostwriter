import SwiftUI
import HealthKit
import EventKit
import StoreKit

struct SettingsView: View {
    let healthService: HealthKitService
    let eventKitService: EventKitService
    @State private var featureFlags = FeatureFlags.shared
    @State private var subscriptionManager = SubscriptionManager.shared
    @State private var showPaywall = false
    @State private var showManageSubscription = false

    var body: some View {
        Form {
            subscriptionSection

            Section {
                permissionRow(
                    title: "HealthKit",
                    icon: "heart.fill",
                    color: .pink,
                    status: healthPermissionStatus,
                    action: { Task { await healthService.requestAuthorization() } }
                )
                permissionRow(
                    title: "Calendar",
                    icon: "calendar",
                    color: .red,
                    status: calendarPermissionStatus,
                    action: { Task { await eventKitService.requestAuthorization() } }
                )
            } header: {
                Text("Permissions")
            } footer: {
                Text("All data is processed on-device. Nothing is uploaded or shared.")
            }

            Section("Bio-Adaptive Engine") {
                Toggle("Bio-Adaptive Scheduling", isOn: Binding(
                    get: { featureFlags.isBioAdaptiveEnabled },
                    set: { featureFlags.isBioAdaptiveEnabled = $0 }
                ))
                Toggle("Auto-Reschedule Suggestions", isOn: Binding(
                    get: { featureFlags.isAutoRescheduleEnabled },
                    set: { featureFlags.isAutoRescheduleEnabled = $0 }
                ))
                Toggle("Calendar Sync", isOn: Binding(
                    get: { featureFlags.isCalendarSyncEnabled },
                    set: { featureFlags.isCalendarSyncEnabled = $0 }
                ))
                Toggle("Model Personalization", isOn: Binding(
                    get: { featureFlags.isPersonalizationEnabled },
                    set: { featureFlags.isPersonalizationEnabled = $0 }
                ))
            }

            Section("Thresholds") {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Deep Work Threshold")
                        Spacer()
                        Text("\(Int(featureFlags.deepWorkThreshold))")
                            .foregroundStyle(.secondary)
                            .monospacedDigit()
                    }
                    Slider(
                        value: Binding(
                            get: { featureFlags.deepWorkThreshold },
                            set: { featureFlags.deepWorkThreshold = $0 }
                        ),
                        in: 30...90,
                        step: 5
                    )
                    .tint(.teal)
                }
            }

            Section("Data") {
                Button("Purge Old Data") {
                    Task {
                        await DataLifecycleManager.shared.purgeOldSamples()
                        await DataLifecycleManager.shared.purgeOldFocusBlocks()
                    }
                }
            }

            Section("Legal") {
                Link(destination: URL(string: "https://socialreporthq.com/flowcrest/privacy")!) {
                    Label("Privacy Policy", systemImage: "hand.raised.fill")
                }
                Link(destination: URL(string: "https://socialreporthq.com/flowcrest/terms")!) {
                    Label("Terms of Use", systemImage: "doc.text.fill")
                }
                Link(destination: URL(string: "mailto:support@socialreporthq.com")!) {
                    Label("Contact Support", systemImage: "envelope.fill")
                }
            }

            Section("About") {
                LabeledContent("Version", value: "1.0.0")
                LabeledContent("Data Storage", value: "On-Device Only")
                LabeledContent("Privacy", value: "No Accounts Required")
            }
        }
        .navigationTitle("Settings")
        .sheet(isPresented: $showPaywall) {
            PaywallView()
        }
        .manageSubscriptionsSheet(isPresented: $showManageSubscription)
    }

    @ViewBuilder
    private var subscriptionSection: some View {
        Section {
            if subscriptionManager.isPremium {
                HStack(spacing: 14) {
                    Image(systemName: "crown.fill")
                        .font(.title2)
                        .foregroundStyle(
                            LinearGradient(colors: [.orange, .purple], startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Premium Active")
                            .font(.headline)
                        Text(subscriptionPlanName)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                }

                Button("Manage Subscription") {
                    showManageSubscription = true
                }
            } else {
                HStack(spacing: 14) {
                    Image(systemName: "sparkles")
                        .font(.title2)
                        .foregroundStyle(.orange)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Upgrade to Premium")
                            .font(.headline)
                        Text("Unlock unlimited bio-adaptive scheduling")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                }

                Button {
                    showPaywall = true
                } label: {
                    Text("View Plans")
                        .font(.subheadline.weight(.semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                }
                .buttonStyle(.borderedProminent)
                .tint(.orange)
                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 12, trailing: 16))
            }
        } header: {
            Text("Subscription")
        }
    }

    private var subscriptionPlanName: String {
        if subscriptionManager.currentSubscriptionProductID?.contains("yearly") == true {
            return "Annual Plan"
        } else if subscriptionManager.currentSubscriptionProductID?.contains("monthly") == true {
            return "Monthly Plan"
        }
        return "Active"
    }

    private func permissionRow(title: String, icon: String, color: Color, status: String, action: @escaping () -> Void) -> some View {
        HStack {
            Label(title, systemImage: icon)
                .foregroundStyle(color)
            Spacer()
            if status == "Granted" {
                Label("Enabled", systemImage: "checkmark.circle.fill")
                    .font(.caption)
                    .foregroundStyle(.green)
                    .labelStyle(.titleAndIcon)
            } else {
                Button(status == "Not Determined" ? "Enable" : status) {
                    action()
                }
                .font(.caption)
                .buttonStyle(.bordered)
                .disabled(status == "Denied")
            }
        }
    }

    private var healthPermissionStatus: String {
        if !healthService.isAvailable { return "Unavailable" }
        switch healthService.authorizationStatus {
        case .sharingAuthorized: return "Granted"
        case .sharingDenied: return "Denied"
        default: return "Not Determined"
        }
    }

    private var calendarPermissionStatus: String {
        switch eventKitService.authorizationStatus {
        case .fullAccess: return "Granted"
        case .denied, .restricted: return "Denied"
        default: return "Not Determined"
        }
    }
}
