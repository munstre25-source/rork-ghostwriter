import SwiftUI

struct TrendingPersonalitiesView: View {
    let personalities: [GhostPersonality]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Label("Trending Personalities", systemImage: "flame.fill")
                    .font(.headline)
                    .foregroundColor(.ghostText)
                Spacer()
                Button("See All") { }
                    .font(.caption.bold())
                    .foregroundColor(.ghostCyan)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 12) {
                    ForEach(personalities) { personality in
                        trendingCard(personality)
                    }
                }
            }
        }
    }

    private func trendingCard(_ personality: GhostPersonality) -> some View {
        VStack(spacing: 8) {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [.ghostCyan, .ghostMagenta],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 50, height: 50)
                .overlay(
                    Text(String(personality.name.prefix(1)))
                        .font(.title3.bold())
                        .foregroundColor(.white)
                )

            Text(personality.name)
                .font(.caption.bold())
                .foregroundColor(.ghostText)
                .lineLimit(1)

            HStack(spacing: 2) {
                Image(systemName: "star.fill")
                    .font(.system(size: 8))
                    .foregroundColor(.ghostGold)
                Text(String(format: "%.1f", personality.rating))
                    .font(.caption2)
                    .foregroundColor(.gray)
            }

            Text("\(personality.downloads)")
                .font(.caption2)
                .foregroundColor(.gray)
        }
        .frame(width: 90)
        .padding(.vertical, 12)
        .background(.ultraThinMaterial)
        .cornerRadius(14)
        .hapticFeedback(.light)
    }
}

#Preview {
    TrendingPersonalitiesView(personalities: [
        GhostPersonality.theMuse(),
        GhostPersonality.theArchitect(),
        GhostPersonality.theCritic(),
        GhostPersonality.theVisionary()
    ])
    .padding()
    .background(Color.ghostBackground)
}
