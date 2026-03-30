import StoreKit
import SwiftUI

@MainActor
final class ReviewPromptService {
    static let shared = ReviewPromptService()
    private init() {}

    private let acceptedSwapsKey = "reviewPrompt_acceptedSwaps"
    private let consecutiveImprovementKey = "reviewPrompt_consecutiveImprovement"
    private let lastPromptDateKey = "reviewPrompt_lastPromptDate"
    private let previousScoresKey = "reviewPrompt_previousScores"

    func recordAcceptedSwap() {
        let count = UserDefaults.standard.integer(forKey: acceptedSwapsKey) + 1
        UserDefaults.standard.set(count, forKey: acceptedSwapsKey)
        checkAndPrompt()
    }

    func recordDailyScore(_ score: Double) {
        var scores = UserDefaults.standard.array(forKey: previousScoresKey) as? [Double] ?? []
        scores.append(score)
        if scores.count > 7 { scores = Array(scores.suffix(7)) }
        UserDefaults.standard.set(scores, forKey: previousScoresKey)

        if scores.count >= 3 {
            let recent = Array(scores.suffix(3))
            let isImproving = zip(recent, recent.dropFirst()).allSatisfy { $0.0 < $0.1 }
            if isImproving {
                let current = UserDefaults.standard.integer(forKey: consecutiveImprovementKey) + 1
                UserDefaults.standard.set(current, forKey: consecutiveImprovementKey)
                checkAndPrompt()
            } else {
                UserDefaults.standard.set(0, forKey: consecutiveImprovementKey)
            }
        }
    }

    private func checkAndPrompt() {
        guard canPrompt() else { return }

        let acceptedSwaps = UserDefaults.standard.integer(forKey: acceptedSwapsKey)
        let consecutiveDays = UserDefaults.standard.integer(forKey: consecutiveImprovementKey)

        if acceptedSwaps >= 3 || consecutiveDays >= 3 {
            requestReview()
        }
    }

    private func canPrompt() -> Bool {
        let lastPrompt = UserDefaults.standard.double(forKey: lastPromptDateKey)
        guard lastPrompt > 0 else { return true }
        let daysSinceLastPrompt = Date().timeIntervalSince1970 - lastPrompt
        return daysSinceLastPrompt > 90 * 24 * 3600
    }

    private func requestReview() {
        UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: lastPromptDateKey)

        if let scene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first {
            SKStoreReviewController.requestReview(in: scene)
        }
    }
}
