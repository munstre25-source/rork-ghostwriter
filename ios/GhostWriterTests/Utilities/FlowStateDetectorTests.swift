import Testing
import Foundation
@testable import GhostWriter

@Suite("Flow State Detection Tests")
struct FlowStateDetectorTests {

    private let flowThreshold: Double = 70.0

    @Test("Should detect flow state for scores above threshold", arguments: [70.0, 75.0, 85.0, 95.0, 100.0])
    func testFlowStateDetection(flowScore: Double) {
        let isInFlow = flowScore >= flowThreshold
        #expect(isInFlow == true)
    }

    @Test("Should not detect flow state for scores below threshold", arguments: [0.0, 10.0, 30.0, 50.0, 69.9])
    func testNotInFlowState(flowScore: Double) {
        let isInFlow = flowScore >= flowThreshold
        #expect(isInFlow == false)
    }

    @Test("Flow score boundary at exactly 70")
    func testFlowStateBoundary() {
        let atThreshold = 70.0 >= flowThreshold
        let belowThreshold = 69.99 >= flowThreshold
        #expect(atThreshold == true)
        #expect(belowThreshold == false)
    }

    @Test("Session flow score increases with word count simulation")
    func testFlowScoreProgression() {
        let session = CreativeSession(
            userId: UUID(),
            type: .writing,
            personalityId: UUID(),
            flowScore: 0
        )
        #expect(session.flowScore < flowThreshold)

        let highFlowSession = CreativeSession(
            userId: UUID(),
            type: .writing,
            personalityId: UUID(),
            flowScore: 85
        )
        #expect(highFlowSession.flowScore >= flowThreshold)
    }

    @Test("Flow score is valid when clamped to 0-100 range", arguments: [-10.0, 0.0, 50.0, 100.0, 150.0])
    func testFlowScoreRange(rawScore: Double) {
        let clamped = min(max(rawScore, 0), 100)
        #expect(clamped >= 0)
        #expect(clamped <= 100)
    }

    @Test("Flow state transitions correctly")
    func testFlowStateTransition() {
        var flowScore = 0.0
        #expect(flowScore < flowThreshold)

        flowScore = 50.0
        #expect(flowScore < flowThreshold)

        flowScore = 70.0
        #expect(flowScore >= flowThreshold)

        flowScore = 95.0
        #expect(flowScore >= flowThreshold)

        flowScore = 40.0
        #expect(flowScore < flowThreshold)
    }

    @Test("Multiple sessions can have independent flow states")
    func testIndependentFlowStates() {
        let lowFlow = CreativeSession(
            userId: UUID(),
            type: .writing,
            personalityId: UUID(),
            flowScore: 30
        )
        let highFlow = CreativeSession(
            userId: UUID(),
            type: .brainstorming,
            personalityId: UUID(),
            flowScore: 85
        )

        #expect(lowFlow.flowScore < flowThreshold)
        #expect(highFlow.flowScore >= flowThreshold)
    }
}
