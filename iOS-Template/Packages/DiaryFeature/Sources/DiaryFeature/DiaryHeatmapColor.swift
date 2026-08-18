import SwiftUI

public enum DiaryHeatmapColor: String, CaseIterable, Identifiable {
    case blue
    case purple
    case green
    case orange
    case red
    case pink
    case teal
    case yellow

    public var id: String { rawValue }

    public var displayName: String {
        switch self {
        case .blue: return "Blue"
        case .purple: return "Purple"
        case .green: return "Green"
        case .orange: return "Orange"
        case .red: return "Red"
        case .pink: return "Pink"
        case .teal: return "Teal"
        case .yellow: return "Yellow"
        }
    }

    public var color: Color {
        switch self {
        case .blue: return .blue
        case .purple: return .purple
        case .green: return .green
        case .orange: return .orange
        case .red: return .red
        case .pink: return .pink
        case .teal: return .teal
        case .yellow: return .yellow
        }
    }
}
