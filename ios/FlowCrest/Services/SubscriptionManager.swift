import Foundation
import StoreKit

@Observable
@MainActor
final class SubscriptionManager {
    static let shared = SubscriptionManager()

    private let monthlyID = "com.flowcrest.premium.monthly"
    private let yearlyID = "com.flowcrest.premium.yearly"
    private let groupID = "FlowCrestPremium"

    var products: [Product] = []
    var isPremium: Bool = false
    var currentSubscriptionProductID: String?
    var isLoading: Bool = false

    private var transactionListener: Task<Void, Never>?

    var monthlyProduct: Product? {
        products.first { $0.id == monthlyID }
    }

    var yearlyProduct: Product? {
        products.first { $0.id == yearlyID }
    }

    private init() {
        transactionListener = listenForTransactions()
        Task { await loadProducts() }
        Task { await refreshEntitlements() }
    }

    func loadProducts() async {
        isLoading = true
        defer { isLoading = false }
        do {
            products = try await Product.products(for: [monthlyID, yearlyID])
                .sorted { $0.price < $1.price }
        } catch {
            products = []
        }
    }

    func purchase(_ product: Product) async throws -> Bool {
        let result = try await product.purchase()
        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)
            await transaction.finish()
            await refreshEntitlements()
            return true
        case .userCancelled:
            return false
        case .pending:
            return false
        @unknown default:
            return false
        }
    }

    func refreshEntitlements() async {
        var foundPremium = false
        var foundProductID: String?

        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result {
                if transaction.productID == monthlyID || transaction.productID == yearlyID {
                    foundPremium = true
                    foundProductID = transaction.productID
                }
            }
        }

        isPremium = foundPremium
        currentSubscriptionProductID = foundProductID
    }

    func restorePurchases() async {
        try? await AppStore.sync()
        await refreshEntitlements()
    }

    private func listenForTransactions() -> Task<Void, Never> {
        Task.detached {
            for await result in Transaction.updates {
                if case .verified(let transaction) = result {
                    await transaction.finish()
                    await self.refreshEntitlements()
                }
            }
        }
    }

    nonisolated private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .verified(let value):
            return value
        case .unverified(_, let error):
            throw error
        }
    }
}
