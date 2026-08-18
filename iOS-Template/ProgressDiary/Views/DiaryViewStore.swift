import Combine
import Foundation
import DiaryFeature

@MainActor
final class DiaryViewStore: DiaryViewModel {
    @Published private(set) var lists: [DiaryListItem] = []
    @Published private(set) var entriesByListID: [UUID: [DiaryEntryItem]] = [:]
    @Published private(set) var activeDayKeysByListID: [UUID: Set<String>] = [:]
    @Published private(set) var selectedListID: UUID? = nil
    @Published private(set) var currentListName: String = ""
    @Published private(set) var editingListID: UUID? = nil
    @Published var isShowingAddEntry: Bool = false
    @Published var isShowingAddList: Bool = false
    @Published var isShowingListSettings: Bool = false
    @Published var isShowingDeleteListConfirmation: Bool = false

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

    // WHY: the view store owns only the feature-facing projection while AppStore remains the shared state owner.
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
            guard let selectedListID else { return }
            appStore.addEntry(text: text, to: selectedListID)
            isShowingAddEntry = false
        case .deleteEntry(let id):
            deleteEntryMatchingID(id)
        case .listSelected(let id):
            appStore.selectList(id)
        case .addListTapped:
            isShowingAddList = true
        case .listNameSubmitted(let name):
            appStore.addList(name: name)
            isShowingAddList = false
        case .deleteList(let id):
            deleteListMatchingID(id)
        case .listSettingsTapped(let id):
            editingListID = id
            isShowingListSettings = true
        case .heatmapColorSelected(let colorID):
            guard let editingListID else { return }
            appStore.updateListHeatmapColor(listID: editingListID, colorID: colorID)
            isShowingListSettings = false
        case .deleteCurrentListRequested:
            isShowingDeleteListConfirmation = true
        case .deleteCurrentListConfirmed:
            guard let selectedListID else { return }
            deleteListMatchingID(selectedListID)
            isShowingDeleteListConfirmation = false
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
        lists = state.lists.map(makeDiaryListItem)
        entriesByListID = buildEntriesByListID(from: state.entries)
        activeDayKeysByListID = buildActiveDayKeysByListID(from: state.entries)
        selectedListID = state.selectedListID
        currentListName = makeCurrentListName(from: state)
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

    // WHY: maps list names into the package-owned shape so persistence identifiers stay outside the feature package.
    private func makeDiaryListItem(from list: DiaryList) -> DiaryListItem {
        DiaryListItem(id: list.id, name: list.name, heatmapColorID: list.heatmapColorID)
    }

    // WHY: keeps the navigation label derived from the same state snapshot as the selected page.
    private func makeCurrentListName(from state: AppState) -> String {
        guard let selectedListID = state.selectedListID,
              let selectedList = state.lists.first(where: { $0.id == selectedListID }) else { return "Progress Diary" }
        return selectedList.name
    }

    // WHY: builds a set of date strings so the heatmap can check membership
    // in O(1) rather than scanning the full entries array per cell.
    private func buildActiveDayKeys(from entries: [DiaryEntry]) -> Set<String> {
        Set(entries.map { Self.dayKeyFormatter.string(from: $0.createdAt) })
    }

    // WHY: grouping once lets each page render its own entries without repeatedly scanning the complete domain collection.
    private func buildEntriesByListID(from entries: [DiaryEntry]) -> [UUID: [DiaryEntryItem]] {
        Dictionary(grouping: entries, by: { $0.listID }).mapValues { $0.map(makeDiaryEntryItem) }
    }

    // WHY: each heatmap needs only the dates belonging to its page, keeping list navigation and calendar state aligned.
    private func buildActiveDayKeysByListID(from entries: [DiaryEntry]) -> [UUID: Set<String>] {
        Dictionary(grouping: entries, by: { $0.listID }).mapValues { buildActiveDayKeys(from: $0) }
    }

    // WHY: resolves the domain entry by id before deletion so the view layer
    // only passes an opaque identifier — not a domain type.
    private func deleteEntryMatchingID(_ id: UUID) {
        guard let entry: DiaryEntry = appStore.state.entries.first(where: { $0.id == id }) else { return }
        appStore.deleteEntry(entry)
    }

    // WHY: resolving the selected domain list here keeps deletion events opaque to the feature package.
    private func deleteListMatchingID(_ id: UUID) {
        guard let list: DiaryList = appStore.state.lists.first(where: { $0.id == id }) else { return }
        appStore.deleteList(list)
    }
}
