import Foundation
import Observation

// MARK: - PayoutRecord

/// A record of a completed payout to the creator.
struct PayoutRecord: Identifiable, Sendable {

    /// Unique identifier for this payout.
    var id: UUID

    /// The amount paid out in USD.
    var amount: Double

    /// When the payout was processed.
    var date: Date

    /// Current status of the payout.
    var status: PayoutStatus

    /// Breakdown of revenue sources in this payout.
    var breakdown: PayoutBreakdown
}

// MARK: - PayoutStatus

/// The processing state of a payout.
enum PayoutStatus: String, Sendable {
    case pending
    case processing
    case completed
    case failed
}

// MARK: - PayoutBreakdown

/// Revenue breakdown by source for a single payout.
struct PayoutBreakdown: Sendable {

    /// Revenue from clip CPM advertising.
    var clipRevenue: Double

    /// Revenue from personality marketplace sales.
    var personalityRevenue: Double

    /// Revenue from user tips.
    var tipRevenue: Double
}

// MARK: - PaymentError

/// Errors that can occur during payment operations.
enum PaymentError: Error, LocalizedError, Sendable {
    case calculationFailed
    case payoutRequestFailed
    case minimumNotMet
    case accountNotSetUp

    var errorDescription: String? {
        switch self {
        case .calculationFailed:    "Failed to calculate earnings."
        case .payoutRequestFailed:  "Payout request failed."
        case .minimumNotMet:        "Minimum payout threshold not met."
        case .accountNotSetUp:      "Payment account has not been set up."
        }
    }
}

// MARK: - PaymentService

/// Manages creator earnings calculations and payout operations.
@Observable
final class PaymentService: @unchecked Sendable {

    /// The amount of unpaid earnings pending payout, in USD.
    var pendingPayouts: Double = 0

    /// Historical payout records, most recent first.
    var payoutHistory: [PayoutRecord] = []

    private let minimumPayoutAmount: Double = 25.0

    /// Calculates total earnings for a creator over a given date interval.
    ///
    /// - Parameters:
    ///   - userId: The creator's user ID.
    ///   - period: The date range to calculate earnings for.
    /// - Returns: Total earnings in USD.
    /// - Throws: ``PaymentError/calculationFailed`` if the calculation fails.
    func calculateEarnings(
        for userId: UUID,
        period: DateInterval
    ) async throws -> Double {
        try await Task.sleep(for: .seconds(Double.random(in: 0.5...1.0)))

        let days = period.duration / 86400.0
        let dailyEarnings = Double.random(in: 2.0...15.0)
        let total = days * dailyEarnings

        pendingPayouts = total
        print("[Payment] Calculated earnings for \(Int(days)) days: $\(String(format: "%.2f", total))")
        return total
    }

    /// Requests a payout of all pending earnings.
    ///
    /// - Throws: ``PaymentError/minimumNotMet`` if pending earnings are below the threshold,
    ///   or ``PaymentError/payoutRequestFailed`` if the request fails.
    func requestPayout() async throws {
        guard pendingPayouts >= minimumPayoutAmount else {
            throw PaymentError.minimumNotMet
        }

        try await Task.sleep(for: .seconds(Double.random(in: 1.0...2.0)))

        let clipShare = pendingPayouts * 0.5
        let personalityShare = pendingPayouts * 0.35
        let tipShare = pendingPayouts * 0.15

        let record = PayoutRecord(
            id: UUID(),
            amount: pendingPayouts,
            date: .now,
            status: .processing,
            breakdown: PayoutBreakdown(
                clipRevenue: clipShare,
                personalityRevenue: personalityShare,
                tipRevenue: tipShare
            )
        )

        payoutHistory.insert(record, at: 0)
        print("[Payment] Payout requested: $\(String(format: "%.2f", pendingPayouts))")
        pendingPayouts = 0
    }
}
