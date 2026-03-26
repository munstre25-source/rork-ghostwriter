import SwiftUI

/// Common application error cases with user-facing messages.
enum AppError: LocalizedError, Identifiable {
    case networkUnavailable
    case serverError(statusCode: Int)
    case sessionExpired
    case subscriptionRequired
    case invalidInput(detail: String)
    case aiUnavailable
    case storageFull
    case unknown(underlying: Error)

    var id: String { localizedDescription }

    var errorDescription: String? {
        switch self {
        case .networkUnavailable:
            return "No internet connection. Please check your network and try again."
        case .serverError(let code):
            return "Something went wrong on our end (error \(code)). Please try again later."
        case .sessionExpired:
            return "Your session has expired. Please sign in again."
        case .subscriptionRequired:
            return "This feature requires a subscription. Upgrade to continue."
        case .invalidInput(let detail):
            return "Invalid input: \(detail)"
        case .aiUnavailable:
            return "The Ghost AI is temporarily unavailable. Please try again in a moment."
        case .storageFull:
            return "Your device storage is full. Free up space to continue."
        case .unknown:
            return "An unexpected error occurred. Please try again."
        }
    }

    /// A short title suitable for alert headers.
    var title: String {
        switch self {
        case .networkUnavailable: return "Offline"
        case .serverError: return "Server Error"
        case .sessionExpired: return "Session Expired"
        case .subscriptionRequired: return "Upgrade Required"
        case .invalidInput: return "Invalid Input"
        case .aiUnavailable: return "Ghost Unavailable"
        case .storageFull: return "Storage Full"
        case .unknown: return "Error"
        }
    }

    /// An appropriate SF Symbol name for the error type.
    var iconName: String {
        switch self {
        case .networkUnavailable: return "wifi.slash"
        case .serverError: return "exclamationmark.icloud"
        case .sessionExpired: return "clock.arrow.circlepath"
        case .subscriptionRequired: return "lock.fill"
        case .invalidInput: return "exclamationmark.triangle"
        case .aiUnavailable: return "brain"
        case .storageFull: return "externaldrive.badge.xmark"
        case .unknown: return "xmark.octagon"
        }
    }
}

/// Observable error handler that manages the current error state and presentation.
@Observable
final class ErrorHandler {
    /// The currently active error, if any.
    var currentError: AppError?

    /// Whether an error alert/view should be shown.
    var showError: Bool = false

    /// Handles a raw `Error`, mapping it to an `AppError` and presenting it.
    /// - Parameter error: The error to handle.
    func handle(_ error: Error) {
        if let appError = error as? AppError {
            currentError = appError
        } else {
            currentError = .unknown(underlying: error)
        }
        showError = true
        GhostLogger.error("ErrorHandler: \(error.localizedDescription)")
    }

    /// Dismisses the currently displayed error.
    func dismiss() {
        showError = false
        currentError = nil
    }
}
