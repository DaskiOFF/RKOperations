import XCTest
import RKOperations

final class RKOperationsTests: XCTestCase {
    func test_SingleOperation() {
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
        
        queue.addOperation(op)
        
        wait(for: [expectation], timeout: 1)
        XCTAssertEqual(operationResultInfo, op.testInfo)
    }
    
    func test_CancelledOperation_BeforeAddingToQueue() {
        let expectation = XCTestExpectation(description: "Operation finished")
        let queue = RKOperationQueue()
        let op = TestOperation()
        let operationResultInfo = TestOperation.TestInfo(
            executeWasCalled: false,
            executeWasCalledTimes: 0,
            finishedWasCalled: true,
            finishedWasCalledTimes: 1,
            finishedWasCalledErrors: [[TestOperation.TestError.cancelled]]
        )
        op.add { expectation.fulfill() }
        
        op.cancelWithError(error: TestOperation.TestError.cancelled)
        queue.addOperation(op)
        
        wait(for: [expectation], timeout: 1)
        XCTAssertEqual(operationResultInfo, op.testInfo)
    }
    
    func test_CancelledOperation_AfterAddingToQueue() {
        let expectation = XCTestExpectation(description: "Operation finished")
        let queue = RKOperationQueue()
        let op = TestOperation(timeout: 0.5)
        let operationResultInfo = TestOperation.TestInfo(
            executeWasCalled: false,
            executeWasCalledTimes: 0,
            finishedWasCalled: true,
            finishedWasCalledTimes: 1,
            finishedWasCalledErrors: [[TestOperation.TestError.cancelled]]
        )
        op.add { expectation.fulfill() }
        
        queue.addOperation(op)
        op.cancelWithError(error: TestOperation.TestError.cancelled)
        
        wait(for: [expectation], timeout: 1)
        XCTAssertEqual(operationResultInfo, op.testInfo)
    }
    
    func test_TwoOperations_whereOp2DependenceFromOp1() {
        let expectationOp1 = XCTestExpectation(description: "Operation1 finished")
        let expectationOp2 = XCTestExpectation(description: "Operation2 finished")
        let queue = RKOperationQueue()
        let op1 = TestOperation()
        let op2 = TestOperation()
        let operationResultInfo = TestOperation.TestInfo(
            executeWasCalled: true,
            executeWasCalledTimes: 1,
            finishedWasCalled: true,
            finishedWasCalledTimes: 1,
            finishedWasCalledErrors: [[TestOperation.TestError.testError]]
        )
        
        var op1FinishedTime: Int64 = 0
        var op2FinishedTime: Int64 = 0
        op1.add {
            op1FinishedTime = Int64(Date().timeIntervalSince1970 * 1000)
            expectationOp1.fulfill()
        }
        op2.add {
            op2FinishedTime = Int64(Date().timeIntervalSince1970 * 1000)
            expectationOp2.fulfill()
        }
        op2.addDependency(op1)
        
        queue.addOperation(op1)
        queue.addOperation(op2)
        
        wait(for: [expectationOp1, expectationOp2], timeout: 1)
        
        XCTAssertEqual(operationResultInfo, op1.testInfo)
        XCTAssertEqual(operationResultInfo, op2.testInfo)
        XCTAssertLessThan(op1FinishedTime, op2FinishedTime)
    }
}
