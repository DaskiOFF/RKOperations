extension RKOperation {
    enum State: Int {
        case initialized
        case pending
        case evaluatingConditions
        case ready
        case executing
        case finishing
        case finished
    }
}

extension RKOperation.State {
    func canTransitionToState(target: RKOperation.State) -> Bool {
        switch (self, target) {
        case (.initialized, .pending),
             (.pending, .evaluatingConditions),
             (.pending, .finishing),
             (.evaluatingConditions, .ready),
             (.ready, .executing),
             (.ready, .finishing),
             (.executing, .finishing),
             (.finishing, .finished):
            return true
        default:
            return false
        }
    }
}

func <(lhs: RKOperation.State, rhs: RKOperation.State) -> Bool {
    return lhs.rawValue < rhs.rawValue
}

func ==(lhs: RKOperation.State, rhs: RKOperation.State) -> Bool {
    return lhs.rawValue == rhs.rawValue
}
