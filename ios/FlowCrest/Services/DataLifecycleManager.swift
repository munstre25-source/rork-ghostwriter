import Foundation
import SwiftData

@MainActor
final class DataLifecycleManager {
    static let shared = DataLifecycleManager()

    private let retentionMonths: Int = 12

    private init() {}

    func purgeOldSamples() async {
        guard let container = try? ModelContainer(for: BioMetricSample.self, FocusBlock.self) else { return }
        let context = ModelContext(container)
        let calendar = Calendar.current
        guard let cutoffDate = calendar.date(byAdding: .month, value: -retentionMonths, to: Date()) else { return }

        do {
            try context.delete(
                model: BioMetricSample.self,
                where: #Predicate<BioMetricSample> { $0.timestamp < cutoffDate }
            )
            try context.save()
        } catch {
            print("Data purge failed: \(error)")
        }
    }

    func purgeOldFocusBlocks() async {
        guard let container = try? ModelContainer(for: FocusBlock.self, BioMetricSample.self) else { return }
        let context = ModelContext(container)
        let calendar = Calendar.current
        guard let cutoffDate = calendar.date(byAdding: .month, value: -retentionMonths, to: Date()) else { return }

        do {
            try context.delete(
                model: FocusBlock.self,
                where: #Predicate<FocusBlock> { $0.endTime < cutoffDate && $0.isCompleted }
            )
            try context.save()
        } catch {
            print("Focus block purge failed: \(error)")
        }
    }
}
