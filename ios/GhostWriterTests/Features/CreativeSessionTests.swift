import Testing
@testable import GhostWriter

@Suite("Creative Session Tests")
struct CreativeSessionTests {

    @Test("Should create a new session with defaults")
    func testCreateSession() {
        let session = CreativeSession(
            userId: UUID(),
            type: .writing,
            personalityId: UUID()
        )
        #expect(session.type == .writing)
        #expect(session.wordCount == 0)
        #expect(session.isPublic == false)
        #expect(session.flowScore == 0)
        #expect(session.rawInputLog.isEmpty)
        #expect(session.isLive == true)
        #expect(session.ideaCount == 0)
        #expect(session.collaboratorIds.isEmpty)
        #expect(session.createdClipIds.isEmpty)
        #expect(session.isMonetized == false)
        #expect(session.endTime == nil)
    }

    @Test("Should create session with all types", arguments: SessionType.allCases)
    func testAllSessionTypes(type: SessionType) {
        let session = CreativeSession(
            userId: UUID(),
            type: type,
            personalityId: UUID()
        )
        #expect(session.type == type)
    }

    @Test("SessionType has display name")
    func testSessionTypeDisplayName() {
        #expect(SessionType.writing.displayName == "Writing")
        #expect(SessionType.brainstorming.displayName == "Brainstorming")
        #expect(SessionType.coding.displayName == "Coding")
        #expect(SessionType.design.displayName == "Design")
        #expect(SessionType.freestyle.displayName == "Freestyle")
    }

    @Test("SessionType has SF Symbol icon")
    func testSessionTypeIcon() {
        for type in SessionType.allCases {
            #expect(!type.icon.isEmpty)
        }
    }

    @Test("SessionType conforms to CaseIterable")
    func testSessionTypeCaseIterable() {
        #expect(SessionType.allCases.count == 5)
    }

    @Test("Flow score is clamped between 0 and 100")
    func testFlowScoreClamping() {
        let overSession = CreativeSession(
            userId: UUID(),
            type: .writing,
            personalityId: UUID(),
            flowScore: 150
        )
        #expect(overSession.flowScore <= 100)

        let underSession = CreativeSession(
            userId: UUID(),
            type: .writing,
            personalityId: UUID(),
            flowScore: -50
        )
        #expect(underSession.flowScore >= 0)
    }

    @Test("Session stores custom title")
    func testSessionTitle() {
        let session = CreativeSession(
            userId: UUID(),
            title: "My Story Draft",
            type: .writing,
            personalityId: UUID()
        )
        #expect(session.title == "My Story Draft")
    }

    @Test("GhostSuggestion created with defaults")
    func testSuggestionDefaults() {
        let suggestion = GhostSuggestion(
            sessionId: UUID(),
            personalityId: UUID(),
            content: "Try a different angle"
        )
        #expect(suggestion.type == .continuation)
        #expect(suggestion.confidenceScore == 0.5)
        #expect(suggestion.accepted == nil)
        #expect(suggestion.userRating == nil)
        #expect(suggestion.contextBefore.isEmpty)
        #expect(suggestion.contextAfter.isEmpty)
    }

    @Test("SuggestionType has all expected cases")
    func testSuggestionTypeCases() {
        let allTypes = SuggestionType.allCases
        #expect(allTypes.contains(.continuation))
        #expect(allTypes.contains(.challenge))
        #expect(allTypes.contains(.summary))
        #expect(allTypes.contains(.reframe))
        #expect(allTypes.contains(.expand))
        #expect(allTypes.count == 5)
    }

    @Test("GhostSuggestion confidence is clamped to 0-1")
    func testSuggestionConfidenceClamping() {
        let high = GhostSuggestion(
            sessionId: UUID(),
            personalityId: UUID(),
            content: "Test",
            confidenceScore: 1.5
        )
        #expect(high.confidenceScore <= 1.0)

        let low = GhostSuggestion(
            sessionId: UUID(),
            personalityId: UUID(),
            content: "Test",
            confidenceScore: -0.5
        )
        #expect(low.confidenceScore >= 0.0)
    }
}
