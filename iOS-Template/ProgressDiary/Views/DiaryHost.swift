import SwiftUI
import DiaryFeature

struct DiaryHost: View {
    @StateObject private var viewStore: DiaryViewStore

    init(appStore: AppStore) {
        _viewStore = StateObject(wrappedValue: DiaryViewStore(appStore: appStore))
    }

    var body: some View {
        DiaryView(model: viewStore)
    }
}
