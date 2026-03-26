import ActivityKit
import WidgetKit
import SwiftUI

nonisolated struct FocusActivityAttributes: ActivityAttributes {
    nonisolated struct ContentState: Codable, Hashable, Sendable {
        var taskDescription: String
        var energyLevelRaw: String
        var endTime: Date
        var readinessScore: Double
    }

    var blockID: String
    var startTime: Date
}

struct FlowCrestLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: FocusActivityAttributes.self) { context in
            lockScreenView(context: context)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    VStack(alignment: .leading, spacing: 2) {
                        Image(systemName: energyIcon(context.state.energyLevelRaw))
                            .font(.title2)
                            .foregroundStyle(energyColor(context.state.energyLevelRaw))
                        Text(energyLabel(context.state.energyLevelRaw))
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
                DynamicIslandExpandedRegion(.trailing) {
                    VStack(alignment: .trailing, spacing: 2) {
                        Text(context.state.endTime, style: .timer)
                            .font(.title2.monospacedDigit().weight(.semibold))
                            .foregroundStyle(.primary)
                        Text("remaining")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
                DynamicIslandExpandedRegion(.center) {
                    Text(context.state.taskDescription)
                        .font(.subheadline.weight(.semibold))
                        .lineLimit(1)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    HStack(spacing: 8) {
                        alignmentIndicator(context: context)
                        Spacer()
                        Text("Readiness: \(Int(context.state.readinessScore))/100")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            } compactLeading: {
                Image(systemName: energyIcon(context.state.energyLevelRaw))
                    .foregroundStyle(energyColor(context.state.energyLevelRaw))
            } compactTrailing: {
                Text(context.state.endTime, style: .timer)
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(alignmentColor(context: context))
            } minimal: {
                Image(systemName: "brain.head.profile.fill")
                    .foregroundStyle(alignmentColor(context: context))
            }
        }
    }

    private func lockScreenView(context: ActivityViewContext<FocusActivityAttributes>) -> some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 6) {
                    Image(systemName: energyIcon(context.state.energyLevelRaw))
                        .foregroundStyle(energyColor(context.state.energyLevelRaw))
                    Text(context.state.taskDescription)
                        .font(.subheadline.weight(.semibold))
                        .lineLimit(1)
                }

                HStack(spacing: 12) {
                    alignmentIndicator(context: context)
                    Text("Readiness: \(Int(context.state.readinessScore))/100")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text(context.state.endTime, style: .timer)
                    .font(.title3.monospacedDigit().weight(.semibold))
                Text("left")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(16)
    }

    private func alignmentIndicator(context: ActivityViewContext<FocusActivityAttributes>) -> some View {
        let threshold = energyThreshold(context.state.energyLevelRaw)
        let isAligned = context.state.readinessScore >= threshold

        return HStack(spacing: 4) {
            Circle()
                .fill(isAligned ? Color.green : Color.orange)
                .frame(width: 6, height: 6)
            Text(isAligned ? "Aligned" : "Misaligned")
                .font(.caption2.weight(.medium))
                .foregroundStyle(isAligned ? .green : .orange)
        }
    }

    private func alignmentColor(context: ActivityViewContext<FocusActivityAttributes>) -> Color {
        let threshold = energyThreshold(context.state.energyLevelRaw)
        return context.state.readinessScore >= threshold ? .teal : .orange
    }

    private func energyIcon(_ raw: String) -> String {
        switch raw {
        case "deep": return "brain.head.profile.fill"
        case "admin": return "envelope.fill"
        default: return "list.bullet.clipboard"
        }
    }

    private func energyLabel(_ raw: String) -> String {
        switch raw {
        case "deep": return "Deep Work"
        case "admin": return "Admin"
        default: return "Shallow"
        }
    }

    private func energyColor(_ raw: String) -> Color {
        switch raw {
        case "deep": return .indigo
        case "admin": return .orange
        default: return .teal
        }
    }

    private func energyThreshold(_ raw: String) -> Double {
        switch raw {
        case "deep": return 60.0
        case "shallow": return 35.0
        default: return 15.0
        }
    }
}
