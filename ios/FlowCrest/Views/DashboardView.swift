import SwiftUI
import SwiftData

struct DashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \BioMetricSample.timestamp, order: .reverse) private var recentSamples: [BioMetricSample]
    @Query(
        filter: #Predicate<FocusBlock> { !$0.isCompleted },
        sort: \FocusBlock.startTime
    ) private var upcomingBlocks: [FocusBlock]
    @Query(sort: \FocusBlock.startTime) private var allBlocks: [FocusBlock]

    let viewModel: DashboardViewModel

    @State private var showShareSheet = false
    @State private var showPaywall = false
    @State private var focusScore: FocusScore?
    @State private var hourlyReadiness: [Double] = []
    @State private var appeared = false
    @State private var subscriptionManager = SubscriptionManager.shared

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                readinessHeroCard
                    .padding(.horizontal)

                if let activeBlock = currentActiveBlock {
                    activeBlockCard(activeBlock)
                        .padding(.horizontal)
                }

                if !viewModel.suggestions.isEmpty {
                    suggestionsSection
                        .padding(.horizontal)
                }

                if let fs = focusScore, fs.totalBlockCount > 0 {
                    FocusScoreCardView(
                        score: fs.score,
                        insight: fs.insight,
                        onShare: { showShareSheet = true }
                    )
                    .padding(.horizontal)
                }

                timelineSection
                    .padding(.horizontal)

                bioMetricsGrid
                    .padding(.horizontal)

                if !subscriptionManager.isPremium {
                    PremiumBannerView {
                        showPaywall = true
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.top, 8)
            .padding(.bottom, 24)
        }
        .navigationTitle("FlowCrest")
        .refreshable {
            await viewModel.refreshBioMetrics(modelContext: modelContext)
        }
        .task {
            await viewModel.refreshBioMetrics(modelContext: modelContext)
            await viewModel.syncCalendarEvents(modelContext: modelContext)
            updateFocusScore()
            updateLiveActivity()
            updateSharedDefaults()
            withAnimation(.spring(response: 0.6)) { appeared = true }
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView()
        }
        .sheet(isPresented: $showShareSheet) {
            ShareScoreSheet(
                score: focusScore?.score ?? 0,
                insight: focusScore?.insight ?? "",
                hourlyReadiness: hourlyReadiness,
                blocks: allBlocks
            )
        }
        .sensoryFeedback(.selection, trigger: viewModel.readinessScore)
    }

    private var readinessHeroCard: some View {
        HStack(spacing: 20) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Cognitive Readiness")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.secondary)

                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text("\(Int(viewModel.readinessScore))")
                        .font(.system(size: 52, weight: .bold, design: .rounded))
                        .foregroundStyle(readinessColor)
                        .contentTransition(.numericText())
                    Text("/ 100")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }

                HStack(spacing: 8) {
                    Image(systemName: viewModel.readinessCategory.icon)
                        .foregroundStyle(readinessColor)
                        .symbolEffect(.bounce, value: viewModel.readinessScore)
                    Text(viewModel.readinessCategory.displayName)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(readinessColor)
                }

                Text(readinessMessage)
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                    .lineLimit(2)
            }

            Spacer()

            ReadinessGaugeView(score: viewModel.readinessScore, size: 100)
        }
        .padding(20)
        .background {
            RoundedRectangle(cornerRadius: 24)
                .fill(Color(.secondarySystemGroupedBackground))
                .overlay(alignment: .topTrailing) {
                    Circle()
                        .fill(readinessColor.opacity(0.08))
                        .frame(width: 120, height: 120)
                        .offset(x: 30, y: -30)
                }
                .clipShape(.rect(cornerRadius: 24))
        }
    }

    @ViewBuilder
    private func activeBlockCard(_ block: FocusBlock) -> some View {
        let alignment = blockAlignment(block)

        VStack(spacing: 12) {
            HStack {
                HStack(spacing: 6) {
                    Circle()
                        .fill(.green)
                        .frame(width: 8, height: 8)
                    Text("IN PROGRESS")
                        .font(.caption2.weight(.bold))
                        .tracking(1)
                        .foregroundStyle(.green)
                }
                Spacer()
                Text(block.endTime, style: .timer)
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(.secondary)
            }

            HStack(spacing: 14) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.energyLevelColor(for: block.intendedEnergyLevel))
                    .frame(width: 4)

                VStack(alignment: .leading, spacing: 4) {
                    Text(block.taskDescription)
                        .font(.headline)
                    HStack(spacing: 8) {
                        Label(block.intendedEnergyLevel.displayName, systemImage: block.intendedEnergyLevel.icon)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        alignmentBadge(alignment)
                    }
                }
                Spacer()
            }
        }
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: 18))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(alignment == .aligned ? Color.green.opacity(0.3) : Color.orange.opacity(0.3), lineWidth: 1)
        )
    }

    private var suggestionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "wand.and.stars")
                    .foregroundStyle(.orange)
                    .symbolEffect(.pulse)
                Text("Suggestions")
                    .font(.headline)
            }

            ForEach(viewModel.suggestions) { suggestion in
                SuggestionCard(suggestion: suggestion) { accepted in
                    viewModel.handleSuggestion(suggestion, accepted: accepted, modelContext: modelContext)
                    if accepted {
                        ReviewPromptService.shared.recordAcceptedSwap()
                    }
                }
            }
        }
    }

    private var timelineSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Upcoming")
                    .font(.headline)
                Spacer()
                if !upcomingBlocks.isEmpty {
                    Text("\(upcomingBlocks.prefix(6).count) blocks")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            if upcomingBlocks.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "calendar.badge.plus")
                        .font(.title)
                        .foregroundStyle(.tertiary)
                    Text("No upcoming focus blocks")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Text("Add tasks or sync your calendar")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 28)
                .background(Color(.secondarySystemGroupedBackground))
                .clipShape(.rect(cornerRadius: 16))
            } else {
                VStack(spacing: 8) {
                    ForEach(Array(upcomingBlocks.prefix(6).enumerated()), id: \.element.id) { index, block in
                        FocusBlockRow(
                            block: block,
                            readinessScore: viewModel.readinessScore,
                            showAlignment: true
                        )
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 12)
                        .animation(.spring(response: 0.4).delay(Double(index) * 0.06), value: appeared)
                    }
                }
            }
        }
    }

    private var bioMetricsGrid: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Bio Metrics")
                .font(.headline)

            if let sample = viewModel.latestSample ?? recentSamples.first {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                    MetricCard(
                        title: "HRV",
                        value: String(format: "%.0f", sample.hrv),
                        unit: "ms",
                        icon: "heart.fill",
                        color: .pink
                    )
                    MetricCard(
                        title: "Sleep Quality",
                        value: String(format: "%.0f%%", sample.sleepQuality * 100),
                        unit: "",
                        icon: "moon.fill",
                        color: .indigo
                    )
                    MetricCard(
                        title: "Resting HR",
                        value: String(format: "%.0f", sample.restingHeartRate),
                        unit: "bpm",
                        icon: "waveform.path.ecg",
                        color: .red
                    )
                    MetricCard(
                        title: "Readiness",
                        value: String(format: "%.0f", sample.cognitiveReadinessScore),
                        unit: "/ 100",
                        icon: "brain.head.profile.fill",
                        color: .teal
                    )
                }
            } else {
                Text("No biometric data available yet.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.secondarySystemGroupedBackground))
                    .clipShape(.rect(cornerRadius: 12))
            }
        }
    }

    private var currentActiveBlock: FocusBlock? {
        let now = Date()
        return upcomingBlocks.first { $0.startTime <= now && $0.endTime >= now }
    }

    private var readinessColor: Color {
        Color.readinessColor(for: viewModel.readinessScore)
    }

    private var readinessMessage: String {
        switch viewModel.readinessCategory {
        case .peak: return "You're in peak condition for deep work"
        case .good: return "Good readiness for focused tasks"
        case .moderate: return "Consider lighter tasks right now"
        case .low: return "Energy is low — admin tasks recommended"
        case .veryLow: return "Rest or take a break before working"
        }
    }

    nonisolated private enum BlockAlignment {
        case aligned, misaligned, neutral
    }

    private func blockAlignment(_ block: FocusBlock) -> BlockAlignment {
        let score = viewModel.readinessScore
        let threshold = block.intendedEnergyLevel.minimumReadinessThreshold
        if score >= threshold { return .aligned }
        if score < threshold * 0.75 { return .misaligned }
        return .neutral
    }

    private func alignmentBadge(_ alignment: BlockAlignment) -> some View {
        HStack(spacing: 4) {
            switch alignment {
            case .aligned:
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
                Text("Aligned")
                    .foregroundStyle(.green)
            case .misaligned:
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundStyle(.orange)
                Text("Misaligned")
                    .foregroundStyle(.orange)
            case .neutral:
                Image(systemName: "minus.circle.fill")
                    .foregroundStyle(.yellow)
                Text("Borderline")
                    .foregroundStyle(.yellow)
            }
        }
        .font(.caption2.weight(.semibold))
    }

    private func updateFocusScore() {
        focusScore = FocusScoreService.shared.calculateDailyScore(
            blocks: allBlocks,
            samples: recentSamples,
            engine: viewModel.engine
        )
        hourlyReadiness = HeatmapGenerator.shared.buildHourlyReadiness(from: recentSamples)

        if let score = focusScore {
            ReviewPromptService.shared.recordDailyScore(score.score)
        }
    }

    private func updateLiveActivity() {
        LiveActivityService.shared.checkAndStartForCurrentBlock(
            blocks: Array(upcomingBlocks),
            readinessScore: viewModel.readinessScore
        )
    }

    private func updateSharedDefaults() {
        let defaults = UserDefaults(suiteName: "group.app.rork.flowcrest.shared")
        defaults?.set(viewModel.readinessScore, forKey: "currentReadiness")

        if let nextBlock = upcomingBlocks.first(where: { $0.startTime > Date() }) {
            defaults?.set(nextBlock.taskDescription, forKey: "nextTaskDescription")
            defaults?.set(nextBlock.intendedEnergyLevelRaw, forKey: "nextTaskEnergy")
            defaults?.set(nextBlock.startTime.timeIntervalSince1970, forKey: "nextTaskStart")
        }
    }
}
