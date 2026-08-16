import Foundation

public struct DiaryEntryItem: Identifiable, Equatable {
    public let id: UUID
    public let text: String
    public let dateLabel: String

    public init(id: UUID, text: String, dateLabel: String) {
        self.id = id
        self.text = text
        self.dateLabel = dateLabel
    }
}
