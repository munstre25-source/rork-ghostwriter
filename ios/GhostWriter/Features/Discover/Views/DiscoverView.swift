import SwiftUI

struct DiscoverView: View {
    @State private var viewModel = DiscoverViewModel()
    @State private var trendingVM = TrendingViewModel()
    @Environment(ModerationService.self) private var moderationService
    @State private var moderationMessage: String?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    filterChips
                    TrendingPersonalitiesView(personalities: trendingVM.trendingPersonalities)
                    challengeBanner
                    feedSection
                }
                .padding(.horizontal)
            }
            .background(Color.ghostBackground.ignoresSafeArea())
            .navigationTitle("Discover")
            .navigationBarTitleDisplayMode(.large)
            .searchable(text: $viewModel.searchQuery, prompt: "Search creators, personalities...")
            .onSubmit(of: .search) { Task { await viewModel.search() } }
            .onChange(of: viewModel.searchQuery) { _, _ in
                Task { await viewModel.search() }
            }
            .task {
                await viewModel.loadFeed()
                await trendingVM.loadTrending()
            }
            .refreshable { await viewModel.refresh() }
            .alert(
                "Safety Action",
                isPresented: Binding(
                    get: { moderationMessage != nil },
                    set: { if !$0 { moderationMessage = nil } }
                )
            ) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(moderationMessage ?? "")
            }
        }
    }

    private var filterChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(DiscoverFilter.allCases) { filter in
                    Button {
                        viewModel.setFilter(filter)
                    } label: {
                        Label(filter.displayName, systemImage: filter.icon)
                            .font(.caption.bold())
                            .foregroundColor(viewModel.selectedFilter == filter ? .black : .ghostText)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(viewModel.selectedFilter == filter ? Color.ghostCyan : .ultraThinMaterial)
                            .cornerRadius(20)
                    }
                    .hapticFeedback(.light)
                }
            }
        }
    }

    private var challengeBanner: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Label("Weekly Challenge", systemImage: "trophy.fill")
                    .font(.caption.bold())
                    .foregroundColor(.ghostGold)
                Text("Write 500 words this week")
                    .font(.subheadline.bold())
                    .foregroundColor(.ghostText)
                Text("5,600 participants · Sponsored by InkFlow")
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
            Spacer()
            VStack(spacing: 6) {
                Text("$1,500 prize")
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(Color.ghostGold)
                Button("Join") { }
                    .font(.caption.bold())
                    .foregroundColor(.black)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.ghostGold)
                    .cornerRadius(14)
                    .hapticFeedback(.medium)
            }
        }
        .padding()
        .background(
            LinearGradient(
                colors: [.ghostGold.opacity(0.1), .clear],
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .background(.ultraThinMaterial)
        .cornerRadius(14)
    }

    private var feedSection: some View {
        LazyVStack(spacing: 12) {
            ForEach(viewModel.filteredItems.filter { !moderationService.isBlocked($0.creatorId) }) { item in
                discoveryCard(item)
            }
        }
    }

    private func discoveryCard(_ item: DiscoveryItem) -> some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 10)
                .fill(
                    LinearGradient(
                        colors: [item.type.accentColor.opacity(0.3), item.type.accentColor.opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 60, height: 60)
                .overlay(
                    Image(systemName: item.type.icon)
                        .foregroundColor(item.type.accentColor)
                )

            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(.subheadline.bold())
                    .foregroundColor(.ghostText)
                    .lineLimit(1)

                Text(item.subtitle)
                    .font(.caption)
                    .foregroundColor(.gray)
                    .lineLimit(2)

                HStack(spacing: 10) {
                    Label("\(item.viewCount)", systemImage: "eye")
                    Label("\(item.likeCount)", systemImage: "heart")
                }
                .font(.caption2)
                .foregroundColor(.gray)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding(12)
        .background(.ultraThinMaterial)
        .cornerRadius(14)
        .hapticFeedback(.light)
        .contextMenu {
            Button("Report Content", systemImage: "flag.fill") {
                Task {
                    await moderationService.reportContent(itemId: item.id, reason: "User report")
                    moderationMessage = "Thanks for your report. Our moderation team will review this content."
                }
            }
            Button("Block Creator", systemImage: "hand.raised.fill", role: .destructive) {
                moderationService.blockCreator(item.creatorId)
                moderationMessage = "Creator blocked. Their public content is hidden from your feed."
            }
        }
    }
}

private extension DiscoveryItemType {
    var icon: String {
        switch self {
        case .trendingSession: "sparkles"
        case .trendingPersonality: "theatermasks"
        case .featuredCreator: "person.circle.fill"
        case .weeklyChallenge: "trophy.fill"
        case .popularClip: "play.rectangle.fill"
        }
    }

    var accentColor: Color {
        switch self {
        case .trendingSession: .ghostCyan
        case .trendingPersonality: .ghostMagenta
        case .featuredCreator: .ghostEmerald
        case .weeklyChallenge: .ghostGold
        case .popularClip: .ghostCyan
        }
    }
}

#Preview {
    DiscoverView()
}
