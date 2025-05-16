import Foundation

/// Default class for operations
///
/// Override
/// - Required:
///     - `execute()`
///
/// - Optional:
///     - `finished(with errors: [Error])`
open class RKOperation: Operation, @unchecked Sendable {
    final public override class func keyPathsForValuesAffectingValue(forKey key: String) -> Set<String> {
        if ["isFinished", "isExecuting", "isReady"].contains(key) {
            return ["state"]
        }
        return super.keyPathsForValuesAffectingValue(forKey: key)
    }
    
    private var _internalErrors = SafeArray<Error>()
    
    public final var userInitiated: Bool {
        get { qualityOfService == .userInitiated }
        set {
            assert(state < .executing, "Cannot modify userInitiated after execution has begun.")
            qualityOfService = newValue ? .userInitiated : .default
        }
    }
    
    public final func produce(operation: Operation) {
        observers.forEach { $0.operation(operation: self, didProduceNewOperation: operation) }
    }
    
    // MARK: - Conditions
    
    public private(set) var conditions: [RKOperationCondition] = []
    public final func add(condition: RKOperationCondition) {
        assert(state < .evaluatingConditions)
        conditions.append(condition)
    }
    
    private func evaluateConditions() {
        guard state == .pending && !isCancelled else { return }
        
        state = .evaluatingConditions
                
        RKOperationConditionEvaluator.evaluate(conditions: conditions, for: self) { errors in
            self._internalErrors.append(contentsOf: errors)
            self.state = .ready
        }
    }
    
    // MARK: - Observers
    
    public private(set) var observers: [RKOperationObserver] = []
    public final func add(observer: RKOperationObserver) {
        assert(state < .executing)
        observers.append(observer)
    }
    
    // MARK: - Main and execute
    
    public final override func main() {
        assert(state == .ready)
        
        guard _internalErrors.isEmpty && !isCancelled else {
            finish()
            return
        }
        state = .executing
        
        observers.forEach { $0.operationDidStart(operation: self) }
        
        execute()
    }
    
    open func execute() {
        finish()
    }
    
    // MARK: - Start, cancel and finish
    
    public final override func start() {
        super.start()
        
        if isCancelled {
            finish()
        }
    }
    
    public final func cancelWithError(error: Error?) {
        if let error = error {
            _internalErrors.append(error)
        }
        
        cancel()
    }
    
    public final func finish(with error: Error?) {
        if let error = error {
            finish(with: [error])
        } else {
            finish()
        }
    }
    
    private var hasFinishedAlready = false
    public final func finish(with errors: [Error] = []) {
        guard !hasFinishedAlready else { return }
        hasFinishedAlready = true
        state = .finishing
        
        let combinedErrors = _internalErrors.elements + errors
        finished(with: combinedErrors)
        
        observers.forEach { $0.operationDidFinish(operation: self, errors: combinedErrors) }
        
        state = .finished
    }
    
    open func finished(with errors: [Error]) { }
    
    // MARK: - State
    
    private let stateLock = NSLock()
    private var _state = State.initialized
    private var state: State {
        get { stateLock.withCriticalScope { _state } }
        set(newState) {
            willChangeValue(forKey: "state")
            stateLock.withCriticalScope {
                if _state != .finished && _state != newState {
                    if _state.canTransitionToState(target: newState) {
                        _state = newState
                    } else {
                        #if DEBUG
                        print("[RK Operation] [\(self.name ?? "")] Change state (\(_state)) -> (\(newState))")
                        #endif
                    }
                }
            }
            didChangeValue(forKey: "state")
        }
    }
    
    public final override var isReady: Bool {
        switch state {
        case .initialized:
            return isCancelled
        case .pending:
            if isCancelled { return true }
            if super.isReady { evaluateConditions() }
            return false
        case .ready:
            return super.isReady || isCancelled
        default:
            return false
        }
    }
    
    public final override var isExecuting: Bool {
        state == .executing
    }
    
    public final override var isFinished: Bool {
        state == .finished
    }
    
    func willEnqueue() {
        state = .pending
    }
}

extension RKOperation {
    open override var name: String? {
        set { super.name = newValue }
        get { super.name ?? "\(Self.self)" }
    }
}

private final class SafeArray<T> {
    private let syncErrorsQueue = DispatchQueue(label: "RKOperations.SyncErrorQueue", qos: .utility)
    private var values: [T] = []
    
    func append(_ newElement: T) {
        syncErrorsQueue.async {
            self.values.append(newElement)
        }
    }
    
    func append(contentsOf newElements: [T]) {
        syncErrorsQueue.async {
            self.values.append(contentsOf: newElements)
        }
    }
    
    var elements: [T] {
        syncErrorsQueue.sync {
            values
        }
    }
    
    var isEmpty: Bool {
        syncErrorsQueue.sync {
            values.isEmpty
        }
    }
}
