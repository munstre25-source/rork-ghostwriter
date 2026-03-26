import Foundation

@MainActor
final class CognitiveReadinessModel {
    static let shared = CognitiveReadinessModel()

    private var personalWeights: PersonalWeights

    private init() {
        if let data = UserDefaults.standard.data(forKey: "cognitiveReadinessWeights"),
           let weights = try? JSONDecoder().decode(PersonalWeights.self, from: data) {
            personalWeights = weights
        } else {
            personalWeights = .default
        }
    }

    func predict(hrv: Double, sleepQuality: Double, restingHeartRate: Double) -> Double {
        let normalizedHRV = normalizeHRV(hrv)
        let normalizedRHR = normalizeRHR(restingHeartRate)
        let clampedSleep = min(max(sleepQuality, 0), 1.0)

        let score = (normalizedHRV * personalWeights.hrvWeight +
                     clampedSleep * personalWeights.sleepWeight +
                     normalizedRHR * personalWeights.rhrWeight +
                     personalWeights.bias)

        return min(max(score * 100, 1), 100)
    }

    func updatePersonalization(
        predictedScore: Double,
        userFeedback: UserFeedback,
        hrv: Double,
        sleepQuality: Double,
        restingHeartRate: Double
    ) {
        let adjustmentFactor: Double
        switch userFeedback {
        case .accurate:
            return
        case .tooHigh:
            adjustmentFactor = -0.02
        case .tooLow:
            adjustmentFactor = 0.02
        }

        let normalizedHRV = normalizeHRV(hrv)
        let normalizedRHR = normalizeRHR(restingHeartRate)
        let clampedSleep = min(max(sleepQuality, 0), 1.0)

        personalWeights.hrvWeight += adjustmentFactor * normalizedHRV
        personalWeights.sleepWeight += adjustmentFactor * clampedSleep
        personalWeights.rhrWeight += adjustmentFactor * normalizedRHR
        personalWeights.bias += adjustmentFactor

        personalWeights.hrvWeight = min(max(personalWeights.hrvWeight, 0.1), 0.8)
        personalWeights.sleepWeight = min(max(personalWeights.sleepWeight, 0.1), 0.8)
        personalWeights.rhrWeight = min(max(personalWeights.rhrWeight, 0.05), 0.5)

        saveWeights()
    }

    private func normalizeHRV(_ hrv: Double) -> Double {
        min(max(hrv / 100.0, 0), 1.0)
    }

    private func normalizeRHR(_ rhr: Double) -> Double {
        guard rhr > 0 else { return 0.5 }
        let inverted = 1.0 - ((rhr - 40.0) / 60.0)
        return min(max(inverted, 0), 1.0)
    }

    private func saveWeights() {
        if let data = try? JSONEncoder().encode(personalWeights) {
            UserDefaults.standard.set(data, forKey: "cognitiveReadinessWeights")
        }
    }
}

nonisolated struct PersonalWeights: Codable, Sendable {
    var hrvWeight: Double
    var sleepWeight: Double
    var rhrWeight: Double
    var bias: Double

    static let `default` = PersonalWeights(
        hrvWeight: 0.40,
        sleepWeight: 0.35,
        rhrWeight: 0.20,
        bias: 0.05
    )
}

nonisolated enum UserFeedback: String, Codable, Sendable {
    case accurate
    case tooHigh
    case tooLow
}
