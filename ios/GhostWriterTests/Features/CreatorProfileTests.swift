import Testing
import Foundation
@testable import GhostWriter

@Suite("Creator Profile Tests")
struct CreatorProfileTests {

    @Test("Should create a CreatorProfile with defaults")
    func testProfileDefaults() {
        let userId = UUID()
        let profile = CreatorProfile(userId: userId, username: "test_creator")

        #expect(profile.userId == userId)
        #expect(profile.username == "test_creator")
        #expect(profile.bio == nil)
        #expect(profile.profileImageURL == nil)
        #expect(profile.followerCount == 0)
        #expect(profile.followingCount == 0)
        #expect(profile.totalClipViews == 0)
        #expect(profile.totalClipLikes == 0)
        #expect(profile.totalEarnings == 0)
        #expect(profile.totalSessionsCreated == 0)
        #expect(profile.favoritePersonalities.isEmpty)
        #expect(profile.badges.isEmpty)
        #expect(profile.isVerified == false)
        #expect(profile.socialLinks.isEmpty)
        #expect(profile.createdPersonalities.isEmpty)
        #expect(profile.publicSessions.isEmpty)
    }

    @Test("Should create a CreatorProfile with all fields")
    func testProfileFullCreation() {
        let personalityId = UUID()
        let sessionId = UUID()

        let profile = CreatorProfile(
            userId: UUID(),
            username: "creative_master",
            bio: "Award-winning writer",
            followerCount: 1500,
            followingCount: 200,
            totalClipViews: 50000,
            totalClipLikes: 3000,
            totalEarnings: 850.00,
            totalSessionsCreated: 120,
            favoritePersonalities: [personalityId],
            badges: ["early_adopter", "streak_30", "top_creator"],
            isVerified: true,
            socialLinks: ["twitter": "@creative_master"],
            createdPersonalities: [personalityId],
            publicSessions: [sessionId]
        )

        #expect(profile.username == "creative_master")
        #expect(profile.bio == "Award-winning writer")
        #expect(profile.followerCount == 1500)
        #expect(profile.totalEarnings == 850.00)
        #expect(profile.badges.count == 3)
        #expect(profile.isVerified == true)
        #expect(profile.socialLinks["twitter"] == "@creative_master")
        #expect(profile.createdPersonalities.count == 1)
        #expect(profile.publicSessions.count == 1)
    }

    @Test("Profile has unique ID on creation")
    func testProfileUniqueId() {
        let p1 = CreatorProfile(userId: UUID(), username: "user1")
        let p2 = CreatorProfile(userId: UUID(), username: "user2")
        #expect(p1.id != p2.id)
    }

    @Test("CreatorStats created with defaults")
    func testStatsDefaults() {
        let stats = CreatorStats()
        #expect(stats.totalSessions == 0)
        #expect(stats.totalWords == 0)
        #expect(stats.totalIdeas == 0)
        #expect(stats.averageFlowScore == 0)
        #expect(stats.totalEarnings == 0)
        #expect(stats.totalClipViews == 0)
        #expect(stats.mostUsedPersonality == nil)
        #expect(stats.currentStreak == 0)
        #expect(stats.longestStreak == 0)
    }

    @Test("CreatorStats created with custom values")
    func testStatsCustomValues() {
        let stats = CreatorStats(
            totalSessions: 50,
            totalWords: 25000,
            totalIdeas: 300,
            averageFlowScore: 72.5,
            totalEarnings: 500.0,
            totalClipViews: 10000,
            mostUsedPersonality: "The Muse",
            currentStreak: 7,
            longestStreak: 21
        )
        #expect(stats.totalSessions == 50)
        #expect(stats.totalWords == 25000)
        #expect(stats.totalIdeas == 300)
        #expect(stats.averageFlowScore == 72.5)
        #expect(stats.totalEarnings == 500.0)
        #expect(stats.totalClipViews == 10000)
        #expect(stats.mostUsedPersonality == "The Muse")
        #expect(stats.currentStreak == 7)
        #expect(stats.longestStreak == 21)
    }

    @Test("CreatorStats conforms to Codable")
    func testStatsCodable() throws {
        let stats = CreatorStats(
            totalSessions: 10,
            totalWords: 5000,
            averageFlowScore: 65.0,
            mostUsedPersonality: "The Architect"
        )
        let data = try JSONEncoder().encode(stats)
        let decoded = try JSONDecoder().decode(CreatorStats.self, from: data)
        #expect(decoded.totalSessions == stats.totalSessions)
        #expect(decoded.totalWords == stats.totalWords)
        #expect(decoded.averageFlowScore == stats.averageFlowScore)
        #expect(decoded.mostUsedPersonality == stats.mostUsedPersonality)
    }
}
