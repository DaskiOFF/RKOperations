import Foundation

public protocol RKOperationObserver {
    func operationDidStart(operation: RKOperation)
    func operation(operation: RKOperation, didProduceNewOperation newOperation: Operation)
    func operationDidFinish(operation: RKOperation, errors: [Error])
}
