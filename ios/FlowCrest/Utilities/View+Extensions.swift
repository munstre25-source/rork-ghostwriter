import SwiftUI

extension View {
    @ViewBuilder
    func adaptiveGlass(in shape: some InsettableShape = .rect(cornerRadius: 20)) -> some View {
        if #available(iOS 26.0, *) {
            self.glassEffect(in: shape)
        } else {
            self.background(shape.fill(.ultraThinMaterial))
        }
    }
}

extension Color {
    static func readinessColor(for score: Double) -> Color {
        switch score {
        case 80...100: return .green
        case 60..<80: return .teal
        case 40..<60: return .yellow
        case 20..<40: return .orange
        default: return .red
        }
    }

    static func energyLevelColor(for level: EnergyLevel) -> Color {
        switch level {
        case .deep: return .indigo
        case .shallow: return .teal
        case .admin: return .orange
        }
    }
}
