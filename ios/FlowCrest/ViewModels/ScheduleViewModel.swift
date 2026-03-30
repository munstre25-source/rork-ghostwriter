import Foundation
import SwiftData

@Observable
@MainActor
final class ScheduleViewModel {
    var selectedDate: Date = Date()
    var showingAddBlock = false
    var editingBlock: FocusBlock?

    var newTaskDescription = ""
    var newStartTime = Date()
    var newEndTime = Date().addingTimeInterval(3600)
    var newEnergyLevel: EnergyLevel = .shallow

    func addFocusBlock(modelContext: ModelContext) {
        let block = FocusBlock(
            startTime: newStartTime,
            endTime: newEndTime,
            taskDescription: newTaskDescription,
            intendedEnergyLevel: newEnergyLevel
        )
        modelContext.insert(block)
        resetForm()
    }

    func toggleCompletion(_ block: FocusBlock) {
        block.isCompleted.toggle()
    }

    func deleteFocusBlock(_ block: FocusBlock, modelContext: ModelContext) {
        modelContext.delete(block)
    }

    func resetForm() {
        newTaskDescription = ""
        newStartTime = Date()
        newEndTime = Date().addingTimeInterval(3600)
        newEnergyLevel = .shallow
        showingAddBlock = false
    }
}
