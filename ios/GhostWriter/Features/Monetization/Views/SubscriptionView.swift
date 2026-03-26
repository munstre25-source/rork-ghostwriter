import SwiftUI

struct SubscriptionView: View {

    @State private var viewModel = SubscriptionViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                Color.ghostBackground.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        headerSection
                        periodToggle
                        tierCards
                        trialBanner
                        featureComparison
                        restoreButton
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 32)
                }
            }
            .navigationTitle("Upgrade")
            .navigationBarTitleDisplayMode(.large)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .task {
                await viewModel.loadProducts()
            }
            .alert("Welcome!", isPresented: $viewModel.showSuccessAlert) {
                Button("Let's Go", role: .cancel) {}
            } message: {
                Text("Your subscription is now active. Enjoy your new features!")
            }
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: 8) {
            Image(systemName: "sparkles")
                .font(.system(size: 40))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.ghostCyan, .ghostMagenta],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .ghostGlow(color: .ghostCyan, intensity: 0.4)

            Text("Unlock Your Creative Potential")
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(.ghostText)
                .multilineTextAlignment(.center)

            Text("Choose the plan that fits your creative journey")
                .font(.system(size: 14))
                .foregroundStyle(.ghostText.opacity(0.6))
                .multilineTextAlignment(.center)
        }
        .padding(.top, 8)
    }

    // MARK: - Period Toggle

    private var periodToggle: some View {
        HStack(spacing: 0) {
            ForEach(SubscriptionPeriod.allCases) { period in
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        viewModel.selectedPeriod = period
                    }
                } label: {
                    VStack(spacing: 2) {
                        Text(period.displayName)
                            .font(.system(size: 14, weight: .semibold))
                        if period == .yearly {
                            Text("Save 17%")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundStyle(.ghostEmerald)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(
                        Capsule()
                            .fill(viewModel.selectedPeriod == period
                                  ? Color.ghostCyan.opacity(0.2)
                                  : .clear)
                    )
                    .foregroundStyle(viewModel.selectedPeriod == period
                                     ? .ghostCyan
                                     : .ghostText.opacity(0.5))
                }
                .hapticFeedback(.light)
            }
        }
        .padding(4)
        .background(Capsule().fill(.ultraThinMaterial))
        .overlay(Capsule().stroke(Color.white.opacity(0.1), lineWidth: 1))
    }

    // MARK: - Tier Cards

    private var tierCards: some View {
        VStack(spacing: 12) {
            ForEach(viewModel.displayTiers) { tier in
                tierCard(for: tier)
            }
        }
    }

    private func tierCard(for tier: SubscriptionTier) -> some View {
        let colors = viewModel.tierColor(for: tier)
        let gradientColors = [Color(hex: colors.primary), Color(hex: colors.secondary)]
        let isCurrent = viewModel.currentTier == tier
        let isPopular = tier == .pro

        return VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Text(tier.displayName)
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(.ghostText)

                        if isCurrent {
                            Text("CURRENT")
                                .font(.system(size: 9, weight: .bold))
                                .foregroundStyle(.ghostEmerald)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Capsule().fill(Color.ghostEmerald.opacity(0.2)))
                        }

                        if isPopular {
                            Text("POPULAR")
                                .font(.system(size: 9, weight: .bold))
                                .foregroundStyle(.ghostMagenta)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Capsule().fill(Color.ghostMagenta.opacity(0.2)))
                        }
                    }

                    Text(viewModel.price(for: tier))
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: gradientColors,
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )

                    if let monthly = viewModel.monthlyEquivalent(for: tier) {
                        Text(monthly)
                            .font(.system(size: 12))
                            .foregroundStyle(.ghostText.opacity(0.5))
                    }

                    if tier != .free {
                        Text(viewModel.selectedPeriod == .monthly ? "/month" : "/year")
                            .font(.system(size: 12))
                            .foregroundStyle(.ghostText.opacity(0.4))
                    }
                }

                Spacer()
            }

            VStack(alignment: .leading, spacing: 6) {
                ForEach(tier.features, id: \.self) { feature in
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 14))
                            .foregroundStyle(Color(hex: colors.primary).opacity(0.8))
                        Text(feature)
                            .font(.system(size: 13))
                            .foregroundStyle(.ghostText.opacity(0.8))
                    }
                }
            }

            if !isCurrent && tier != .free {
                Button {
                    Task { try? await viewModel.purchase(tier: tier) }
                } label: {
                    Group {
                        if viewModel.isPurchasing && viewModel.selectedTier == tier {
                            ProgressView()
                                .tint(.ghostBackground)
                        } else {
                            Text(tier == .free ? "Current Plan" : "Choose \(tier.displayName)")
                                .font(.system(size: 15, weight: .bold))
                        }
                    }
                    .foregroundStyle(.ghostBackground)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        Capsule().fill(
                            LinearGradient(
                                colors: gradientColors,
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                    )
                }
                .hapticFeedback(.medium)
                .disabled(viewModel.isPurchasing)
            }
        }
        .padding(16)
        .liquidGlass(cornerRadius: 16)
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(
                    isCurrent
                        ? Color(hex: colors.primary).opacity(0.5)
                        : isPopular ? Color.ghostMagenta.opacity(0.3) : .clear,
                    lineWidth: isCurrent || isPopular ? 1.5 : 0
                )
        )
    }

    // MARK: - Trial Banner

    private var trialBanner: some View {
        Button {
            Task { try? await viewModel.purchase(tier: .pro) }
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "gift.fill")
                    .font(.system(size: 24))
                    .foregroundStyle(.ghostGold)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Try Pro Free for 7 Days")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.ghostText)
                    Text("Cancel anytime. No commitment.")
                        .font(.system(size: 12))
                        .foregroundStyle(.ghostText.opacity(0.6))
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.ghostGold)
            }
            .padding(16)
            .liquidGlass(cornerRadius: 16)
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(Color.ghostGold.opacity(0.3), lineWidth: 1)
            )
        }
        .hapticFeedback(.medium)
    }

    // MARK: - Feature Comparison

    private var featureComparison: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Feature Comparison")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(.ghostText)

            let features: [(String, Bool, Bool, Bool, Bool)] = [
                ("Creative Sessions",    true,  true,  true,  true),
                ("Basic Sharing",        true,  true,  true,  true),
                ("Unlimited Sessions",   false, true,  true,  true),
                ("All Personalities",    false, true,  true,  true),
                ("HD Clip Export",       false, true,  true,  true),
                ("Custom Personalities", false, false, true,  true),
                ("Advanced AI",          false, false, true,  true),
                ("Detailed Analytics",   false, false, true,  true),
                ("Live Jam",             false, false, false, true),
                ("Monetization Tools",   false, false, false, true),
                ("Marketplace Access",   false, false, false, true),
            ]

            VStack(spacing: 0) {
                comparisonHeader

                ForEach(features, id: \.0) { feature in
                    comparisonRow(
                        name: feature.0,
                        free: feature.1,
                        creator: feature.2,
                        pro: feature.3,
                        studio: feature.4
                    )
                }
            }
            .liquidGlass(cornerRadius: 14)
        }
    }

    private var comparisonHeader: some View {
        HStack {
            Text("")
                .frame(maxWidth: .infinity, alignment: .leading)
            ForEach(viewModel.displayTiers) { tier in
                Text(tier.displayName)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(.ghostText.opacity(0.6))
                    .frame(width: 50)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
    }

    private func comparisonRow(name: String, free: Bool, creator: Bool, pro: Bool, studio: Bool) -> some View {
        HStack {
            Text(name)
                .font(.system(size: 12))
                .foregroundStyle(.ghostText.opacity(0.8))
                .frame(maxWidth: .infinity, alignment: .leading)

            ForEach([free, creator, pro, studio], id: \.self) { included in
                Image(systemName: included ? "checkmark" : "minus")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(included ? .ghostEmerald : .ghostText.opacity(0.2))
                    .frame(width: 50)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
    }

    // MARK: - Restore

    private var restoreButton: some View {
        Button {
            Task { try? await viewModel.restorePurchases() }
        } label: {
            Text("Restore Purchases")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(.ghostText.opacity(0.5))
        }
        .padding(.top, 8)
    }
}

#Preview {
    SubscriptionView()
        .preferredColorScheme(.dark)
}
