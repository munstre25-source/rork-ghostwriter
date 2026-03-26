import Testing
@testable import GhostWriter

@Suite("Validation Helper Tests")
struct ValidationHelperTests {

    // MARK: - Username Validation

    @Test("Valid usernames are accepted", arguments: [
        "user123", "ghost_writer", "abc", "A_B_C_D_E_F_G_H_I_J", "user_name_2024"
    ])
    func testValidUsernames(username: String) {
        #expect(ValidationHelper.isValidUsername(username) == true)
    }

    @Test("Invalid usernames are rejected", arguments: [
        "", "ab", "user name", "user@name", "user.name",
        "this_username_is_way_too_long_for_validation", "user-name", "user!name"
    ])
    func testInvalidUsernames(username: String) {
        #expect(ValidationHelper.isValidUsername(username) == false)
    }

    @Test("Username length boundaries")
    func testUsernameLengthBoundaries() {
        let twoChars = "ab"
        let threeChars = "abc"
        let twentyChars = "abcdefghijklmnopqrst"
        let twentyOneChars = "abcdefghijklmnopqrstu"

        #expect(ValidationHelper.isValidUsername(twoChars) == false)
        #expect(ValidationHelper.isValidUsername(threeChars) == true)
        #expect(ValidationHelper.isValidUsername(twentyChars) == true)
        #expect(ValidationHelper.isValidUsername(twentyOneChars) == false)
    }

    // MARK: - Email Validation

    @Test("Valid emails are accepted", arguments: [
        "user@example.com", "test.user@domain.co", "name+tag@email.org",
        "first.last@company.io", "user123@test.dev"
    ])
    func testValidEmails(email: String) {
        #expect(ValidationHelper.isValidEmail(email) == true)
    }

    @Test("Invalid emails are rejected", arguments: [
        "", "notanemail", "@domain.com", "user@", "user@.com",
        "user@domain", "user domain@test.com", "user@@domain.com"
    ])
    func testInvalidEmails(email: String) {
        #expect(ValidationHelper.isValidEmail(email) == false)
    }

    // MARK: - Personality Name Validation

    @Test("Valid personality names are accepted", arguments: [
        "The Muse", "Architect", "My Ghost-Writer", "AI Helper 2"
    ])
    func testValidPersonalityNames(name: String) {
        #expect(ValidationHelper.isValidPersonalityName(name) == true)
    }

    @Test("Invalid personality names are rejected", arguments: [
        "", "A", "Name_With_Underscores", "Name@Special!"
    ])
    func testInvalidPersonalityNames(name: String) {
        #expect(ValidationHelper.isValidPersonalityName(name) == false)
    }

    @Test("Personality name trims whitespace before validation")
    func testPersonalityNameTrimsWhitespace() {
        #expect(ValidationHelper.isValidPersonalityName("  The Muse  ") == true)
        #expect(ValidationHelper.isValidPersonalityName("  A  ") == false)
    }

    // MARK: - Input Sanitization

    @Test("Sanitization trims leading and trailing whitespace")
    func testSanitizeTrimming() {
        let result = ValidationHelper.sanitizeInput("  hello world  ")
        #expect(result == "hello world")
    }

    @Test("Sanitization removes control characters")
    func testSanitizeControlCharacters() {
        let input = "Hello\u{0000}World\u{0001}Test"
        let result = ValidationHelper.sanitizeInput(input)
        #expect(!result.contains("\u{0000}"))
        #expect(!result.contains("\u{0001}"))
    }

    @Test("Sanitization preserves normal text")
    func testSanitizePreservesNormalText() {
        let input = "The quick brown fox jumps over the lazy dog."
        let result = ValidationHelper.sanitizeInput(input)
        #expect(result == input)
    }

    @Test("Sanitization handles empty string")
    func testSanitizeEmptyString() {
        let result = ValidationHelper.sanitizeInput("")
        #expect(result.isEmpty)
    }

    @Test("Sanitization handles whitespace-only string")
    func testSanitizeWhitespaceOnly() {
        let result = ValidationHelper.sanitizeInput("   ")
        #expect(result.isEmpty)
    }
}
