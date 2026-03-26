import Foundation

extension String {
    /// The number of whitespace-separated words in the string.
    var wordCount: Int {
        let words = self.split { $0.isWhitespace || $0.isNewline }
        return words.count
    }

    /// The number of sentences, estimated by counting sentence-terminating punctuation.
    var sentenceCount: Int {
        guard !isEmpty else { return 0 }
        let terminators: [Character] = [".", "!", "?"]
        let count = self.filter { terminators.contains($0) }.count
        return max(count, isEmpty ? 0 : 1)
    }

    /// Estimated reading time in seconds, based on 238 words per minute (average adult reading speed).
    var readingTime: TimeInterval {
        let wordsPerMinute: Double = 238
        return Double(wordCount) / wordsPerMinute * 60
    }

    /// Returns the string truncated to at most `length` characters, appending "..." if truncated.
    /// - Parameter length: Maximum character count before truncation.
    /// - Returns: The truncated string.
    func truncated(to length: Int) -> String {
        guard count > length else { return self }
        return String(prefix(length)) + "..."
    }

    /// Whether the string is a valid username (3-20 alphanumeric characters or underscores).
    var isValidUsername: Bool {
        let pattern = #"^[a-zA-Z0-9_]{3,20}$"#
        return range(of: pattern, options: .regularExpression) != nil
    }
}
