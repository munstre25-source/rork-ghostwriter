import Foundation
import Observation
import StoreKit

// MARK: - SubscriptionError

/// Errors that can occur during subscription operations.
enum SubscriptionError: Error, LocalizedError, Sendable {
    /// StoreKit failed to return products for the requested identifiers.
    case productsLoadFailed
    /// The in-app purchase transaction could not be completed.
    case purchaseFailed
    /// Restoring previously purchased subscriptions failed.
    case restoreFailed
    /// The App Store receipt or transaction could not be verified.
    case verificationFailed
    /// The user explicitly cancelled the purchase flow.
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

/// Manages subscription products, purchases, and entitlement checks via StoreKit 2.
///
/// ## Overview
///
/// `SubscriptionService` wraps the StoreKit 2 APIs to provide a streamlined
/// interface for loading products, executing purchases, restoring transactions,
/// and continuously monitoring entitlement status.
///
/// When products are not yet configured in App Store Connect the service falls
/// back to mock catalogue data so the UI remains functional during development.
///
/// ## Usage
///
/// ```swift
/// let service = SubscriptionService()
/// try await service.loadProducts()
/// try await service.purchase(service.availableSubscriptions.first!)
/// ```
///
/// ## Concurrency
///
/// The class is `@Observable` for SwiftUI integration and conforms to
/// `@unchecked Sendable` because all mutable state is written exclusively
/// from `async` entry points that serialise through StoreKit's own
/// concurrency guarantees.
@Observable
final class SubscriptionService: @unchecked Sendable {

    // MARK: Product Identifiers

    /// The set of product identifiers registered in App Store Connect.
    static let productIDs: Set<String> = [
        "com.ghostwriter.creator.monthly",
        "com.ghostwriter.creator.yearly",
        "com.ghostwriter.pro.monthly",
        "com.ghostwriter.pro.yearly",
        "com.ghostwriter.studio.monthly",
        "com.ghostwriter.studio.yearly"
    ]

    // MARK: Observable State

    /// The user's current subscription tier derived from active entitlements.
    var currentTier: SubscriptionTier = .free

    /// Subscription descriptors available for purchase.
    var availableSubscriptions: [Subscription] = []

    /// Locale-formatted display prices keyed by product identifier.
    ///
    /// When real StoreKit products are loaded the values come from
    /// `Product.displayPrice`. For mock fallback data a `NumberFormatter`
    /// with the user's current locale is used instead.
    var formattedPrices: [String: String] = [:]

    // MARK: Private State

    private var storeKitProducts: [String: Product] = [:]
    private var transactionListenerTask: Task<Void, Never>?
    private var isUsingMockData = false

    // MARK: Lifecycle

    /// Creates a new service and immediately begins listening for
    /// transaction updates from the App Store.
    init() {
        transactionListenerTask = Task(priority: .background) { [weak self] in
            await self?.listenForTransactionUpdates()
        }
    }

    deinit {
        transactionListenerTask?.cancel()
    }

    // MARK: - Loading Products

    /// Fetches subscription products from the App Store.
    ///
    /// If StoreKit returns no products (e.g. they haven't been configured in
    /// App Store Connect yet) the service transparently falls back to built-in
    /// mock catalogue data so the UI can still render.
    ///
    /// After products are loaded ``checkSubscriptionStatus()`` runs
    /// automatically to synchronise ``currentTier``.
    ///
    /// - Throws: ``SubscriptionError/productsLoadFailed`` only when both
    ///   StoreKit *and* the fallback fail (should not happen in practice).
    func loadProducts() async throws {
        do {
            let products = try await Product.products(for: Self.productIDs)

            guard !products.isEmpty else {
                loadMockProducts()
                await checkSubscriptionStatus()
                return
            }

            var subscriptions: [Subscription] = []
            var prices: [String: String] = [:]
            var productMap: [String: Product] = [:]

            for product in products {
                guard let (tier, period) = Self.parseTierAndPeriod(from: product.id) else {
                    continue
                }
                subscriptions.append(
                    Subscription(id: product.id, tier: tier, price: product.price, period: period)
                )
                prices[product.id] = product.displayPrice
                productMap[product.id] = product
            }

            subscriptions.sort { lhs, rhs in
                let lo = Self.tierSortOrder(lhs.tier)
                let ro = Self.tierSortOrder(rhs.tier)
                if lo != ro { return lo < ro }
                return lhs.period == .monthly
            }

            self.availableSubscriptions = subscriptions
            self.formattedPrices = prices
            self.storeKitProducts = productMap
            self.isUsingMockData = false

        } catch {
            loadMockProducts()
        }

        await checkSubscriptionStatus()
    }

    // MARK: - Purchasing

    /// Initiates a purchase for the given subscription.
    ///
    /// When running against mock data the purchase is simulated locally.
    /// Otherwise the full StoreKit 2 purchase flow is executed including
    /// server verification.
    ///
    /// - Parameter subscription: The subscription to purchase.
    /// - Throws: ``SubscriptionError/cancelled`` when the user dismisses
    ///   the payment sheet, ``SubscriptionError/verificationFailed`` when
    ///   the receipt cannot be verified, or ``SubscriptionError/purchaseFailed``
    ///   for all other failures.
    func purchase(_ subscription: Subscription) async throws {
        if isUsingMockData {
            try await Task.sleep(for: .seconds(1))
            currentTier = subscription.tier
            return
        }

        guard let product = storeKitProducts[subscription.id] else {
            throw SubscriptionError.purchaseFailed
        }

        let result: Product.PurchaseResult

        do {
            result = try await product.purchase()
        } catch let error as StoreKitError {
            throw Self.mapStoreKitError(error)
        } catch {
            throw SubscriptionError.purchaseFailed
        }

        switch result {
        case .success(let verification):
            let transaction = try checkVerification(verification)
            await transaction.finish()
            await checkSubscriptionStatus()

        case .userCancelled:
            throw SubscriptionError.cancelled

        case .pending:
            break

        @unknown default:
            throw SubscriptionError.purchaseFailed
        }
    }

    // MARK: - Restoring Purchases

    /// Synchronises the local receipt with the App Store and refreshes
    /// the current entitlement status.
    ///
    /// When running against mock data this is a no-op because there are
    /// no real transactions to restore.
    ///
    /// - Throws: ``SubscriptionError/restoreFailed`` if `AppStore.sync()` fails.
    func restorePurchases() async throws {
        if isUsingMockData { return }

        do {
            try await AppStore.sync()
        } catch {
            throw SubscriptionError.restoreFailed
        }

        await checkSubscriptionStatus()
    }

    // MARK: - Entitlement Status

    /// Iterates through `Transaction.currentEntitlements` and sets
    /// ``currentTier`` to the highest active tier found.
    func checkSubscriptionStatus() async {
        var highestTier: SubscriptionTier = .free

        for await result in Transaction.currentEntitlements {
            guard let transaction = try? checkVerification(result) else { continue }

            if let (tier, _) = Self.parseTierAndPeriod(from: transaction.productID),
               Self.tierSortOrder(tier) > Self.tierSortOrder(highestTier) {
                highestTier = tier
            }
        }

        currentTier = highestTier
    }

    // MARK: - Transaction Listener

    /// Continuously observes `Transaction.updates` for renewals, revocations,
    /// and other server-side changes, finishing each verified transaction and
    /// refreshing the entitlement status.
    private func listenForTransactionUpdates() async {
        for await result in Transaction.updates {
            guard let transaction = try? checkVerification(result) else { continue }
            await transaction.finish()
            await checkSubscriptionStatus()
        }
    }

    // MARK: - Verification

    /// Unwraps a `VerificationResult`, returning the payload for verified
    /// results and throwing ``SubscriptionError/verificationFailed`` for
    /// unverified ones.
    private func checkVerification<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .verified(let value):
            return value
        case .unverified:
            throw SubscriptionError.verificationFailed
        }
    }

    // MARK: - Helpers

    /// Extracts the ``SubscriptionTier`` and ``SubscriptionPeriod`` encoded
    /// in a product identifier of the form `com.ghostwriter.<tier>.<period>`.
    private static func parseTierAndPeriod(
        from productID: String
    ) -> (SubscriptionTier, SubscriptionPeriod)? {
        let components = productID.split(separator: ".")
        guard components.count == 4,
              let tier = SubscriptionTier(rawValue: String(components[2])),
              let period = SubscriptionPeriod(rawValue: String(components[3]))
        else { return nil }
        return (tier, period)
    }

    /// Stable sort order for subscription tiers (lowest to highest).
    private static func tierSortOrder(_ tier: SubscriptionTier) -> Int {
        switch tier {
        case .free:       0
        case .creator:    1
        case .pro:        2
        case .studio:     3
        case .enterprise: 4
        }
    }

    /// Maps a `StoreKitError` to the corresponding ``SubscriptionError``.
    private static func mapStoreKitError(_ error: StoreKitError) -> SubscriptionError {
        switch error {
        case .userCancelled:
            .cancelled
        case .networkError:
            .purchaseFailed
        default:
            .purchaseFailed
        }
    }

    // MARK: - Mock Fallback

    /// Populates ``availableSubscriptions`` and ``formattedPrices`` with
    /// hard-coded development data when real products are unavailable.
    private func loadMockProducts() {
        let mockData: [(String, SubscriptionTier, Decimal, SubscriptionPeriod)] = [
            ("com.ghostwriter.creator.monthly", .creator,  9.99,  .monthly),
            ("com.ghostwriter.creator.yearly",  .creator,  79.00, .yearly),
            ("com.ghostwriter.pro.monthly",     .pro,      19.99, .monthly),
            ("com.ghostwriter.pro.yearly",      .pro,      149.00, .yearly),
            ("com.ghostwriter.studio.monthly",  .studio,   49.99, .monthly),
            ("com.ghostwriter.studio.yearly",   .studio,   399.99, .yearly),
        ]

        availableSubscriptions = mockData.map {
            Subscription(id: $0.0, tier: $0.1, price: $0.2, period: $0.3)
        }

        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = .current

        formattedPrices = [:]
        for sub in availableSubscriptions {
            formattedPrices[sub.id] = formatter.string(
                from: sub.price as NSDecimalNumber
            ) ?? "$\(sub.price)"
        }

        storeKitProducts = [:]
        isUsingMockData = true
    }
}
