import SwiftUI

struct CreatorProfileView: View {
    var userId: UUID?
    @State private var viewModel = CreatorProfileViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    profileHeader
                    statsRow
                    recentClipsSection
                    badgesSection
                    navigationLinks
                }
                .padding()
            }
            .background(Color.ghostBackground.ignoresSafeArea())
            .navigationTitle("Creator")
            .navigationBarTitleDisplayMode(.large)
            .task { await viewModel.loadProfile() }
            .refreshable { await viewModel.loadProfile() }
        }
    }

    private var profileHeader: some View {
        VStack(spacing: 12) {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [.ghostCyan, .ghostMagenta],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 80, height: 80)
                .overlay(
                    Text(String(viewModel.profile?.username.prefix(1).uppercased() ?? "G"))
                        .font(.title.bold())
                        .foregroundColor(.white)
                )

            Text("@\(viewModel.profile?.username ?? "creator")")
                .font(.title2.bold())
                .foregroundColor(.ghostText)

            if let bio = viewModel.profile?.bio {
                Text(bio)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
            }

            HStack(spacing: 30) {
                statColumn(value: "\(viewModel.profile?.followerCount ?? 0)", label: "Followers")
                statColumn(value: "\(viewModel.profile?.followingCount ?? 0)", label: "Following")
                statColumn(value: "\(viewModel.profile?.totalSessionsCreated ?? 0)", label: "Sessions")
            }

            if viewModel.isCurrentUser {
                Button("Edit Profile") { }
                    .font(.subheadline.bold())
                    .foregroundColor(.ghostCyan)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 8)
                    .background(.ultraThinMaterial)
                    .cornerRadius(20)
                    .hapticFeedback(.light)
            } else {
                Button(viewModel.isFollowing ? "Following" : "Follow") {
                    Task { try? await viewModel.toggleFollow() }
                }
                .font(.subheadline.bold())
                .foregroundColor(viewModel.isFollowing ? .ghostText : .black)
                .padding(.horizontal, 24)
                .padding(.vertical, 8)
                .background(viewModel.isFollowing ? .ultraThinMaterial : AnyShapeStyle(Color.ghostCyan))
                .cornerRadius(20)
                .hapticFeedback(.medium)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(.ultraThinMaterial)
        .cornerRadius(16)
    }

    private func statColumn(value: String, label: String) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.headline.bold())
                .foregroundColor(.ghostText)
            Text(label)
                .font(.caption2)
                .foregroundColor(.gray)
        }
    }

    private var statsRow: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            statCard(title: "Total Words", value: "\(viewModel.stats?.totalWords ?? 0)", icon: "text.word.spacing", color: .ghostCyan)
            statCard(title: "Avg Flow", value: String(format: "%.0f", viewModel.stats?.averageFlowScore ?? 0), icon: "flame.fill", color: .ghostGold)
            statCard(title: "Earnings", value: String(format: "$%.2f", viewModel.stats?.totalEarnings ?? 0), icon: "dollarsign.circle", color: .ghostEmerald)
            statCard(title: "Streak", value: "\(viewModel.stats?.currentStreak ?? 0)d", icon: "bolt.fill", color: .ghostMagenta)
        }
    }

    private func statCard(title: String, value: String, icon: String, color: Color) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
            Text(value)
                .font(.headline.bold())
                .foregroundColor(.ghostText)
            Text(title)
                .font(.caption2)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(.ultraThinMaterial)
        .cornerRadius(12)
    }

    private var recentClipsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Recent Clips")
                .font(.headline)
                .foregroundColor(.ghostText)

            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 12) {
                    ForEach(viewModel.recentClips) { clip in
                        GhostClipPreviewView(clip: clip)
                            .frame(width: 160)
                    }
                }
            }
        }
    }

    private var badgesSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Badges")
                .font(.headline)
                .foregroundColor(.ghostText)

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 8) {
                ForEach(viewModel.profile?.badges ?? [], id: \.self) { badge in
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.caption2)
                            .foregroundColor(.ghostGold)
                        Text(badge)
                            .font(.caption2)
                            .foregroundColor(.ghostText)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(.ultraThinMaterial)
                    .cornerRadius(12)
                }
            }
        }
    }

    private var navigationLinks: some View {
        VStack(spacing: 10) {
            NavigationLink(value: AppDestination.leaderboard) {
                navigationRow(title: "Analytics", icon: "chart.bar.fill", color: .ghostCyan)
            }
            NavigationLink(value: AppDestination.subscriptionView) {
                navigationRow(title: "Earnings", icon: "dollarsign.circle.fill", color: .ghostEmerald)
            }
        }
    }

    private func navigationRow(title: String, icon: String, color: Color) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
            Text(title)
                .foregroundColor(.ghostText)
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(12)
    }
}

#Preview {
    CreatorProfileView()
}
