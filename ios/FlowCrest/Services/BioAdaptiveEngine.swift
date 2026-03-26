import Foundation
import SwiftData

@Observable
@MainActor
final class BioAdaptiveEngine {
    private let model = CognitiveReadinessModel.shared

    var currentReadinessScore: Double = 0
    var lastAnalysisDate: Date?
    var activeSuggestions: [ScheduleSuggestion] = []

    func analyzeAndScore(hrv: Double, sleepQuality: Double, restingHeartRate: Double) -> Double {
        let score = model.predict(hrv: hrv, sleepQuality: sleepQuality, restingHeartRate: restingHeartRate)
        currentReadinessScore = score
        lastAnalysisDate = Date()
        return score
    }

    func detectMismatches(blocks: [FocusBlock], readinessScore: Double) -> [ScheduleSuggestion] {
        var suggestions: [ScheduleSuggestion] = []

        let upcomingBlocks = blocks
            .filter { !$0.isCompleted && $0.startTime > Date() && $0.rescheduleAccepted == nil }
            .sorted { $0.startTime < $1.startTime }

        for block in upcomingBlocks {
            let threshold = block.intendedEnergyLevel.minimumReadinessThreshold
            guard readinessScore < threshold else { continue }

            let swapCandidate = findSwapCandidate(
                for: block,
                in: upcomingBlocks,
                readinessScore: readinessScore
            )

            let reason = buildReason(
                energyLevel: block.intendedEnergyLevel,
                readinessScore: readinessScore,
                threshold: threshold
            )

            let suggestion = ScheduleSuggestion(
                focusBlockID: block.id,
                originalTime: block.startTime,
                suggestedTime: swapCandidate?.startTime ?? findNextOptimalSlot(after: block.startTime),
                reason: reason,
                currentReadiness: readinessScore,
                requiredReadiness: threshold,
                swapWith: swapCandidate?.id
            )
            suggestions.append(suggestion)
        }

        activeSuggestions = suggestions
        return suggestions
    }

    func applySuggestion(_ suggestion: ScheduleSuggestion, to blocks: [FocusBlock], accepted: Bool) {
        guard let block = blocks.first(where: { $0.id == suggestion.focusBlockID }) else { return }

        if accepted {
            block.suggestedReschedule = suggestion.suggestedTime
            block.rescheduleAccepted = true

            if let swapID = suggestion.swapWith,
               let swapBlock = blocks.first(where: { $0.id == swapID }) {
                let tempStart = block.startTime
                let tempEnd = block.endTime
                block.startTime = swapBlock.startTime
                block.endTime = swapBlock.endTime
                swapBlock.startTime = tempStart
                swapBlock.endTime = tempEnd
            } else {
                let duration = block.duration
                block.startTime = suggestion.suggestedTime
                block.endTime = suggestion.suggestedTime.addingTimeInterval(duration)
            }
        } else {
            block.suggestedReschedule = suggestion.suggestedTime
            block.rescheduleAccepted = false
        }

        activeSuggestions.removeAll { $0.id == suggestion.id }
    }

    func provideFeedback(_ feedback: UserFeedback, hrv: Double, sleepQuality: Double, restingHeartRate: Double) {
        model.updatePersonalization(
            predictedScore: currentReadinessScore,
            userFeedback: feedback,
            hrv: hrv,
            sleepQuality: sleepQuality,
            restingHeartRate: restingHeartRate
        )
    }

    private func findSwapCandidate(for block: FocusBlock, in blocks: [FocusBlock], readinessScore: Double) -> FocusBlock? {
        blocks.first { candidate in
            candidate.id != block.id &&
            candidate.intendedEnergyLevel.minimumReadinessThreshold <= readinessScore &&
            block.intendedEnergyLevel.minimumReadinessThreshold > readinessScore
        }
    }

    private func findNextOptimalSlot(after date: Date) -> Date {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)

        if hour < 10 {
            return calendar.date(bySettingHour: 10, minute: 0, second: 0, of: date) ?? date
        } else if hour < 14 {
            return calendar.date(bySettingHour: 14, minute: 0, second: 0, of: date) ?? date
        } else {
            let tomorrow = calendar.date(byAdding: .day, value: 1, to: date)!
            return calendar.date(bySettingHour: 9, minute: 0, second: 0, of: tomorrow) ?? date
        }
    }

    private func buildReason(energyLevel: EnergyLevel, readinessScore: Double, threshold: Double) -> String {
        let deficit = Int(threshold - readinessScore)
        switch energyLevel {
        case .deep:
            return "Your cognitive readiness is \(deficit) points below the threshold for deep work. Consider rescheduling to when you're more alert."
        case .shallow:
            return "Your current readiness is lower than optimal for this task. A lighter task may be more productive right now."
        case .admin:
            return "Even routine tasks may be affected. Consider taking a break first."
        }
    }
}
