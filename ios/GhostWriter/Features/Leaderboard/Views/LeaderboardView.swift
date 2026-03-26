import SwiftUI

struct LeaderboardView: View {

    @State private var viewModel = LeaderboardViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                Color.ghostBackground.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        scopeTabs
                        categoryTabs

                        if viewModel.isLoading {
                            loadingState
                        } else {
                            if !viewModel.topThree.isEmpty {
                                podiumView
                            }

                            remainingList

                            if let rank = viewModel.currentUserRank {
                                currentUserBanner(rank: rank)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 32)
                }
                .refreshable {
                    await viewModel.loadLeaderboard()
                }
            }
            .navigationTitle("Leaderboard")
            .navigationBarTitleDisplayMode(.large)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .task {
                await viewModel.loadLeaderboard()
            }
        }
    }

    // MARK: - Category Tabs

    private var scopeTabs: some View {
        HStack(spacing: 10) {
            ForEach(LeaderboardScope.allCases) { scope in
                Button {
                    Task { await viewModel.switchScope(scope) }
                } label: {
                    Text(scope.title)
                        .font(.system(size: 13, weight: .semibold))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .fill(viewModel.selectedScope == scope
                                      ? Color.ghostMagenta.opacity(0.2)
                                      : Color.white.opacity(0.06))
                        )
                        .overlay(
                            Capsule()
                                .stroke(viewModel.selectedScope == scope
                                        ? Color.ghostMagenta.opacity(0.6)
                                        : Color.white.opacity(0.1), lineWidth: 1)
                        )
                        .foregroundStyle(viewModel.selectedScope == scope
                                         ? .ghostMagenta
                                         : .ghostText.opacity(0.6))
                }
                .hapticFeedback(.light)
            }
            Spacer()
        }
    }

    private var categoryTabs: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(LeaderboardCategory.allCases) { category in
                    Button {
                        Task { await viewModel.switchCategory(category) }
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: category.icon)
                                .font(.system(size: 12))
                            Text(category.displayName)
                                .font(.system(size: 13, weight: .semibold))
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .fill(viewModel.selectedCategory == category
                                      ? Color.ghostCyan.opacity(0.2)
                                      : Color.white.opacity(0.06))
                        )
                        .overlay(
                            Capsule()
                                .stroke(viewModel.selectedCategory == category
                                        ? Color.ghostCyan.opacity(0.6)
                                        : Color.white.opacity(0.1), lineWidth: 1)
                        )
                        .foregroundStyle(viewModel.selectedCategory == category
                                         ? .ghostCyan
                                         : .ghostText.opacity(0.6))
                    }
                    .hapticFeedback(.light)
                }
            }
            .padding(.vertical, 4)
        }
    }

    // MARK: - Podium

    private var podiumView: some View {
        HStack(alignment: .bottom, spacing: 12) {
            if viewModel.topThree.count >= 2 {
                podiumColumn(entry: viewModel.topThree[1], height: 100, color: Color(hex: "C0C0C0"), medal: "🥈")
            }
            if viewModel.topThree.count >= 1 {
                podiumColumn(entry: viewModel.topThree[0], height: 130, color: .ghostGold, medal: "🥇")
            }
            if viewModel.topThree.count >= 3 {
                podiumColumn(entry: viewModel.topThree[2], height: 80, color: Color(hex: "CD7F32"), medal: "🥉")
            }
        }
        .padding(.vertical, 8)
    }

    private func podiumColumn(entry: LeaderboardEntry, height: CGFloat, color: Color, medal: String) -> some View {
        VStack(spacing: 8) {
            Text(medal)
                .font(.system(size: 28))

            Circle()
                .fill(.ultraThinMaterial)
                .frame(width: 52, height: 52)
                .overlay(
                    Text(String(entry.username.prefix(1)).uppercased())
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundStyle(color)
                )
                .overlay(
                    Circle().stroke(color.opacity(0.6), lineWidth: 2)
                )
                .ghostGlow(color: color, intensity: 0.4)

            Text(entry.username)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(.ghostText)
                .lineLimit(1)

            Text(viewModel.formattedScore(for: entry))
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundStyle(color)

            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(.ultraThinMaterial)
                .frame(height: height)
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Remaining List

    private var remainingList: some View {
        LazyVStack(spacing: 8) {
            ForEach(viewModel.remaining) { entry in
                LeaderboardRowView(
                    entry: entry,
                    statLabel: viewModel.categoryStatLabel(),
                    isCurrentUser: entry.rank == viewModel.currentUserRank
                )
            }
        }
    }

    // MARK: - Current User Banner

    private func currentUserBanner(rank: Int) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "person.fill")
                .font(.system(size: 16))
                .foregroundStyle(.ghostCyan)

            Text("Your Rank")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(.ghostText.opacity(0.7))

            Spacer()

            Text("#\(rank)")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundStyle(.ghostCyan)
        }
        .padding(16)
        .liquidGlass(cornerRadius: 16)
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.ghostCyan.opacity(0.3), lineWidth: 1)
        )
    }

    // MARK: - Loading

    private var loadingState: some View {
        VStack(spacing: 16) {
            ForEach(0..<6, id: \.self) { _ in
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .frame(height: 64)
                    .shimmer()
            }
        }
    }
}

#Preview {
    LeaderboardView()
        .preferredColorScheme(.dark)
}
