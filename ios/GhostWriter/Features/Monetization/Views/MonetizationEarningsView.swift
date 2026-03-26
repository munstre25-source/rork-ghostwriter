import SwiftUI

struct MonetizationEarningsView: View {

    @State private var viewModel = EarningsViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                Color.ghostBackground.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        if viewModel.isLoading {
                            loadingState
                        } else {
                            earningsHero
                            revenueBreakdown
                            monthlyTrend
                            payoutSection
                            payoutHistoryList
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 32)
                }
                .refreshable {
                    await viewModel.loadEarnings()
                }
            }
            .navigationTitle("Earnings")
            .navigationBarTitleDisplayMode(.large)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .task {
                await viewModel.loadEarnings()
            }
            .alert("Payout Requested", isPresented: $viewModel.showPayoutSuccess) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Your payout is being processed. You'll receive funds within 3-5 business days.")
            }
        }
    }

    // MARK: - Earnings Hero

    private var earningsHero: some View {
        VStack(spacing: 8) {
            Image(systemName: "dollarsign.circle.fill")
                .font(.system(size: 44))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.ghostGold, .ghostEmerald],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .ghostGlow(color: .ghostGold, intensity: 0.4)

            Text("Total Earnings")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(.ghostText.opacity(0.6))

            Text(viewModel.formattedTotal)
                .font(.system(size: 48, weight: .bold, design: .rounded))
                .foregroundStyle(.ghostText)

            Text("Last 30 days")
                .font(.system(size: 12))
                .foregroundStyle(.ghostText.opacity(0.4))
        }
        .padding(.vertical, 24)
        .frame(maxWidth: .infinity)
        .liquidGlass(cornerRadius: 20)
    }

    // MARK: - Revenue Breakdown

    private var revenueBreakdown: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Revenue Sources")
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(.ghostText)

            revenueRow(
                icon: "play.rectangle.fill",
                label: "Clip CPM",
                percent: viewModel.clipRevenuePercent,
                amount: viewModel.totalEarnings * viewModel.clipRevenuePercent,
                color: .ghostCyan
            )

            revenueRow(
                icon: "theatermasks.fill",
                label: "Personality Sales",
                percent: viewModel.personalityRevenuePercent,
                amount: viewModel.totalEarnings * viewModel.personalityRevenuePercent,
                color: .ghostMagenta
            )

            revenueRow(
                icon: "heart.fill",
                label: "Tips",
                percent: viewModel.tipRevenuePercent,
                amount: viewModel.totalEarnings * viewModel.tipRevenuePercent,
                color: .ghostEmerald
            )
        }
        .padding(16)
        .liquidGlass(cornerRadius: 16)
    }

    private func revenueRow(icon: String, label: String, percent: Double, amount: Double, color: Color) -> some View {
        VStack(spacing: 8) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundStyle(color)
                    .frame(width: 28)

                VStack(alignment: .leading, spacing: 2) {
                    Text(label)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.ghostText)
                    Text("\(Int(percent * 100))% of revenue")
                        .font(.system(size: 11))
                        .foregroundStyle(.ghostText.opacity(0.4))
                }

                Spacer()

                Text(String(format: "$%.2f", amount))
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(color)
            }

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.white.opacity(0.06))
                        .frame(height: 6)

                    Capsule()
                        .fill(color)
                        .frame(width: geometry.size.width * percent, height: 6)
                }
            }
            .frame(height: 6)
        }
    }

    // MARK: - Monthly Trend

    private var monthlyTrend: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("30-Day Trend")
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(.ghostText)

            HStack(alignment: .bottom, spacing: 3) {
                ForEach(viewModel.monthlyEarnings.reversed().prefix(30), id: \.id) { earning in
                    let maxRevenue = viewModel.monthlyEarnings.map(\.totalRevenue).max() ?? 1
                    let height = max(4, CGFloat(earning.totalRevenue / maxRevenue) * 60)

                    RoundedRectangle(cornerRadius: 2)
                        .fill(
                            LinearGradient(
                                colors: [.ghostCyan.opacity(0.6), .ghostCyan],
                                startPoint: .bottom,
                                endPoint: .top
                            )
                        )
                        .frame(height: height)
                }
            }
            .frame(height: 64)
            .frame(maxWidth: .infinity)

            HStack {
                Text("30 days ago")
                    .font(.system(size: 10))
                    .foregroundStyle(.ghostText.opacity(0.3))
                Spacer()
                Text("Today")
                    .font(.system(size: 10))
                    .foregroundStyle(.ghostText.opacity(0.3))
            }
        }
        .padding(16)
        .liquidGlass(cornerRadius: 16)
    }

    // MARK: - Payout

    private var payoutSection: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Pending Payout")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.ghostText.opacity(0.6))
                    Text(viewModel.formattedPending)
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(.ghostGold)
                }

                Spacer()

                Button {
                    Task { try? await viewModel.requestPayout() }
                } label: {
                    Group {
                        if viewModel.isRequestingPayout {
                            ProgressView()
                                .tint(.ghostBackground)
                        } else {
                            Text("Request Payout")
                                .font(.system(size: 14, weight: .bold))
                        }
                    }
                    .foregroundStyle(.ghostBackground)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(
                        Capsule().fill(
                            LinearGradient(
                                colors: [.ghostGold, .ghostEmerald],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                    )
                }
                .hapticFeedback(.medium)
                .disabled(viewModel.isRequestingPayout || viewModel.pendingPayout < 25)
            }

            Text("Minimum payout: $25.00")
                .font(.system(size: 11))
                .foregroundStyle(.ghostText.opacity(0.3))
        }
        .padding(16)
        .liquidGlass(cornerRadius: 16)
    }

    // MARK: - Payout History

    @ViewBuilder
    private var payoutHistoryList: some View {
        if !viewModel.payoutHistory.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                Text("Payout History")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.ghostText)

                ForEach(viewModel.payoutHistory) { record in
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(String(format: "$%.2f", record.amount))
                                .font(.system(size: 16, weight: .bold))
                                .foregroundStyle(.ghostText)
                            Text(record.date, format: .dateTime.month().day().year())
                                .font(.system(size: 12))
                                .foregroundStyle(.ghostText.opacity(0.4))
                        }

                        Spacer()

                        Text(record.status.rawValue.capitalized)
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(statusColor(for: record.status))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(
                                Capsule().fill(statusColor(for: record.status).opacity(0.15))
                            )
                    }
                    .padding(12)
                    .liquidGlass(cornerRadius: 12)
                }
            }
        }
    }

    // MARK: - Loading

    private var loadingState: some View {
        VStack(spacing: 16) {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.ultraThinMaterial)
                .frame(height: 180)
                .shimmer()
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.ultraThinMaterial)
                .frame(height: 200)
                .shimmer()
        }
    }

    // MARK: - Helpers

    private func statusColor(for status: PayoutStatus) -> Color {
        switch status {
        case .pending:    .ghostGold
        case .processing: .ghostCyan
        case .completed:  .ghostEmerald
        case .failed:     .ghostMagenta
        }
    }
}

#Preview {
    MonetizationEarningsView()
        .preferredColorScheme(.dark)
}
