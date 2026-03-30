import Foundation
import SwiftData

@Model
class BioMetricSample {
    #Index<BioMetricSample>([\.timestamp])

    var id: UUID
    var timestamp: Date
    var hrv: Double
    var sleepQuality: Double
    var restingHeartRate: Double
    var cognitiveReadinessScore: Double
    var healthKitUUID: String?

    init(
        timestamp: Date = Date(),
        hrv: Double = 0,
        sleepQuality: Double = 0,
        restingHeartRate: Double = 0,
        cognitiveReadinessScore: Double = 0,
        healthKitUUID: String? = nil
    ) {
        self.id = UUID()
        self.timestamp = timestamp
        self.hrv = hrv
        self.sleepQuality = sleepQuality
        self.restingHeartRate = restingHeartRate
        self.cognitiveReadinessScore = cognitiveReadinessScore
        self.healthKitUUID = healthKitUUID
    }
}
