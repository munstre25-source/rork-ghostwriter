import Foundation
import SwiftData

@MainActor
final class FocusScoreService {
    static let shared = FocusScoreService()
    private init() {}

    func calculateDailyScore(
        blocks: [FocusBlock],
        samples: [BioMetricSample],
        engine: BioAdaptiveEngine
    ) -> FocusScore {
        let calendar = Calendar.current
        let todayBlocks = blocks.filter { calendar.isDateInToday($0.startTime) }
        let completedBlocks = todayBlocks.filter { $0.isCompleted }

        guard !todayBlocks.isEmpty else {
            return FocusScore(
                date: Date(),
                score: 0,
                insight: "No focus blocks scheduled today. Add some tasks to track your productivity."
            )
        }

        var alignmentScore: Double = 0
        var alignedCount = 0
        let avgReadiness = samples.isEmpty ? 50.0 :
            samples.prefix(5).reduce(0.0) { $0 + $1.cognitiveReadinessScore } / Double(min(samples.count, 5))

        for block in completedBlocks {
            let threshold = block.intendedEnergyLevel.minimumReadinessThreshold
            if avgReadiness >= threshold {
                alignmentScore += 1.0
                alignedCount += 1
            } else {
                let ratio = avgReadiness / threshold
                alignmentScore += min(ratio, 0.8)
                if ratio > 0.75 { alignedCount += 1 }
            }
        }

        let completionRate = Double(completedBlocks.count) / Double(todayBlocks.count)
        let alignmentRate = completedBlocks.isEmpty ? 0.5 : alignmentScore / Double(completedBlocks.count)

        let acceptedCount = todayBlocks.filter { $0.rescheduleAccepted == true }.count
        let rejectedCount = todayBlocks.filter { $0.rescheduleAccepted == false }.count
        let suggestionBonus: Double = acceptedCount > 0 ? 0.1 : 0

        let rawScore = (alignmentRate * 0.5 + completionRate * 0.35 + suggestionBonus + 0.05) * 100
        let finalScore = min(max(rawScore, 1), 100)

        let insight = generateInsight(
            score: finalScore,
            completionRate: completionRate,
            alignmentRate: alignmentRate,
            completedCount: completedBlocks.count,
            totalCount: todayBlocks.count
        )

        let focusScore = FocusScore(
            date: Date(),
            score: finalScore,
            alignedBlockCount: alignedCount,
            totalBlockCount: todayBlocks.count,
            acceptedSuggestions: acceptedCount,
            rejectedSuggestions: rejectedCount,
            insight: insight
        )

        updateSharedDefaults(score: finalScore, insight: insight)

        return focusScore
    }

    private func generateInsight(score: Double, completionRate: Double, alignmentRate: Double, completedCount: Int, totalCount: Int) -> String {
        if score >= 85 {
            return "Outstanding! You're working in perfect sync with your biology."
        } else if score >= 70 {
            return "Great day! Most of your tasks aligned well with your energy levels."
        } else if score >= 50 {
            return "Decent progress. Try accepting more swap suggestions tomorrow."
        } else if completionRate < 0.3 {
            return "You completed \(completedCount) of \(totalCount) blocks. Small steps build momentum."
        } else {
            return "Your tasks didn't align with your energy today. Let FlowCrest guide your schedule."
        }
    }

    private func updateSharedDefaults(score: Double, insight: String) {
        let defaults = UserDefaults(suiteName: "group.app.rork.flowcrest.shared")
        defaults?.set(score, forKey: "latestFocusScore")
        defaults?.set(insight, forKey: "latestInsight")
        defaults?.set(Date().timeIntervalSince1970, forKey: "lastScoreUpdate")
    }
}
