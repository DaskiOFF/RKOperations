import XCTest
import RKOperations

final class RKOperationsQueueTests: XCTestCase {
    func test_OperationQueue_AddOperations_WaitUntilFinished_FALSE() {
        let expectation = XCTestExpectation(description: "Operation finished")
        let queue = RKOperationQueue()
        let op = TestOperation()
        let operationResultInfo = TestOperation.TestInfo(
            executeWasCalled: true,
            executeWasCalledTimes: 1,
            finishedWasCalled: true,
            finishedWasCalledTimes: 1,
            finishedWasCalledErrors: [[TestOperation.TestError.testError]]
        )
        op.add { expectation.fulfill() }
        
        queue.addOperations([op], waitUntilFinished: false)
        
        wait(for: [expectation], timeout: 1)
        XCTAssertEqual(operationResultInfo, op.testInfo)
    }
    
    func test_OperationQueue_AddOperations_WaitUntilFinished_TRUE() {
        let queue = RKOperationQueue()
        let op = TestOperation()
        let operationResultInfo = TestOperation.TestInfo(
            executeWasCalled: true,
            executeWasCalledTimes: 1,
            finishedWasCalled: true,
            finishedWasCalledTimes: 1,
            finishedWasCalledErrors: [[TestOperation.TestError.testError]]
        )
        var completionWasCalled = false
        op.add { completionWasCalled = true }
        
        queue.addOperations([op], waitUntilFinished: true)
        
        XCTAssertTrue(completionWasCalled)
        XCTAssertEqual(operationResultInfo, op.testInfo)
    }
    
    func test_OperationQueueDelegate_RKOperation() {
        let expectation = XCTestExpectation(description: "Operation finished")
        let queue = RKOperationQueue()
        let delegate = RKOperationQueueDelegateMock()
        queue.delegate = delegate
        let op = TestOperation()
        op.add { expectation.fulfill() }
        
        queue.addOperation(op)
        
        wait(for: [expectation], timeout: 1)
        XCTAssertTrue(delegate.willAddOperationCalled)
        XCTAssertEqual(1, delegate.willAddOperationCalledTimes)
        XCTAssertEqual(1, delegate.willAddOperationCalledArgs.count)
        XCTAssert(queue === delegate.willAddOperationCalledArgs[0].queue)
        XCTAssert(op === delegate.willAddOperationCalledArgs[0].operation)
        
        XCTAssertTrue(delegate.operationDidFinishCalled)
        XCTAssertEqual(1, delegate.operationDidFinishCalledTimes)
        XCTAssertEqual(1, delegate.operationDidFinishCalledArgs.count)
        XCTAssert(queue === delegate.operationDidFinishCalledArgs[0].queue)
        XCTAssert(op === delegate.operationDidFinishCalledArgs[0].operation)
        
    }
    
    func test_OperationQueueDelegate_Operation() {
        let expectation = XCTestExpectation(description: "Operation finished")
        let queue = RKOperationQueue()
        let delegate = RKOperationQueueDelegateMock()
        queue.delegate = delegate
        let op = BlockOperation { }
        op.add { expectation.fulfill() }
        
        queue.addOperation(op)
        
        wait(for: [expectation], timeout: 1)
        XCTAssertTrue(delegate.willAddOperationCalled)
        XCTAssertEqual(1, delegate.willAddOperationCalledTimes)
        XCTAssertEqual(1, delegate.willAddOperationCalledArgs.count)
        XCTAssert(queue === delegate.willAddOperationCalledArgs[0].queue)
        XCTAssert(op === delegate.willAddOperationCalledArgs[0].operation)
        
        XCTAssertTrue(delegate.operationDidFinishCalled)
        XCTAssertEqual(1, delegate.operationDidFinishCalledTimes)
        XCTAssertEqual(1, delegate.operationDidFinishCalledArgs.count)
        XCTAssert(queue === delegate.operationDidFinishCalledArgs[0].queue)
        XCTAssert(op === delegate.operationDidFinishCalledArgs[0].operation)
        
    }
}
