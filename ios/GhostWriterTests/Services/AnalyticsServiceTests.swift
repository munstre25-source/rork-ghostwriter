import Testing
import Foundation
@testable import GhostWriter

@Suite("Analytics Service Tests")
struct AnalyticsServiceTests {

    @Test("AnalyticsService can be instantiated")
    func testInstantiation() {
        let service = AnalyticsService()
        #expect(service != nil)
    }

    @Test("Track generic event does not throw")
    func testTrackEvent() {
        let service = AnalyticsService()
        service.trackEvent("test_event", properties: ["key": "value"])
    }

    @Test("Track event without properties does not throw")
    func testTrackEventNoProperties() {
        let service = AnalyticsService()
        service.trackEvent("simple_event")
    }

    @Test("Track session start for all session types", arguments: SessionType.allCases)
    func testTrackSessionStart(type: SessionType) {
        let service = AnalyticsService()
        service.trackSessionStart(type: type)
    }

    @Test("Track session end with metrics")
    func testTrackSessionEnd() {
        let service = AnalyticsService()
        service.trackSessionEnd(wordCount: 500, flowScore: 75.0, duration: 1800)
    }

    @Test("Track suggestion accepted")
    func testTrackSuggestionAccepted() {
        let service = AnalyticsService()
        let suggestionId = UUID()
        service.trackSuggestionAccepted(suggestionId: suggestionId)
    }

    @Test("Track suggestion rejected")
    func testTrackSuggestionRejected() {
        let service = AnalyticsService()
        let suggestionId = UUID()
        service.trackSuggestionRejected(suggestionId: suggestionId)
    }

    @Test("Track clip created")
    func testTrackClipCreated() {
        let service = AnalyticsService()
        let clipId = UUID()
        service.trackClipCreated(clipId: clipId)
    }

    @Test("Track clip shared with platform")
    func testTrackClipShared() {
        let service = AnalyticsService()
        let clipId = UUID()
        service.trackClipShared(clipId: clipId, platform: "twitter")
    }

    @Test("Multiple events can be tracked sequentially")
    func testMultipleEvents() {
        let service = AnalyticsService()
        service.trackSessionStart(type: .writing)
        service.trackEvent("keystroke", properties: ["count": "50"])
        service.trackSuggestionAccepted(suggestionId: UUID())
        service.trackSessionEnd(wordCount: 200, flowScore: 60.0, duration: 900)
    }
}
