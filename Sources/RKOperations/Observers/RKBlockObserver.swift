import Foundation

public class RKBlockObserver: RKOperationObserver {
    public typealias StartHandler = (_ operation: RKOperation) -> Void
    public typealias ProduceHandler = (_ operation: RKOperation, _ newOperation: Operation) -> Void
    public typealias FinishHandler = (_ operation: RKOperation, _ errors: [Error]) -> Void
    
    private let start: StartHandler
    private let produce: ProduceHandler
    private let finish: FinishHandler
    
    public init(
        start: StartHandler? = nil,
        produce: ProduceHandler? = nil,
        finish: FinishHandler? = nil
    ) {
        self.start = start ?? { _ in }
        self.produce = produce ?? { _, _ in }
        self.finish = finish ?? { _, _ in }
    }
    
    public func operationDidStart(operation: RKOperation) {
        start(operation)
    }
    
    public func operation(operation: RKOperation, didProduceNewOperation newOperation: Operation) {
        produce(operation, newOperation)
    }
    
    public func operationDidFinish(operation: RKOperation, errors: [Error]) {
        finish(operation, errors)
    }
}
