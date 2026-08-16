import Combine
import Foundation

protocol DiaryEntryRepository {
    var entriesPublisher: AnyPublisher<[DiaryEntry], Never> { get }
    func addEntry(text: String)
    func deleteEntry(_ entry: DiaryEntry)
}
