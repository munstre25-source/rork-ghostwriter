import Foundation
import HealthKit

@Observable
@MainActor
final class HealthKitService {
    private let healthStore = HKHealthStore()

    var authorizationStatus: HKAuthorizationStatus = .notDetermined
    var isAvailable: Bool { HKHealthStore.isHealthDataAvailable() }
    var lastError: String?

    private let readTypes: Set<HKSampleType> = {
        var types = Set<HKSampleType>()
        if let hrvType = HKQuantityType.quantityType(forIdentifier: .heartRateVariabilitySDNN) {
            types.insert(hrvType)
        }
        if let rhrType = HKQuantityType.quantityType(forIdentifier: .restingHeartRate) {
            types.insert(rhrType)
        }
        types.insert(HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!)
        return types
    }()

    func requestAuthorization() async {
        guard isAvailable else {
            lastError = "HealthKit is not available on this device."
            return
        }

        do {
            try await healthStore.requestAuthorization(toShare: [], read: readTypes)
            updateAuthorizationStatus()
        } catch {
            lastError = error.localizedDescription
        }
    }

    func updateAuthorizationStatus() {
        guard let hrvType = HKQuantityType.quantityType(forIdentifier: .heartRateVariabilitySDNN) else { return }
        authorizationStatus = healthStore.authorizationStatus(for: hrvType)
    }

    func fetchLatestHRV() async -> Double? {
        guard let hrvType = HKQuantityType.quantityType(forIdentifier: .heartRateVariabilitySDNN) else { return nil }
        return await fetchLatestQuantity(type: hrvType, unit: HKUnit.secondUnit(with: .milli))
    }

    func fetchLatestRestingHeartRate() async -> Double? {
        guard let rhrType = HKQuantityType.quantityType(forIdentifier: .restingHeartRate) else { return nil }
        let bpm = HKUnit.count().unitDivided(by: .minute())
        return await fetchLatestQuantity(type: rhrType, unit: bpm)
    }

    func fetchSleepQuality(for date: Date) async -> Double {
        let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: endOfDay, options: .strictStartDate)

        let samples: [HKCategorySample] = await withCheckedContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: sleepType,
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)]
            ) { _, results, _ in
                continuation.resume(returning: (results as? [HKCategorySample]) ?? [])
            }
            healthStore.execute(query)
        }

        guard !samples.isEmpty else { return 0 }

        var totalSleepSeconds: TimeInterval = 0
        var deepSleepSeconds: TimeInterval = 0
        var remSleepSeconds: TimeInterval = 0

        for sample in samples {
            let duration = sample.endDate.timeIntervalSince(sample.startDate)
            let value = HKCategoryValueSleepAnalysis(rawValue: sample.value)

            switch value {
            case .asleepDeep:
                deepSleepSeconds += duration
                totalSleepSeconds += duration
            case .asleepREM:
                remSleepSeconds += duration
                totalSleepSeconds += duration
            case .asleepCore:
                totalSleepSeconds += duration
            case .asleepUnspecified:
                totalSleepSeconds += duration
            default:
                break
            }
        }

        let totalHours = totalSleepSeconds / 3600.0
        let idealHours = 8.0
        let durationScore = min(totalHours / idealHours, 1.0)

        var compositionScore = 0.5
        if totalSleepSeconds > 0 {
            let deepRatio = deepSleepSeconds / totalSleepSeconds
            let remRatio = remSleepSeconds / totalSleepSeconds
            compositionScore = min((deepRatio / 0.20 + remRatio / 0.25) / 2.0, 1.0)
        }

        return min((durationScore * 0.6 + compositionScore * 0.4), 1.0)
    }

    func fetchBioMetrics() async -> (hrv: Double, sleepQuality: Double, restingHeartRate: Double)? {
        guard isAvailable else { return nil }

        async let hrv = fetchLatestHRV()
        async let rhr = fetchLatestRestingHeartRate()
        async let sleep = fetchSleepQuality(for: Date())

        let hrvValue = await hrv ?? 0
        let rhrValue = await rhr ?? 0
        let sleepValue = await sleep

        if hrvValue == 0 && rhrValue == 0 && sleepValue == 0 {
            return nil
        }

        return (hrv: hrvValue, sleepQuality: sleepValue, restingHeartRate: rhrValue)
    }

    private func fetchLatestQuantity(type: HKQuantityType, unit: HKUnit) async -> Double? {
        let predicate = HKQuery.predicateForSamples(
            withStart: Calendar.current.date(byAdding: .day, value: -7, to: Date()),
            end: Date(),
            options: .strictStartDate
        )

        return await withCheckedContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: type,
                predicate: predicate,
                limit: 1,
                sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)]
            ) { _, results, _ in
                guard let sample = results?.first as? HKQuantitySample else {
                    continuation.resume(returning: nil)
                    return
                }
                continuation.resume(returning: sample.quantity.doubleValue(for: unit))
            }
            healthStore.execute(query)
        }
    }
}
