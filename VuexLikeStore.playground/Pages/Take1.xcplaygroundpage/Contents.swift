typealias State = [String: Any]
typealias Action = (_ payload: Any?) -> Void
typealias Mutation = (_: inout State, _ payload: Any?) -> Void

protocol StoreFunctionality {
    var state: State { get }
    var mutations: [String: Mutation] { get }
    var actions: [String: Action] { get }
    
    
    func dispatch(_ name: String, _ payload: Any?) -> Void
    mutating func commit(_ name: String, _ payload: Any?) -> Void
}

struct Store: StoreFunctionality {
    private var _state: State
    private var _getters: [String: (State) -> Any]
    
    var state: State { _state }
    var getters: [String: Any] {
        var getterList: [String: Any] = [:]
        for (name, getter) in self._getters {
            getterList[name] = getter(self._state)
        }
        return getterList
    }
    
    var mutations: [String : Mutation] = [:]
    var actions: [String : Action] = [:]
    
    init(_ state: State, getters: [String: (State) -> Any] = [:], mutations: [String: Mutation] = [:], actions: [String: Action] = [:]) {
        self._state = state
        self._getters = getters
        self.mutations = mutations
        self.actions = actions
    }
    
    func dispatch(_ name: String, _ payload: Any? = nil) {
        if let action = self.actions[name] {
            action(payload)
        }
    }
    mutating func commit(_ name: String, _ payload: Any? = nil) {
        if let mutation = self.mutations[name] {
            mutation(&self._state, payload)
        }
    }
}

// Stuff to try

let state = ["count": 2]
let getters: [String: (State) -> Any] = [
    "doubleCount": { (state: State) in (state["count"] as! Int) * 2 }
]
let mutations = [
    "increment": { (state: inout State, payload: Any?) in
        state["count"] = state["count"] as! Int + 1
    },
    "setTo": { (state: inout State, payload: Any?) in
        state.updateValue(payload as! Int, forKey: "count")
    }
]

var myStore = Store(state, getters: getters, mutations: mutations)
print(myStore.state["count"] as Any)
print(myStore.getters["doubleCount"] as Any)
myStore.commit("increment")
print(myStore.state["count"] as Any)
myStore.commit("setTo", 20)
print(myStore.state["count"] as Any)

print(myStore.state)
print(myStore.getters)
