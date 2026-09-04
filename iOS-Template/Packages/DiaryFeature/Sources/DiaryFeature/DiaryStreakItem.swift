import Foundation

public struct DiaryStreakItem: Equatable {
    public let currentDays: Int
    public let longestDays: Int
    public let hasEntryToday: Bool
    public let nextEntryDays: Int

    public init(currentDays: Int, longestDays: Int, hasEntryToday: Bool, nextEntryDays: Int) {
        self.currentDays = currentDays
        self.longestDays = longestDays
        self.hasEntryToday = hasEntryToday
        self.nextEntryDays = nextEntryDays
    }
}
