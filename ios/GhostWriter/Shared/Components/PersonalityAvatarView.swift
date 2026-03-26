import SwiftUI

/// A circular avatar for a ghost personality.
///
/// Displays the personality's initial or an SF Symbol icon with a
/// colored border based on personality traits. An optional online indicator
/// can be shown.
///
/// ```swift
/// PersonalityAvatarView(
///     name: "Mentor",
///     color: .ghostCyan,
///     icon: "brain.head.profile",
///     isActive: true,
///     size: 48
/// )
/// ```
struct PersonalityAvatarView: View {
    /// Personality display name.
    var name: String
    /// Accent color representing the personality.
    var color: Color
    /// Optional SF Symbol name. Falls back to the first letter of `name`.
    var icon: String?
    /// Whether the personality is currently active/online.
    var isActive: Bool
    /// Diameter of the avatar circle.
    var size: CGFloat = 48

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            // Main circle
            Circle()
                .fill(.ultraThinMaterial)
                .frame(width: size, height: size)
                .overlay(
                    Group {
                        if let icon {
                            Image(systemName: icon)
                                .font(.system(size: size * 0.38, weight: .medium))
                                .foregroundStyle(color)
                        } else {
                            Text(String(name.prefix(1)).uppercased())
                                .font(.system(size: size * 0.4, weight: .bold, design: .rounded))
                                .foregroundStyle(color)
                        }
                    }
                )
                .overlay(
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [color, color.opacity(0.4)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2
                        )
                )

            // Active indicator
            if isActive {
                Circle()
                    .fill(Color.ghostEmerald)
                    .frame(width: size * 0.24, height: size * 0.24)
                    .overlay(
                        Circle()
                            .stroke(Color.ghostBackground, lineWidth: 2)
                    )
                    .offset(x: 2, y: 2)
            }
        }
    }
}

// MARK: - Previews

#Preview("Active with Icon") {
    ZStack {
        Color.ghostBackground.ignoresSafeArea()
        PersonalityAvatarView(
            name: "Mentor",
            color: .ghostCyan,
            icon: "brain.head.profile",
            isActive: true,
            size: 56
        )
    }
}

#Preview("Initial Only") {
    ZStack {
        Color.ghostBackground.ignoresSafeArea()
        PersonalityAvatarView(
            name: "Provocateur",
            color: .ghostMagenta,
            isActive: false,
            size: 48
        )
    }
}

#Preview("Gallery") {
    ZStack {
        Color.ghostBackground.ignoresSafeArea()
        HStack(spacing: 16) {
            PersonalityAvatarView(name: "Mentor", color: .ghostCyan, icon: "brain.head.profile", isActive: true)
            PersonalityAvatarView(name: "Provocateur", color: .ghostMagenta, isActive: false)
            PersonalityAvatarView(name: "Collaborator", color: .ghostEmerald, icon: "person.2", isActive: true)
            PersonalityAvatarView(name: "Mystic", color: Color(hex: "A855F7"), icon: "sparkles", isActive: false)
        }
    }
}
