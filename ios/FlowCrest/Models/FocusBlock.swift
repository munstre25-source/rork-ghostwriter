import Foundation
import SwiftData

@Model
class FocusBlock {
    #Index<FocusBlock>([\.startTime], [\.endTime])

    var id: UUID
    var eventIdentifier: String?
    var startTime: Date
    var endTime: Date
    var taskDescription: String
    var intendedEnergyLevelRaw: String
    var isCompleted: Bool
    var originalSchedule: Date
    var suggestedReschedule: Date?
    var rescheduleAccepted: Bool?

    var intendedEnergyLevel: EnergyLevel {
        get { EnergyLevel(rawValue: intendedEnergyLevelRaw) ?? .shallow }
        set { intendedEnergyLevelRaw = newValue.rawValue }
    }

    var duration: TimeInterval {
        endTime.timeIntervalSince(startTime)
    }

    var hasMismatch: Bool {
        suggestedReschedule != nil && rescheduleAccepted == nil
    }

    init(
        eventIdentifier: String? = nil,
        startTime: Date,
        endTime: Date,
        taskDescription: String,
        intendedEnergyLevel: EnergyLevel = .shallow,
        isCompleted: Bool = false
    ) {
        self.id = UUID()
        self.eventIdentifier = eventIdentifier
        self.startTime = startTime
        self.endTime = endTime
        self.taskDescription = taskDescription
        self.intendedEnergyLevelRaw = intendedEnergyLevel.rawValue
        self.isCompleted = isCompleted
        self.originalSchedule = startTime
        self.suggestedReschedule = nil
        self.rescheduleAccepted = nil
    }
}
