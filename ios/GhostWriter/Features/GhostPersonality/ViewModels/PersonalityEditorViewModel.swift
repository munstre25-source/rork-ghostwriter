import Foundation
import Observation
import SwiftUI

// MARK: - Environment

private enum PersonalityServiceEnvironmentKey: EnvironmentKey {
    static let defaultValue: PersonalityService = PersonalityService()
}

extension EnvironmentValues {
    var personalityService: PersonalityService {
        get { self[PersonalityServiceEnvironmentKey.self] }
        set { self[PersonalityServiceEnvironmentKey.self] = newValue }
    }
}

// MARK: - PersonalityEditorViewModel

@MainActor
@Observable
final class PersonalityEditorViewModel {

    var name = ""
    var description = ""
    var systemPrompt = ""
    var selectedTraits: Set<PersonalityTrait> = []
    var responseStyle = "balanced"
    var hapticPattern = "default"
    var voiceId = "default"
    var isLoading = false
    var isSaving = false
    var existingPersonality: GhostPersonality?

    /// Sample line shown in the editor preview panel.
    var previewSampleText = ""
    var isPreviewLoading = false

    private let personalityService: PersonalityService
    private let coreMLService: CoreMLService
    private let hapticService: HapticService

    init(
        personalityService: PersonalityService,
        coreMLService: CoreMLService,
        hapticService: HapticService
    ) {
        self.personalityService = personalityService
        self.coreMLService = coreMLService
        self.hapticService = hapticService
    }

    var isValid: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !selectedTraits.isEmpty
    }

    func loadPersonality(id: UUID) async {
        isLoading = true
        defer { isLoading = false }

        await personalityService.loadBuiltInPersonalities()
        let combined = personalityService.availablePersonalities + personalityService.marketplacePersonalities
        guard let found = combined.first(where: { $0.id == id }) else {
            existingPersonality = nil
            clearForm()
            return
        }

        existingPersonality = found
        name = found.name
        description = found.personalityDescription
        systemPrompt = found.systemPrompt
        selectedTraits = Set(found.traits.compactMap { PersonalityTrait(rawValue: $0) })
        responseStyle = found.responseStyle
        hapticPattern = found.hapticPattern
        voiceId = found.voiceId
    }

    func clearForm() {
        name = ""
        description = ""
        systemPrompt = ""
        selectedTraits = []
        responseStyle = "balanced"
        hapticPattern = "default"
        voiceId = "default"
        previewSampleText = ""
    }

    func resetForNewPersonality() {
        existingPersonality = nil
        clearForm()
    }

    func buildDraftPersonality() -> GhostPersonality {
        GhostPersonality(
            id: existingPersonality?.id ?? UUID(),
            name: name,
            description: description,
            systemPrompt: systemPrompt,
            creatorId: existingPersonality?.creatorId,
            hapticPattern: hapticPattern,
            voiceId: voiceId,
            traits: selectedTraits.map(\.rawValue).sorted(),
            responseStyle: responseStyle,
            usageCount: existingPersonality?.usageCount ?? 0,
            rating: existingPersonality?.rating ?? 0,
            purchasePrice: existingPersonality?.purchasePrice,
            revenue: existingPersonality?.revenue ?? 0,
            downloads: existingPersonality?.downloads ?? 0,
            isPublished: existingPersonality?.isPublished ?? false,
            customTrainingData: existingPersonality?.customTrainingData
        )
    }

    func refreshPreview() async {
        isPreviewLoading = true
        defer { isPreviewLoading = false }

        let draft = buildDraftPersonality()
        do {
            if !coreMLService.isModelLoaded {
                try await coreMLService.loadModel()
            }
            let text = try await coreMLService.generateText(
                prompt: "The user is drafting a story opening about a rainy night in the city.",
                personality: draft
            )
            previewSampleText = text
        } catch {
            previewSampleText = "\(draft.name) (\(draft.responseStyle)): \(description.isEmpty ? "Your voice will guide tone and pacing here." : description)"
        }
    }

    func savePersonality() async throws -> GhostPersonality {
        guard isValid else { throw PersonalityError.creationFailed }
        guard !systemPrompt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw PersonalityError.creationFailed
        }

        isSaving = true
        defer { isSaving = false }

        let traitStrings = selectedTraits.map(\.rawValue).sorted()

        if let existing = existingPersonality {
            existing.name = name
            existing.personalityDescription = description
            existing.systemPrompt = systemPrompt
            existing.traits = traitStrings
            existing.responseStyle = responseStyle
            existing.hapticPattern = hapticPattern
            existing.voiceId = voiceId
            hapticService.successNotification()
            return existing
        }

        let created = try await personalityService.createPersonality(
            name: name,
            traits: traitStrings,
            systemPrompt: systemPrompt
        )
        created.personalityDescription = description
        created.responseStyle = responseStyle
        created.hapticPattern = hapticPattern
        created.voiceId = voiceId
        existingPersonality = created
        hapticService.successNotification()
        return created
    }

    func publishPersonality() async throws {
        let personality = try await savePersonality()
        try await personalityService.publishPersonality(personality)
        hapticService.successNotification()
    }
}
