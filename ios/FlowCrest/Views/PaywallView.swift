import SwiftUI
import StoreKit

struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var subscriptionManager = SubscriptionManager.shared
    @State private var selectedProduct: Product?
    @State private var isPurchasing = false
    @State private var showError = false
    @State private var errorMessage = ""

    private let features: [(icon: String, title: String, subtitle: String)] = [
        ("infinity", "Unlimited Scheduling", "Full bio-adaptive adjustments for all events"),
        ("chart.line.uptrend.xyaxis", "Advanced Analytics", "Deep insights into readiness trends & history"),
        ("calendar.badge.checkmark", "Full Calendar Sync", "Two-way sync with all your calendars"),
        ("brain.head.profile.fill", "Personalized Model", "AI adapts to your unique biology over time"),
        ("bell.badge.fill", "Smart Notifications", "Proactive alerts when schedule mismatches occur"),
        ("star.fill", "Priority Support", "Dedicated help when you need it"),
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                headerSection
                featuresSection
                pricingSection
                legalSection
            }
        }
        .background(Color(.systemGroupedBackground))
        .overlay(alignment: .topTrailing) {
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.title2)
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(.secondary)
            }
            .padding()
        }
        .alert("Purchase Error", isPresented: $showError) {
            Button("OK") {}
        } message: {
            Text(errorMessage)
        }
        .task {
            if subscriptionManager.products.isEmpty {
                await subscriptionManager.loadProducts()
            }
            selectedProduct = subscriptionManager.yearlyProduct
        }
    }

    private var headerSection: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [.orange.opacity(0.3), .purple.opacity(0.15), .clear],
                            center: .center,
                            startRadius: 20,
                            endRadius: 100
                        )
                    )
                    .frame(width: 200, height: 200)

                Image(systemName: "waveform.path.ecg")
                    .font(.system(size: 48, weight: .medium))
                    .foregroundStyle(
                        LinearGradient(colors: [.orange, .purple], startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .symbolEffect(.pulse, options: .repeating)
            }

            VStack(spacing: 8) {
                Text("FlowCrest Premium")
                    .font(.title.bold())

                Text("Unlock your full bio-adaptive potential")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            if subscriptionManager.yearlyProduct != nil {
                HStack(spacing: 6) {
                    Image(systemName: "gift.fill")
                        .foregroundStyle(.orange)
                    Text("7-day free trial included")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.orange)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.orange.opacity(0.1))
                .clipShape(.capsule)
            }
        }
        .padding(.top, 48)
        .padding(.bottom, 28)
    }

    private var featuresSection: some View {
        VStack(spacing: 0) {
            ForEach(Array(features.enumerated()), id: \.offset) { index, feature in
                HStack(spacing: 14) {
                    Image(systemName: feature.icon)
                        .font(.body.weight(.semibold))
                        .foregroundStyle(
                            LinearGradient(colors: [.orange, .purple], startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                        .frame(width: 36, height: 36)
                        .background(Color(.tertiarySystemFill))
                        .clipShape(.rect(cornerRadius: 8))

                    VStack(alignment: .leading, spacing: 2) {
                        Text(feature.title)
                            .font(.subheadline.weight(.semibold))
                        Text(feature.subtitle)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    Image(systemName: "checkmark")
                        .font(.caption.bold())
                        .foregroundStyle(.green)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)

                if index < features.count - 1 {
                    Divider()
                        .padding(.leading, 70)
                }
            }
        }
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: 16))
        .padding(.horizontal, 16)
    }

    private var pricingSection: some View {
        VStack(spacing: 12) {
            if subscriptionManager.isLoading {
                ProgressView()
                    .padding(.vertical, 40)
            } else if subscriptionManager.products.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                    Text("Subscriptions unavailable")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Button("Retry") {
                        Task { await subscriptionManager.loadProducts() }
                    }
                    .font(.subheadline.weight(.medium))
                }
                .padding(.vertical, 24)
            } else {
                ForEach(subscriptionManager.products, id: \.id) { product in
                    subscriptionOption(product)
                }

                purchaseButton

                Button("Restore Purchases") {
                    Task { await subscriptionManager.restorePurchases() }
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
        }
        .padding(16)
        .padding(.top, 8)
    }

    private func subscriptionOption(_ product: Product) -> some View {
        let isSelected = selectedProduct?.id == product.id
        let isYearly = product.id == subscriptionManager.yearlyProduct?.id

        return Button {
            withAnimation(.spring(response: 0.3)) {
                selectedProduct = product
            }
        } label: {
            HStack(spacing: 14) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(isSelected ? .orange : .secondary)

                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Text(isYearly ? "Annual" : "Monthly")
                            .font(.headline)
                            .foregroundStyle(.primary)

                        if isYearly {
                            Text("SAVE 58%")
                                .font(.caption2.bold())
                                .foregroundStyle(.white)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.orange)
                                .clipShape(.capsule)
                        }
                    }

                    Text(product.displayPrice + (isYearly ? "/year" : "/month"))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                if isYearly {
                    VStack(alignment: .trailing, spacing: 2) {
                        Text(monthlyEquivalent(for: product))
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.primary)
                        Text("/month")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding(16)
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(.rect(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(isSelected ? Color.orange : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }

    private var purchaseButton: some View {
        Button {
            guard let product = selectedProduct else { return }
            isPurchasing = true
            Task {
                do {
                    let success = try await subscriptionManager.purchase(product)
                    if success {
                        dismiss()
                    }
                } catch {
                    errorMessage = error.localizedDescription
                    showError = true
                }
                isPurchasing = false
            }
        } label: {
            Group {
                if isPurchasing {
                    ProgressView()
                        .tint(.white)
                } else {
                    Text("Start Free Trial")
                        .font(.headline)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                LinearGradient(colors: [.orange, .purple.opacity(0.8)], startPoint: .leading, endPoint: .trailing)
            )
            .foregroundStyle(.white)
            .clipShape(.rect(cornerRadius: 14))
        }
        .disabled(selectedProduct == nil || isPurchasing)
        .opacity(selectedProduct == nil ? 0.6 : 1)
        .padding(.top, 4)
    }

    private var legalSection: some View {
        VStack(spacing: 6) {
            Text("Payment will be charged to your Apple ID account at the confirmation of purchase. Subscription automatically renews unless it is canceled at least 24 hours before the end of the current period. Your account will be charged for renewal within 24 hours prior to the end of the current period.")
                .font(.caption2)
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)

            HStack(spacing: 16) {
                Link("Privacy Policy", destination: URL(string: "https://socialreporthq.com/flowcrest/privacy")!)
                Link("Terms of Use", destination: URL(string: "https://socialreporthq.com/flowcrest/terms")!)
            }
            .font(.caption2)
            .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
    }

    private func monthlyEquivalent(for product: Product) -> String {
        let monthly = product.price / 12
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = product.priceFormatStyle.locale
        return formatter.string(from: monthly as NSDecimalNumber) ?? ""
    }
}
