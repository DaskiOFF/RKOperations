import Foundation
import RKOperations

class RKOperationQueueDelegateMock: RKOperationQueueDelegate {
    private(set) var willAddOperationCalled = false
    private(set) var willAddOperationCalledTimes = 0
    private(set) var willAddOperationCalledArgs: [(queue: OperationQueue, operation: Operation)] = []
    func operationQueue(_ queue: OperationQueue, willAddOperation operation: Operation) {
        willAddOperationCalled = true
        willAddOperationCalledTimes += 1
        willAddOperationCalledArgs.append((queue, operation))
    }
    
    private(set) var operationDidFinishCalled = false
    private(set) var operationDidFinishCalledTimes = 0
    private(set) var operationDidFinishCalledArgs: [(queue: OperationQueue, operation: Operation)] = []
    func operationQueue(_ queue: OperationQueue, operationDidFinish operation: Operation, errors: [Error]) {
        operationDidFinishCalled = true
        operationDidFinishCalledTimes += 1
        operationDidFinishCalledArgs.append((queue, operation))
    }
}
