import SwiftUI
import SwiftData

struct InsightsView: View {
    @Query(sort: \BioMetricSample.timestamp, order: .reverse) private var samples: [BioMetricSample]
    @Query(sort: \FocusScore.date, order: .reverse) private var focusScores: [FocusScore]
    @Query(sort: \FocusBlock.startTime) private var allBlocks: [FocusBlock]

    @State private var showShareSheet = false
    @State private var selectedTimeRange = 0
    @State private var showPaywall = false
    @State private var subscriptionManager = SubscriptionManager.shared

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                if samples.isEmpty && focusScores.isEmpty {
                    ContentUnavailableView(
                        "No Data Yet",
                        systemImage: "chart.line.uptrend.xyaxis",
                        description: Text("Bio metrics and focus scores will appear here as data is collected.")
                    )
                } else {
                    if let latestScore = focusScores.first {
                        todayScoreSection(latestScore)
                    }

                    Picker("Time Range", selection: $selectedTimeRange) {
                        Text("7 Days").tag(0)
                        Text("14 Days").tag(1)
                        Text("30 Days").tag(2)
                    }
                    .pickerStyle(.segmented)
                    .onChange(of: selectedTimeRange) { _, newValue in
                        if !subscriptionManager.isPremium && newValue > 0 {
                            selectedTimeRange = 0
                            showPaywall = true
                        }
                    }

                    weeklyOverviewSection

                    if focusScores.count > 1 {
                        focusScoreTrendSection
                    }

                    readinessHistorySection
                    hrvTrendSection
                    sleepTrendSection
                }
            }
            .padding(.horizontal)
            .padding(.top, 8)
            .padding(.bottom, 24)
        }
        .navigationTitle("Insights")
        .sheet(isPresented: $showPaywall) {
            PaywallView()
        }
        .sheet(isPresented: $showShareSheet) {
            if let score = focusScores.first {
                ShareScoreSheet(
                    score: score.score,
                    insight: score.insight,
                    hourlyReadiness: HeatmapGenerator.shared.buildHourlyReadiness(from: samples),
                    blocks: allBlocks
                )
            }
        }
    }

    private var dataCount: Int {
        switch selectedTimeRange {
        case 0: return 7
        case 1: return 14
        default: return 30
        }
    }

    @ViewBuilder
    private func todayScoreSection(_ score: FocusScore) -> some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text("TODAY'S FOCUS")
                        .font(.caption.weight(.semibold))
                        .tracking(1)
                        .foregroundStyle(.secondary)
                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text("\(Int(score.score))")
                            .font(.system(size: 56, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.readinessColor(for: score.score))
                        Text("/ 100")
                            .font(.title3)
                            .foregroundStyle(.secondary)
                    }
                }
                Spacer()
                VStack(spacing: 8) {
                    Button {
                        showShareSheet = true
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                            .font(.body.weight(.medium))
                            .padding(10)
                            .background(Color(.tertiarySystemFill))
                            .clipShape(.circle)
                    }
                }
            }

            Text(score.insight)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 16) {
                statPill(label: "Aligned", value: "\(score.alignedBlockCount)/\(score.totalBlockCount)", color: .green)
                statPill(label: "Accepted", value: "\(score.acceptedSuggestions)", color: .orange)
                statPill(label: "Rejected", value: "\(score.rejectedSuggestions)", color: .secondary)
            }
        }
        .padding(20)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: 20))
    }

    private func statPill(label: String, value: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.headline)
                .foregroundStyle(color)
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }

    private var weeklyOverviewSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Overview")
                .font(.headline)

            let weekSamples = Array(samples.prefix(dataCount))
            let avgScore = weekSamples.isEmpty ? 0 : weekSamples.reduce(0.0) { $0 + $1.cognitiveReadinessScore } / Double(weekSamples.count)
            let avgHRV = weekSamples.isEmpty ? 0 : weekSamples.reduce(0.0) { $0 + $1.hrv } / Double(weekSamples.count)
            let avgSleep = weekSamples.isEmpty ? 0 : weekSamples.reduce(0.0) { $0 + $1.sleepQuality } / Double(weekSamples.count)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                SummaryPill(title: "Avg Score", value: String(format: "%.0f", avgScore), color: .teal)
                SummaryPill(title: "Avg HRV", value: String(format: "%.0f", avgHRV), color: .pink)
                SummaryPill(title: "Avg Sleep", value: String(format: "%.0f%%", avgSleep * 100), color: .indigo)
            }
        }
    }

    private var focusScoreTrendSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Focus Score Trend")
                .font(.headline)

            MiniBarChart(
                data: Array(focusScores.prefix(dataCount).reversed().map { $0.score }),
                maxValue: 100,
                barColor: .teal
            )
            .frame(height: 120)
            .padding()
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(.rect(cornerRadius: 16))
        }
    }

    private var readinessHistorySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Readiness Trend")
                .font(.headline)

            MiniBarChart(
                data: Array(samples.prefix(dataCount).reversed().map { $0.cognitiveReadinessScore }),
                maxValue: 100,
                barColor: .teal
            )
            .frame(height: 120)
            .padding()
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(.rect(cornerRadius: 16))
        }
    }

    private var hrvTrendSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("HRV Trend")
                .font(.headline)

            MiniBarChart(
                data: Array(samples.prefix(dataCount).reversed().map { $0.hrv }),
                maxValue: 100,
                barColor: .pink
            )
            .frame(height: 120)
            .padding()
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(.rect(cornerRadius: 16))
        }
    }

    private var sleepTrendSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Sleep Quality Trend")
                .font(.headline)

            MiniBarChart(
                data: Array(samples.prefix(dataCount).reversed().map { $0.sleepQuality * 100 }),
                maxValue: 100,
                barColor: .indigo
            )
            .frame(height: 120)
            .padding()
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(.rect(cornerRadius: 16))
        }
    }
}

struct SummaryPill: View {
    let title: String
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title3.bold())
                .foregroundStyle(color)
                .contentTransition(.numericText())
            Text(title)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: 12))
    }
}

struct MiniBarChart: View {
    let data: [Double]
    let maxValue: Double
    let barColor: Color

    var body: some View {
        GeometryReader { geo in
            HStack(alignment: .bottom, spacing: 4) {
                ForEach(Array(data.enumerated()), id: \.offset) { _, value in
                    let height = maxValue > 0 ? (value / maxValue) * geo.size.height : 0
                    RoundedRectangle(cornerRadius: 3)
                        .fill(barColor.gradient)
                        .frame(height: max(height, 2))
                }
            }
        }
    }
}
