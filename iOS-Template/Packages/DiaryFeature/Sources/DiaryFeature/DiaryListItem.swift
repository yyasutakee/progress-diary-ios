import Foundation

public struct DiaryListItem: Identifiable, Hashable {
    public let id: UUID
    public let name: String
    public let heatmapColorID: String
    public let isStreakEnabled: Bool

    public init(id: UUID, name: String, heatmapColorID: String, isStreakEnabled: Bool) {
        self.id = id
        self.name = name
        self.heatmapColorID = heatmapColorID
        self.isStreakEnabled = isStreakEnabled
    }
}
