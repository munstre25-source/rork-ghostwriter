import SwiftUI

/// Browse, filter, and purchase ghost personalities from the marketplace.
struct PersonalityMarketplaceView: View {

    @Environment(\.personalityService) private var personalityService
    @Environment(HapticService.self) private var hapticService

    @State private var viewModel: PersonalityMarketplaceViewModel?
    @State private var purchaseError: String?
    @State private var showPurchaseAlert = false

    private var categoryTitles: [String] {
        ["All"] + PersonalityTrait.allCases.map(\.displayName)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.ghostBackground.ignoresSafeArea()

                if let vm = viewModel {
                    MarketplaceBody(
                        viewModel: vm,
                        categoryTitles: categoryTitles,
                        hapticService: hapticService,
                        purchaseError: $purchaseError,
                        showPurchaseAlert: $showPurchaseAlert
                    )
                } else {
                    ProgressView("Loading…")
                        .tint(.ghostCyan)
                        .foregroundStyle(Color.ghostText.opacity(0.7))
                }
            }
            .navigationTitle("Personalities")
            .navigationBarTitleDisplayMode(.large)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
        }
        .alert("Purchase", isPresented: $showPurchaseAlert) {
            Button("OK", role: .cancel) { purchaseError = nil }
        } message: {
            Text(purchaseError ?? "")
        }
        .task {
            if viewModel == nil {
                viewModel = PersonalityMarketplaceViewModel(
                    personalityService: personalityService,
                    hapticService: hapticService
                )
            }
            await viewModel?.loadMarketplace()
        }
    }
}

// MARK: - Body

private struct MarketplaceBody: View {
    @Bindable var viewModel: PersonalityMarketplaceViewModel
    var categoryTitles: [String]
    var hapticService: HapticService
    @Binding var purchaseError: String?
    @Binding var showPurchaseAlert: Bool

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 16, pinnedViews: [.sectionHeaders]) {
                Section {
                    sortPicker
                    categoryChips
                } header: {
                    searchHeader
                }

                Section {
                    if viewModel.filteredPersonalities.isEmpty {
                        emptyState
                    } else {
                        cardsList
                    }
                } header: {
                    resultsHeader
                }
            }
            .padding(.horizontal, 18)
            .padding(.bottom, 28)
        }
        .scrollIndicators(.hidden)
        .refreshable {
            hapticService.lightTap()
            await viewModel.loadMarketplace()
        }
        .searchable(text: $viewModel.searchQuery, prompt: "Search personalities")
        .onChange(of: viewModel.searchQuery) { _, newValue in
            Task { await viewModel.search(query: newValue) }
        }
    }

    private var searchHeader: some View {
        HStack(spacing: 8) {
            Image(systemName: "sparkles")
                .foregroundStyle(Color.ghostGold)
            Text("Discover voices that match your flow.")
                .font(.subheadline)
                .foregroundStyle(Color.ghostText.opacity(0.65))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 6)
    }

    private var sortPicker: some View {
        HStack {
            Label("Sort", systemImage: "arrow.up.arrow.down.circle")
                .font(.caption.weight(.semibold))
                .foregroundStyle(Color.ghostCyan)
            Spacer()
            Menu {
                ForEach(MarketplaceSortOrder.allCases) { order in
                    Button {
                        hapticService.lightTap()
                        viewModel.sortOrder = order
                    } label: {
                        HStack {
                            Text(order.title)
                            if viewModel.sortOrder == order {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            } label: {
                HStack(spacing: 6) {
                    Text(viewModel.sortOrder.title)
                        .font(.subheadline.weight(.medium))
                    Image(systemName: "chevron.down.circle.fill")
                        .font(.caption)
                }
                .foregroundStyle(Color.ghostText)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background {
                    Capsule().fill(.ultraThinMaterial)
                }
            }
        }
        .padding(14)
        .background { glassCard(cornerRadius: 16) }
    }

    private var categoryChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 10) {
                ForEach(categoryTitles, id: \.self) { title in
                    let isAll = title == "All"
                    let selected = isAll
                        ? viewModel.selectedCategory == nil
                        : viewModel.selectedCategory == title

                    Button {
                        hapticService.lightTap()
                        viewModel.selectedCategory = isAll ? nil : title
                    } label: {
                        Text(title)
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(selected ? Color.ghostBackground : Color.ghostText)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 9)
                            .background {
                                Capsule()
                                    .fill(selected ? Color.ghostMagenta.opacity(0.95) : .ultraThinMaterial)
                            }
                            .overlay {
                                Capsule()
                                    .stroke(Color.ghostCyan.opacity(selected ? 0 : 0.25), lineWidth: 1)
                            }
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.vertical, 4)
        }
        .padding(14)
        .background { glassCard(cornerRadius: 16) }
    }

    private var resultsHeader: some View {
        HStack {
            Text("Results")
                .font(.caption.weight(.bold))
                .foregroundStyle(Color.ghostEmerald)
            Spacer()
            Text("\(viewModel.filteredPersonalities.count)")
                .font(.caption.monospacedDigit())
                .foregroundStyle(Color.ghostText.opacity(0.45))
        }
        .padding(.top, 8)
    }

    private var cardsList: some View {
        LazyVStack(spacing: 14) {
            ForEach(viewModel.filteredPersonalities, id: \.id) { personality in
                PersonalityCard(
                    personality: personality,
                    isOwned: viewModel.isOwned(personality),
                    canTry: viewModel.canTryPersonality(personality),
                    trialButtonTitle: viewModel.trialButtonTitle(for: personality),
                    creatorPayoutText: viewModel.creatorPayoutText(for: personality),
                    onTry: {
                        Task { await viewModel.tryPersonality(personality) }
                    },
                    onPurchase: {
                        Task {
                            do {
                                try await viewModel.purchasePersonality(personality)
                            } catch {
                                hapticService.errorNotification()
                                purchaseError = error.localizedDescription
                                showPurchaseAlert = true
                            }
                        }
                    }
                )
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "tray")
                .font(.largeTitle)
                .foregroundStyle(Color.ghostText.opacity(0.35))
            Text("No personalities match your filters.")
                .font(.subheadline)
                .foregroundStyle(Color.ghostText.opacity(0.55))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 48)
        .background { glassCard(cornerRadius: 20) }
    }

    private func glassCard(cornerRadius: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(.regularMaterial)
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [Color.ghostCyan.opacity(0.22), Color.ghostMagenta.opacity(0.12)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            }
    }
}

// MARK: - Preview

#Preview("Marketplace") {
    PersonalityMarketplaceView()
        .environment(PersonalityService())
        .environment(HapticService())
}

#Preview("Marketplace — dark") {
    ZStack {
        Color.ghostBackground.ignoresSafeArea()
        PersonalityMarketplaceView()
            .environment(PersonalityService())
            .environment(HapticService())
    }
}
