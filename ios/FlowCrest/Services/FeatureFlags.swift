import Foundation

@Observable
@MainActor
final class FeatureFlags {
    static let shared = FeatureFlags()

    var isBioAdaptiveEnabled: Bool {
        get { UserDefaults.standard.bool(forKey: "ff_bioAdaptive") }
        set { UserDefaults.standard.set(newValue, forKey: "ff_bioAdaptive") }
    }

    var isAutoRescheduleEnabled: Bool {
        get { UserDefaults.standard.bool(forKey: "ff_autoReschedule") }
        set { UserDefaults.standard.set(newValue, forKey: "ff_autoReschedule") }
    }

    var isCalendarSyncEnabled: Bool {
        get { UserDefaults.standard.bool(forKey: "ff_calendarSync") }
        set { UserDefaults.standard.set(newValue, forKey: "ff_calendarSync") }
    }

    var isPersonalizationEnabled: Bool {
        get { UserDefaults.standard.bool(forKey: "ff_personalization") }
        set { UserDefaults.standard.set(newValue, forKey: "ff_personalization") }
    }

    var deepWorkThreshold: Double {
        get {
            let val = UserDefaults.standard.double(forKey: "ff_deepWorkThreshold")
            return val > 0 ? val : 60.0
        }
        set { UserDefaults.standard.set(newValue, forKey: "ff_deepWorkThreshold") }
    }

    private init() {
        let defaults: [String: Any] = [
            "ff_bioAdaptive": true,
            "ff_autoReschedule": true,
            "ff_calendarSync": true,
            "ff_personalization": true,
            "ff_deepWorkThreshold": 60.0
        ]
        UserDefaults.standard.register(defaults: defaults)
    }
}
