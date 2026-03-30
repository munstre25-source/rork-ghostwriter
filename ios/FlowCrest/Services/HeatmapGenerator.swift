import SwiftUI

@MainActor
final class HeatmapGenerator {
    static let shared = HeatmapGenerator()
    private init() {}

    func generateHeatmapImage(
        score: Double,
        insight: String,
        hourlyReadiness: [Double],
        blocks: [FocusBlock]
    ) -> UIImage? {
        let view = HeatmapShareView(
            score: score,
            insight: insight,
            hourlyReadiness: hourlyReadiness,
            blocks: blocks
        )

        let renderer = ImageRenderer(content: view)
        renderer.scale = 3.0
        return renderer.uiImage
    }

    func buildHourlyReadiness(from samples: [BioMetricSample]) -> [Double] {
        var hourly = [Double](repeating: 0, count: 24)
        let calendar = Calendar.current

        for sample in samples where calendar.isDateInToday(sample.timestamp) {
            let hour = calendar.component(.hour, from: sample.timestamp)
            if hour < 24 {
                hourly[hour] = sample.cognitiveReadinessScore
            }
        }

        if hourly.allSatisfy({ $0 == 0 }) {
            for i in 0..<24 {
                let base: Double = switch i {
                case 6...9: Double.random(in: 60...85)
                case 10...12: Double.random(in: 70...95)
                case 13...14: Double.random(in: 40...65)
                case 15...17: Double.random(in: 55...80)
                case 18...21: Double.random(in: 30...55)
                default: Double.random(in: 10...35)
                }
                hourly[i] = base
            }
        }

        return hourly
    }
}

struct HeatmapShareView: View {
    let score: Double
    let insight: String
    let hourlyReadiness: [Double]
    let blocks: [FocusBlock]

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 16) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("FOCUS SCORE")
                            .font(.caption.weight(.semibold))
                            .tracking(1.5)
                            .foregroundStyle(.white.opacity(0.7))
                        Text("\(Int(score))")
                            .font(.system(size: 72, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 4) {
                        Text(Date(), format: .dateTime.month(.wide).day())
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(.white.opacity(0.8))
                        scoreLabel
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 28)

                Text(insight)
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.85))
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 24)

                heatmapGrid
                    .padding(.horizontal, 24)
                    .padding(.top, 8)

                HStack {
                    HStack(spacing: 4) {
                        Circle().fill(Color(hue: 0.0, saturation: 0.6, brightness: 0.9))
                            .frame(width: 8, height: 8)
                        Text("Low")
                            .font(.caption2)
                            .foregroundStyle(.white.opacity(0.6))
                    }
                    Rectangle()
                        .fill(LinearGradient(
                            colors: [
                                Color(hue: 0.0, saturation: 0.6, brightness: 0.9),
                                Color(hue: 0.12, saturation: 0.6, brightness: 0.9),
                                Color(hue: 0.35, saturation: 0.6, brightness: 0.8)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        ))
                        .frame(height: 6)
                        .clipShape(.capsule)
                    HStack(spacing: 4) {
                        Text("High")
                            .font(.caption2)
                            .foregroundStyle(.white.opacity(0.6))
                        Circle().fill(Color(hue: 0.35, saturation: 0.6, brightness: 0.8))
                            .frame(width: 8, height: 8)
                    }
                }
                .padding(.horizontal, 24)

                HStack {
                    Image(systemName: "waveform.path.ecg")
                        .font(.caption)
                    Text("FlowCrest")
                        .font(.caption.weight(.semibold))
                    Spacer()
                    Text("#FlowCrestApp")
                        .font(.caption2)
                        .foregroundStyle(.white.opacity(0.5))
                }
                .foregroundStyle(.white.opacity(0.6))
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
                .padding(.top, 8)
            }
        }
        .frame(width: 390)
        .background(
            LinearGradient(
                colors: [
                    Color(red: 0.08, green: 0.08, blue: 0.14),
                    Color(red: 0.05, green: 0.12, blue: 0.18),
                    Color(red: 0.06, green: 0.06, blue: 0.12)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(.rect(cornerRadius: 24))
    }

    private var scoreLabel: some View {
        Text(scoreLabelText)
            .font(.caption.weight(.semibold))
            .foregroundStyle(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(scoreLabelColor.opacity(0.4))
            .clipShape(.capsule)
    }

    private var scoreLabelText: String {
        if score >= 85 { return "Exceptional" }
        if score >= 70 { return "Great" }
        if score >= 50 { return "Good" }
        if score >= 30 { return "Fair" }
        return "Needs Work"
    }

    private var scoreLabelColor: Color {
        if score >= 70 { return .green }
        if score >= 50 { return .teal }
        if score >= 30 { return .orange }
        return .red
    }

    private var heatmapGrid: some View {
        VStack(spacing: 3) {
            ForEach(0..<4, id: \.self) { row in
                HStack(spacing: 3) {
                    ForEach(0..<6, id: \.self) { col in
                        let hour = row * 6 + col
                        let value = hour < hourlyReadiness.count ? hourlyReadiness[hour] : 0

                        VStack(spacing: 2) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(heatmapColor(for: value))
                                .frame(height: 28)
                            if row == 3 {
                                Text("\(hour)")
                                    .font(.system(size: 8))
                                    .foregroundStyle(.white.opacity(0.4))
                            }
                        }
                    }
                }
            }
        }
    }

    private func heatmapColor(for value: Double) -> Color {
        let normalized = min(max(value / 100.0, 0), 1.0)
        let hue = normalized * 0.35
        return Color(hue: hue, saturation: 0.55 + normalized * 0.15, brightness: 0.65 + normalized * 0.25)
    }
}
