import Foundation

public struct MutuallyExclusive<T>: RKOperationCondition {
    public var name: String {
        "MutuallyExclusive<\(T.self)>"
    }
    
    public let isMutuallyExclusive = true
    
    public init() { }
    
    public func dependency(for operation: RKOperation) -> Operation? {
        nil
    }
    
    public func evaluate(for operation: RKOperation, completion: @escaping (RKOperationConditionResult) -> Void) {
        completion(.satisfied)
    }
}
