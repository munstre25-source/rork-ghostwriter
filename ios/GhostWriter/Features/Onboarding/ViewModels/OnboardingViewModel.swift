import Foundation
import Observation

@Observable
final class OnboardingViewModel {

    var currentStep: OnboardingStep = .welcome
    var quizAnswers: [String: String] = [:]
    var matchedPersonality: GhostPersonality?
    var firstSessionText: String = ""
    var isLoading: Bool = false
    var showSkipConfirmation: Bool = false

    private let service: OnboardingService

    init(service: OnboardingService = OnboardingService()) {
        self.service = service
    }

    var progress: Double {
        currentStep.progress
    }

    var canGoBack: Bool {
        guard let index = OnboardingStep.allCases.firstIndex(of: currentStep) else { return false }
        return index > 0
    }

    var isLastStep: Bool {
        currentStep == .socialProof
    }

    var firstSessionWordCount: Int {
        firstSessionText.split(whereSeparator: \.isWhitespace).count
    }

    func advanceStep() {
        service.completeStep(currentStep)
        currentStep = service.currentStep
    }

    func goBack() {
        guard let index = OnboardingStep.allCases.firstIndex(of: currentStep), index > 0 else { return }
        currentStep = OnboardingStep.allCases[index - 1]
    }

    func answerQuiz(question: String, answer: String) {
        quizAnswers[question] = answer
    }

    func matchPersonality() {
        matchedPersonality = service.matchPersonality(from: quizAnswers)
    }

    func completeOnboarding() {
        service.markOnboardingComplete()
        currentStep = .complete
    }

    func skipOnboarding() {
        matchedPersonality = GhostPersonality.theMuse()
        service.markOnboardingComplete()
        currentStep = .complete
    }
}
