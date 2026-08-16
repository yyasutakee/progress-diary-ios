import Combine
import Foundation
import DiaryFeature

@MainActor
final class DiaryViewStore: DiaryViewModel {
    @Published private(set) var entries: [DiaryEntryItem] = []
    @Published private(set) var activeDayKeys: Set<String> = Set<String>()
    @Published var isShowingAddEntry: Bool = false

    private let appStore: AppStore
    private var cancellables: Set<AnyCancellable> = Set<AnyCancellable>()

    private static let dayKeyFormatter: DateFormatter = {
        let f: DateFormatter = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()

    private static let dateLabelFormatter: DateFormatter = {
        let f: DateFormatter = DateFormatter()
        f.dateFormat = "M.d"
        return f
    }()

    init(appStore: AppStore) {
        self.appStore = appStore
        observeStoreChanges()
        recompute(from: appStore.state)
    }

    // WHY: events are the only channel views use to express intent;
    // all logic stays here so views remain purely declarative.
    func send(_ event: DiaryEvent) {
        switch event {
        case .addEntryTapped:
            isShowingAddEntry = true
        case .entryTextSubmitted(let text):
            appStore.addEntry(text: text)
            isShowingAddEntry = false
        case .deleteEntry(let id):
            deleteEntryMatchingID(id)
        }
    }

    // WHY: subscribes to didChange, not objectWillChange — this handler reads
    // state values, and objectWillChange fires before the mutation has landed.
    private func observeStoreChanges() {
        appStore.didChange
            .sink { [weak self] newState in self?.recompute(from: newState) }
            .store(in: &cancellables)
    }

    // WHY: state is a parameter so there is no route to accidentally read
    // a stale snapshot from a different moment inside this method.
    private func recompute(from state: AppState) {
        entries = state.entries.map(makeDiaryEntryItem)
        activeDayKeys = buildActiveDayKeys(from: state.entries)
    }

    // WHY: maps the domain value type to a display-only model so DiaryFeature
    // never needs to import domain or persistence types.
    private func makeDiaryEntryItem(from entry: DiaryEntry) -> DiaryEntryItem {
        DiaryEntryItem(
            id: entry.id,
            text: entry.text,
            dateLabel: Self.dateLabelFormatter.string(from: entry.createdAt)
        )
    }

    // WHY: builds a set of date strings so the heatmap can check membership
    // in O(1) rather than scanning the full entries array per cell.
    private func buildActiveDayKeys(from entries: [DiaryEntry]) -> Set<String> {
        Set(entries.map { Self.dayKeyFormatter.string(from: $0.createdAt) })
    }

    // WHY: resolves the domain entry by id before deletion so the view layer
    // only passes an opaque identifier — not a domain type.
    private func deleteEntryMatchingID(_ id: UUID) {
        guard let entry: DiaryEntry = appStore.state.entries.first(where: { $0.id == id }) else { return }
        appStore.deleteEntry(entry)
    }
}
