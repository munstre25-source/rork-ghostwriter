import Testing
import Foundation
@testable import GhostWriter

@Suite("CoreML Service Tests")
struct CoreMLServiceTests {

    @Test("Service starts with model not loaded")
    func testInitialState() {
        let service = CoreMLService()
        #expect(service.isModelLoaded == false)
    }

    @Test("Model loads successfully")
    func testModelLoading() async throws {
        let service = CoreMLService()
        try await service.loadModel()
        #expect(service.isModelLoaded == true)
    }

    @Test("Loading model twice is idempotent")
    func testDoubleLoad() async throws {
        let service = CoreMLService()
        try await service.loadModel()
        try await service.loadModel()
        #expect(service.isModelLoaded == true)
    }

    @Test("Generate text throws when model not loaded")
    func testGenerateTextWithoutModel() async {
        let service = CoreMLService()
        let personality = GhostPersonality.theMuse()

        await #expect(throws: CoreMLError.self) {
            _ = try await service.generateText(prompt: "Hello", personality: personality)
        }
    }

    @Test("Generate text throws on empty prompt")
    func testGenerateTextEmptyPrompt() async throws {
        let service = CoreMLService()
        try await service.loadModel()
        let personality = GhostPersonality.theMuse()

        await #expect(throws: CoreMLError.self) {
            _ = try await service.generateText(prompt: "", personality: personality)
        }
    }

    @Test("Generate text returns non-empty result")
    func testGenerateTextReturnsResult() async throws {
        let service = CoreMLService()
        try await service.loadModel()
        let personality = GhostPersonality.theMuse()

        let result = try await service.generateText(
            prompt: "The rain fell softly",
            personality: personality
        )
        #expect(!result.isEmpty)
    }

    @Test("Score confidence throws when model not loaded")
    func testScoreConfidenceWithoutModel() async {
        let service = CoreMLService()

        await #expect(throws: CoreMLError.self) {
            _ = try await service.scoreConfidence(suggestion: "test", context: "context")
        }
    }

    @Test("Score confidence returns value between 0 and 1")
    func testScoreConfidenceRange() async throws {
        let service = CoreMLService()
        try await service.loadModel()

        let score = try await service.scoreConfidence(
            suggestion: "Consider a new approach",
            context: "The protagonist walked through the garden, thinking about the choices ahead."
        )
        #expect(score >= 0.0)
        #expect(score <= 1.0)
    }

    @Test("Generate suggestions throws when model not loaded")
    func testGenerateSuggestionsWithoutModel() async {
        let service = CoreMLService()
        let personality = GhostPersonality.theMuse()

        await #expect(throws: CoreMLError.self) {
            _ = try await service.generateSuggestions(for: "text", personality: personality)
        }
    }

    @Test("Generate suggestions returns requested count")
    func testGenerateSuggestionsCount() async throws {
        let service = CoreMLService()
        try await service.loadModel()
        let personality = GhostPersonality.theArchitect()

        let suggestions = try await service.generateSuggestions(
            for: "The story begins with a quiet morning.",
            personality: personality,
            count: 3
        )
        #expect(suggestions.count == 3)
        for suggestion in suggestions {
            #expect(!suggestion.content.isEmpty)
            #expect(suggestion.confidenceScore >= 0.0)
            #expect(suggestion.confidenceScore <= 1.0)
        }
    }
}
