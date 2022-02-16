import XCTest
import RKOperations

final class RKOperationsConditionsTests: XCTestCase {
    func test_RKOperation_MutuallyExclusiveCondition() {
        let queue = RKOperationQueue()
        let condition = MutuallyExclusive<TestOperation>()
        let operationResultInfo = TestOperation.TestInfo(
            executeWasCalled: true,
            executeWasCalledTimes: 1,
            finishedWasCalled: true,
            finishedWasCalledTimes: 1,
            finishedWasCalledErrors: [[TestOperation.TestError.testError]]
        )
        
        var finishTimes: [Int64] = [0, 0]
        let expectation1 = XCTestExpectation(description: "Operation1 finished")
        let op = TestOperation()
        op.add(condition: condition)
        op.add {
            finishTimes[0] = Int64(Date().timeIntervalSince1970 * 1000)
            expectation1.fulfill()
        }
        
        let expectation2 = XCTestExpectation(description: "Operation1 finished")
        let op1 = TestOperation()
        op1.add(condition: condition)
        op1.add {
            finishTimes[1] = Int64(Date().timeIntervalSince1970 * 1000)
            expectation2.fulfill()
        }
        
        queue.addOperations([op, op1], waitUntilFinished: false)
        wait(for: [expectation1, expectation2], timeout: 1)
        
        XCTAssertLessThan(finishTimes[0], finishTimes[1])
        
        XCTAssertEqual(operationResultInfo, op.testInfo)
        XCTAssertEqual(operationResultInfo, op1.testInfo)
    }
    
    func test_RKOperation_FailedCondition() {
        let queue = RKOperationQueue()
        let condition = FailedCondition()
        let operationResultInfo = TestOperation.TestInfo(
            executeWasCalled: false,
            executeWasCalledTimes: 0,
            finishedWasCalled: true,
            finishedWasCalledTimes: 1,
            finishedWasCalledErrors: [[TestOperation.TestError.condition]]
        )
        
        let expectation = XCTestExpectation(description: "Operation1 finished")
        let op = TestOperation()
        op.add(condition: condition)
        op.add { expectation.fulfill() }
        
        queue.addOperations([op], waitUntilFinished: false)
        wait(for: [expectation], timeout: 1)
        
        XCTAssertEqual(operationResultInfo, op.testInfo)
    }
}
