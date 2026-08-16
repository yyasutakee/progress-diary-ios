import Combine

class AppStore: Store<AppState> {
    private let diaryEntryRepository: any DiaryEntryRepository
    private var cancellables: Set<AnyCancellable> = Set<AnyCancellable>()

    init(diaryEntryRepository: some DiaryEntryRepository) {
        self.diaryEntryRepository = diaryEntryRepository
        super.init(initialState: AppState())
        observeEntries()
    }

    // WHY: mirrors the repository's published list into state so every observing view
    // stays reactive to inserts and deletes without touching the repository directly.
    private func observeEntries() {
        diaryEntryRepository.entriesPublisher
            .sink { [weak self] newEntries in
                guard let self else { return }
                self.setState { $0.entries = newEntries }
            }
            .store(in: &cancellables)
    }
}

extension AppStore {
    // WHY: the store is the single door to persistence; views must not reach into the repository.
    func addEntry(text: String) {
        diaryEntryRepository.addEntry(text: text)
    }

    // WHY: routes deletion through the store so the view layer stays unaware of persistence types.
    func deleteEntry(_ entry: DiaryEntry) {
        diaryEntryRepository.deleteEntry(entry)
    }
}
