import AppIntents
import SwiftUI

struct GetReadinessIntent: AppIntent {
    static var title: LocalizedStringResource = "Check Cognitive Readiness"
    static var description: IntentDescription = "Get your current cognitive readiness score from FlowCrest"
    static var openAppWhenRun: Bool = false

    func perform() async throws -> some IntentResult & ProvidesDialog {
        let defaults = UserDefaults(suiteName: "group.app.rork.flowcrest.shared")
        let score = defaults?.double(forKey: "currentReadiness") ?? 0
        let category = ReadinessCategory.from(score: score)

        if score > 0 {
            return .result(dialog: "Your cognitive readiness is \(Int(score)) out of 100 — that's \(category.displayName.lowercased()). \(readinessAdvice(for: category))")
        } else {
            return .result(dialog: "I don't have recent readiness data. Open FlowCrest to sync your bio metrics.")
        }
    }

    private func readinessAdvice(for category: ReadinessCategory) -> String {
        switch category {
        case .peak: return "Perfect time for deep, focused work."
        case .good: return "You're ready for focused tasks."
        case .moderate: return "Consider lighter tasks right now."
        case .low: return "Stick to admin tasks or take a break."
        case .veryLow: return "Rest up before tackling anything demanding."
        }
    }
}

struct GetNextTaskIntent: AppIntent {
    static var title: LocalizedStringResource = "What Should I Work On"
    static var description: IntentDescription = "Get a recommendation for what to work on now based on your readiness"
    static var openAppWhenRun: Bool = false

    func perform() async throws -> some IntentResult & ProvidesDialog {
        let defaults = UserDefaults(suiteName: "group.app.rork.flowcrest.shared")
        let score = defaults?.double(forKey: "currentReadiness") ?? 0
        let nextTask = defaults?.string(forKey: "nextTaskDescription") ?? ""
        let nextEnergy = defaults?.string(forKey: "nextTaskEnergy") ?? ""

        if !nextTask.isEmpty {
            return .result(dialog: "Your next task is \"\(nextTask)\" (\(nextEnergy)). With a readiness of \(Int(score)), \(alignmentMessage(score: score, energy: nextEnergy))")
        } else if score > 0 {
            let recommendation = score >= 60 ? "deep work" : (score >= 35 ? "shallow tasks" : "admin work or a break")
            return .result(dialog: "No upcoming tasks found. Based on your readiness of \(Int(score)), I'd suggest \(recommendation).")
        } else {
            return .result(dialog: "Open FlowCrest to sync your schedule and bio data for personalized recommendations.")
        }
    }

    private func alignmentMessage(score: Double, energy: String) -> String {
        let level = EnergyLevel(rawValue: energy) ?? .shallow
        if score >= level.minimumReadinessThreshold {
            return "you're well aligned for this task!"
        } else {
            return "consider swapping to a lighter task — your energy is below optimal for this."
        }
    }
}

struct FlowCrestShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: GetReadinessIntent(),
            phrases: [
                "Am I ready for deep work in \(.applicationName)",
                "Check my readiness in \(.applicationName)",
                "How's my focus in \(.applicationName)"
            ],
            shortTitle: "Check Readiness",
            systemImageName: "brain.head.profile.fill"
        )
        AppShortcut(
            intent: GetNextTaskIntent(),
            phrases: [
                "What should I work on in \(.applicationName)",
                "What's next in \(.applicationName)"
            ],
            shortTitle: "Next Task",
            systemImageName: "checklist"
        )
    }
}
