import Testing
import Foundation
@testable import GhostWriter

@Suite("Ghost Clips Tests")
struct GhostClipsTests {

    @Test("Should create a GhostClip with defaults")
    func testClipDefaults() {
        let clip = GhostClip(
            sessionId: UUID(),
            creatorId: UUID(),
            videoURL: URL(string: "https://example.com/clip.mp4")!,
            personalityUsed: "The Muse"
        )
        #expect(clip.duration == 0)
        #expect(clip.shareCount == 0)
        #expect(clip.viewCount == 0)
        #expect(clip.likeCount == 0)
        #expect(clip.saveCount == 0)
        #expect(clip.isMonetized == false)
        #expect(clip.cpmRevenue == 0)
        #expect(clip.isPublic == true)
        #expect(clip.title == nil)
        #expect(clip.clipDescription == nil)
        #expect(clip.thumbnailURL == nil)
    }

    @Test("Should create a GhostClip with all fields")
    func testClipFullCreation() {
        let sessionId = UUID()
        let creatorId = UUID()
        let videoURL = URL(string: "https://clips.ghostwriter.app/test.mp4")!
        let thumbnailURL = URL(string: "https://clips.ghostwriter.app/thumb.jpg")!

        let clip = GhostClip(
            sessionId: sessionId,
            creatorId: creatorId,
            videoURL: videoURL,
            duration: 30.0,
            thumbnailURL: thumbnailURL,
            title: "My Amazing Clip",
            clipDescription: "A great creative moment",
            shareCount: 5,
            viewCount: 100,
            likeCount: 25,
            saveCount: 10,
            isMonetized: true,
            cpmRevenue: 12.50,
            isPublic: true,
            personalityUsed: "The Architect"
        )

        #expect(clip.sessionId == sessionId)
        #expect(clip.creatorId == creatorId)
        #expect(clip.videoURL == videoURL)
        #expect(clip.duration == 30.0)
        #expect(clip.thumbnailURL == thumbnailURL)
        #expect(clip.title == "My Amazing Clip")
        #expect(clip.clipDescription == "A great creative moment")
        #expect(clip.shareCount == 5)
        #expect(clip.viewCount == 100)
        #expect(clip.likeCount == 25)
        #expect(clip.saveCount == 10)
        #expect(clip.isMonetized == true)
        #expect(clip.cpmRevenue == 12.50)
        #expect(clip.personalityUsed == "The Architect")
    }

    @Test("Clip stores personality used name")
    func testClipPersonalityUsed() {
        let clip = GhostClip(
            sessionId: UUID(),
            creatorId: UUID(),
            videoURL: URL(string: "https://example.com/clip.mp4")!,
            personalityUsed: "The Critic"
        )
        #expect(clip.personalityUsed == "The Critic")
    }

    @Test("Clip defaults to public visibility")
    func testClipDefaultPublicVisibility() {
        let clip = GhostClip(
            sessionId: UUID(),
            creatorId: UUID(),
            videoURL: URL(string: "https://example.com/clip.mp4")!,
            personalityUsed: "The Muse"
        )
        #expect(clip.isPublic == true)
    }

    @Test("Clip can be set to private")
    func testClipPrivateVisibility() {
        let clip = GhostClip(
            sessionId: UUID(),
            creatorId: UUID(),
            videoURL: URL(string: "https://example.com/clip.mp4")!,
            isPublic: false,
            personalityUsed: "The Muse"
        )
        #expect(clip.isPublic == false)
    }

    @Test("Clip has unique ID on creation")
    func testClipUniqueId() {
        let clip1 = GhostClip(
            sessionId: UUID(),
            creatorId: UUID(),
            videoURL: URL(string: "https://example.com/1.mp4")!,
            personalityUsed: "The Muse"
        )
        let clip2 = GhostClip(
            sessionId: UUID(),
            creatorId: UUID(),
            videoURL: URL(string: "https://example.com/2.mp4")!,
            personalityUsed: "The Muse"
        )
        #expect(clip1.id != clip2.id)
    }
}
