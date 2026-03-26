import Foundation

nonisolated enum EnergyLevel: String, Codable, CaseIterable, Sendable {
    case deep
    case shallow
    case admin

    var displayName: String {
        switch self {
        case .deep: return "Deep Work"
        case .shallow: return "Shallow Work"
        case .admin: return "Admin"
        }
    }

    var icon: String {
        switch self {
        case .deep: return "brain.head.profile.fill"
        case .shallow: return "list.bullet.clipboard"
        case .admin: return "envelope.fill"
        }
    }

    var minimumReadinessThreshold: Double {
        switch self {
        case .deep: return 60.0
        case .shallow: return 35.0
        case .admin: return 15.0
        }
    }

    var color: String {
        switch self {
        case .deep: return "indigo"
        case .shallow: return "teal"
        case .admin: return "orange"
        }
    }
}
