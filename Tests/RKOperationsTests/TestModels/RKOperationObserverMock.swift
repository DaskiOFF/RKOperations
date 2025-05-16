import Foundation.NSOperation
import RKOperations

final class RKOperationObserverMock {
    private(set) var blockObserver: RKBlockObserver!
    
    init() {
        blockObserver = RKBlockObserver(start: { operation in
            self.operationDidStart(operation: operation)
        }, produce: { operation, newOperation in
            self.operation(operation: operation, didProduceNewOperation: newOperation)
        }, finish: { operation, errors in
            self.operationDidFinish(operation: operation, errors: errors)
        })
    }
    
    private(set) var operationDidStartCalled = false
    private(set) var operationDidStartCalledTimes = 0
    private(set) var operationDidStartCalledArgs: [RKOperation] = []
    private func operationDidStart(operation: RKOperation) {
        operationDidStartCalled = true
        operationDidStartCalledTimes += 1
        operationDidStartCalledArgs.append(operation)
    }
    
    private(set) var operationDidProduceOperationCalled = false
    private(set) var operationDidProduceOperationCalledTimes = 0
    private(set) var operationDidProduceOperationCalledArgs: [(operation: RKOperation, newOperation: Operation)] = []
    private func operation(operation: RKOperation, didProduceNewOperation newOperation: Operation) {
        operationDidProduceOperationCalled = true
        operationDidProduceOperationCalledTimes += 1
        operationDidProduceOperationCalledArgs.append((operation, newOperation))
    }
    
    private(set) var operationDidFinishCalled = false
    private(set) var operationDidFinishCalledTimes = 0
    private(set) var operationDidFinishCalledArgs: [(operation: RKOperation, errors: [Error])] = []
    private func operationDidFinish(operation: RKOperation, errors: [Error]) {
        operationDidFinishCalled = true
        operationDidFinishCalledTimes += 1
        operationDidFinishCalledArgs.append((operation, errors))
    }
}
