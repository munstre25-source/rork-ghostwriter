import SwiftUI

/// Marketplace / list card for a single ``GhostPersonality``.
struct PersonalityCard: View {

    var personality: GhostPersonality
    var isOwned: Bool
    var canTry: Bool
    var trialButtonTitle: String
    var creatorPayoutText: String?
    var onTry: () -> Void
    var onPurchase: () -> Void

    @Environment(HapticService.self) private var hapticService

    private var creatorLabel: String {
        personality.creatorId == nil ? "GhostWriter" : "Community"
    }

    private var accentColor: Color {
        if let first = personality.traits.first, let trait = PersonalityTrait(rawValue: first) {
            switch trait {
            case .encouraging, .playful: return .ghostMagenta
            case .analytical, .structured: return .ghostCyan
            case .critical, .formal: return .ghostGold
            case .freeform, .verbose: return .ghostEmerald
            case .concise, .casual: return .ghostText
            }
        }
        return .ghostCyan
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                PersonalityAvatarView(
                    name: personality.name,
                    color: accentColor,
                    icon: "person.crop.circle.dashed",
                    isActive: false,
                    size: 52
                )

                VStack(alignment: .leading, spacing: 4) {
                    Text(personality.name)
                        .font(.headline)
                        .foregroundStyle(Color.ghostText)

                    Text(creatorLabel)
                        .font(.caption)
                        .foregroundStyle(Color.ghostText.opacity(0.55))
                }

                Spacer(minLength: 0)

                priceTag
            }

            Text(personality.personalityDescription)
                .font(.subheadline)
                .foregroundStyle(Color.ghostText.opacity(0.85))
                .lineLimit(2)
                .multilineTextAlignment(.leading)

            starRow

            HStack(spacing: 8) {
                Label("\(personality.downloads)", systemImage: "arrow.down.circle")
                    .font(.caption2)
                    .foregroundStyle(Color.ghostText.opacity(0.5))

                Spacer(minLength: 0)
            }

            if let creatorPayoutText {
                Text(creatorPayoutText)
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(Color.ghostEmerald.opacity(0.85))
            }

            traitsRow

            HStack(spacing: 10) {
                Button {
                    hapticService.lightTap()
                    onTry()
                } label: {
                    Label(trialButtonTitle, systemImage: "play.circle")
                        .font(.subheadline.weight(.semibold))
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .tint(.ghostCyan)
                .disabled(!canTry)

                Button {
                    hapticService.mediumTap()
                    onPurchase()
                } label: {
                    Text(isOwned ? "Owned" : (personality.purchasePrice == nil ? "Get" : "Purchase"))
                        .font(.subheadline.weight(.semibold))
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(.ghostMagenta)
                .disabled(isOwned)
            }
        }
        .padding(16)
        .background {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.regularMaterial)
                .overlay {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(
                            LinearGradient(
                                colors: [accentColor.opacity(0.45), Color.ghostMagenta.opacity(0.2)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                }
        }
        .contentShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .onTapGesture {
            hapticService.lightTap()
        }
    }

    private var priceTag: some View {
        Group {
            if let price = personality.purchasePrice {
                Text(String(format: "$%.2f", price))
                    .font(.caption.weight(.bold))
                    .foregroundStyle(Color.ghostGold)
            } else {
                Text("Free")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(Color.ghostEmerald)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background {
            Capsule().fill(.ultraThinMaterial)
        }
    }

    private var starRow: some View {
        HStack(spacing: 2) {
            ForEach(0..<5, id: \.self) { index in
                Image(systemName: starName(for: index))
                    .font(.caption)
                    .foregroundStyle(
                        starName(for: index) == "star"
                            ? Color.ghostText.opacity(0.25)
                            : Color.ghostGold
                    )
            }
            Text(String(format: "%.1f", personality.rating))
                .font(.caption2)
                .foregroundStyle(Color.ghostText.opacity(0.5))
                .padding(.leading, 4)
        }
    }

    private func starName(for index: Int) -> String {
        if personality.rating >= Double(index + 1) {
            return "star.fill"
        }
        if personality.rating > Double(index) {
            return "star.leadinghalf.filled"
        }
        return "star"
    }

    private var traitsRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 8) {
                ForEach(displayTraits, id: \.self) { label in
                    Text(label)
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(Color.ghostCyan)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background {
                            Capsule().fill(.ultraThinMaterial)
                        }
                }
            }
        }
    }

    private var displayTraits: [String] {
        personality.traits.prefix(5).compactMap { raw in
            PersonalityTrait(rawValue: raw)?.displayName ?? raw.capitalized
        }
    }
}

// MARK: - Preview

#Preview("Card — free") {
    ZStack {
        Color.ghostBackground.ignoresSafeArea()
        PersonalityCard(
            personality: GhostPersonality.theMuse(),
            isOwned: false,
            canTry: true,
            trialButtonTitle: "Try 1 Session",
            creatorPayoutText: nil,
            onTry: {},
            onPurchase: {}
        )
        .padding()
    }
    .environment(HapticService())
}

#Preview("Card — priced & owned") {
    ZStack {
        Color.ghostBackground.ignoresSafeArea()
        PersonalityCard(
            personality: GhostPersonality(
                name: "Noir Scribe",
                description: "Lean, cinematic prose with tight pacing and moody atmosphere for thrillers and short fiction.",
                systemPrompt: "You are Noir Scribe...",
                hapticPattern: "sharp_tap",
                voiceId: "critic_voice",
                traits: ["concise", "formal", "analytical"],
                responseStyle: "direct",
                rating: 4.2,
                purchasePrice: 4.99,
                downloads: 1280
            ),
            isOwned: true,
            canTry: true,
            trialButtonTitle: "Try 1 Session",
            creatorPayoutText: "Creator earns $3.49 (70%)",
            onTry: {},
            onPurchase: {}
        )
        .padding()
    }
    .environment(HapticService())
}
