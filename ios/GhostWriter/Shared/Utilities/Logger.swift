import Foundation
import os

/// Lightweight logging facade backed by `os.Logger`.
struct GhostLogger {
    private static let subsystem = "com.ghostwriter.app"
    private static let logger = os.Logger(subsystem: subsystem, category: "general")

    /// Logs an informational message.
    /// - Parameter message: The message to log.
    static func info(_ message: String) {
        logger.info("\(message, privacy: .public)")
    }

    /// Logs a debug-level message. Only visible in Console.app when debug logging is enabled.
    /// - Parameter message: The message to log.
    static func debug(_ message: String) {
        logger.debug("\(message, privacy: .public)")
    }

    /// Logs a warning-level message.
    /// - Parameter message: The message to log.
    static func warning(_ message: String) {
        logger.warning("\(message, privacy: .public)")
    }

    /// Logs an error-level message.
    /// - Parameter message: The message to log.
    static func error(_ message: String) {
        logger.error("\(message, privacy: .public)")
    }

    /// Creates a category-scoped logger.
    /// - Parameter category: The logging category.
    /// - Returns: A new `os.Logger` scoped to the GhostWriter subsystem.
    static func scoped(_ category: String) -> os.Logger {
        os.Logger(subsystem: subsystem, category: category)
    }
}
