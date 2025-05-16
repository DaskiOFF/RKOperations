import XCTest
import RKOperations

final class RKOperationsObserverTests: XCTestCase {
    func test_RKOperationObserver() {
        let expectation = XCTestExpectation(description: "Operation finished")
        let queue = RKOperationQueue()
        let observer = RKOperationObserverMock()
        let op = TestOperation()
        let operationResultInfo = TestOperation.TestInfo(
            executeWasCalled: true,
            executeWasCalledTimes: 1,
            finishedWasCalled: true,
            finishedWasCalledTimes: 1,
            finishedWasCalledErrors: [[TestOperation.TestError.testError]]
        )
        op.add(observer: observer.blockObserver)
        op.add { expectation.fulfill() }
        
        queue.addOperations([op], waitUntilFinished: false)
        
        wait(for: [expectation], timeout: 1)
        
        XCTAssertTrue(observer.operationDidStartCalled, "Observer's didStart must be called")
        XCTAssertEqual(1, observer.operationDidStartCalledTimes)
        XCTAssertEqual(1, observer.operationDidStartCalledArgs.count)
        XCTAssertEqual(op, observer.operationDidStartCalledArgs[0])
        
        XCTAssertTrue(observer.operationDidFinishCalled, "Observer's didFinish must be called")
        XCTAssertEqual(1, observer.operationDidFinishCalledTimes)
        XCTAssertEqual(1, observer.operationDidFinishCalledArgs.count)
        XCTAssertEqual(op, observer.operationDidFinishCalledArgs[0].operation)
        XCTAssertEqual(1, observer.operationDidFinishCalledArgs[0].errors.count)
        if let error = observer.operationDidFinishCalledArgs[0].errors[0] as? TestOperation.TestError {
            XCTAssert(error == .testError)
        } else {
            XCTFail()
        }
        
        XCTAssertEqual(operationResultInfo, op.testInfo)
    }
}
