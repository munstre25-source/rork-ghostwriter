import Testing
@testable import GhostWriter

@Suite("Haptic Service Tests")
struct HapticServiceTests {

    @Test("HapticService can be instantiated")
    func testInstantiation() {
        let service = HapticService()
        #expect(service != nil)
    }

    @Test("HapticService is a reference type")
    func testReferenceType() {
        let service1 = HapticService()
        let service2 = service1
        #expect(service1 === service2)
    }

    @Test("Light tap does not throw")
    func testLightTap() {
        let service = HapticService()
        service.lightTap()
    }

    @Test("Medium tap does not throw")
    func testMediumTap() {
        let service = HapticService()
        service.mediumTap()
    }

    @Test("Heavy tap does not throw")
    func testHeavyTap() {
        let service = HapticService()
        service.heavyTap()
    }

    @Test("Success notification does not throw")
    func testSuccessNotification() {
        let service = HapticService()
        service.successNotification()
    }

    @Test("Error notification does not throw")
    func testErrorNotification() {
        let service = HapticService()
        service.errorNotification()
    }

    @Test("Suggestion appeared with various confidence levels", arguments: [0.0, 0.3, 0.5, 0.8, 1.0])
    func testSuggestionAppeared(confidence: Double) {
        let service = HapticService()
        service.suggestionAppeared(confidence: confidence)
    }

    @Test("Personality haptic with known patterns", arguments: [
        "gentle_wave", "steady_pulse", "sharp_tap", "rising_crescendo", "even_rhythm", "unknown_pattern"
    ])
    func testPersonalityHaptic(pattern: String) {
        let service = HapticService()
        service.personalityHaptic(pattern: pattern)
    }

    @Test("Collaborator typing does not throw")
    func testCollaboratorTyping() {
        let service = HapticService()
        service.collaboratorTyping()
    }
}
