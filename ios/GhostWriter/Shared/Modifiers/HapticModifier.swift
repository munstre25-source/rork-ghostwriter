import SwiftUI
import UIKit

/// A `ViewModifier` that triggers haptic feedback on tap.
///
/// Apply via the convenience extension:
/// ```swift
/// Button("Tap me") { }
///     .hapticFeedback(.light)
/// ```
struct HapticModifier: ViewModifier {
    /// The impact feedback style to use.
    var style: UIImpactFeedbackGenerator.FeedbackStyle

    func body(content: Content) -> some View {
        content
            .simultaneousGesture(
                TapGesture().onEnded {
                    let generator = UIImpactFeedbackGenerator(style: style)
                    generator.impactOccurred()
                }
            )
    }
}
