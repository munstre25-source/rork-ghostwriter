import Foundation
import SwiftData

@Model
class FocusScore {
    var id: UUID
    var date: Date
    var score: Double
    var alignedBlockCount: Int
    var totalBlockCount: Int
    var acceptedSuggestions: Int
    var rejectedSuggestions: Int
    var insight: String

    init(
        date: Date = Date(),
        score: Double = 0,
        alignedBlockCount: Int = 0,
        totalBlockCount: Int = 0,
        acceptedSuggestions: Int = 0,
        rejectedSuggestions: Int = 0,
        insight: String = ""
    ) {
        self.id = UUID()
        self.date = date
        self.score = score
        self.alignedBlockCount = alignedBlockCount
        self.totalBlockCount = totalBlockCount
        self.acceptedSuggestions = acceptedSuggestions
        self.rejectedSuggestions = rejectedSuggestions
        self.insight = insight
    }
}
