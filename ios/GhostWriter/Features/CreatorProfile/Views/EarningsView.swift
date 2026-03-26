import SwiftUI

struct EarningsView: View {
    @State private var totalEarnings: Double = 247.50
    @State private var pendingPayout: Double = 85.20
    @State private var clipRevenue: Double = 150.00
    @State private var personalityRevenue: Double = 72.50
    @State private var tipRevenue: Double = 25.00

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                heroCard
                revenueBreakdown
                monthlyTrend
                payoutButton
            }
            .padding()
        }
        .background(Color.ghostBackground.ignoresSafeArea())
        .navigationTitle("Earnings")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var heroCard: some View {
        VStack(spacing: 8) {
            Text("Total Earnings")
                .font(.subheadline)
                .foregroundColor(.gray)
            Text(String(format: "$%.2f", totalEarnings))
                .font(.system(size: 42, weight: .bold, design: .rounded))
                .foregroundColor(.ghostEmerald)
            Text("Pending: \(String(format: "$%.2f", pendingPayout))")
                .font(.caption)
                .foregroundColor(.ghostGold)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(
            LinearGradient(
                colors: [.ghostEmerald.opacity(0.1), .ghostCyan.opacity(0.05)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .background(.ultraThinMaterial)
        .cornerRadius(16)
    }

    private var revenueBreakdown: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Revenue Breakdown")
                .font(.headline)
                .foregroundColor(.ghostText)

            revenueRow(label: "Clip Views (CPM)", amount: clipRevenue, color: .ghostCyan, ratio: clipRevenue / totalEarnings)
            revenueRow(label: "Personality Sales", amount: personalityRevenue, color: .ghostMagenta, ratio: personalityRevenue / totalEarnings)
            revenueRow(label: "Tips", amount: tipRevenue, color: .ghostGold, ratio: tipRevenue / totalEarnings)
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(14)
    }

    private func revenueRow(label: String, amount: Double, color: Color, ratio: Double) -> some View {
        VStack(spacing: 4) {
            HStack {
                Circle()
                    .fill(color)
                    .frame(width: 8, height: 8)
                Text(label)
                    .font(.subheadline)
                    .foregroundColor(.ghostText)
                Spacer()
                Text(String(format: "$%.2f", amount))
                    .font(.subheadline.bold())
                    .foregroundColor(.ghostText)
            }

            GeometryReader { geo in
                RoundedRectangle(cornerRadius: 3)
                    .fill(color.opacity(0.6))
                    .frame(width: geo.size.width * ratio)
            }
            .frame(height: 6)
            .background(Color.gray.opacity(0.2))
            .cornerRadius(3)
        }
    }

    private var monthlyTrend: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Last 30 Days")
                .font(.headline)
                .foregroundColor(.ghostText)

            HStack(alignment: .bottom, spacing: 4) {
                ForEach(0..<30, id: \.self) { day in
                    let height = Double.random(in: 0.1...1.0)
                    RoundedRectangle(cornerRadius: 2)
                        .fill(height > 0.5 ? Color.ghostEmerald : Color.gray.opacity(0.3))
                        .frame(height: CGFloat(height) * 50)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 60)
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(14)
    }

    private var payoutButton: some View {
        Button {
            // Request payout
        } label: {
            HStack {
                Image(systemName: "banknote")
                Text("Request Payout")
            }
            .font(.headline)
            .foregroundColor(.black)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(Color.ghostEmerald)
            .cornerRadius(14)
        }
        .disabled(pendingPayout < 25)
        .hapticFeedback(.medium)
    }
}

#Preview {
    NavigationStack {
        EarningsView()
    }
}
