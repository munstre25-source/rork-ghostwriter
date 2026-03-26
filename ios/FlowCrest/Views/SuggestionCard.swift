import SwiftUI

struct SuggestionCard: View {
    let suggestion: ScheduleSuggestion
    let onAction: (Bool) -> Void
    @State private var appeared = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "wand.and.stars")
                    .foregroundStyle(.orange)
                Text("Reschedule Suggestion")
                    .font(.subheadline.weight(.semibold))
                Spacer()
                readinessBadge
            }

            Text(suggestion.reason)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(3)

            Divider()

            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Your Readiness")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                    HStack(spacing: 4) {
                        Text("\(Int(suggestion.currentReadiness))")
                            .font(.subheadline.weight(.bold))
                            .foregroundStyle(Color.readinessColor(for: suggestion.currentReadiness))
                        Text("→ needs \(Int(suggestion.requiredReadiness))")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }

                Spacer()

                HStack(spacing: 8) {
                    Button {
                        onAction(false)
                    } label: {
                        Text("Dismiss")
                            .font(.caption.weight(.medium))
                    }
                    .buttonStyle(.bordered)
                    .tint(.secondary)

                    Button {
                        onAction(true)
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "arrow.triangle.swap")
                            Text("Swap")
                        }
                        .font(.caption.weight(.medium))
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.orange)
                }
            }
        }
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.orange.opacity(0.25), lineWidth: 1)
        )
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 8)
        .onAppear {
            withAnimation(.spring(response: 0.4)) { appeared = true }
        }
        .sensoryFeedback(.warning, trigger: appeared)
    }

    private var readinessBadge: some View {
        let deficit = Int(suggestion.requiredReadiness - suggestion.currentReadiness)
        return Text("-\(deficit)")
            .font(.caption2.weight(.bold))
            .foregroundStyle(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(.orange)
            .clipShape(.capsule)
    }
}
