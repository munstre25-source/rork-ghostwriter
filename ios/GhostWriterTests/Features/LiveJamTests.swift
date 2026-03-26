import Testing
import Foundation
@testable import GhostWriter

@Suite("Live Jam Tests")
struct LiveJamTests {

    @Test("Should create a LiveJamSession with defaults")
    func testSessionDefaults() {
        let hostId = UUID()
        let sessionId = UUID()
        let jam = LiveJamSession(hostId: hostId, sessionId: sessionId)

        #expect(jam.hostId == hostId)
        #expect(jam.sessionId == sessionId)
        #expect(jam.collaboratorIds.isEmpty)
        #expect(jam.endTime == nil)
        #expect(jam.collaborationScore == 0)
        #expect(jam.totalWordsWritten == 0)
        #expect(jam.sharedSuggestionCount == 0)
        #expect(jam.isActive == true)
    }

    @Test("Should create a LiveJamSession with all fields")
    func testSessionFullCreation() {
        let hostId = UUID()
        let collaborator1 = UUID()
        let collaborator2 = UUID()
        let sessionId = UUID()

        let jam = LiveJamSession(
            hostId: hostId,
            collaboratorIds: [collaborator1, collaborator2],
            sessionId: sessionId,
            collaborationScore: 85.0,
            totalWordsWritten: 1500,
            sharedSuggestionCount: 12,
            isActive: true
        )

        #expect(jam.hostId == hostId)
        #expect(jam.collaboratorIds.count == 2)
        #expect(jam.collaborationScore == 85.0)
        #expect(jam.totalWordsWritten == 1500)
        #expect(jam.sharedSuggestionCount == 12)
        #expect(jam.isActive == true)
    }

    @Test("Collaboration score is clamped between 0 and 100")
    func testCollaborationScoreClamping() {
        let overJam = LiveJamSession(
            hostId: UUID(),
            sessionId: UUID(),
            collaborationScore: 150
        )
        #expect(overJam.collaborationScore <= 100)

        let underJam = LiveJamSession(
            hostId: UUID(),
            sessionId: UUID(),
            collaborationScore: -20
        )
        #expect(underJam.collaborationScore >= 0)
    }

    @Test("LiveJamSession has unique ID on creation")
    func testUniqueId() {
        let jam1 = LiveJamSession(hostId: UUID(), sessionId: UUID())
        let jam2 = LiveJamSession(hostId: UUID(), sessionId: UUID())
        #expect(jam1.id != jam2.id)
    }

    @Test("LiveJamSession can be ended")
    func testSessionEnding() {
        let jam = LiveJamSession(hostId: UUID(), sessionId: UUID())
        #expect(jam.isActive == true)
        #expect(jam.endTime == nil)

        jam.isActive = false
        jam.endTime = .now
        #expect(jam.isActive == false)
        #expect(jam.endTime != nil)
    }

    @Test("LiveJamSession tracks collaborator count")
    func testCollaboratorTracking() {
        let jam = LiveJamSession(
            hostId: UUID(),
            collaboratorIds: [UUID(), UUID(), UUID()],
            sessionId: UUID()
        )
        #expect(jam.collaboratorIds.count == 3)
    }
}
