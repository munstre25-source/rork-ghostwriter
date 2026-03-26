import Foundation
import SwiftUI
import Observation

/// Manages the first-launch onboarding flow, personality quiz, and completion state.
@Observable
final class OnboardingService: @unchecked Sendable {

    /// Whether the user has completed onboarding. Backed by `AppStorage`.
    var isOnboardingComplete: Bool {
        get { UserDefaults.standard.bool(forKey: onboardingCompleteKey) }
        set { UserDefaults.standard.set(newValue, forKey: onboardingCompleteKey) }
    }

    /// The current step in the onboarding flow.
    var currentStep: OnboardingStep = .welcome

    /// Accumulated quiz answers keyed by question identifier.
    var quizAnswers: [String: String] = [:]

    // Keep this key aligned with RootView's @AppStorage("onboardingComplete")
    // so onboarding completion state is consistent app-wide.
    private let onboardingCompleteKey = "onboardingComplete"

    /// Completes the given onboarding step and advances to the next.
    ///
    /// - Parameter step: The step the user has just completed.
    func completeStep(_ step: OnboardingStep) {
        guard let currentIndex = OnboardingStep.allCases.firstIndex(of: step) else { return }
        let nextIndex = OnboardingStep.allCases.index(after: currentIndex)

        if nextIndex < OnboardingStep.allCases.endIndex {
            currentStep = OnboardingStep.allCases[nextIndex]
        } else {
            currentStep = .complete
        }

        print("[Onboarding] Completed step: \(step.title) → now at \(currentStep.title)")
    }

    /// Matches the user to a ghost personality based on quiz answers.
    ///
    /// Uses keyword analysis from the quiz answers to select the best-fit
    /// built-in personality.
    ///
    /// - Parameter answers: The quiz answers keyed by question identifier.
    /// - Returns: The recommended ``GhostPersonality``.
    func matchPersonality(from answers: [String: String]) -> GhostPersonality {
        let combined = answers.values.joined(separator: " ").lowercased()

        let scoringRules: [(keywords: [String], personality: () -> GhostPersonality)] = [
            (["creative", "inspire", "flow", "free", "explore"],    GhostPersonality.theMuse),
            (["structure", "organize", "plan", "outline", "logic"], GhostPersonality.theArchitect),
            (["improve", "edit", "critique", "quality", "polish"],  GhostPersonality.theCritic),
            (["vision", "bold", "dream", "future", "imagine"],     GhostPersonality.theVisionary),
            (["data", "analyze", "research", "evidence", "detail"], GhostPersonality.theAnalyst)
        ]

        var bestMatch: (() -> GhostPersonality) = GhostPersonality.theMuse
        var bestScore = 0

        for rule in scoringRules {
            let score = rule.keywords.reduce(0) { total, keyword in
                total + (combined.contains(keyword) ? 1 : 0)
            }
            if score > bestScore {
                bestScore = score
                bestMatch = rule.personality
            }
        }

        let personality = bestMatch()
        print("[Onboarding] Matched personality: \(personality.name) (score: \(bestScore))")
        return personality
    }

    /// Marks the onboarding flow as complete and persists the state.
    func markOnboardingComplete() {
        currentStep = .complete
        isOnboardingComplete = true
        print("[Onboarding] Onboarding marked complete")
    }
}
