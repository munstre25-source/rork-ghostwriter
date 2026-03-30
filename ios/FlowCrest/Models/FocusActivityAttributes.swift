import ActivityKit
import Foundation

nonisolated struct FocusActivityAttributes: ActivityAttributes {
    nonisolated struct ContentState: Codable, Hashable, Sendable {
        var taskDescription: String
        var energyLevelRaw: String
        var endTime: Date
        var readinessScore: Double
    }

    var blockID: String
    var startTime: Date
}
