import Foundation

@MainActor
public protocol DiaryViewModel: ObservableObject {
    var entries: [DiaryEntryItem] { get }
    var activeDayKeys: Set<String> { get }
    var isShowingAddEntry: Bool { get set }
    func send(_ event: DiaryEvent)
}
