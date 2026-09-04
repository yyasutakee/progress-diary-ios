import Foundation

struct DiaryList: Identifiable {
    let id: UUID
    let name: String
    let heatmapColorID: String
    let isStreakEnabled: Bool
    let createdAt: Date
}
