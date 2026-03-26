import Foundation
import SwiftData

/// A daily earnings record for a creator's revenue streams.
///
/// Each record captures one day's revenue broken down by source.
/// The ``totalRevenue`` property is computed from the individual streams.
@Model
final class CreatorEarnings: @unchecked Sendable {

    /// Unique identifier for this earnings record.
    @Attribute(.unique) var id: UUID

    /// The creator's user ID.
    var userId: UUID

    /// The date this record covers.
    var date: Date

    /// Revenue earned from clip CPM advertising.
    var clipRevenue: Double

    /// Revenue earned from personality marketplace sales.
    var personalityRevenue: Double

    /// Revenue earned from user tips.
    var tipRevenue: Double

    /// Total clip views for this date.
    var clipViews: Int

    /// Total personality sales for this date.
    var personalitySales: Int

    /// Aggregate revenue across all streams for this date.
    var totalRevenue: Double {
        clipRevenue + personalityRevenue + tipRevenue
    }

    /// Creates a new daily earnings record.
    ///
    /// - Parameters:
    ///   - id: Unique identifier. Defaults to a new UUID.
    ///   - userId: The creator's user ID.
    ///   - date: The date this record covers. Defaults to today.
    ///   - clipRevenue: Clip advertising revenue. Defaults to `0`.
    ///   - personalityRevenue: Personality sales revenue. Defaults to `0`.
    ///   - tipRevenue: Tips received. Defaults to `0`.
    ///   - clipViews: Clip views on this date. Defaults to `0`.
    ///   - personalitySales: Personality sales on this date. Defaults to `0`.
    init(
        id: UUID = UUID(),
        userId: UUID,
        date: Date = .now,
        clipRevenue: Double = 0,
        personalityRevenue: Double = 0,
        tipRevenue: Double = 0,
        clipViews: Int = 0,
        personalitySales: Int = 0
    ) {
        self.id = id
        self.userId = userId
        self.date = date
        self.clipRevenue = clipRevenue
        self.personalityRevenue = personalityRevenue
        self.tipRevenue = tipRevenue
        self.clipViews = clipViews
        self.personalitySales = personalitySales
    }
}
