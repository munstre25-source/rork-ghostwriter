import Foundation

struct ScheduleSuggestion: Identifiable {
    let id = UUID()
    let focusBlockID: UUID
    let originalTime: Date
    let suggestedTime: Date
    let reason: String
    let currentReadiness: Double
    let requiredReadiness: Double
    let swapWith: UUID?
}
