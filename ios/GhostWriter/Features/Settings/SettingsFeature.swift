import Foundation
import SwiftUI

public struct SettingsFeature {
    public static let views = SettingsViews.self
    public static let services = SettingsServices.self
}

public enum SettingsViews {
    public static func settingsView() -> some View {
        SettingsView()
    }
}

public enum SettingsServices {
    public static func makePreferencesService(defaults: UserDefaults = .standard) -> PreferencesService {
        PreferencesService(defaults: defaults)
    }
}
