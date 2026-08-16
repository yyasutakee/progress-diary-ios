import Foundation

public enum DiaryEvent {
    case addEntryTapped
    case entryTextSubmitted(String)
    case deleteEntry(UUID)
}
