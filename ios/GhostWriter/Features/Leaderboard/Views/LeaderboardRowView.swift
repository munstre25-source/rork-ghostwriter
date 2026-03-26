import SwiftUI

struct LeaderboardRowView: View {

    let entry: LeaderboardEntry
    let statLabel: String
    var isCurrentUser: Bool = false

    private var rankDisplay: String {
        switch entry.rank {
        case 1: "🥇"
        case 2: "🥈"
        case 3: "🥉"
        default: "\(entry.rank)"
        }
    }

    private var rankColor: Color {
        switch entry.rank {
        case 1: .ghostGold
        case 2: Color(hex: "C0C0C0")
        case 3: Color(hex: "CD7F32")
        default: .ghostText.opacity(0.6)
        }
    }

    private var formattedScore: String {
        if entry.score >= 1_000_000 {
            return String(format: "%.1fM", Double(entry.score) / 1_000_000)
        } else if entry.score >= 1_000 {
            return String(format: "%.1fK", Double(entry.score) / 1_000)
        }
        return "\(entry.score)"
    }

    var body: some View {
        HStack(spacing: 14) {
            Text(rankDisplay)
                .font(entry.rank <= 3
                      ? .system(size: 24)
                      : .system(size: 16, weight: .bold, design: .rounded))
                .foregroundStyle(rankColor)
                .frame(width: 36)

            Circle()
                .fill(.ultraThinMaterial)
                .frame(width: 40, height: 40)
                .overlay(
                    Text(String(entry.username.prefix(1)).uppercased())
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundStyle(.ghostCyan)
                )
                .overlay(
                    Circle()
                        .stroke(Color.white.opacity(0.15), lineWidth: 1)
                )

            VStack(alignment: .leading, spacing: 2) {
                Text(entry.username)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(isCurrentUser ? .ghostCyan : .ghostText)

                Text("\(formattedScore) \(statLabel)")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.ghostText.opacity(0.5))
            }

            Spacer()

            Text(formattedScore)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(entry.rank <= 3 ? rankColor : .ghostText)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .liquidGlass(cornerRadius: 14)
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(isCurrentUser ? Color.ghostCyan.opacity(0.4) : .clear, lineWidth: 1.5)
        )
    }
}

#Preview {
    ZStack {
        Color.ghostBackground.ignoresSafeArea()
        VStack(spacing: 8) {
            LeaderboardRowView(
                entry: LeaderboardEntry(
                    userId: UUID(),
                    username: "luna_writes",
                    score: 15420,
                    rank: 1,
                    category: .mostViewed
                ),
                statLabel: "views"
            )
            LeaderboardRowView(
                entry: LeaderboardEntry(
                    userId: UUID(),
                    username: "creative_storm",
                    score: 12300,
                    rank: 2,
                    category: .mostViewed
                ),
                statLabel: "views"
            )
            LeaderboardRowView(
                entry: LeaderboardEntry(
                    userId: UUID(),
                    username: "you_writer",
                    score: 4200,
                    rank: 7,
                    category: .mostViewed
                ),
                statLabel: "views",
                isCurrentUser: true
            )
        }
        .padding()
    }
}
