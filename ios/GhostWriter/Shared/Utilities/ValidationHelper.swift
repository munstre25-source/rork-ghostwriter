import Foundation

/// Common input validation utilities.
struct ValidationHelper {
    /// Validates a username: 3–20 characters, alphanumeric and underscores only.
    /// - Parameter username: The username to validate.
    /// - Returns: `true` if the username meets the criteria.
    static func isValidUsername(_ username: String) -> Bool {
        let pattern = #"^[a-zA-Z0-9_]{3,20}$"#
        return username.range(of: pattern, options: .regularExpression) != nil
    }

    /// Validates an email address format.
    /// - Parameter email: The email to validate.
    /// - Returns: `true` if the email has a valid format.
    static func isValidEmail(_ email: String) -> Bool {
        let pattern = #"^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        return email.range(of: pattern, options: .regularExpression) != nil
    }

    /// Validates a personality name: 2–30 characters, letters, numbers, spaces, and hyphens.
    /// - Parameter name: The personality name to validate.
    /// - Returns: `true` if the name meets the criteria.
    static func isValidPersonalityName(_ name: String) -> Bool {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.count >= 2, trimmed.count <= 30 else { return false }
        let pattern = #"^[a-zA-Z0-9 \-]{2,30}$"#
        return trimmed.range(of: pattern, options: .regularExpression) != nil
    }

    /// Sanitizes input by trimming whitespace and removing control characters.
    /// - Parameter text: The raw input text.
    /// - Returns: Sanitized text safe for display and storage.
    static func sanitizeInput(_ text: String) -> String {
        text.trimmingCharacters(in: .whitespacesAndNewlines)
            .filter { !$0.isNewline || $0 == "\n" }
            .replacingOccurrences(
                of: #"[\x00-\x08\x0B\x0C\x0E-\x1F\x7F]"#,
                with: "",
                options: .regularExpression
            )
    }
}
