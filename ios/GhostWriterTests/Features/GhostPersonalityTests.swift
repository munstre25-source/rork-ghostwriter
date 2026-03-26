import Testing
@testable import GhostWriter

@Suite("Ghost Personality Tests")
struct GhostPersonalityTests {

    @Test("The Muse built-in personality has correct properties")
    func testTheMuse() {
        let muse = GhostPersonality.theMuse()
        #expect(muse.name == "The Muse")
        #expect(!muse.personalityDescription.isEmpty)
        #expect(!muse.systemPrompt.isEmpty)
        #expect(muse.hapticPattern == "gentle_wave")
        #expect(muse.voiceId == "muse_voice")
        #expect(muse.traits.contains("encouraging"))
        #expect(muse.responseStyle == "expressive")
        #expect(muse.creatorId == nil)
        #expect(muse.isPublished == false)
    }

    @Test("The Architect built-in personality has correct properties")
    func testTheArchitect() {
        let architect = GhostPersonality.theArchitect()
        #expect(architect.name == "The Architect")
        #expect(architect.hapticPattern == "steady_pulse")
        #expect(architect.traits.contains("structured"))
        #expect(architect.traits.contains("analytical"))
        #expect(architect.responseStyle == "structured")
    }

    @Test("The Critic built-in personality has correct properties")
    func testTheCritic() {
        let critic = GhostPersonality.theCritic()
        #expect(critic.name == "The Critic")
        #expect(critic.hapticPattern == "sharp_tap")
        #expect(critic.traits.contains("critical"))
        #expect(critic.responseStyle == "direct")
    }

    @Test("The Visionary built-in personality has correct properties")
    func testTheVisionary() {
        let visionary = GhostPersonality.theVisionary()
        #expect(visionary.name == "The Visionary")
        #expect(visionary.hapticPattern == "rising_crescendo")
        #expect(visionary.traits.contains("encouraging"))
        #expect(visionary.responseStyle == "expansive")
    }

    @Test("The Analyst built-in personality has correct properties")
    func testTheAnalyst() {
        let analyst = GhostPersonality.theAnalyst()
        #expect(analyst.name == "The Analyst")
        #expect(analyst.hapticPattern == "even_rhythm")
        #expect(analyst.traits.contains("analytical"))
        #expect(analyst.responseStyle == "analytical")
    }

    @Test("Custom personality creation with all fields")
    func testCustomPersonalityCreation() {
        let personality = GhostPersonality(
            name: "Custom Ghost",
            description: "A test personality",
            systemPrompt: "You are a helpful test ghost.",
            creatorId: UUID(),
            traits: ["playful", "concise"],
            responseStyle: "minimal"
        )
        #expect(personality.name == "Custom Ghost")
        #expect(personality.personalityDescription == "A test personality")
        #expect(personality.creatorId != nil)
        #expect(personality.traits.count == 2)
        #expect(personality.usageCount == 0)
        #expect(personality.rating == 0)
        #expect(personality.downloads == 0)
        #expect(personality.purchasePrice == nil)
        #expect(personality.revenue == 0)
    }

    @Test("Personality defaults are applied correctly")
    func testPersonalityDefaults() {
        let personality = GhostPersonality(
            name: "Minimal",
            description: "Minimal setup",
            systemPrompt: "Be minimal."
        )
        #expect(personality.hapticPattern == "default")
        #expect(personality.voiceId == "default")
        #expect(personality.traits.isEmpty)
        #expect(personality.responseStyle == "balanced")
        #expect(personality.isPublished == false)
        #expect(personality.customTrainingData == nil)
    }

    @Test("PersonalityTrait has correct display names", arguments: PersonalityTrait.allCases)
    func testTraitDisplayNames(trait: PersonalityTrait) {
        #expect(!trait.displayName.isEmpty)
        let firstChar = trait.displayName.first!
        #expect(firstChar.isUppercase)
    }

    @Test("PersonalityTrait has all expected cases")
    func testTraitCaseCount() {
        #expect(PersonalityTrait.allCases.count == 10)
    }

    @Test("All built-in personalities have unique names")
    func testUniqueBuiltInNames() {
        let builtIns = [
            GhostPersonality.theMuse(),
            GhostPersonality.theArchitect(),
            GhostPersonality.theCritic(),
            GhostPersonality.theVisionary(),
            GhostPersonality.theAnalyst()
        ]
        let names = builtIns.map(\.name)
        let uniqueNames = Set(names)
        #expect(names.count == uniqueNames.count)
    }

    @Test("All built-in personalities have non-empty system prompts")
    func testBuiltInSystemPrompts() {
        let builtIns = [
            GhostPersonality.theMuse(),
            GhostPersonality.theArchitect(),
            GhostPersonality.theCritic(),
            GhostPersonality.theVisionary(),
            GhostPersonality.theAnalyst()
        ]
        for personality in builtIns {
            #expect(!personality.systemPrompt.isEmpty)
            #expect(personality.systemPrompt.count > 20)
        }
    }
}
