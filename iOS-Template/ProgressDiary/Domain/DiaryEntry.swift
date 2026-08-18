import Foundation

struct DiaryEntry: Identifiable {
    let id: UUID
    let listID: UUID
    let text: String
    let createdAt: Date
}
