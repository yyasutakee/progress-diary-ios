import SwiftUI
import Combine

class Store<State>: ObservableObject {
    private(set) var state: State

    let didChange: PassthroughSubject<State, Never> = PassthroughSubject<State, Never>()

    init(initialState: State) {
        self.state = initialState
    }

    // WHY: manual objectWillChange.send() avoids the compiler crash that @Published triggers in generic
    // ObservableObject subclasses; the inout closure is the single funnel every mutation passes through.
    func setState(_ mutation: (inout State) -> Void) {
        objectWillChange.send()
        mutation(&state)
        didChange.send(state)
    }

    deinit {}
}
