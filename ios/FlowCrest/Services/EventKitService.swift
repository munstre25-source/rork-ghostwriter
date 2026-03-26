import Foundation
import EventKit

@Observable
@MainActor
final class EventKitService {
    private let eventStore = EKEventStore()

    var authorizationStatus: EKAuthorizationStatus = .notDetermined
    var lastError: String?

    init() {
        authorizationStatus = EKEventStore.authorizationStatus(for: .event)
    }

    func requestAuthorization() async {
        do {
            let granted = try await eventStore.requestFullAccessToEvents()
            authorizationStatus = granted ? .fullAccess : .denied
        } catch {
            lastError = error.localizedDescription
            authorizationStatus = .denied
        }
    }

    func fetchEvents(from startDate: Date, to endDate: Date) -> [EKEvent] {
        guard authorizationStatus == .fullAccess else { return [] }
        let predicate = eventStore.predicateForEvents(withStart: startDate, end: endDate, calendars: nil)
        return eventStore.events(matching: predicate)
    }

    func convertToFocusBlocks(from startDate: Date, to endDate: Date) -> [FocusBlock] {
        let events = fetchEvents(from: startDate, to: endDate)
        return events.map { event in
            let energyLevel = inferEnergyLevel(from: event)
            return FocusBlock(
                eventIdentifier: event.eventIdentifier,
                startTime: event.startDate,
                endTime: event.endDate,
                taskDescription: event.title ?? "Untitled Event",
                intendedEnergyLevel: energyLevel
            )
        }
    }

    private func inferEnergyLevel(from event: EKEvent) -> EnergyLevel {
        let title = (event.title ?? "").lowercased()
        let notes = (event.notes ?? "").lowercased()
        let combined = title + " " + notes

        let deepKeywords = ["focus", "deep work", "code", "write", "design", "develop", "research", "strategy", "analysis", "brainstorm", "create"]
        let adminKeywords = ["email", "admin", "inbox", "expense", "filing", "organize", "clean", "update", "report"]

        if deepKeywords.contains(where: { combined.contains($0) }) {
            return .deep
        } else if adminKeywords.contains(where: { combined.contains($0) }) {
            return .admin
        }

        let duration = event.endDate.timeIntervalSince(event.startDate)
        if duration >= 3600 {
            return .deep
        } else if duration <= 1800 {
            return .admin
        }

        return .shallow
    }
}
