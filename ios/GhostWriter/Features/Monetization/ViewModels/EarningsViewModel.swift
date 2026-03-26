import Foundation
import Observation

@Observable
final class EarningsViewModel {

    var totalEarnings: Double = 0
    var monthlyEarnings: [CreatorEarnings] = []
    var pendingPayout: Double = 0
    var isLoading: Bool = false
    var isRequestingPayout: Bool = false
    var error: Error?
    var payoutHistory: [PayoutRecord] = []
    var showPayoutSuccess: Bool = false

    private let paymentService: PaymentService
    private let userId = UUID()

    init(paymentService: PaymentService = PaymentService()) {
        self.paymentService = paymentService
    }

    func loadEarnings() async {
        isLoading = true
        defer { isLoading = false }

        do {
            let thirtyDaysAgo = Calendar.current.date(byAdding: .day, value: -30, to: .now) ?? .now
            let period = DateInterval(start: thirtyDaysAgo, end: .now)

            totalEarnings = try await paymentService.calculateEarnings(for: userId, period: period)
            pendingPayout = paymentService.pendingPayouts
            payoutHistory = paymentService.payoutHistory
            generateMockMonthlyEarnings()
        } catch {
            self.error = error
        }
    }

    func requestPayout() async throws {
        isRequestingPayout = true
        defer { isRequestingPayout = false }

        try await paymentService.requestPayout()
        pendingPayout = paymentService.pendingPayouts
        payoutHistory = paymentService.payoutHistory
        showPayoutSuccess = true
    }

    var clipRevenuePercent: Double {
        guard totalEarnings > 0 else { return 0 }
        return 0.50
    }

    var personalityRevenuePercent: Double {
        guard totalEarnings > 0 else { return 0 }
        return 0.35
    }

    var tipRevenuePercent: Double {
        guard totalEarnings > 0 else { return 0 }
        return 0.15
    }

    var formattedTotal: String {
        String(format: "$%.2f", totalEarnings)
    }

    var formattedPending: String {
        String(format: "$%.2f", pendingPayout)
    }

    private func generateMockMonthlyEarnings() {
        let calendar = Calendar.current
        monthlyEarnings = (0..<30).compactMap { dayOffset in
            guard let date = calendar.date(byAdding: .day, value: -dayOffset, to: .now) else {
                return nil
            }
            return CreatorEarnings(
                userId: userId,
                date: date,
                clipRevenue: Double.random(in: 1...20),
                personalityRevenue: Double.random(in: 0.5...10),
                tipRevenue: Double.random(in: 0...5),
                clipViews: Int.random(in: 50...500),
                personalitySales: Int.random(in: 0...5)
            )
        }
    }
}
