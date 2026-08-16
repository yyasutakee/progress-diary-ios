import SwiftUI
import SwiftData

@main
struct ProgressDiaryApp: App {
    private let modelContainer: ModelContainer
    @StateObject private var appStore: AppStore

    init() {
        let container: ModelContainer
        do {
            container = try ModelContainer(for: DiaryEntryRecord.self)
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
        let repository: SwiftDataDiaryEntryRepository = SwiftDataDiaryEntryRepository(
            modelContext: container.mainContext
        )
        self.modelContainer = container
        _appStore = StateObject(wrappedValue: AppStore(diaryEntryRepository: repository))
    }

    var body: some Scene {
        WindowGroup {
            DiaryHost(appStore: appStore)
        }
    }
}
