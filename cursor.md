# GhostWriter iOS Development Ruleset

## Project Context & Constraints

**Target Platform**: iOS 18+ (Swift 6 with strict concurrency)
**UI Framework**: SwiftUI only (no UIKit unless absolutely necessary)
**Deployment**: iPhone and iPad (universal app)
**Architecture**: MVVM with @Observable ViewModels
**Data Persistence**: SwiftData for models, AppStorage for preferences
**Build System**: BuildProject (not xcodebuild)
**Testing**: Swift Testing framework (@Test, #expect())
**Package Management**: SPM only (no CocoaPods)

---

## Architecture Principles

### 1. MVVM with @Observable ViewModels

**Rule**: All ViewModels must use `@Observable` (NOT `@ObservableObject`). Views hold ViewModels as `@State` properties.

```swift
// ✅ Correct: @Observable ViewModel
@Observable
final class CreativeSessionViewModel {
    var session: CreativeSession?
    var suggestions: [GhostSuggestion] = []
    var isLoading = false
    
    func startSession(type: SessionType) async {
        isLoading = true
        // Business logic here
        isLoading = false
    }
}

// ✅ Correct: View with ViewModel as @State
struct CreativeSessionView: View {
    @State private var viewModel = CreativeSessionViewModel()
    
    var body: some View {
        // Declarative UI only
    }
}

// ❌ Wrong: @ObservableObject (deprecated pattern)
class OldViewModel: ObservableObject {
    @Published var data: String = ""
}
```

**Why**: `@Observable` is the modern Swift 6 pattern with better performance and strict concurrency support.

---

### 2. Dependency Injection Through SwiftUI Environment

**Rule**: Inject dependencies via `.environment()` modifier, not through initializers.

```swift
// ✅ Correct: Dependency injection via environment
@main
struct GhostWriterApp: App {
    let coreMLService = CoreMLService()
    let audioService = AudioService()
    let analyticsService = AnalyticsService()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(coreMLService)
                .environment(audioService)
                .environment(analyticsService)
        }
    }
}

// In child views, access via @Environment
struct CreativeSessionView: View {
    @Environment(CoreMLService.self) var coreMLService
    @Environment(AudioService.self) var audioService
    
    var body: some View {
        // Use services here
    }
}

// ❌ Wrong: Passing through initializers
struct ChildView: View {
    let coreMLService: CoreMLService
    let audioService: AudioService
    
    init(coreMLService: CoreMLService, audioService: AudioService) {
        self.coreMLService = coreMLService
        self.audioService = audioService
    }
}
```

**Why**: Environment injection is cleaner, more scalable, and reduces boilerplate.

---

### 3. Navigation with NavigationStack & NavigationPath

**Rule**: Always use `NavigationStack` with `NavigationPath`. Never use `NavigationView` (deprecated).

```swift
// ✅ Correct: NavigationStack with NavigationPath
@Observable
final class NavigationCoordinator {
    var path = NavigationPath()
    
    func navigate(to destination: AppDestination) {
        path.append(destination)
    }
    
    func popToRoot() {
        path.removeLast(path.count)
    }
}

enum AppDestination: Hashable {
    case creativeSession(sessionId: UUID)
    case personalityEditor(personalityId: UUID?)
    case creatorProfile(userId: UUID)
    case ghostClipEditor(clipId: UUID)
}

struct ContentView: View {
    @State private var coordinator = NavigationCoordinator()
    
    var body: some View {
        NavigationStack(path: $coordinator.path) {
            TabView {
                LiveView()
                    .navigationDestination(for: AppDestination.self) { destination in
                        navigationView(for: destination)
                    }
                
                DiscoverView()
                    .navigationDestination(for: AppDestination.self) { destination in
                        navigationView(for: destination)
                    }
            }
        }
        .environment(coordinator)
    }
    
    @ViewBuilder
    func navigationView(for destination: AppDestination) -> some View {
        switch destination {
        case .creativeSession(let sessionId):
            CreativeSessionDetailView(sessionId: sessionId)
        case .personalityEditor(let personalityId):
            PersonalityEditorView(personalityId: personalityId)
        case .creatorProfile(let userId):
            CreatorProfileView(userId: userId)
        case .ghostClipEditor(let clipId):
            GhostClipEditorView(clipId: clipId)
        }
    }
}

// ❌ Wrong: NavigationView (deprecated)
struct OldNavigation: View {
    var body: some View {
        NavigationView {
            List {
                NavigationLink("Item", destination: DetailView())
            }
        }
    }
}
```

**Why**: NavigationStack is the modern pattern with better state management and predictable behavior.

---

### 4. Data Persistence: SwiftData for Models, AppStorage for Preferences

**Rule**: Use SwiftData for complex models, AppStorage for simple user preferences.

```swift
// ✅ Correct: SwiftData for persistent models
import SwiftData

@Model
final class CreativeSession {
    @Attribute(.unique) var id: UUID
    var startTime: Date
    var endTime: Date?
    var title: String?
    var type: SessionType
    var rawInputLog: [String]
    var personalityId: UUID
    var wordCount: Int = 0
    var flowScore: Double = 0
    var isPublic: Bool = false
    
    init(id: UUID = UUID(), startTime: Date = Date(), type: SessionType) {
        self.id = id
        self.startTime = startTime
        self.type = type
        self.rawInputLog = []
    }
}

// ✅ Correct: AppStorage for simple preferences
struct SettingsView: View {
    @AppStorage("creatorUsername") var username: String = ""
    @AppStorage("enableHaptics") var enableHaptics: Bool = true
    @AppStorage("preferredPersonality") var preferredPersonality: String = "The Muse"
    @AppStorage("notificationsEnabled") var notificationsEnabled: Bool = true
    
    var body: some View {
        Form {
            TextField("Username", text: $username)
            Toggle("Enable Haptics", isOn: $enableHaptics)
            Picker("Preferred Personality", selection: $preferredPersonality) {
                ForEach(GhostPersonality.allCases, id: \.self) { personality in
                    Text(personality.name).tag(personality.rawValue)
                }
            }
        }
    }
}

// ❌ Wrong: Using UserDefaults directly
struct OldSettings: View {
    var body: some View {
        TextField("Username", text: Binding(
            get: { UserDefaults.standard.string(forKey: "username") ?? "" },
            set: { UserDefaults.standard.set($0, forKey: "username") }
        ))
    }
}
```

**Why**: SwiftData is type-safe and provides better query capabilities. AppStorage is cleaner than UserDefaults for simple values.

---

### 5. Async/Await & Structured Concurrency

**Rule**: Always use `async/await` and structured concurrency. Never use completion handlers.

```swift
// ✅ Correct: async/await with structured concurrency
@Observable
final class CreativeSessionViewModel {
    var suggestions: [GhostSuggestion] = []
    var isLoading = false
    var error: Error?
    
    func generateSuggestions(for text: String) async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            // Use TaskGroup for parallel operations
            let results = try await withThrowingTaskGroup(of: GhostSuggestion.self) { group in
                for personalityId in [UUID(), UUID(), UUID()] {
                    group.addTask {
                        try await generateSuggestion(text: text, personalityId: personalityId)
                    }
                }
                
                var suggestions: [GhostSuggestion] = []
                for try await suggestion in group {
                    suggestions.append(suggestion)
                }
                return suggestions
            }
            
            self.suggestions = results
        } catch {
            self.error = error
        }
    }
    
    private func generateSuggestion(text: String, personalityId: UUID) async throws -> GhostSuggestion {
        // Implementation
        fatalError()
    }
}

// ✅ Correct: Typed throws for better error handling
enum SessionError: Error {
    case invalidInput
    case aiProcessingFailed
    case networkError
    case storageError
}

func saveSession(_ session: CreativeSession) async throws(SessionError) {
    do {
        try session.save()
    } catch {
        throw .storageError
    }
}

// ❌ Wrong: Completion handlers
func generateSuggestionsOld(for text: String, completion: @escaping ([GhostSuggestion]) -> Void) {
    DispatchQueue.global().async {
        let suggestions = generateSuggestions(text)
        DispatchQueue.main.async {
            completion(suggestions)
        }
    }
}
```

**Why**: async/await is cleaner, safer, and integrates with Swift's strict concurrency model.

---

## File Organization

### 1. Group by Feature, Not by Type

**Rule**: Organize files by feature domain, not by architectural layer.

```
GhostWriter/
├── App/
│   ├── GhostWriterApp.swift
│   ├── AppDelegate.swift
│   └── SceneDelegate.swift
│
├── Features/
│   ├── CreativeSession/
│   │   ├── Models/
│   │   │   ├── CreativeSession.swift
│   │   │   └── SessionType.swift
│   │   ├── ViewModels/
│   │   │   └── CreativeSessionViewModel.swift
│   │   ├── Views/
│   │   │   ├── CreativeSessionView.swift
│   │   │   ├── GhostBoardCanvas.swift
│   │   │   └── SuggestionCard.swift
│   │   ├── Services/
│   │   │   └── SessionService.swift
│   │   └── CreativeSessionFeature.swift (exports public API)
│   │
│   ├── GhostPersonality/
│   │   ├── Models/
│   │   │   ├── GhostPersonality.swift
│   │   │   └── PersonalityTrait.swift
│   │   ├── ViewModels/
│   │   │   ├── PersonalityEditorViewModel.swift
│   │   │   └── PersonalityMarketplaceViewModel.swift
│   │   ├── Views/
│   │   │   ├── PersonalityEditorView.swift
│   │   │   ├── PersonalityMarketplaceView.swift
│   │   │   └── PersonalityCard.swift
│   │   ├── Services/
│   │   │   └── PersonalityService.swift
│   │   └── GhostPersonalityFeature.swift
│   │
│   ├── LiveJam/
│   │   ├── Models/
│   │   │   └── LiveJamSession.swift
│   │   ├── ViewModels/
│   │   │   └── LiveJamViewModel.swift
│   │   ├── Views/
│   │   │   ├── LiveJamView.swift
│   │   │   └── CollaborationIndicator.swift
│   │   ├── Services/
│   │   │   └── SharePlayService.swift
│   │   └── LiveJamFeature.swift
│   │
│   ├── GhostClips/
│   │   ├── Models/
│   │   │   └── GhostClip.swift
│   │   ├── ViewModels/
│   │   │   ├── GhostClipEditorViewModel.swift
│   │   │   └── GhostClipShareViewModel.swift
│   │   ├── Views/
│   │   │   ├── GhostClipEditorView.swift
│   │   │   ├── GhostClipPreviewView.swift
│   │   │   └── GhostClipShareSheet.swift
│   │   ├── Services/
│   │   │   └── ClipService.swift
│   │   └── GhostClipsFeature.swift
│   │
│   ├── CreatorProfile/
│   │   ├── Models/
│   │   │   ├── CreatorProfile.swift
│   │   │   └── CreatorStats.swift
│   │   ├── ViewModels/
│   │   │   └── CreatorProfileViewModel.swift
│   │   ├── Views/
│   │   │   ├── CreatorProfileView.swift
│   │   │   ├── CreatorStatsView.swift
│   │   │   └── EarningsView.swift
│   │   ├── Services/
│   │   │   └── ProfileService.swift
│   │   └── CreatorProfileFeature.swift
│   │
│   ├── Discover/
│   │   ├── Models/
│   │   │   └── DiscoveryFeed.swift
│   │   ├── ViewModels/
│   │   │   ├── DiscoverViewModel.swift
│   │   │   └── TrendingViewModel.swift
│   │   ├── Views/
│   │   │   ├── DiscoverView.swift
│   │   │   ├── TrendingPersonalitiesView.swift
│   │   │   ├── PublicSessionsView.swift
│   │   │   └── CreatorDiscoveryView.swift
│   │   ├── Services/
│   │   │   └── DiscoveryService.swift
│   │   └── DiscoverFeature.swift
│   │
│   ├── Leaderboard/
│   │   ├── Models/
│   │   │   └── LeaderboardEntry.swift
│   │   ├── ViewModels/
│   │   │   └── LeaderboardViewModel.swift
│   │   ├── Views/
│   │   │   ├── LeaderboardView.swift
│   │   │   └── LeaderboardRowView.swift
│   │   ├── Services/
│   │   │   └── LeaderboardService.swift
│   │   └── LeaderboardFeature.swift
│   │
│   ├── CreativeStreak/
│   │   ├── Models/
│   │   │   └── CreativeStreak.swift
│   │   ├── ViewModels/
│   │   │   └── StreakViewModel.swift
│   │   ├── Views/
│   │   │   ├── StreakView.swift
│   │   │   └── StreakCalendarView.swift
│   │   ├── Services/
│   │   │   └── StreakService.swift
│   │   └── CreativeStreakFeature.swift
│   │
│   ├── Monetization/
│   │   ├── Models/
│   │   │   ├── Subscription.swift
│   │   │   └── CreatorEarnings.swift
│   │   ├── ViewModels/
│   │   │   ├── SubscriptionViewModel.swift
│   │   │   └── EarningsViewModel.swift
│   │   ├── Views/
│   │   │   ├── SubscriptionView.swift
│   │   │   └── EarningsView.swift
│   │   ├── Services/
│   │   │   ├── SubscriptionService.swift
│   │   │   └── PaymentService.swift
│   │   └── MonetizationFeature.swift
│   │
│   ├── Settings/
│   │   ├── Models/
│   │   │   └── UserPreferences.swift
│   │   ├── ViewModels/
│   │   │   └── SettingsViewModel.swift
│   │   ├── Views/
│   │   │   ├── SettingsView.swift
│   │   │   ├── NotificationSettingsView.swift
│   │   │   └── PrivacySettingsView.swift
│   │   ├── Services/
│   │   │   └── PreferencesService.swift
│   │   └── SettingsFeature.swift
│   │
│   └── Onboarding/
│       ├── Models/
│       │   └── OnboardingStep.swift
│       ├── ViewModels/
│       │   └── OnboardingViewModel.swift
│       ├── Views/
│       │   ├── OnboardingView.swift
│       │   ├── PersonalityQuizView.swift
│       │   └── FirstSessionView.swift
│       ├── Services/
│       │   └── OnboardingService.swift
│       └── OnboardingFeature.swift
│
├── Services/
│   ├── CoreML/
│   │   ├── CoreMLService.swift
│   │   ├── LLMService.swift
│   │   └── MoodDetectionService.swift
│   │
│   ├── Audio/
│   │   ├── AudioService.swift
│   │   ├── HapticService.swift
│   │   └── TextToSpeechService.swift
│   │
│   ├── Analytics/
│   │   ├── AnalyticsService.swift
│   │   └── CreatorAnalyticsService.swift
│   │
│   ├── Cloud/
│   │   ├── CloudSyncService.swift
│   │   └── BackupService.swift
│   │
│   ├── Networking/
│   │   ├── APIClient.swift
│   │   └── APIEndpoints.swift
│   │
│   └── Storage/
│       ├── StorageService.swift
│       └── ImageCacheService.swift
│
├── Shared/
│   ├── Components/
│   │   ├── GhostOrbView.swift (animated aura orb)
│   │   ├── ConfidenceScoreIndicator.swift
│   │   ├── FlowStateIndicator.swift
│   │   ├── CreativeStreakBadge.swift
│   │   ├── PersonalityAvatarView.swift
│   │   ├── LoadingView.swift
│   │   └── ErrorView.swift
│   │
│   ├── Modifiers/
│   │   ├── LiquidGlassModifier.swift
│   │   ├── GhostGlowModifier.swift
│   │   ├── HapticModifier.swift
│   │   └── FlowStateModifier.swift
│   │
│   ├── Extensions/
│   │   ├── View+Extensions.swift
│   │   ├── Color+Extensions.swift
│   │   ├── Date+Extensions.swift
│   │   └── String+Extensions.swift
│   │
│   ├── Constants/
│   │   ├── AppConstants.swift
│   │   ├── ColorConstants.swift
│   │   ├── TypographyConstants.swift
│   │   └── AnimationConstants.swift
│   │
│   └── Utilities/
│       ├── Logger.swift
│       ├── ErrorHandler.swift
│       └── ValidationHelper.swift
│
└── Resources/
    ├── Localizable.strings
    ├── Assets.xcassets
    └── Fonts/
```

**Why**: Feature-based organization makes it easier to find related code and facilitates feature teams working in parallel.

---

### 2. Feature Module Pattern

**Rule**: Each feature should have a public API file that exports only what's needed.

```swift
// CreativeSession/CreativeSessionFeature.swift
@_exported import Foundation

// Public API
public struct CreativeSessionFeature {
    public static let views = CreativeSessionViews.self
    public static let services = CreativeSessionServices.self
}

// Views
public enum CreativeSessionViews {
    public static func creativeSessionView(sessionId: UUID) -> some View {
        CreativeSessionView(sessionId: sessionId)
    }
}

// Services
public enum CreativeSessionServices {
    public static let session = SessionService.shared
}

// Models (public)
public typealias Session = CreativeSession
public typealias Suggestion = GhostSuggestion
```

**Why**: Encapsulation and clear public API boundaries.

---

## Naming Conventions

### 1. Types: PascalCase

```swift
// ✅ Correct
struct CreativeSession { }
class SessionViewModel { }
enum SessionType { }
protocol SessionDelegate { }

// ❌ Wrong
struct creative_session { }
class sessionViewModel { }
enum sessionType { }
```

### 2. Properties & Functions: camelCase

```swift
// ✅ Correct
var wordCount: Int
var isLoading: Bool
func generateSuggestions()
func saveSession()

// ❌ Wrong
var WordCount: Int
var IsLoading: Bool
func GenerateSuggestions()
func SaveSession()
```

### 3. Constants: UPPER_SNAKE_CASE (for compile-time constants)

```swift
// ✅ Correct
let MAX_SESSION_DURATION: TimeInterval = 3600
let DEFAULT_PERSONALITY_ID = UUID()
let API_BASE_URL = "https://api.ghostwriter.app"

// For runtime constants, use camelCase
let maxSessionDuration: TimeInterval = 3600
```

### 4. Enums: PascalCase for type, camelCase for cases

```swift
// ✅ Correct
enum SessionType {
    case writing
    case brainstorming
    case coding
    case design
    case freestyle
}

enum CreatorTier {
    case free
    case creator
    case pro
    case studio
    case enterprise
}

// ❌ Wrong
enum SessionType {
    case Writing
    case Brainstorming
}
```

---

## Code Style & Patterns

### 1. All Views Must Include #Preview Block

**Rule**: Every view must have a #Preview block for SwiftUI Previews.

```swift
// ✅ Correct
struct CreativeSessionView: View {
    @State private var viewModel = CreativeSessionViewModel()
    
    var body: some View {
        ZStack {
            // UI implementation
        }
    }
}

#Preview {
    CreativeSessionView()
        .environment(CoreMLService())
        .environment(AudioService())
}

// ✅ Correct: Multiple previews for different states
#Preview("Loading State") {
    var viewModel = CreativeSessionViewModel()
    viewModel.isLoading = true
    return CreativeSessionView()
}

#Preview("With Suggestions") {
    var viewModel = CreativeSessionViewModel()
    viewModel.suggestions = [
        GhostSuggestion(content: "This is a great idea", confidenceScore: 0.95),
        GhostSuggestion(content: "Consider another angle", confidenceScore: 0.75)
    ]
    return CreativeSessionView()
}
```

**Why**: Previews are essential for rapid UI development and catching regressions.

---

### 2. Use SF Symbols for Icons

**Rule**: Always use SF Symbols. Reference by exact name from Apple's SF Symbols app.

```swift
// ✅ Correct: SF Symbols
Button(action: { }) {
    Label("Start Session", systemImage: "play.circle.fill")
}

Image(systemName: "sparkles")
    .foregroundColor(.cyan)

Image(systemName: "waveform.circle.fill")
    .font(.system(size: 24))

// ❌ Wrong: Custom images or incorrect names
Button(action: { }) {
    Label("Start Session", systemImage: "play_button") // Wrong name
}

Image("custom_icon") // Avoid custom images for standard icons
```

**Why**: SF Symbols are consistent, scalable, and automatically support dark mode.

---

### 3. Prefer Liquid Glass Materials (iOS 18+)

**Rule**: Use `.glass` or `.ultraThinMaterial` for modern, frosted glass effects.

```swift
// ✅ Correct: Liquid Glass
VStack {
    Text("Creative Session")
        .font(.title2)
        .bold()
    
    HStack {
        Image(systemName: "sparkles")
        Text("In Flow State")
    }
}
.padding()
.background(.ultraThinMaterial)
.cornerRadius(16)

// ✅ Correct: Glassmorphism for floating cards
SuggestionCard()
    .background(.regularMaterial)
    .cornerRadius(12)
    .shadow(color: .black.opacity(0.1), radius: 8)

// ❌ Wrong: Solid colors (outdated)
VStack {
    Text("Creative Session")
}
.padding()
.background(Color.gray.opacity(0.2))
.cornerRadius(16)
```

**Why**: Liquid Glass creates a premium, modern aesthetic that's perfect for GhostWriter's design language.

---

### 4. One Type Per File

**Rule**: Each Swift type (struct, class, enum) should be in its own file, except for closely related types.

```
// ✅ Correct file structure
CreativeSession.swift
    ├── struct CreativeSession
    
CreativeSessionViewModel.swift
    ├── @Observable final class CreativeSessionViewModel
    
SessionType.swift
    ├── enum SessionType
    ├── enum SessionError (related type, OK to include)

// ❌ Wrong: Multiple unrelated types in one file
CreativeSession.swift
    ├── struct CreativeSession
    ├── @Observable final class CreativeSessionViewModel
    ├── enum SessionType
    ├── struct GhostSuggestion
```

**Why**: Single responsibility, easier to navigate, better for version control.

---

## GhostWriter-Specific Patterns

### 1. Ghost AI Suggestion Pattern

**Rule**: All AI suggestions must include confidence scoring and user feedback.

```swift
@Observable
final class SuggestionEngine {
    func generateSuggestion(
        context: String,
        personality: GhostPersonality
    ) async throws -> GhostSuggestion {
        let suggestion = try await coreMLService.generateText(
            prompt: context,
            personality: personality
        )
        
        let confidenceScore = try await coreMLService.scoreConfidence(
            suggestion: suggestion,
            context: context
        )
        
        return GhostSuggestion(
            content: suggestion,
            type: .continuation,
            confidenceScore: confidenceScore
        )
    }
}

// View displays confidence visually
struct SuggestionCardView: View {
    let suggestion: GhostSuggestion
    @State private var userRating: Int? = nil
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(suggestion.content)
                    .lineLimit(3)
                
                Spacer()
                
                // Confidence indicator
                ConfidenceScoreIndicator(score: suggestion.confidenceScore)
            }
            
            // User feedback
            HStack {
                Button(action: { userRating = -1 }) {
                    Image(systemName: "hand.thumbsdown")
                        .foregroundColor(userRating == -1 ? .red : .gray)
                }
                
                Button(action: { userRating = 1 }) {
                    Image(systemName: "hand.thumbsup")
                        .foregroundColor(userRating == 1 ? .green : .gray)
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(12)
    }
}
```

**Why**: Confidence scoring builds user trust and enables on-device learning.

---

### 2. Haptic Feedback Pattern

**Rule**: All interactive elements should provide haptic feedback. Use HapticService for consistency.

```swift
@Observable
final class HapticService {
    func lightTap() {
        let impact = UIImpactFeedbackGenerator(style: .light)
        impact.impactOccurred()
    }
    
    func mediumTap() {
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()
    }
    
    func heavyTap() {
        let impact = UIImpactFeedbackGenerator(style: .heavy)
        impact.impactOccurred()
    }
    
    func successNotification() {
        let notification = UINotificationFeedbackGenerator()
        notification.notificationOccurred(.success)
    }
    
    func errorNotification() {
        let notification = UINotificationFeedbackGenerator()
        notification.notificationOccurred(.error)
    }
}

// Usage in views
struct SuggestionCardView: View {
    @Environment(HapticService.self) var hapticService
    
    var body: some View {
        Button(action: {
            hapticService.mediumTap()
            acceptSuggestion()
        }) {
            Label("Accept", systemImage: "checkmark.circle.fill")
        }
    }
}

// Custom modifier for haptic feedback
struct HapticModifier: ViewModifier {
    @Environment(HapticService.self) var hapticService
    let feedbackType: UIImpactFeedbackGenerator.FeedbackStyle
    
    func body(content: Content) -> some View {
        content
            .onTapGesture {
                hapticService.lightTap()
            }
    }
}

extension View {
    func hapticFeedback(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .light) -> some View {
        modifier(HapticModifier(feedbackType: style))
    }
}
```

**Why**: Haptic feedback is critical for GhostWriter's sensory experience and flow state.

---

### 3. Flow State Detection Pattern

**Rule**: Track typing cadence and pauses to detect flow state.

```swift
@Observable
final class FlowStateDetector {
    var flowScore: Double = 0
    private var typingEvents: [(timestamp: Date, wordCount: Int)] = []
    
    func recordTyping(wordCount: Int) {
        let event = (timestamp: Date(), wordCount: wordCount)
        typingEvents.append(event)
        
        // Keep only last 5 minutes
        typingEvents.removeAll { Date().timeIntervalSince($0.timestamp) > 300 }
        
        updateFlowScore()
    }
    
    private func updateFlowScore() {
        guard typingEvents.count > 2 else { return }
        
        // Calculate consistency (lower variance = higher flow)
        let intervals = typingEvents.dropFirst().map { event in
            event.timestamp.timeIntervalSince(typingEvents[typingEvents.count - 2].timestamp)
        }
        
        let avgInterval = intervals.reduce(0, +) / Double(intervals.count)
        let variance = intervals.map { pow($0 - avgInterval, 2) }.reduce(0, +) / Double(intervals.count)
        
        // Higher consistency = lower variance = higher flow score
        flowScore = max(0, min(100, 100 - (variance * 10)))
    }
    
    var isInFlowState: Bool {
        flowScore > 70
    }
}

// Usage in view
struct CreativeSessionView: View {
    @State private var flowDetector = FlowStateDetector()
    
    var body: some View {
        VStack {
            TextEditor(text: $sessionText)
                .onChange(of: sessionText) { oldValue, newValue in
                    let wordCount = newValue.split(separator: " ").count
                    flowDetector.recordTyping(wordCount: wordCount)
                }
            
            if flowDetector.isInFlowState {
                HStack {
                    Image(systemName: "flame.fill")
                        .foregroundColor(.orange)
                    Text("In Flow State")
                        .font(.caption)
                }
            }
        }
    }
}
```

**Why**: Flow state detection is core to GhostWriter's value proposition.

---

### 4. Creator Analytics Pattern

**Rule**: Track all creator metrics in a structured way for dashboard display.

```swift
@Model
final class CreatorAnalytics {
    @Attribute(.unique) var id: UUID
    var userId: UUID
    var date: Date
    
    // Session metrics
    var sessionCount: Int = 0
    var totalSessionMinutes: Int = 0
    var totalWordsWritten: Int = 0
    var ideasGenerated: Int = 0
    
    // Engagement metrics
    var clipViews: Int = 0
    var clipLikes: Int = 0
    var clipShares: Int = 0
    var earnings: Double = 0
    
    // Behavioral metrics
    var mostProductiveHour: Int? // 0-23
    var flowStateMinutes: Int = 0
    var collaborationCount: Int = 0
    
    init(userId: UUID, date: Date = Date()) {
        self.id = UUID()
        self.userId = userId
        self.date = date
    }
}

@Observable
final class CreatorAnalyticsViewModel {
    @Query var analytics: [CreatorAnalytics]
    
    var weeklyStats: [CreatorAnalytics] {
        let sevenDaysAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
        return analytics.filter { $0.date >= sevenDaysAgo }
    }
    
    var totalEarningsThisMonth: Double {
        let monthStart = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: Date()))!
        return analytics
            .filter { $0.date >= monthStart }
            .reduce(0) { $0 + $1.earnings }
    }
    
    var mostProductiveHour: Int? {
        let hours = analytics.compactMap { $0.mostProductiveHour }
        let frequency = Dictionary(grouping: hours, by: { $0 })
        return frequency.max(by: { $0.value.count < $1.value.count })?.key
    }
}
```

**Why**: Creator analytics are essential for retention and monetization.

---

### 5. Live Jam Collaboration Pattern

**Rule**: Use structured concurrency for real-time collaboration.

```swift
@Observable
final class LiveJamViewModel {
    var localText: String = ""
    var remoteText: String = ""
    var sharedSuggestions: [GhostSuggestion] = []
    var collaborationScore: Double = 0
    
    private let sharePlayService: SharePlayService
    
    func startLiveJam(with collaborator: UUID) async throws {
        try await sharePlayService.initializeGroupActivity()
        
        // Use TaskGroup to handle both local and remote updates
        try await withThrowingTaskGroup(of: Void.self) { group in
            group.addTask {
                try await self.listenForRemoteUpdates()
            }
            
            group.addTask {
                try await self.broadcastLocalUpdates()
            }
            
            group.addTask {
                try await self.generateSharedSuggestions()
            }
        }
    }
    
    private func listenForRemoteUpdates() async throws {
        for try await update in sharePlayService.remoteUpdates {
            remoteText = update.text
            updateCollaborationScore()
        }
    }
    
    private func broadcastLocalUpdates() async throws {
        for try await _ in Timer.publish(every: 0.5, on: .main, in: .common).autoconnect() {
            try await sharePlayService.broadcast(text: localText)
        }
    }
    
    private func generateSharedSuggestions() async throws {
        let combined = localText + " " + remoteText
        let suggestions = try await coreMLService.generateSuggestions(
            for: combined,
            personality: currentPersonality
        )
        sharedSuggestions = suggestions
    }
    
    private func updateCollaborationScore() {
        // Score based on how well both users are contributing
        let localWords = localText.split(separator: " ").count
        let remoteWords = remoteText.split(separator: " ").count
        let balance = min(Double(localWords), Double(remoteWords)) / max(Double(localWords), Double(remoteWords))
        collaborationScore = balance * 100
    }
}
```

**Why**: Structured concurrency ensures reliable real-time collaboration.

---

## Testing Guidelines

### 1. Use Swift Testing Framework

**Rule**: All tests use `@Test` attribute and `#expect()` assertions.

```swift
import Testing

@Suite("Creative Session Tests")
struct CreativeSessionTests {
    @Test("Should create a new session")
    func testCreateSession() {
        let session = CreativeSession(type: .writing)
        
        #expect(session.type == .writing)
        #expect(session.wordCount == 0)
        #expect(session.isPublic == false)
    }
    
    @Test("Should update word count on text input")
    async func testWordCountUpdate() {
        var viewModel = CreativeSessionViewModel()
        let text = "This is a test sentence"
        
        await viewModel.updateText(text)
        
        #expect(viewModel.wordCount == 5)
    }
    
    @Test("Should generate suggestions with confidence score")
    async func testSuggestionGeneration() {
        let engine = SuggestionEngine()
        let suggestion = try await engine.generateSuggestion(
            context: "The project is",
            personality: .muse
        )
        
        #expect(suggestion.confidenceScore > 0)
        #expect(suggestion.confidenceScore <= 1)
        #expect(!suggestion.content.isEmpty)
    }
    
    @Test("Should detect flow state correctly", arguments: [70.0, 75.0, 85.0, 95.0])
    func testFlowStateDetection(flowScore: Double) {
        let detector = FlowStateDetector()
        detector.flowScore = flowScore
        
        #expect(detector.isInFlowState == (flowScore > 70))
    }
}
```

**Why**: Swift Testing is the modern, native testing framework for Swift 6.

---

### 2. Test Organization

**Rule**: Mirror feature structure in test targets.

```
GhostWriterTests/
├── Features/
│   ├── CreativeSessionTests.swift
│   ├── GhostPersonalityTests.swift
│   ├── LiveJamTests.swift
│   ├── GhostClipsTests.swift
│   └── CreatorProfileTests.swift
│
├── Services/
│   ├── CoreMLServiceTests.swift
│   ├── HapticServiceTests.swift
│   └── AnalyticsServiceTests.swift
│
└── Utilities/
    ├── FlowStateDetectorTests.swift
    └── ValidationHelperTests.swift
```

---

## Performance Guidelines

### 1. Lazy Loading for Large Lists

**Rule**: Use `LazyVStack` and `LazyHStack` for scrollable content.

```swift
// ✅ Correct: Lazy loading
ScrollView {
    LazyVStack(spacing: 12) {
        ForEach(clips) { clip in
            GhostClipCardView(clip: clip)
        }
    }
}

// ❌ Wrong: Eager loading
ScrollView {
    VStack(spacing: 12) {
        ForEach(clips) { clip in
            GhostClipCardView(clip: clip)
        }
    }
}
```

### 2. Debounce User Input

**Rule**: Debounce text input before triggering AI suggestions.

```swift
@Observable
final class CreativeSessionViewModel {
    var sessionText: String = "" {
        didSet {
            debounceTextInput()
        }
    }
    
    private var debounceTask: Task<Void, Never>?
    
    private func debounceTextInput() {
        debounceTask?.cancel()
        
        debounceTask = Task {
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
            
            if !Task.isCancelled {
                await generateSuggestions()
            }
        }
    }
}
```

### 3. Image Caching

**Rule**: Use `ImageCacheService` for all remote images.

```swift
@Observable
final class ImageCacheService {
    private var cache = NSCache<NSString, UIImage>()
    
    func cachedImage(for url: URL) async -> UIImage? {
        let key = url.absoluteString as NSString
        
        if let cached = cache.object(forKey: key) {
            return cached
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let image = UIImage(data: data) {
                cache.setObject(image, forKey: key)
                return image
            }
        } catch {
            Logger.error("Failed to load image: \(error)")
        }
        
        return nil
    }
}
```

---

## Documentation Standards

### 1. DocC Comments for Public APIs

**Rule**: All public functions and types must have DocC documentation.

```swift
/// Generates AI suggestions for the given text context.
///
/// This function uses the on-device CoreML model to generate suggestions
/// based on the provided text context and personality. The suggestions
/// include confidence scores to help users understand the AI's certainty.
///
/// - Parameters:
///   - context: The text context to generate suggestions for
///   - personality: The ghost personality to use for generation
/// - Returns: An array of suggestions with confidence scores
/// - Throws: `SessionError.aiProcessingFailed` if generation fails
///
/// Example:
/// ```swift
/// let suggestions = try await engine.generateSuggestions(
///     context: "The project is",
///     personality: .architect
/// )
/// ```
public func generateSuggestions(
    context: String,
    personality: GhostPersonality
) async throws -> [GhostSuggestion]
```

---

## Summary: GhostWriter Development Checklist

- [ ] All ViewModels use `@Observable` (not `@ObservableObject`)
- [ ] All dependencies injected via `.environment()`
- [ ] Navigation uses `NavigationStack` with `NavigationPath`
- [ ] Complex models use SwiftData, simple prefs use AppStorage
- [ ] All async code uses `async/await` and structured concurrency
- [ ] Files organized by feature, not by type
- [ ] All views have `#Preview` blocks
- [ ] All icons use SF Symbols
- [ ] UI uses `.glass` or `.ultraThinMaterial` materials
- [ ] One type per file (except closely related types)
- [ ] All tests use `@Test` and `#expect()`
- [ ] All public APIs have DocC documentation
- [ ] Haptic feedback on all interactive elements
- [ ] Flow state detection implemented
- [ ] Creator analytics tracked
- [ ] Live Jam uses structured concurrency
- [ ] Images are cached
- [ ] Text input is debounced
- [ ] No completion handlers (all async/await)
- [ ] No UIKit (SwiftUI only)

This ruleset ensures GhostWriter is built with modern Swift best practices, optimal performance, and a cohesive architecture ready for scale.
