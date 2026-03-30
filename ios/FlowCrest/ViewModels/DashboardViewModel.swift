import Foundation
import SwiftData
import EventKit

@Observable
@MainActor
final class DashboardViewModel {
    let healthService: HealthKitService
    let eventKitService: EventKitService
    let engine: BioAdaptiveEngine
    let featureFlags: FeatureFlags

    var isLoading = false
    var latestSample: BioMetricSample?
    var suggestions: [ScheduleSuggestion] = []
    var errorMessage: String?

    var readinessScore: Double {
        engine.currentReadinessScore
    }

    var readinessCategory: ReadinessCategory {
        ReadinessCategory.from(score: readinessScore)
    }

    init(
        healthService: HealthKitService,
        eventKitService: EventKitService,
        engine: BioAdaptiveEngine,
        featureFlags: FeatureFlags
    ) {
        self.healthService = healthService
        self.eventKitService = eventKitService
        self.engine = engine
        self.featureFlags = featureFlags
    }

    func refreshBioMetrics(modelContext: ModelContext) async {
        isLoading = true
        defer { isLoading = false }

        guard let metrics = await healthService.fetchBioMetrics() else {
            if !healthService.isAvailable {
                generatePlaceholderData(modelContext: modelContext)
            }
            return
        }

        let score = engine.analyzeAndScore(
            hrv: metrics.hrv,
            sleepQuality: metrics.sleepQuality,
            restingHeartRate: metrics.restingHeartRate
        )

        let sample = BioMetricSample(
            timestamp: Date(),
            hrv: metrics.hrv,
            sleepQuality: metrics.sleepQuality,
            restingHeartRate: metrics.restingHeartRate,
            cognitiveReadinessScore: score
        )
        modelContext.insert(sample)
        latestSample = sample

        if featureFlags.isBioAdaptiveEnabled {
            await analyzeSchedule(modelContext: modelContext)
        }
    }

    private let freeTierSuggestionLimit = 3

    func analyzeSchedule(modelContext: ModelContext) async {
        let now = Date()
        let endOfDay = Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: now)!

        do {
            let descriptor = FetchDescriptor<FocusBlock>(
                predicate: #Predicate { $0.startTime >= now && $0.endTime <= endOfDay && !$0.isCompleted },
                sortBy: [SortDescriptor(\.startTime)]
            )
            let blocks = try modelContext.fetch(descriptor)
            var detected = engine.detectMismatches(blocks: blocks, readinessScore: readinessScore)

            if !SubscriptionManager.shared.isPremium {
                detected = Array(detected.prefix(freeTierSuggestionLimit))
            }

            suggestions = detected
        } catch {
            errorMessage = "Failed to analyze schedule: \(error.localizedDescription)"
        }
    }

    func handleSuggestion(_ suggestion: ScheduleSuggestion, accepted: Bool, modelContext: ModelContext) {
        do {
            let descriptor = FetchDescriptor<FocusBlock>()
            let blocks = try modelContext.fetch(descriptor)
            engine.applySuggestion(suggestion, to: blocks, accepted: accepted)
        } catch {
            errorMessage = "Failed to apply suggestion: \(error.localizedDescription)"
        }
    }

    func syncCalendarEvents(modelContext: ModelContext) async {
        guard featureFlags.isCalendarSyncEnabled else { return }
        guard eventKitService.authorizationStatus == .fullAccess else { return }

        let now = Date()
        let endOfWeek = Calendar.current.date(byAdding: .day, value: 7, to: now)!
        let calendarBlocks = eventKitService.convertToFocusBlocks(from: now, to: endOfWeek)

        for block in calendarBlocks {
            guard let eventID = block.eventIdentifier else { continue }
            let descriptor = FetchDescriptor<FocusBlock>(
                predicate: #Predicate<FocusBlock> { $0.eventIdentifier == eventID }
            )
            let existing = (try? modelContext.fetch(descriptor)) ?? []
            if existing.isEmpty {
                modelContext.insert(block)
            }
        }
    }

    private func generatePlaceholderData(modelContext: ModelContext) {
        let baseHRV = Double.random(in: 30...80)
        let baseSleep = Double.random(in: 0.4...0.9)
        let baseRHR = Double.random(in: 55...75)

        let score = engine.analyzeAndScore(hrv: baseHRV, sleepQuality: baseSleep, restingHeartRate: baseRHR)
        let sample = BioMetricSample(
            timestamp: Date(),
            hrv: baseHRV,
            sleepQuality: baseSleep,
            restingHeartRate: baseRHR,
            cognitiveReadinessScore: score
        )
        modelContext.insert(sample)
        latestSample = sample
    }
}

nonisolated enum ReadinessCategory: Sendable {
    case peak
    case good
    case moderate
    case low
    case veryLow

    static func from(score: Double) -> ReadinessCategory {
        switch score {
        case 80...100: return .peak
        case 60..<80: return .good
        case 40..<60: return .moderate
        case 20..<40: return .low
        default: return .veryLow
        }
    }

    var displayName: String {
        switch self {
        case .peak: return "Peak"
        case .good: return "Good"
        case .moderate: return "Moderate"
        case .low: return "Low"
        case .veryLow: return "Very Low"
        }
    }

    var icon: String {
        switch self {
        case .peak: return "bolt.fill"
        case .good: return "checkmark.circle.fill"
        case .moderate: return "minus.circle.fill"
        case .low: return "arrow.down.circle.fill"
        case .veryLow: return "exclamationmark.triangle.fill"
        }
    }

    var colorName: String {
        switch self {
        case .peak: return "green"
        case .good: return "teal"
        case .moderate: return "yellow"
        case .low: return "orange"
        case .veryLow: return "red"
        }
    }
}
