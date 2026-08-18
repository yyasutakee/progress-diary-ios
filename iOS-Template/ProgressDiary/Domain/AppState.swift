import Foundation

struct AppState {
    var lists: [DiaryList] = []
    var entries: [DiaryEntry] = []
    var selectedListID: UUID? = nil
}
