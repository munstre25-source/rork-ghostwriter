import Foundation
import BackgroundTasks
import SwiftData

@MainActor
final class BackgroundScheduler {
    static let shared = BackgroundScheduler()

    static let refreshTaskID = "com.flowcrest.bio-refresh"
    static let processingTaskID = "com.flowcrest.bio-processing"

    private init() {}

    func registerTasks() {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: Self.refreshTaskID, using: nil) { task in
            Task { @MainActor in
                self.handleAppRefresh(task: task as! BGAppRefreshTask)
            }
        }

        BGTaskScheduler.shared.register(forTaskWithIdentifier: Self.processingTaskID, using: nil) { task in
            Task { @MainActor in
                self.handleProcessingTask(task: task as! BGProcessingTask)
            }
        }
    }

    func scheduleAppRefresh() {
        let request = BGAppRefreshTaskRequest(identifier: Self.refreshTaskID)
        request.earliestBeginDate = Date(timeIntervalSinceNow: 30 * 60)
        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            print("Could not schedule app refresh: \(error)")
        }
    }

    func scheduleProcessingTask() {
        let request = BGProcessingTaskRequest(identifier: Self.processingTaskID)
        request.earliestBeginDate = Date(timeIntervalSinceNow: 60 * 60)
        request.requiresNetworkConnectivity = false
        request.requiresExternalPower = false
        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            print("Could not schedule processing task: \(error)")
        }
    }

    private func handleAppRefresh(task: BGAppRefreshTask) {
        scheduleAppRefresh()

        let refreshTask = Task {
            let healthService = HealthKitService()
            guard let metrics = await healthService.fetchBioMetrics() else {
                task.setTaskCompleted(success: true)
                return
            }

            let engine = BioAdaptiveEngine()
            _ = engine.analyzeAndScore(
                hrv: metrics.hrv,
                sleepQuality: metrics.sleepQuality,
                restingHeartRate: metrics.restingHeartRate
            )
            task.setTaskCompleted(success: true)
        }

        task.expirationHandler = {
            refreshTask.cancel()
        }
    }

    private func handleProcessingTask(task: BGProcessingTask) {
        scheduleProcessingTask()

        let processingTask = Task {
            await DataLifecycleManager.shared.purgeOldSamples()
            task.setTaskCompleted(success: true)
        }

        task.expirationHandler = {
            processingTask.cancel()
        }
    }
}
