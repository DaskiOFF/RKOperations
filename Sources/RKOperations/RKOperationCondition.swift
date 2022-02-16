import Foundation

public protocol RKOperationCondition {
    var name: String { get }
    var isMutuallyExclusive: Bool { get }
    func dependency(for operation: RKOperation) -> Operation?
    func evaluate(for operation: RKOperation, completion: @escaping (RKOperationConditionResult) -> Void)
}

// MARK: - Result

public enum RKOperationConditionResult {
    case satisfied
    case failed(error: Error)
}

extension RKOperationConditionResult {
    var error: Error? {
        if case .failed(let error) = self {
            return error
        } else {
            return nil
        }
    }
}

// MARK: - Evaluator

enum RKOperationConditionEvaluator {
    typealias Completion = ([Error]) -> Void
    static func evaluate(
        conditions: [RKOperationCondition],
        for operation: RKOperation,
        completion: @escaping Completion
    ) {
        let group = DispatchGroup()
        
        var results = [RKOperationConditionResult?](repeating: nil, count: conditions.count)
        for (index, condition) in conditions.enumerated() {
            group.enter()
            condition.evaluate(for: operation) { result in
                results[index] = result
                group.leave()
            }
        }
        
        group.notify(queue: DispatchQueue.global()) {
            completion(results.compactMap(\.?.error))
        }
    }
}

// MARK: - ExclusivityController

class ExclusivityController {
    static let shared = ExclusivityController()
    
    private let serialQueue = DispatchQueue(label: "RKOperations.ExclusivityController")
    private var operations: [String: [Operation]] = [:]
    
    private init() { }
    
    func add(operation: Operation, categories: [String]) {
        serialQueue.sync {
            for category in categories {
                self.noqueue_add(operation: operation, category: category)
            }
        }
    }
    
    func remove(operation: Operation, categories: [String]) {
        serialQueue.async {
            for category in categories {
                self.noqueue_remove(operation: operation, category: category)
            }
        }
    }
    
    // MARK: Operation Management
    
    private func noqueue_add(operation: Operation, category: String) {
        var operationsWithThisCategory = operations[category] ?? []
        
        if let last = operationsWithThisCategory.last {
            operation.addDependency(last)
        }
        
        operationsWithThisCategory.append(operation)
        operations[category] = operationsWithThisCategory
    }
    
    private func noqueue_remove(operation: Operation, category: String) {
        let matchingOperations = operations[category]
        
        if var operationsWithThisCategory = matchingOperations,
           let index = operationsWithThisCategory.firstIndex(of: operation) {
            
            operationsWithThisCategory.remove(at: index)
            operations[category] = operationsWithThisCategory
        }
    }
    
}
