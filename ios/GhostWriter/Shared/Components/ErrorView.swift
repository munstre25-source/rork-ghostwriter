import SwiftUI
import UIKit

/// A view that presents an error with an icon, message, and retry action.
///
/// Triggers haptic feedback when the retry button is tapped.
///
/// ```swift
/// ErrorView(
///     icon: "wifi.slash",
///     message: "No internet connection.",
///     onRetry: { loadData() }
/// )
/// ```
struct ErrorView: View {
    /// SF Symbol name for the error icon.
    var icon: String = "exclamationmark.triangle"
    /// The error message to display.
    var message: String
    /// Optional retry action. When provided the retry button is shown.
    var onRetry: (() -> Void)?

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: icon)
                .font(.system(size: 44, weight: .light))
                .foregroundStyle(Color.ghostMagenta)
                .symbolEffect(.pulse)

            Text(message)
                .font(.system(size: TypographyConstants.subheadline, weight: .medium))
                .foregroundStyle(Color.ghostText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            if let onRetry {
                Button(action: {
                    let generator = UIImpactFeedbackGenerator(style: .medium)
                    generator.impactOccurred()
                    onRetry()
                }) {
                    Label("Try Again", systemImage: "arrow.clockwise")
                        .font(.system(size: TypographyConstants.callout, weight: .semibold))
                        .foregroundStyle(Color.ghostCyan)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 10)
                        .background(
                            Capsule()
                                .fill(.ultraThinMaterial)
                        )
                        .overlay(
                            Capsule()
                                .stroke(Color.ghostCyan.opacity(0.3), lineWidth: 1)
                        )
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.regularMaterial)
    }
}

// MARK: - Convenience initializer from AppError

extension ErrorView {
    /// Creates an `ErrorView` from an ``AppError``.
    /// - Parameters:
    ///   - error: The application error.
    ///   - onRetry: Optional retry closure.
    init(error: AppError, onRetry: (() -> Void)? = nil) {
        self.icon = error.iconName
        self.message = error.localizedDescription
        self.onRetry = onRetry
    }
}

// MARK: - Previews

#Preview("Default Error") {
    ZStack {
        Color.ghostBackground.ignoresSafeArea()
        ErrorView(message: "Something went wrong. Please try again.") {
            print("Retry tapped")
        }
    }
}

#Preview("Network Error") {
    ZStack {
        Color.ghostBackground.ignoresSafeArea()
        ErrorView(
            icon: "wifi.slash",
            message: "No internet connection. Check your network settings."
        ) {
            print("Retry tapped")
        }
    }
}

#Preview("No Retry") {
    ZStack {
        Color.ghostBackground.ignoresSafeArea()
        ErrorView(
            icon: "lock.fill",
            message: "This feature requires a subscription."
        )
    }
}

#Preview("From AppError") {
    ZStack {
        Color.ghostBackground.ignoresSafeArea()
        ErrorView(error: .aiUnavailable) {
            print("Retry tapped")
        }
    }
}
