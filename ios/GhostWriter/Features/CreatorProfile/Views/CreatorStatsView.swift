import SwiftUI

struct CreatorStatsView: View {
    let stats: CreatorStats

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                overviewCards
                productiveHoursSection
                personalityUsageSection
            }
            .padding()
        }
        .background(Color.ghostBackground.ignoresSafeArea())
        .navigationTitle("Analytics")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var overviewCards: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            analyticsCard(title: "Sessions", value: "\(stats.totalSessions)", icon: "sparkles", color: .ghostCyan)
            analyticsCard(title: "Words", value: "\(stats.totalWords)", icon: "text.word.spacing", color: .ghostMagenta)
            analyticsCard(title: "Ideas", value: "\(stats.totalIdeas)", icon: "lightbulb.fill", color: .ghostGold)
            analyticsCard(title: "Avg Flow", value: String(format: "%.0f%%", stats.averageFlowScore), icon: "flame.fill", color: .ghostEmerald)
        }
    }

    private func analyticsCard(title: String, value: String, icon: String, color: Color) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            Text(value)
                .font(.title3.bold())
                .foregroundColor(.ghostText)
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(14)
    }

    private var productiveHoursSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Most Productive Hours")
                .font(.headline)
                .foregroundColor(.ghostText)

            HStack(alignment: .bottom, spacing: 4) {
                ForEach(0..<24, id: \.self) { hour in
                    let height = productivityForHour(hour)
                    VStack(spacing: 2) {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(height > 0.6 ? Color.ghostCyan : Color.gray.opacity(0.3))
                            .frame(width: 8, height: CGFloat(height) * 60)

                        if hour % 6 == 0 {
                            Text("\(hour)")
                                .font(.system(size: 8))
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(.ultraThinMaterial)
            .cornerRadius(14)
        }
    }

    private func productivityForHour(_ hour: Int) -> Double {
        let peak = 10
        let distance = abs(hour - peak)
        return max(0.1, 1.0 - Double(distance) * 0.08)
    }

    private var personalityUsageSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Personality Usage")
                .font(.headline)
                .foregroundColor(.ghostText)

            ForEach(["The Muse", "The Architect", "The Critic", "The Visionary"], id: \.self) { name in
                HStack {
                    Text(name)
                        .font(.subheadline)
                        .foregroundColor(.ghostText)
                    Spacer()
                    let usage = Double.random(in: 0.1...1.0)
                    GeometryReader { geo in
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.ghostCyan.opacity(0.6))
                            .frame(width: geo.size.width * usage)
                    }
                    .frame(width: 100, height: 8)
                    Text("\(Int(Double.random(in: 5...50)))")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .frame(width: 30, alignment: .trailing)
                }
                .padding(.vertical, 4)
            }
            .padding()
            .background(.ultraThinMaterial)
            .cornerRadius(14)
        }
    }
}

#Preview {
    NavigationStack {
        CreatorStatsView(stats: CreatorStats(
            totalSessions: 150,
            totalWords: 45000,
            totalIdeas: 320,
            averageFlowScore: 72,
            totalEarnings: 247.50,
            totalClipViews: 12000,
            mostUsedPersonality: "The Muse",
            currentStreak: 12,
            longestStreak: 28
        ))
    }
}
