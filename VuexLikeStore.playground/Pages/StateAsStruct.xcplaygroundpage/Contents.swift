//: [Previous](@previous)

protocol State {}

protocol Mutation {
    associatedtype S: State
    static func commit(mutation: Self, state: inout S)
}

struct Store<S: State, M: Mutation> {
    private(set) var state: S
    private var _commit: (M, inout S) -> Void
    
    mutating func commit(_ mutation: M) {
        self._commit(mutation, &state)
    }
    
    init(state: S, commit: @escaping (M, inout S) -> Void) {
        self.state = state
        self._commit = commit
    }
    
}

struct ExampleState: State {
    var count = 0
    var isOn = false
}

enum ExampleMutation: Mutation {

    case increment
    case setTo(Int)
    case toggle

    static func commit(mutation: Self, state: inout ExampleState) {
        switch mutation {
        case .increment:
            state.count += 1
        case .setTo(let setTo):
            state.count = setTo
        case .toggle:
            state.isOn = !state.isOn
        }
    }
}


var myState = ExampleState()

var myStore = Store(state: myState, commit: ExampleMutation.commit)
print(myStore.state)

myStore.commit(.increment)
print(myStore.state)

myStore.commit(.setTo(10))
print(myStore.state)

myStore.commit(.toggle)
print(myStore.state)

//: [ Next ] (@next)
