import SwiftUI

struct FocusBlockRow: View {
    let block: FocusBlock
    var readinessScore: Double = 0
    var showAlignment: Bool = false

    var body: some View {
        HStack(spacing: 14) {
            RoundedRectangle(cornerRadius: 3)
                .fill(energyColor)
                .frame(width: 4)
                .frame(maxHeight: .infinity)
                .padding(.vertical, 4)

            VStack(alignment: .leading, spacing: 4) {
                Text(block.taskDescription)
                    .font(.subheadline.weight(.medium))
                    .strikethrough(block.isCompleted)
                    .foregroundStyle(block.isCompleted ? .secondary : .primary)

                HStack(spacing: 8) {
                    Label(block.intendedEnergyLevel.displayName, systemImage: block.intendedEnergyLevel.icon)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(timeRange)
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
            }

            Spacer()

            if showAlignment && !block.isCompleted && readinessScore > 0 {
                alignmentIndicator
            }

            if block.hasMismatch {
                Image(systemName: "exclamationmark.circle.fill")
                    .foregroundStyle(.orange)
                    .font(.body)
            }

            if block.isCompleted {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: 14))
    }

    @ViewBuilder
    private var alignmentIndicator: some View {
        let threshold = block.intendedEnergyLevel.minimumReadinessThreshold
        let isAligned = readinessScore >= threshold

        Circle()
            .fill(isAligned ? Color.green.opacity(0.2) : Color.orange.opacity(0.2))
            .frame(width: 28, height: 28)
            .overlay {
                Image(systemName: isAligned ? "checkmark" : "arrow.triangle.swap")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(isAligned ? .green : .orange)
            }
    }

    private var energyColor: Color {
        Color.energyLevelColor(for: block.intendedEnergyLevel)
    }

    private var timeRange: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return "\(formatter.string(from: block.startTime)) – \(formatter.string(from: block.endTime))"
    }
}
