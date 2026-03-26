import SwiftUI

struct SettingsView: View {

    @State private var viewModel = SettingsViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                Color.ghostBackground.ignoresSafeArea()

                List {
                    profileSection
                    preferencesSection
                    accessibilitySection
                    subscriptionSection
                    integrationsSection
                    aboutSection
                    accountSection
                }
                .scrollContentBackground(.hidden)
                .listStyle(.insetGrouped)
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .alert("Delete Account", isPresented: $viewModel.showDeleteConfirmation) {
                Button("Cancel", role: .cancel) {}
                Button("Delete", role: .destructive) {
                    Task { try? await viewModel.deleteAccount() }
                }
            } message: {
                Text("This action is permanent and cannot be undone. All your data will be deleted.")
            }
            .sheet(isPresented: $viewModel.showExportSheet) {
                if let url = viewModel.exportedURL {
                    ShareSheet(items: [url])
                }
            }
        }
    }

    // MARK: - Profile

    private var profileSection: some View {
        Section {
            HStack(spacing: 14) {
                Circle()
                    .fill(.ultraThinMaterial)
                    .frame(width: 56, height: 56)
                    .overlay(
                        Text(String(viewModel.username.prefix(1)).uppercased())
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundStyle(.ghostCyan)
                    )
                    .overlay(
                        Circle().stroke(Color.ghostCyan.opacity(0.4), lineWidth: 2)
                    )

                VStack(alignment: .leading, spacing: 4) {
                    TextField("Username", text: $viewModel.username)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.ghostText)

                    Text("Edit your profile")
                        .font(.system(size: 13))
                        .foregroundStyle(.ghostText.opacity(0.5))
                }
            }
            .listRowBackground(Color.white.opacity(0.04))
        } header: {
            Text("Profile")
                .foregroundStyle(.ghostText.opacity(0.5))
        }
    }

    // MARK: - Preferences

    private var preferencesSection: some View {
        Section {
            Toggle(isOn: $viewModel.enableHaptics) {
                Label("Haptic Feedback", systemImage: "hand.tap.fill")
                    .foregroundStyle(.ghostText)
            }
            .tint(.ghostCyan)

            NavigationLink {
                NotificationSettingsView()
            } label: {
                Label("Notifications", systemImage: "bell.fill")
                    .foregroundStyle(.ghostText)
            }

            Toggle(isOn: $viewModel.darkModeEnabled) {
                Label("Dark Mode", systemImage: "moon.fill")
                    .foregroundStyle(.ghostText)
            }
            .tint(.ghostCyan)
        } header: {
            Text("Preferences")
                .foregroundStyle(.ghostText.opacity(0.5))
        }
        .listRowBackground(Color.white.opacity(0.04))
    }

    // MARK: - Accessibility

    private var accessibilitySection: some View {
        Section {
            Toggle(isOn: $viewModel.dyslexiaFontEnabled) {
                Label("Dyslexia-Friendly Font", systemImage: "textformat.abc")
                    .foregroundStyle(.ghostText)
            }
            .tint(.ghostCyan)

            Toggle(isOn: $viewModel.highContrastEnabled) {
                Label("High Contrast", systemImage: "circle.lefthalf.filled")
                    .foregroundStyle(.ghostText)
            }
            .tint(.ghostCyan)

            VStack(alignment: .leading, spacing: 8) {
                Label("Text Size", systemImage: "textformat.size")
                    .foregroundStyle(.ghostText)

                HStack {
                    Text("A")
                        .font(.system(size: 12))
                        .foregroundStyle(.ghostText.opacity(0.5))
                    Slider(value: $viewModel.textSize, in: 0.8...1.5, step: 0.1)
                        .tint(.ghostCyan)
                    Text("A")
                        .font(.system(size: 20))
                        .foregroundStyle(.ghostText.opacity(0.5))
                }

                Text("Preview: \(String(format: "%.0f%%", viewModel.textSize * 100))")
                    .font(.system(size: 13 * viewModel.textSize))
                    .foregroundStyle(.ghostText.opacity(0.6))
            }

            Toggle(isOn: $viewModel.voiceFirstMode) {
                Label("Voice-First Mode", systemImage: "mic.fill")
                    .foregroundStyle(.ghostText)
            }
            .tint(.ghostCyan)
        } header: {
            Text("Accessibility")
                .foregroundStyle(.ghostText.opacity(0.5))
        }
        .listRowBackground(Color.white.opacity(0.04))
    }

    // MARK: - Subscription

    private var subscriptionSection: some View {
        Section {
            NavigationLink {
                SubscriptionView()
            } label: {
                HStack {
                    Label("Current Plan", systemImage: "crown.fill")
                        .foregroundStyle(.ghostText)
                    Spacer()
                    Text(viewModel.currentTier.displayName)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.ghostGold)
                }
            }
        } header: {
            Text("Subscription")
                .foregroundStyle(.ghostText.opacity(0.5))
        }
        .listRowBackground(Color.white.opacity(0.04))
    }

    // MARK: - Integrations

    private var integrationsSection: some View {
        Section {
            integrationRow(name: "Notion", icon: "doc.text.fill", connected: false)
            integrationRow(name: "GitHub", icon: "chevron.left.forwardslash.chevron.right", connected: false)
            integrationRow(name: "Figma", icon: "pencil.and.ruler.fill", connected: false)
        } header: {
            Text("Integrations")
                .foregroundStyle(.ghostText.opacity(0.5))
        }
        .listRowBackground(Color.white.opacity(0.04))
    }

    private func integrationRow(name: String, icon: String, connected: Bool) -> some View {
        HStack {
            Label(name, systemImage: icon)
                .foregroundStyle(.ghostText)
            Spacer()
            Text(connected ? "Connected" : "Connect")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(connected ? .ghostEmerald : .ghostCyan)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(
                    Capsule().fill(
                        connected
                            ? Color.ghostEmerald.opacity(0.15)
                            : Color.ghostCyan.opacity(0.15)
                    )
                )
        }
    }

    // MARK: - About

    private var aboutSection: some View {
        Section {
            HStack {
                Label("Version", systemImage: "info.circle.fill")
                    .foregroundStyle(.ghostText)
                Spacer()
                Text(viewModel.appVersion)
                    .font(.system(size: 14))
                    .foregroundStyle(.ghostText.opacity(0.5))
            }

            HStack {
                Label("Support", systemImage: "envelope.fill")
                    .foregroundStyle(.ghostText)
                Spacer()
                Text(AppConstants.supportEmail)
                    .font(.system(size: 13))
                    .foregroundStyle(.ghostCyan)
            }

            NavigationLink {
                PrivacySettingsView()
            } label: {
                Label("Privacy Settings", systemImage: "lock.shield.fill")
                    .foregroundStyle(.ghostText)
            }

            Link(destination: URL(string: "https://ghostwriter.app/privacy")!) {
                Label("Privacy Policy", systemImage: "hand.raised.fill")
                    .foregroundStyle(.ghostText)
            }

            Link(destination: URL(string: "https://ghostwriter.app/terms")!) {
                Label("Terms of Service", systemImage: "doc.text.fill")
                    .foregroundStyle(.ghostText)
            }
        } header: {
            Text("About")
                .foregroundStyle(.ghostText.opacity(0.5))
        }
        .listRowBackground(Color.white.opacity(0.04))
    }

    // MARK: - Account

    private var accountSection: some View {
        Section {
            Button {
                Task {
                    if let url = try? await viewModel.exportData() {
                        viewModel.exportedURL = url
                        viewModel.showExportSheet = true
                    }
                }
            } label: {
                Label {
                    Text(viewModel.isExporting ? "Exporting..." : "Export My Data")
                        .foregroundStyle(.ghostText)
                } icon: {
                    if viewModel.isExporting {
                        ProgressView()
                            .scaleEffect(0.8)
                    } else {
                        Image(systemName: "square.and.arrow.up.fill")
                    }
                }
            }
            .disabled(viewModel.isExporting)

            Button(role: .destructive) {
                viewModel.showDeleteConfirmation = true
            } label: {
                Label("Delete Account", systemImage: "trash.fill")
                    .foregroundStyle(.red)
            }
        } header: {
            Text("Account")
                .foregroundStyle(.ghostText.opacity(0.5))
        }
        .listRowBackground(Color.white.opacity(0.04))
    }
}

// MARK: - ShareSheet

private struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    SettingsView()
        .preferredColorScheme(.dark)
}
