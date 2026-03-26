import Foundation
import SwiftUI

public struct GhostClipsFeature {
    public static let views = GhostClipsViews.self
    public static let services = GhostClipsServices.self
}

public enum GhostClipsViews {
    public static func ghostClipEditorView() -> some View {
        GhostClipEditorView()
    }

    public static func ghostClipsListView() -> some View {
        GhostClipsListView()
    }
}

public enum GhostClipsServices {
    public static func makeClipService() -> ClipService {
        ClipService()
    }
}

public typealias Clip = GhostClip
