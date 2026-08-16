import SwiftData
import Combine
import Foundation

@Model
final class DiaryEntryRecord {
    var id: UUID
    var text: String
    var createdAt: Date

    init(text: String) {
        self.id = UUID()
        self.text = text
        self.createdAt = Date()
    }
}

final class SwiftDataDiaryEntryRepository: DiaryEntryRepository {
    private let modelContext: ModelContext
    private let entriesSubject: CurrentValueSubject<[DiaryEntry], Never>

    var entriesPublisher: AnyPublisher<[DiaryEntry], Never> {
        entriesSubject.eraseToAnyPublisher()
    }

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        self.entriesSubject = CurrentValueSubject<[DiaryEntry], Never>([])
        loadAndPublishEntries()
    }

    // WHY: inserts and persists immediately, then refreshes the publisher
    // so all observers see the new entry without a separate fetch trigger.
    func addEntry(text: String) {
        let record: DiaryEntryRecord = DiaryEntryRecord(text: text)
        modelContext.insert(record)
        saveContext()
        loadAndPublishEntries()
    }

    // WHY: looks up the record by id so callers can use the plain DiaryEntry
    // value type rather than holding a reference to the @Model object.
    func deleteEntry(_ entry: DiaryEntry) {
        let id: UUID = entry.id
        let descriptor: FetchDescriptor<DiaryEntryRecord> = FetchDescriptor<DiaryEntryRecord>(
            predicate: #Predicate { $0.id == id }
        )
        guard let record: DiaryEntryRecord = try? modelContext.fetch(descriptor).first else { return }
        modelContext.delete(record)
        saveContext()
        loadAndPublishEntries()
    }

    // WHY: all mutations share one save call so none can bypass persistence.
    private func saveContext() {
        try? modelContext.save()
    }

    // WHY: re-fetches the full sorted list after every mutation so the publisher
    // always reflects the actual persisted state rather than an in-memory mirror.
    private func loadAndPublishEntries() {
        let descriptor: FetchDescriptor<DiaryEntryRecord> = FetchDescriptor<DiaryEntryRecord>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        let records: [DiaryEntryRecord] = (try? modelContext.fetch(descriptor)) ?? []
        entriesSubject.send(records.map(makeDiaryEntry))
    }

    // WHY: converts @Model reference types into plain value types so the domain
    // layer has no dependency on SwiftData.
    private func makeDiaryEntry(from record: DiaryEntryRecord) -> DiaryEntry {
        DiaryEntry(id: record.id, text: record.text, createdAt: record.createdAt)
    }
}
