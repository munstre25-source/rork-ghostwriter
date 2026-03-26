import WidgetKit
import SwiftUI

nonisolated struct FlowCrestEntry: TimelineEntry {
    let date: Date
    let readinessScore: Double
    let readinessCategory: String
    let nextTask: String
    let nextTaskEnergy: String
    let nextTaskStart: Date?
    let focusScore: Double
    let insight: String
}

nonisolated struct FlowCrestProvider: TimelineProvider {
    func placeholder(in context: Context) -> FlowCrestEntry {
        FlowCrestEntry(
            date: .now,
            readinessScore: 72,
            readinessCategory: "Good",
            nextTask: "Deep Work Session",
            nextTaskEnergy: "deep",
            nextTaskStart: Date().addingTimeInterval(1800),
            focusScore: 78,
            insight: "Great day so far!"
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (FlowCrestEntry) -> Void) {
        completion(readEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<FlowCrestEntry>) -> Void) {
        let entry = readEntry()
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 30, to: Date())!
        completion(Timeline(entries: [entry], policy: .after(nextUpdate)))
    }

    private func readEntry() -> FlowCrestEntry {
        let defaults = UserDefaults(suiteName: "group.app.rork.flowcrest.shared")
        let score = defaults?.double(forKey: "currentReadiness") ?? 0
        let nextTask = defaults?.string(forKey: "nextTaskDescription") ?? ""
        let nextEnergy = defaults?.string(forKey: "nextTaskEnergy") ?? ""
        let nextStart = defaults?.double(forKey: "nextTaskStart") ?? 0
        let focusScore = defaults?.double(forKey: "latestFocusScore") ?? 0
        let insight = defaults?.string(forKey: "latestInsight") ?? ""

        let category: String
        switch score {
        case 80...100: category = "Peak"
        case 60..<80: category = "Good"
        case 40..<60: category = "Moderate"
        case 20..<40: category = "Low"
        default: category = score > 0 ? "Very Low" : "—"
        }

        return FlowCrestEntry(
            date: .now,
            readinessScore: score,
            readinessCategory: category,
            nextTask: nextTask,
            nextTaskEnergy: nextEnergy,
            nextTaskStart: nextStart > 0 ? Date(timeIntervalSince1970: nextStart) : nil,
            focusScore: focusScore,
            insight: insight
        )
    }
}

struct FlowCrestWidgetView: View {
    @Environment(\.widgetFamily) var family
    var entry: FlowCrestEntry

    var body: some View {
        switch family {
        case .systemSmall:
            smallWidget
        case .systemMedium:
            mediumWidget
        default:
            largeWidget
        }
    }

    private var smallWidget: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "brain.head.profile.fill")
                    .font(.caption)
                    .foregroundStyle(readinessColor)
                Spacer()
                Text(entry.readinessCategory)
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(readinessColor)
            }

            Spacer()

            Text("\(Int(entry.readinessScore))")
                .font(.system(size: 44, weight: .bold, design: .rounded))
                .foregroundStyle(readinessColor)

            Text("Readiness")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .containerBackground(.fill.tertiary, for: .widget)
    }

    private var mediumWidget: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 6) {
                    Image(systemName: "brain.head.profile.fill")
                        .font(.caption)
                        .foregroundStyle(readinessColor)
                    Text("Cognitive Readiness")
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(.secondary)
                }

                Text("\(Int(entry.readinessScore))")
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                    .foregroundStyle(readinessColor)

                Text(entry.readinessCategory)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(readinessColor)
            }

            Divider()

            if !entry.nextTask.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    Text("NEXT UP")
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(.secondary)

                    Text(entry.nextTask)
                        .font(.subheadline.weight(.medium))
                        .lineLimit(2)

                    HStack(spacing: 4) {
                        Image(systemName: energyIcon)
                            .font(.caption2)
                        Text(energyLabel)
                            .font(.caption2)
                    }
                    .foregroundStyle(.secondary)

                    if let start = entry.nextTaskStart {
                        Text(start, style: .relative)
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                    }
                }
            } else {
                VStack(alignment: .leading, spacing: 6) {
                    Text("No upcoming tasks")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Text("Add focus blocks in the app")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
            }

            Spacer(minLength: 0)
        }
        .containerBackground(.fill.tertiary, for: .widget)
    }

    private var largeWidget: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Image(systemName: "brain.head.profile.fill")
                            .foregroundStyle(readinessColor)
                        Text("FlowCrest")
                            .font(.headline)
                    }
                    Text("Cognitive Readiness")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Text(entry.readinessCategory)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(readinessColor)
                    .clipShape(.capsule)
            }

            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text("\(Int(entry.readinessScore))")
                    .font(.system(size: 52, weight: .bold, design: .rounded))
                    .foregroundStyle(readinessColor)
                Text("/ 100")
                    .font(.title3)
                    .foregroundStyle(.secondary)
            }

            Divider()

            if entry.focusScore > 0 {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Today's Focus Score")
                            .font(.caption.weight(.medium))
                            .foregroundStyle(.secondary)
                        Text("\(Int(entry.focusScore))")
                            .font(.title2.bold())
                            .foregroundStyle(.teal)
                    }
                    Spacer()
                }
            }

            if !entry.nextTask.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("NEXT UP")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(.secondary)
                    HStack(spacing: 8) {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(energyColor)
                            .frame(width: 3)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(entry.nextTask)
                                .font(.subheadline.weight(.medium))
                            HStack(spacing: 4) {
                                Image(systemName: energyIcon)
                                Text(energyLabel)
                            }
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                        }
                    }
                    .frame(height: 40)
                }
            }

            Spacer(minLength: 0)
        }
        .containerBackground(.fill.tertiary, for: .widget)
    }

    private var readinessColor: Color {
        switch entry.readinessScore {
        case 80...100: return .green
        case 60..<80: return .teal
        case 40..<60: return .yellow
        case 20..<40: return .orange
        default: return entry.readinessScore > 0 ? .red : .secondary
        }
    }

    private var energyIcon: String {
        switch entry.nextTaskEnergy {
        case "deep": return "brain.head.profile.fill"
        case "admin": return "envelope.fill"
        default: return "list.bullet.clipboard"
        }
    }

    private var energyLabel: String {
        switch entry.nextTaskEnergy {
        case "deep": return "Deep Work"
        case "admin": return "Admin"
        default: return "Shallow Work"
        }
    }

    private var energyColor: Color {
        switch entry.nextTaskEnergy {
        case "deep": return .indigo
        case "admin": return .orange
        default: return .teal
        }
    }
}

struct FlowCrestWidget: Widget {
    let kind: String = "FlowCrestWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: FlowCrestProvider()) { entry in
            FlowCrestWidgetView(entry: entry)
        }
        .configurationDisplayName("Cognitive Readiness")
        .description("See your current cognitive readiness score and next focus block.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}
