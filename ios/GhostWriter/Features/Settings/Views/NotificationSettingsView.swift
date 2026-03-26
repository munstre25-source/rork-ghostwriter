import SwiftUI

struct NotificationSettingsView: View {

    @AppStorage("notif_push_enabled") private var pushEnabled = true
    @AppStorage("notif_streak_reminders") private var streakReminders = true
    @AppStorage("notif_session_suggestions") private var sessionSuggestions = true
    @AppStorage("notif_friend_activity") private var friendActivity = false
    @AppStorage("notif_earnings") private var earningsNotifications = true
    @AppStorage("notif_challenges") private var challengeNotifications = true

    var body: some View {
        ZStack {
            Color.ghostBackground.ignoresSafeArea()

            List {
                Section {
                    Toggle(isOn: $pushEnabled) {
                        Label("Push Notifications", systemImage: "bell.fill")
                            .foregroundStyle(.ghostText)
                    }
                    .tint(.ghostCyan)
                } header: {
                    Text("General")
                        .foregroundStyle(.ghostText.opacity(0.5))
                } footer: {
                    Text("Enable push notifications to stay updated on your creative journey.")
                        .foregroundStyle(.ghostText.opacity(0.3))
                }
                .listRowBackground(Color.white.opacity(0.04))

                Section {
                    Toggle(isOn: $streakReminders) {
                        Label("Streak Reminders", systemImage: "flame.fill")
                            .foregroundStyle(.ghostText)
                    }
                    .tint(.ghostCyan)
                    .disabled(!pushEnabled)

                    Toggle(isOn: $sessionSuggestions) {
                        Label("Session Suggestions", systemImage: "lightbulb.fill")
                            .foregroundStyle(.ghostText)
                    }
                    .tint(.ghostCyan)
                    .disabled(!pushEnabled)

                    Toggle(isOn: $challengeNotifications) {
                        Label("Challenge Updates", systemImage: "trophy.fill")
                            .foregroundStyle(.ghostText)
                    }
                    .tint(.ghostCyan)
                    .disabled(!pushEnabled)
                } header: {
                    Text("Creative")
                        .foregroundStyle(.ghostText.opacity(0.5))
                } footer: {
                    Text("Get reminded to maintain your streak and discover new writing prompts.")
                        .foregroundStyle(.ghostText.opacity(0.3))
                }
                .listRowBackground(Color.white.opacity(0.04))

                Section {
                    Toggle(isOn: $friendActivity) {
                        Label("Friend Activity", systemImage: "person.2.fill")
                            .foregroundStyle(.ghostText)
                    }
                    .tint(.ghostCyan)
                    .disabled(!pushEnabled)
                } header: {
                    Text("Social")
                        .foregroundStyle(.ghostText.opacity(0.5))
                }
                .listRowBackground(Color.white.opacity(0.04))

                Section {
                    Toggle(isOn: $earningsNotifications) {
                        Label("Earnings Updates", systemImage: "dollarsign.circle.fill")
                            .foregroundStyle(.ghostText)
                    }
                    .tint(.ghostCyan)
                    .disabled(!pushEnabled)
                } header: {
                    Text("Monetization")
                        .foregroundStyle(.ghostText.opacity(0.5))
                } footer: {
                    Text("Receive notifications when you earn revenue or a payout is processed.")
                        .foregroundStyle(.ghostText.opacity(0.3))
                }
                .listRowBackground(Color.white.opacity(0.04))
            }
            .scrollContentBackground(.hidden)
            .listStyle(.insetGrouped)
        }
        .navigationTitle("Notifications")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }
}

#Preview {
    NavigationStack {
        NotificationSettingsView()
    }
    .preferredColorScheme(.dark)
}
