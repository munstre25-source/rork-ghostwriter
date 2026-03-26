import ActivityKit
import Foundation

@MainActor
final class LiveActivityService {
    static let shared = LiveActivityService()
    private var currentActivity: Activity<FocusActivityAttributes>?
    private init() {}

    var isActivityActive: Bool {
        currentActivity != nil
    }

    func startFocusSession(block: FocusBlock, readinessScore: Double) {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }

        endCurrentSession()

        let attributes = FocusActivityAttributes(
            blockID: block.id.uuidString,
            startTime: block.startTime
        )

        let state = FocusActivityAttributes.ContentState(
            taskDescription: block.taskDescription,
            energyLevelRaw: block.intendedEnergyLevelRaw,
            endTime: block.endTime,
            readinessScore: readinessScore
        )

        do {
            currentActivity = try Activity.request(
                attributes: attributes,
                content: .init(state: state, staleDate: block.endTime),
                pushType: nil
            )
        } catch {
            print("Failed to start Live Activity: \(error)")
        }
    }

    func updateActivity(readinessScore: Double, taskDescription: String? = nil) {
        guard let activity = currentActivity else { return }

        let currentState = activity.content.state
        let newState = FocusActivityAttributes.ContentState(
            taskDescription: taskDescription ?? currentState.taskDescription,
            energyLevelRaw: currentState.energyLevelRaw,
            endTime: currentState.endTime,
            readinessScore: readinessScore
        )

        Task {
            await activity.update(.init(state: newState, staleDate: nil))
        }
    }

    func endCurrentSession() {
        guard let activity = currentActivity else { return }

        let finalState = activity.content.state
        Task {
            await activity.end(.init(state: finalState, staleDate: nil), dismissalPolicy: .default)
        }
        currentActivity = nil
    }

    func checkAndStartForCurrentBlock(blocks: [FocusBlock], readinessScore: Double) {
        let now = Date()
        guard let activeBlock = blocks.first(where: {
            !$0.isCompleted && $0.startTime <= now && $0.endTime >= now
        }) else {
            if isActivityActive { endCurrentSession() }
            return
        }

        if currentActivity == nil {
            startFocusSession(block: activeBlock, readinessScore: readinessScore)
        } else {
            updateActivity(readinessScore: readinessScore)
        }
    }
}
