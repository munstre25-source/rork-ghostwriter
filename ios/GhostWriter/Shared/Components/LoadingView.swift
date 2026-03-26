import SwiftUI

/// A full-area loading state view with a pulsing ``GhostOrbView`` animation.
///
/// ```swift
/// LoadingView(message: "Generating suggestions...")
/// ```
struct LoadingView: View {
    /// Message displayed below the orb. Defaults to "Thinking...".
    var message: String = "Thinking..."
    /// Orb accent color. Defaults to `.ghostCyan`.
    var color: Color = .ghostCyan
    /// Orb size. Defaults to `60`.
    var orbSize: CGFloat = 60

    var body: some View {
        VStack(spacing: 24) {
            GhostOrbView(color: color, activity: .thinking, size: orbSize)

            Text(message)
                .font(.system(size: TypographyConstants.subheadline, weight: .medium))
                .foregroundStyle(Color.ghostText.opacity(0.7))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.regularMaterial)
    }
}

// MARK: - Previews

#Preview("Default") {
    ZStack {
        Color.ghostBackground.ignoresSafeArea()
        LoadingView()
    }
}

#Preview("Custom Message") {
    ZStack {
        Color.ghostBackground.ignoresSafeArea()
        LoadingView(message: "Generating suggestions...", color: .ghostMagenta)
    }
}

#Preview("Compact") {
    ZStack {
        Color.ghostBackground.ignoresSafeArea()
        LoadingView(message: "Loading...", orbSize: 40)
            .frame(height: 200)
            .liquidGlass(cornerRadius: 20)
            .padding()
    }
}
