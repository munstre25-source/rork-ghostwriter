import SwiftUI

struct FocusScoreCardView: View {
    let score: Double
    let insight: String
    let onShare: () -> Void

    @State private var appeared = false

    var body: some View {
        VStack(spacing: 16) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("TODAY'S FOCUS")
                        .font(.caption.weight(.semibold))
                        .tracking(1)
                        .foregroundStyle(.secondary)

                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text("\(Int(score))")
                            .font(.system(size: 48, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.readinessColor(for: score))
                            .contentTransition(.numericText())
                        Text("pts")
                            .font(.title3.weight(.medium))
                            .foregroundStyle(.secondary)
                    }
                }

                Spacer()

                Button(action: onShare) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.body.weight(.medium))
                        .foregroundStyle(.teal)
                        .padding(10)
                        .background(Color(.tertiarySystemFill))
                        .clipShape(.circle)
                }
            }

            Text(insight)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(20)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: 20))
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 10)
        .onAppear {
            withAnimation(.spring(response: 0.5).delay(0.1)) {
                appeared = true
            }
        }
    }
}
