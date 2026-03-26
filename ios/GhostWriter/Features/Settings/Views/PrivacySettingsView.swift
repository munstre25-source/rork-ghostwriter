import SwiftUI

struct PrivacySettingsView: View {

    @AppStorage("privacy_cloud_sync") private var cloudSync = true
    @AppStorage("privacy_public_profile") private var publicProfile = false
    @AppStorage("privacy_session_visibility") private var sessionVisibility = "private"
    @AppStorage("privacy_data_sharing") private var dataSharing = false
    @State private var showDeleteAlert = false

    private let visibilityOptions = ["public", "private"]

    var body: some View {
        ZStack {
            Color.ghostBackground.ignoresSafeArea()

            List {
                Section {
                    Toggle(isOn: $cloudSync) {
                        Label("Cloud Sync", systemImage: "icloud.fill")
                            .foregroundStyle(.ghostText)
                    }
                    .tint(.ghostCyan)
                } header: {
                    Text("Storage")
                        .foregroundStyle(.ghostText.opacity(0.5))
                } footer: {
                    Text("Sync your sessions and preferences across devices using iCloud.")
                        .foregroundStyle(.ghostText.opacity(0.3))
                }
                .listRowBackground(Color.white.opacity(0.04))

                Section {
                    Toggle(isOn: $publicProfile) {
                        Label("Public Profile", systemImage: "person.crop.circle.fill")
                            .foregroundStyle(.ghostText)
                    }
                    .tint(.ghostCyan)

                    Picker(selection: $sessionVisibility) {
                        ForEach(visibilityOptions, id: \.self) { option in
                            Text(option.capitalized)
                                .tag(option)
                        }
                    } label: {
                        Label("Default Session Visibility", systemImage: "eye.fill")
                            .foregroundStyle(.ghostText)
                    }
                    .tint(.ghostCyan)
                } header: {
                    Text("Visibility")
                        .foregroundStyle(.ghostText.opacity(0.5))
                }
                .listRowBackground(Color.white.opacity(0.04))

                Section {
                    Toggle(isOn: $dataSharing) {
                        Label("Share Usage Data", systemImage: "chart.bar.fill")
                            .foregroundStyle(.ghostText)
                    }
                    .tint(.ghostCyan)
                } header: {
                    Text("Data Sharing")
                        .foregroundStyle(.ghostText.opacity(0.5))
                } footer: {
                    Text("Anonymous usage data helps us improve the app experience. No personal content is shared.")
                        .foregroundStyle(.ghostText.opacity(0.3))
                }
                .listRowBackground(Color.white.opacity(0.04))

                Section {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack(spacing: 10) {
                            Image(systemName: "lock.shield.fill")
                                .font(.system(size: 24))
                                .foregroundStyle(.ghostEmerald)
                            Text("Your Data Stays on Device")
                                .font(.system(size: 15, weight: .bold))
                                .foregroundStyle(.ghostText)
                        }

                        Text("Your creative sessions, drafts, and personal content are stored locally on your device by default. Cloud sync is optional and end-to-end encrypted. We never train AI models on your personal writing.")
                            .font(.system(size: 13))
                            .foregroundStyle(.ghostText.opacity(0.7))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(.vertical, 8)
                }
                .listRowBackground(Color.ghostEmerald.opacity(0.06))

                Section {
                    Button(role: .destructive) {
                        showDeleteAlert = true
                    } label: {
                        Label("Delete All Local Data", systemImage: "trash.fill")
                            .foregroundStyle(.red)
                    }
                } footer: {
                    Text("This will permanently delete all locally stored sessions, preferences, and cached data.")
                        .foregroundStyle(.ghostText.opacity(0.3))
                }
                .listRowBackground(Color.white.opacity(0.04))
            }
            .scrollContentBackground(.hidden)
            .listStyle(.insetGrouped)
        }
        .navigationTitle("Privacy")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .alert("Delete All Data", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Delete Everything", role: .destructive) {
                cloudSync = true
                publicProfile = false
                sessionVisibility = "private"
                dataSharing = false
            }
        } message: {
            Text("This cannot be undone. All local sessions, preferences, and cached data will be permanently removed.")
        }
    }
}

#Preview {
    NavigationStack {
        PrivacySettingsView()
    }
    .preferredColorScheme(.dark)
}
