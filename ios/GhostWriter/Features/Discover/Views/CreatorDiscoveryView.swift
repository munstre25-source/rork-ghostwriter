import SwiftUI

struct CreatorDiscoveryView: View {
    @State private var creators: [FeaturedCreator] = []

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Featured Creators")
                .font(.headline)
                .foregroundColor(.ghostText)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(creators) { creator in
                    creatorCard(creator)
                }
            }
        }
        .task { loadCreators() }
    }

    private func creatorCard(_ creator: FeaturedCreator) -> some View {
        VStack(spacing: 8) {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [.ghostCyan.opacity(0.6), .ghostMagenta.opacity(0.6)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 50, height: 50)
                .overlay(
                    Text(String(creator.name.prefix(1).uppercased()))
                        .font(.title3.bold())
                        .foregroundColor(.white)
                )

            Text(creator.name)
                .font(.subheadline.bold())
                .foregroundColor(.ghostText)
                .lineLimit(1)

            Text("\(creator.followerCount) followers")
                .font(.caption2)
                .foregroundColor(.gray)

            Button("Follow") { }
                .font(.caption2.bold())
                .foregroundColor(.black)
                .padding(.horizontal, 16)
                .padding(.vertical, 6)
                .background(Color.ghostCyan)
                .cornerRadius(12)
                .hapticFeedback(.light)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(.ultraThinMaterial)
        .cornerRadius(14)
    }

    private func loadCreators() {
        creators = [
            FeaturedCreator(name: "alex_creates", followerCount: 12400, sessionCount: 320),
            FeaturedCreator(name: "maya_writes", followerCount: 8900, sessionCount: 210),
            FeaturedCreator(name: "code_ninja", followerCount: 15200, sessionCount: 450),
            FeaturedCreator(name: "design_flow", followerCount: 6700, sessionCount: 180),
        ]
    }
}

struct FeaturedCreator: Identifiable {
    let id = UUID()
    let name: String
    let followerCount: Int
    let sessionCount: Int
}

#Preview {
    CreatorDiscoveryView()
        .padding()
        .background(Color.ghostBackground)
}
