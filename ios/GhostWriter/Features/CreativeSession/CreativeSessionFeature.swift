import Foundation
import SwiftUI

public struct CreativeSessionFeature {
    public static let views = CreativeSessionViews.self
    public static let services = CreativeSessionServices.self
}

public enum CreativeSessionViews {
    public static func creativeSessionView() -> some View {
        CreativeSessionView()
    }

    public static func ghostBoardCanvas(text: Binding<String>, wordCount: Int, isInFlowState: Bool) -> some View {
        GhostBoardCanvas(text: text, wordCount: wordCount, isInFlowState: isInFlowState)
    }
}

public enum CreativeSessionServices {
    public static let session = SessionService.shared
}

public typealias Session = CreativeSession
public typealias Suggestion = GhostSuggestion
