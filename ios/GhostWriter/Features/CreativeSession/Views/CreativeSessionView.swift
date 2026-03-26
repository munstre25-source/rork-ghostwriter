import SwiftUI
import SwiftData

// MARK: - CreativeSessionView

/// The main "Live" tab — the GhostBoard creative canvas.
///
/// Bridges `@Environment` services into a `CreativeSessionViewModel` and
/// presents either a session-start screen (personality + type picker) or
/// the active writing canvas with live suggestions.
struct CreativeSessionView: View {
    @Environment(CoreMLService.self) private var coreMLService
    @Environment(HapticService.self) private var hapticService
    @Environment(AnalyticsService.self) private var analyticsService
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        SessionContainer(
            coreMLService: coreMLService,
            hapticService: hapticService,
            analyticsService: analyticsService,
            modelContext: modelContext
        )
    }
}

// MARK: - SessionContainer

/// Inner content view that owns the `CreativeSessionViewModel` via `@State`.
///
/// Separated from `CreativeSessionView` so that `@Environment` values can
/// be forwarded as init parameters, giving the ViewModel real dependencies
/// from the very first body evaluation.
private struct SessionContainer: View {
    @State private var viewModel: CreativeSessionViewModel
    @State private var showEndConfirmation = false
    @State private var timerTick: Date = .now
    @Query(sort: \GhostPersonality.name) private var personalities: [GhostPersonality]
    @Environment(\.dismiss) private var dismiss

    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    init(
        coreMLService: CoreMLService,
        hapticService: HapticService,
        analyticsService: AnalyticsService,
        modelContext: ModelContext
    ) {
        _viewModel = State(initialValue: CreativeSessionViewModel(
            coreMLService: coreMLService,
            hapticService: hapticService,
            analyticsService: analyticsService,
            modelContext: modelContext
        ))
    }

    var body: some View {
        ZStack {
            Color.ghostBackground.ignoresSafeArea()

            if viewModel.hasActiveSession {
                activeSessionView
            } else {
                startSessionView
            }
        }
        .task {
            viewModel.ensureBuiltInPersonalities()
            await viewModel.loadModel()
        }
        .onChange(of: personalities.count) {
            if viewModel.selectedPersonality == nil, let first = personalities.first {
                viewModel.selectedPersonality = first
            }
        }
        .onReceive(timer) { timerTick = $0 }
        .confirmationDialog(
            "End Session?",
            isPresented: $showEndConfirmation,
            titleVisibility: .visible
        ) {
            Button("End Session", role: .destructive) {
                viewModel.endSession()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Your session has \(viewModel.wordCount) words. Are you sure?")
        }
        .alert("Error", isPresented: Binding(
            get: { viewModel.error != nil },
            set: { if !$0 { viewModel.error = nil } }
        )) {
            Button("OK") { viewModel.error = nil }
        } message: {
            Text(viewModel.error?.localizedDescription ?? "An unknown error occurred.")
        }
        .preferredColorScheme(.dark)
    }

    // MARK: - Start Session Screen

    private var startSessionView: some View {
        ScrollView {
            VStack(spacing: 32) {
                startHeader
                sessionTypeSection
                personalitySection
                startButton
                modelStatusIndicator
            }
            .padding(.bottom, 48)
        }
        .scrollIndicators(.hidden)
    }

    private var startHeader: some View {
        VStack(spacing: 10) {
            Image(systemName: "wand.and.stars")
                .font(.system(size: 48))
                .foregroundStyle(
                    .linearGradient(
                        colors: [.ghostCyan, .ghostMagenta],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .symbolEffect(.pulse, isActive: !viewModel.isModelReady)

            Text("GhostBoard")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(Color.ghostText)

            Text("Choose your ghost and begin creating")
                .font(.system(size: 15))
                .foregroundStyle(Color.ghostText.opacity(0.6))
        }
        .padding(.top, 48)
    }

    private var sessionTypeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("SESSION TYPE")
                .font(.system(size: 11, weight: .bold, design: .monospaced))
                .foregroundStyle(Color.ghostText.opacity(0.4))
                .padding(.horizontal, 20)

            sessionTypeSelector
        }
    }

    private var sessionTypeSelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(SessionType.allCases) { type in
                    Button {
                        withAnimation(.snappy(duration: 0.3)) {
                            viewModel.selectedSessionType = type
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: type.icon)
                                .font(.system(size: 13, weight: .semibold))
                            Text(type.displayName)
                                .font(.system(size: 13, weight: .medium))
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(
                            viewModel.selectedSessionType == type
                                ? AnyShapeStyle(Color.ghostCyan.opacity(0.25))
                                : AnyShapeStyle(.ultraThinMaterial)
                        )
                        .foregroundStyle(
                            viewModel.selectedSessionType == type
                                ? Color.ghostCyan
                                : Color.ghostText.opacity(0.7)
                        )
                        .clipShape(Capsule())
                        .overlay(
                            Capsule()
                                .strokeBorder(
                                    viewModel.selectedSessionType == type
                                        ? Color.ghostCyan.opacity(0.6)
                                        : Color.white.opacity(0.08),
                                    lineWidth: 1
                                )
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal)
        }
    }

    private var personalitySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("CHOOSE YOUR GHOST")
                .font(.system(size: 11, weight: .bold, design: .monospaced))
                .foregroundStyle(Color.ghostText.opacity(0.4))
                .padding(.horizontal, 20)

            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 12) {
                    ForEach(personalities) { personality in
                        PersonalityPickerCard(
                            personality: personality,
                            isSelected: viewModel.selectedPersonality?.id == personality.id
                        ) {
                            withAnimation(.snappy(duration: 0.3)) {
                                viewModel.selectedPersonality = personality
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }
            .frame(height: 165)
        }
    }

    private var startButton: some View {
        let canStart = viewModel.selectedPersonality != nil && viewModel.isModelReady

        return Button {
            guard let personality = viewModel.selectedPersonality else { return }
            withAnimation(.spring(duration: 0.5)) {
                viewModel.startSession(
                    type: viewModel.selectedSessionType,
                    personality: personality
                )
            }
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "sparkles")
                    .font(.system(size: 16, weight: .semibold))
                Text("Begin Session")
                    .font(.system(size: 17, weight: .bold))
            }
            .foregroundStyle(Color.ghostBackground)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(canStart ? Color.ghostCyan : Color.ghostCyan.opacity(0.3))
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
        .disabled(!canStart)
        .padding(.horizontal)
    }

    @ViewBuilder
    private var modelStatusIndicator: some View {
        if !viewModel.isModelReady {
            HStack(spacing: 8) {
                ProgressView()
                    .tint(.ghostCyan)
                Text("Loading AI model…")
                    .font(.system(size: 13))
                    .foregroundStyle(Color.ghostText.opacity(0.5))
            }
        }
    }

    // MARK: - Active Session

    private var activeSessionView: some View {
        ZStack {
            VStack(spacing: 0) {
                sessionHeader
                ghostBoardArea
                suggestionsArea
            }

            floatingControls
            ghostOrbOverlay
        }
    }

    // MARK: - Session Header

    private var sessionHeader: some View {
        VStack(spacing: 12) {
            HStack {
                sessionTimerBadge
                Spacer()
                flowIndicator
                Spacer()
                wordCountBadge
            }
            .padding(.horizontal)

            activeSessionTypeSelector
        }
        .padding(.top, 8)
    }

    private var activeSessionTypeSelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(SessionType.allCases) { type in
                    HStack(spacing: 6) {
                        Image(systemName: type.icon)
                            .font(.system(size: 13, weight: .semibold))
                        Text(type.displayName)
                            .font(.system(size: 13, weight: .medium))
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(
                        viewModel.selectedSessionType == type
                            ? AnyShapeStyle(Color.ghostCyan.opacity(0.25))
                            : AnyShapeStyle(.ultraThinMaterial)
                    )
                    .foregroundStyle(
                        viewModel.selectedSessionType == type
                            ? Color.ghostCyan
                            : Color.ghostText.opacity(0.7)
                    )
                    .clipShape(Capsule())
                    .overlay(
                        Capsule()
                            .strokeBorder(
                                viewModel.selectedSessionType == type
                                    ? Color.ghostCyan.opacity(0.6)
                                    : Color.white.opacity(0.08),
                                lineWidth: 1
                            )
                    )
                }
            }
            .padding(.horizontal)
        }
    }

    private var sessionTimerBadge: some View {
        HStack(spacing: 5) {
            Circle()
                .fill(viewModel.isPaused ? Color.ghostGold : Color.ghostEmerald)
                .frame(width: 7, height: 7)
                .shadow(color: viewModel.isPaused ? .ghostGold : .ghostEmerald, radius: 4)

            Text(viewModel.formattedDuration)
                .font(.system(size: 14, weight: .semibold, design: .monospaced))
                .foregroundStyle(Color.ghostText)
                .contentTransition(.numericText())
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(.ultraThinMaterial)
        .clipShape(Capsule())
    }

    private var wordCountBadge: some View {
        HStack(spacing: 4) {
            Image(systemName: "text.word.spacing")
                .font(.system(size: 11))
            Text("\(viewModel.wordCount)")
                .font(.system(size: 13, weight: .semibold, design: .monospaced))
                .contentTransition(.numericText())
        }
        .foregroundStyle(Color.ghostText.opacity(0.8))
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(.ultraThinMaterial)
        .clipShape(Capsule())
    }

    private var flowIndicator: some View {
        HStack(spacing: 5) {
            if viewModel.isInFlowState {
                Image(systemName: "flame.fill")
                    .font(.system(size: 14))
                    .foregroundStyle(
                        .linearGradient(
                            colors: [.orange, .ghostMagenta],
                            startPoint: .bottom,
                            endPoint: .top
                        )
                    )
                    .symbolEffect(.pulse, isActive: true)
                Text("Flow")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(Color.ghostMagenta)
            } else {
                Image(systemName: "wind")
                    .font(.system(size: 13))
                    .foregroundStyle(Color.ghostText.opacity(0.4))
                Text("\(Int(viewModel.flowScore))%")
                    .font(.system(size: 12, weight: .medium, design: .monospaced))
                    .foregroundStyle(Color.ghostText.opacity(0.4))
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(
            viewModel.isInFlowState
                ? AnyShapeStyle(Color.ghostMagenta.opacity(0.15))
                : AnyShapeStyle(.ultraThinMaterial)
        )
        .clipShape(Capsule())
        .animation(.easeInOut(duration: 0.5), value: viewModel.isInFlowState)
    }

    // MARK: - GhostBoard Canvas

    private var ghostBoardArea: some View {
        GhostBoardCanvas(
            text: $viewModel.sessionText,
            wordCount: viewModel.wordCount,
            isInFlowState: viewModel.isInFlowState
        )
        .padding(.horizontal)
        .padding(.top, 12)
    }

    // MARK: - Suggestions

    private var suggestionsArea: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 12) {
                ForEach(viewModel.suggestions) { suggestion in
                    SuggestionCard(
                        suggestion: suggestion,
                        onAccept: { viewModel.acceptSuggestion(suggestion) },
                        onReject: { viewModel.rejectSuggestion(suggestion) },
                        onRate: { rating in
                            viewModel.rateSuggestion(suggestion, rating: rating)
                        }
                    )
                    .transition(.asymmetric(
                        insertion: .move(edge: .bottom).combined(with: .opacity),
                        removal: .move(edge: .trailing).combined(with: .opacity)
                    ))
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 10)
        }
        .frame(height: viewModel.suggestions.isEmpty ? 0 : 170)
        .animation(.spring(duration: 0.4), value: viewModel.suggestions.count)
    }

    // MARK: - Floating Controls

    private var floatingControls: some View {
        VStack {
            Spacer()

            HStack(spacing: 16) {
                FloatingActionButton(
                    icon: viewModel.isPaused ? "play.fill" : "pause.fill",
                    color: .ghostGold
                ) {
                    viewModel.togglePause()
                }

                FloatingActionButton(
                    icon: "camera.viewfinder",
                    color: .ghostCyan
                ) {
                    // Snapshot / future feature
                }

                FloatingActionButton(
                    icon: "stop.circle.fill",
                    color: .ghostMagenta
                ) {
                    showEndConfirmation = true
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(.regularMaterial)
            .clipShape(Capsule())
            .shadow(color: .black.opacity(0.4), radius: 16, y: 8)
            .padding(.bottom, 24)
        }
        .ignoresSafeArea(.keyboard)
    }

    // MARK: - Ghost Orb

    private var ghostOrbOverlay: some View {
        VStack {
            HStack {
                Spacer()
                GhostOrb(isThinking: viewModel.isLoading, flowScore: viewModel.flowScore)
                    .frame(width: 48, height: 48)
                    .padding(.trailing, 16)
                    .padding(.top, 8)
            }
            Spacer()
        }
    }
}

// MARK: - PersonalityPickerCard

private struct PersonalityPickerCard: View {
    let personality: GhostPersonality
    let isSelected: Bool
    let action: () -> Void

    private var accentColor: Color {
        switch personality.responseStyle {
        case "expressive": .ghostMagenta
        case "structured": .ghostCyan
        case "direct":     .ghostGold
        case "expansive":  .ghostEmerald
        case "analytical": .ghostCyan
        default:           .ghostCyan
        }
    }

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: iconForPersonality)
                        .font(.system(size: 20))
                        .foregroundStyle(isSelected ? accentColor : Color.ghostText.opacity(0.6))
                    Spacer()
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 16))
                            .foregroundStyle(accentColor)
                    }
                }

                Text(personality.name)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(isSelected ? accentColor : Color.ghostText)

                Text(personality.personalityDescription)
                    .font(.system(size: 11))
                    .foregroundStyle(Color.ghostText.opacity(0.55))
                    .lineLimit(3)
                    .lineSpacing(1)

                Spacer(minLength: 0)

                HStack(spacing: 4) {
                    ForEach(personality.traits.prefix(3), id: \.self) { trait in
                        Text(trait)
                            .font(.system(size: 9, weight: .medium, design: .monospaced))
                            .foregroundStyle(Color.ghostText.opacity(0.45))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.white.opacity(0.06))
                            .clipShape(Capsule())
                    }
                }
            }
            .padding(14)
            .frame(width: 200, height: 155, alignment: .topLeading)
            .background(
                isSelected
                    ? AnyShapeStyle(accentColor.opacity(0.1))
                    : AnyShapeStyle(.ultraThinMaterial)
            )
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .strokeBorder(
                        isSelected ? accentColor.opacity(0.6) : Color.white.opacity(0.08),
                        lineWidth: isSelected ? 1.5 : 1
                    )
            )
        }
        .buttonStyle(.plain)
    }

    private var iconForPersonality: String {
        switch personality.responseStyle {
        case "expressive": "flame"
        case "structured": "building.columns"
        case "direct":     "eye"
        case "expansive":  "sparkles"
        case "analytical": "chart.bar"
        default:           "person.fill"
        }
    }
}

// MARK: - FloatingActionButton

private struct FloatingActionButton: View {
    let icon: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(color)
                .frame(width: 44, height: 44)
                .contentShape(Circle())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - GhostOrb

private struct GhostOrb: View {
    let isThinking: Bool
    let flowScore: Double

    @State private var phase: CGFloat = 0

    private var orbColor: Color {
        if isThinking { return .ghostCyan }
        if flowScore > 70 { return .ghostMagenta }
        return .ghostText.opacity(0.3)
    }

    var body: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [orbColor.opacity(0.6), orbColor.opacity(0.0)],
                        center: .center,
                        startRadius: 4,
                        endRadius: 24
                    )
                )
                .scaleEffect(isThinking ? 1.3 : 1.0)
                .animation(
                    .easeInOut(duration: 0.8).repeatForever(autoreverses: true),
                    value: isThinking
                )

            Circle()
                .fill(orbColor)
                .frame(width: 14, height: 14)
                .shadow(color: orbColor, radius: isThinking ? 12 : 4)

            if isThinking {
                Circle()
                    .stroke(orbColor.opacity(0.4), lineWidth: 2)
                    .frame(width: 28, height: 28)
                    .rotationEffect(.degrees(phase * 360))
                    .onAppear {
                        withAnimation(.linear(duration: 2).repeatForever(autoreverses: false)) {
                            phase = 1
                        }
                    }
            }
        }
    }
}

// MARK: - Previews

#Preview {
    CreativeSessionView()
        .environment(CoreMLService())
        .environment(HapticService())
        .environment(AnalyticsService())
        .modelContainer(for: [CreativeSession.self, GhostPersonality.self, GhostSuggestion.self])
}

#Preview("With Active Session") {
    CreativeSessionView()
        .environment(CoreMLService())
        .environment(HapticService())
        .environment(AnalyticsService())
        .modelContainer(for: [CreativeSession.self, GhostPersonality.self, GhostSuggestion.self])
}
