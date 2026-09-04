import Foundation

struct DiaryStreak {
    let currentDays: Int
    let longestDays: Int
    let hasEntryToday: Bool

    var nextEntryDays: Int { hasEntryToday ? currentDays : currentDays + 1 }
}

struct DiaryStreakCalculator {
    static func calculate(from entries: [DiaryEntry], calendar: Calendar = .current, now: Date = Date()) -> DiaryStreak {
        let activeDays: Set<Date> = Set(entries.map { calendar.startOfDay(for: $0.createdAt) })
        let today: Date = calendar.startOfDay(for: now)
        let hasEntryToday: Bool = activeDays.contains(today)
        let currentStart: Date? = activeDays.contains(today) ? today : previousActiveDay(before: today, in: activeDays, calendar: calendar)
        let currentDays: Int = consecutiveDays(endingAt: currentStart, in: activeDays, calendar: calendar)
        let longestDays: Int = longestConsecutiveDays(in: activeDays, calendar: calendar)
        return DiaryStreak(currentDays: currentDays, longestDays: longestDays, hasEntryToday: hasEntryToday)
    }

    private static func previousActiveDay(before day: Date, in activeDays: Set<Date>, calendar: Calendar) -> Date? {
        guard let yesterday: Date = calendar.date(byAdding: .day, value: -1, to: day), activeDays.contains(yesterday) else { return nil }
        return yesterday
    }

    private static func consecutiveDays(endingAt endDay: Date?, in activeDays: Set<Date>, calendar: Calendar) -> Int {
        guard var day: Date = endDay else { return 0 }
        var count: Int = 0
        while activeDays.contains(day) {
            count += 1
            guard let previousDay: Date = calendar.date(byAdding: .day, value: -1, to: day) else { break }
            day = previousDay
        }
        return count
    }

    private static func longestConsecutiveDays(in activeDays: Set<Date>, calendar: Calendar) -> Int {
        activeDays.reduce(0) { longest: Int, day: Date in
            let startsRun: Bool = !activeDays.contains(calendar.date(byAdding: .day, value: -1, to: day) ?? day)
            guard startsRun else { return longest }
            return max(longest, consecutiveDays(endingAt: lastActiveDay(startingAt: day, in: activeDays, calendar: calendar), in: activeDays, calendar: calendar))
        }
    }

    private static func lastActiveDay(startingAt startDay: Date, in activeDays: Set<Date>, calendar: Calendar) -> Date {
        var day: Date = startDay
        while let nextDay: Date = calendar.date(byAdding: .day, value: 1, to: day), activeDays.contains(nextDay) { day = nextDay }
        return day
    }
}
