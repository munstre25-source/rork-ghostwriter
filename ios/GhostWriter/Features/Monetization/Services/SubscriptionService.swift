import Foundation
import Observation

// MARK: - SubscriptionError

/// Errors that can occur during subscription operations.
enum SubscriptionError: Error, LocalizedError, Sendable {
    case productsLoadFailed
    case purchaseFailed
    case restoreFailed
    case verificationFailed
    case cancelled

    var errorDescription: String? {
        switch self {
        case .productsLoadFailed:   "Failed to load available subscriptions."
        case .purchaseFailed:       "Subscription purchase failed."
        case .restoreFailed:        "Failed to restore purchases."
        case .verificationFailed:   "Subscription verification failed."
        case .cancelled:            "Purchase was cancelled."
        }
    }
}

// MARK: - SubscriptionService

/// Manages subscription products, purchases, and entitlement checks.
///
/// Architecture is ready for StoreKit 2 integration. Current implementation
/// uses mock data for development and testing.
@Observable
final class SubscriptionService: @unchecked Sendable {

    /// The user's current subscription tier.
    var currentTier: SubscriptionTier = .free

    /// Available subscription products from the App Store.
    var availableSubscriptions: [Subscription] = []

    /// Loads available subscription products.
    ///
    /// - Throws: ``SubscriptionError/productsLoadFailed`` if products cannot be fetched.
    func loadProducts() async throws {
        try await Task.sleep(for: .seconds(Double.random(in: 0.5...1.5)))

        availableSubscriptions = [
            Subscription(
                id: "com.ghostwriter.creator.monthly",
                tier: .creator,
                price: 9.99,
                period: .monthly
            ),
            Subscription(
                id: "com.ghostwriter.creator.yearly",
                tier: .creator,
                price: 99.99,
                period: .yearly
            ),
            Subscription(
                id: "com.ghostwriter.pro.monthly",
                tier: .pro,
                price: 19.99,
                period: .monthly
            ),
            Subscription(
                id: "com.ghostwriter.pro.yearly",
                tier: .pro,
                price: 199.99,
                period: .yearly
            ),
            Subscription(
                id: "com.ghostwriter.studio.monthly",
                tier: .studio,
                price: 39.99,
                period: .monthly
            ),
            Subscription(
                id: "com.ghostwriter.studio.yearly",
                tier: .studio,
                price: 399.99,
                period: .yearly
            )
        ]
    }

    /// Purchases a subscription product.
    ///
    /// - Parameter subscription: The subscription to purchase.
    /// - Throws: ``SubscriptionError/purchaseFailed`` if the purchase cannot complete.
    func purchase(_ subscription: Subscription) async throws {
        try await Task.sleep(for: .seconds(Double.random(in: 1.0...2.0)))

        currentTier = subscription.tier
        print("[Subscription] Purchased \(subscription.tier.displayName) (\(subscription.period.displayName))")
    }

    /// Restores previously purchased subscriptions.
    ///
    /// - Throws: ``SubscriptionError/restoreFailed`` if restoration fails.
    func restorePurchases() async throws {
        try await Task.sleep(for: .seconds(Double.random(in: 1.0...2.0)))

        print("[Subscription] Purchases restored — tier: \(currentTier.displayName)")
    }

    /// Checks the current subscription status and updates the tier.
    func checkSubscriptionStatus() async {
        try? await Task.sleep(for: .seconds(Double.random(in: 0.3...0.8)))

        print("[Subscription] Status check — current tier: \(currentTier.displayName)")
    }
}
