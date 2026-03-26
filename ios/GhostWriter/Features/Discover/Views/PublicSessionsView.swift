import SwiftUI

struct PublicSessionsView: View {
    @State private var sessions: [PublicSessionItem] = []

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Public Sessions")
                .font(.headline)
                .foregroundColor(.ghostText)

            LazyVStack(spacing: 10) {
                ForEach(sessions) { session in
                    sessionCard(session)
                }
            }
        }
        .task { loadSessions() }
    }

    private func sessionCard(_ session: PublicSessionItem) -> some View {
        HStack(spacing: 12) {
            Image(systemName: session.typeIcon)
                .font(.title3)
                .foregroundColor(.ghostCyan)
                .frame(width: 40, height: 40)
                .background(.ultraThinMaterial)
                .cornerRadius(10)

            VStack(alignment: .leading, spacing: 2) {
                Text(session.title)
                    .font(.subheadline.bold())
                    .foregroundColor(.ghostText)
                    .lineLimit(1)

                HStack(spacing: 8) {
                    Label("\(session.wordCount) words", systemImage: "text.word.spacing")
                    Label("\(Int(session.flowScore))%", systemImage: "flame")
                }
                .font(.caption2)
                .foregroundColor(.gray)

                Text("by \(session.creatorName) · \(session.personalityName)")
                    .font(.caption2)
                    .foregroundColor(.ghostMagenta)
            }

            Spacer()

            VStack(spacing: 6) {
                Button("Fork") { }
                    .font(.caption2.bold())
                    .foregroundColor(.ghostCyan)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(.ultraThinMaterial)
                    .cornerRadius(8)

                Button("Try") { }
                    .font(.caption2.bold())
                    .foregroundColor(.ghostMagenta)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(.ultraThinMaterial)
                    .cornerRadius(8)
            }
        }
        .padding(12)
        .background(.ultraThinMaterial)
        .cornerRadius(14)
    }

    private func loadSessions() {
        sessions = [
            PublicSessionItem(title: "Building an AI Assistant", typeIcon: "brain.head.profile", wordCount: 1250, flowScore: 82, creatorName: "alex_codes", personalityName: "The Architect"),
            PublicSessionItem(title: "Poetry in Motion", typeIcon: "text.quote", wordCount: 340, flowScore: 95, creatorName: "luna_writes", personalityName: "The Muse"),
            PublicSessionItem(title: "Startup Pitch Deck", typeIcon: "lightbulb.fill", wordCount: 890, flowScore: 68, creatorName: "startup_sam", personalityName: "The Visionary"),
        ]
    }
}

struct PublicSessionItem: Identifiable {
    let id = UUID()
    let title: String
    let typeIcon: String
    let wordCount: Int
    let flowScore: Double
    let creatorName: String
    let personalityName: String
}

#Preview {
    PublicSessionsView()
        .padding()
        .background(Color.ghostBackground)
}
