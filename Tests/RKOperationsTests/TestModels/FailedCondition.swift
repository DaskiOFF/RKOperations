import Foundation.NSOperation
import RKOperations

struct FailedCondition: RKOperationCondition {
    public var name: String {
        "FailedCondition"
    }
    
    public var isMutuallyExclusive: Bool {
        false
    }
    
    public init() { }
    
    public func dependency(for operation: RKOperation) -> Operation? {
        nil
    }
    
    public func evaluate(for operation: RKOperation, completion: @escaping (RKOperationConditionResult) -> Void) {
        completion(.failed(error: TestOperation.TestError.condition))
    }
}
