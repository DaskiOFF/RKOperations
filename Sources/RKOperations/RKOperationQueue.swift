import Foundation

public protocol RKOperationQueueDelegate: AnyObject {
    func operationQueue(_ queue: OperationQueue, willAddOperation operation: Operation)
    func operationQueue(_ queue: OperationQueue, operationDidFinish operation: Operation, errors: [Error])
}

public class RKOperationQueue: OperationQueue, @unchecked Sendable {
    public weak var delegate: RKOperationQueueDelegate?
    
    /// Initialize new instance of RKOperationQueue with quality of service
    /// - Parameter qualityOfService: QualityOfService value. Default is .utility
    public init(qualityOfService: QualityOfService = .utility) {
        super.init()
        self.qualityOfService = qualityOfService
    }
        
    public override func addOperation(_ op: Operation) {
        if let op = op as? RKOperation {
            setupObserver(for: op)
            setupDependencies(for: op)
            setupMutualState(for: op)
            
            op.willEnqueue()
        } else {
            op.add { [weak self, weak op] in
                guard let self = self, let op = op else { return }
                self.delegate?.operationQueue(self, operationDidFinish: op, errors: [])
            }
        }
        
        delegate?.operationQueue(self, willAddOperation: op)
        super.addOperation(op)
    }
    
    public override func addOperations(_ ops: [Operation], waitUntilFinished wait: Bool) {
        ops.forEach(addOperation)
        
        if wait {
            ops.forEach { $0.waitUntilFinished() }
        }
    }
}

// MARK: - Private

private extension RKOperationQueue {
    func setupObserver(for op: RKOperation) {
        let observer = RKBlockObserver(
            start: nil,
            produce: { [weak self] _, newOperation in
                self?.addOperation(newOperation)
            },
            finish: { [weak self] operation, errors in
                guard let self = self else { return }
                self.delegate?.operationQueue(self, operationDidFinish: operation, errors: errors)
            }
        )
        op.add(observer: observer)
    }
    
    func setupDependencies(for op: RKOperation) {
        op.conditions.compactMap { $0.dependency(for: op) }.forEach { dependency in
            op.addDependency(dependency)
            addOperation(dependency)
        }
    }
    
    func setupMutualState(for op: RKOperation) {
        let categories = op.conditions.compactMap { condition in
            condition.isMutuallyExclusive ? condition.name : nil
        }
        guard !categories.isEmpty else { return }
        
        let exclusivityController = ExclusivityController.shared
        exclusivityController.add(operation: op, categories: categories)
        
        op.add(observer: RKBlockObserver(finish: { operation, _ in
            exclusivityController.remove(operation: operation, categories: categories)
        }))
    }
}
