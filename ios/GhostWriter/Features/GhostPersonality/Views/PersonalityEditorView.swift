import SwiftUI

/// Full-screen form to create or edit a ``GhostPersonality``.
struct PersonalityEditorView: View {

    var personalityId: UUID?

    @Environment(\.personalityService) private var personalityService
    @Environment(CoreMLService.self) private var coreMLService
    @Environment(HapticService.self) private var hapticService

    @State private var viewModel: PersonalityEditorViewModel?
    @State private var alertMessage: String?
    @State private var showAlert = false

    var body: some View {
        ZStack {
            Color.ghostBackground.ignoresSafeArea()

            if let vm = viewModel {
                EditorScrollContent(
                    viewModel: vm,
                    showAlert: $showAlert,
                    alertMessage: $alertMessage,
                    hapticService: hapticService
                )
            } else {
                ProgressView()
                    .tint(.ghostCyan)
                    .scaleEffect(1.2)
            }
        }
        .alert("Personality", isPresented: $showAlert) {
            Button("OK", role: .cancel) {
                alertMessage = nil
            }
        } message: {
            Text(alertMessage ?? "")
        }
        .task(id: personalityId) {
            if viewModel == nil {
                viewModel = PersonalityEditorViewModel(
                    personalityService: personalityService,
                    coreMLService: coreMLService,
                    hapticService: hapticService
                )
            }
            guard let vm = viewModel else { return }
            if let id = personalityId {
                await vm.loadPersonality(id: id)
            } else {
                vm.resetForNewPersonality()
            }
        }
    }
}

// MARK: - Subviews

private struct EditorScrollContent: View {
    @Bindable var viewModel: PersonalityEditorViewModel
    @Binding var showAlert: Bool
    @Binding var alertMessage: String?
    var hapticService: HapticService

    private let responsePresets: [(label: String, value: String)] = [
        ("Balanced", "balanced"),
        ("Short & casual", "short_casual"),
        ("Short & formal", "short_formal"),
        ("Long & casual", "long_casual"),
        ("Long & formal", "long_formal")
    ]

    private let hapticOptions: [(label: String, id: String)] = [
        ("Default", "default"),
        ("Gentle wave", "gentle_wave"),
        ("Steady pulse", "steady_pulse"),
        ("Sharp tap", "sharp_tap"),
        ("Rising crescendo", "rising_crescendo"),
        ("Even rhythm", "even_rhythm")
    ]

    private let voiceOptions: [(label: String, id: String)] = [
        ("Default", "default"),
        ("Muse", "muse_voice"),
        ("Architect", "architect_voice"),
        ("Critic", "critic_voice"),
        ("Visionary", "visionary_voice"),
        ("Analyst", "analyst_voice")
    ]

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 20) {
                headerSection
                basicsSection
                traitsSection
                styleSection
                hapticsVoiceSection
                previewSection
                actionsSection
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .padding(.bottom, 32)
        }
        .scrollIndicators(.hidden)
        .overlay(alignment: .top) {
            if viewModel.isLoading || viewModel.isSaving {
                ProgressView()
                    .tint(.ghostCyan)
                    .padding(12)
                    .background {
                        Capsule().fill(.ultraThinMaterial)
                    }
                    .padding(.top, 8)
            }
        }
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Ghost personality", systemImage: "person.crop.circle.badge.sparkles")
                .font(.title2.weight(.bold))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.ghostCyan, .ghostMagenta],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
            Text("Shape tone, voice, and feedback for your creative sessions.")
                .font(.subheadline)
                .foregroundStyle(Color.ghostText.opacity(0.65))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background { glassBackground(cornerRadius: 18) }
    }

    private var basicsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionTitle("Basics", icon: "textformat")

            TextField("Name", text: $viewModel.name)
                .textFieldStyle(.plain)
                .padding(14)
                .background { RoundedRectangle(cornerRadius: 12).fill(.ultraThinMaterial) }
                .foregroundStyle(Color.ghostText)

            TextField("Short description", text: $viewModel.description, axis: .vertical)
                .lineLimit(2...4)
                .textFieldStyle(.plain)
                .padding(14)
                .background { RoundedRectangle(cornerRadius: 12).fill(.ultraThinMaterial) }
                .foregroundStyle(Color.ghostText)

            Text("System prompt")
                .font(.caption.weight(.semibold))
                .foregroundStyle(Color.ghostText.opacity(0.55))

            TextField("Instructions for the model…", text: $viewModel.systemPrompt, axis: .vertical)
                .lineLimit(6...12)
                .textFieldStyle(.plain)
                .padding(14)
                .background { RoundedRectangle(cornerRadius: 12).fill(.ultraThinMaterial) }
                .foregroundStyle(Color.ghostText)
        }
        .padding(18)
        .background { glassBackground(cornerRadius: 18) }
    }

    private var traitsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionTitle("Traits", icon: "square.grid.3x3.fill")

            let columns = [GridItem(.adaptive(minimum: 104), spacing: 10)]

            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(PersonalityTrait.allCases, id: \.self) { trait in
                    let selected = viewModel.selectedTraits.contains(trait)
                    Button {
                        hapticService.lightTap()
                        if selected {
                            viewModel.selectedTraits.remove(trait)
                        } else {
                            viewModel.selectedTraits.insert(trait)
                        }
                    } label: {
                        Text(trait.displayName)
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(selected ? Color.ghostBackground : Color.ghostText)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .fill(.ultraThinMaterial)
                                    if selected {
                                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                                            .fill(Color.ghostCyan.opacity(0.92))
                                    }
                                }
                            }
                            .overlay {
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .stroke(selected ? Color.ghostEmerald.opacity(0.6) : Color.ghostCyan.opacity(0.25), lineWidth: 1)
                            }
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(18)
        .background { glassBackground(cornerRadius: 18) }
    }

    private var styleSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionTitle("Response style", icon: "text.quote")

            Menu {
                ForEach(responsePresets, id: \.value) { preset in
                    Button(preset.label) {
                        hapticService.lightTap()
                        viewModel.responseStyle = preset.value
                    }
                }
            } label: {
                HStack {
                    Text(currentResponseLabel)
                        .foregroundStyle(Color.ghostText)
                    Spacer()
                    Image(systemName: "chevron.up.chevron.down")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color.ghostCyan)
                }
                .padding(14)
                .background { RoundedRectangle(cornerRadius: 12).fill(.ultraThinMaterial) }
            }
        }
        .padding(18)
        .background { glassBackground(cornerRadius: 18) }
    }

    private var currentResponseLabel: String {
        responsePresets.first { $0.value == viewModel.responseStyle }?.label ?? "Balanced"
    }

    private var hapticsVoiceSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionTitle("Haptics & voice", icon: "waveform.and.mic")

            Picker("Haptic pattern", selection: $viewModel.hapticPattern) {
                ForEach(hapticOptions, id: \.id) { opt in
                    Text(opt.label).tag(opt.id)
                }
            }
            .pickerStyle(.menu)
            .tint(.ghostMagenta)
            .padding(12)
            .background { RoundedRectangle(cornerRadius: 12).fill(.ultraThinMaterial) }
            .onChange(of: viewModel.hapticPattern) { _, _ in hapticService.lightTap() }

            Picker("Voice", selection: $viewModel.voiceId) {
                ForEach(voiceOptions, id: \.id) { opt in
                    Text(opt.label).tag(opt.id)
                }
            }
            .pickerStyle(.menu)
            .tint(.ghostEmerald)
            .padding(12)
            .background { RoundedRectangle(cornerRadius: 12).fill(.ultraThinMaterial) }
            .onChange(of: viewModel.voiceId) { _, _ in hapticService.lightTap() }
        }
        .padding(18)
        .background { glassBackground(cornerRadius: 18) }
    }

    private var previewSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                sectionTitle("Live preview", icon: "eye")
                Spacer()
                Button {
                    hapticService.mediumTap()
                    Task { await viewModel.refreshPreview() }
                } label: {
                    Label("Refresh", systemImage: "arrow.clockwise")
                        .font(.caption.weight(.semibold))
                }
                .buttonStyle(.bordered)
                .tint(.ghostGold)
            }

            if viewModel.isPreviewLoading {
                ProgressView()
                    .tint(.ghostCyan)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 20)
            } else {
                Text(viewModel.previewSampleText.isEmpty
                    ? "Tap Refresh to sample how this personality might respond."
                    : viewModel.previewSampleText)
                    .font(.subheadline)
                    .foregroundStyle(Color.ghostText.opacity(0.9))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(14)
                    .background { RoundedRectangle(cornerRadius: 12).fill(.regularMaterial) }
            }
        }
        .padding(18)
        .background { glassBackground(cornerRadius: 18) }
    }

    private var actionsSection: some View {
        VStack(spacing: 12) {
            Button {
                hapticService.mediumTap()
                Task {
                    do {
                        _ = try await viewModel.savePersonality()
                        alertMessage = "Saved successfully."
                        showAlert = true
                    } catch {
                        hapticService.errorNotification()
                        alertMessage = error.localizedDescription
                        showAlert = true
                    }
                }
            } label: {
                Label("Save", systemImage: "square.and.arrow.down")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
            }
            .buttonStyle(.borderedProminent)
            .tint(.ghostCyan)
            .disabled(!viewModel.isValid || viewModel.isSaving)

            Button {
                hapticService.heavyTap()
                Task {
                    do {
                        try await viewModel.publishPersonality()
                        alertMessage = "Published to the marketplace."
                        showAlert = true
                    } catch {
                        hapticService.errorNotification()
                        alertMessage = error.localizedDescription
                        showAlert = true
                    }
                }
            } label: {
                Label("Publish", systemImage: "storefront")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
            }
            .buttonStyle(.borderedProminent)
            .tint(.ghostMagenta)
            .disabled(!viewModel.isValid || viewModel.isSaving)
        }
        .padding(.top, 8)
    }

    private func sectionTitle(_ text: String, icon: String) -> some View {
        Label(text, systemImage: icon)
            .font(.subheadline.weight(.bold))
            .foregroundStyle(Color.ghostEmerald)
    }

    @ViewBuilder
    private func glassBackground(cornerRadius: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(.ultraThinMaterial)
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(Color.ghostCyan.opacity(0.18), lineWidth: 1)
            }
    }
}

// MARK: - Preview

#Preview("New personality") {
    PersonalityEditorView(personalityId: nil)
        .environment(PersonalityService())
        .environment(CoreMLService())
        .environment(HapticService())
}

#Preview("Editor — random id (empty if not found)") {
    PersonalityEditorView(personalityId: UUID())
        .environment(PersonalityService())
        .environment(CoreMLService())
        .environment(HapticService())
}
