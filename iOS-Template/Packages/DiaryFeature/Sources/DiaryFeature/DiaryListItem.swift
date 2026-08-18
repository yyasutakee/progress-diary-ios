import Foundation

public struct DiaryListItem: Identifiable, Hashable {
    public let id: UUID
    public let name: String
    public let heatmapColorID: String

    public init(id: UUID, name: String, heatmapColorID: String) {
        self.id = id
        self.name = name
        self.heatmapColorID = heatmapColorID
    }
}
