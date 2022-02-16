import Foundation
import RKOperations

class TestOperation: RKOperation {
    enum TestError: Error {
        case testError
        case condition
        case cancelled
    }
    
    let timeout: TimeInterval
    private(set) var testInfo = TestInfo()
    init(timeout: TimeInterval = 0.1) {
        self.timeout = timeout
    }
    
    override func execute() {
        testInfo.executeWasCalled = true
        testInfo.executeWasCalledTimes += 1
        DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + timeout) {
            self.finish(with: TestError.testError)
        }
    }
    
    override func finished(with errors: [Error]) {
        testInfo.finishedWasCalled = true
        testInfo.finishedWasCalledTimes += 1
        testInfo.finishedWasCalledErrors.append(errors)
    }
}

extension TestOperation {
    struct TestInfo: Equatable {
        fileprivate(set) var executeWasCalled = false
        fileprivate(set) var executeWasCalledTimes = 0
        fileprivate(set) var finishedWasCalled = false
        fileprivate(set) var finishedWasCalledTimes = 0
        fileprivate(set) var finishedWasCalledErrors: [[Error]] = []
        
        static func == (lhs: Self, rhs: Self) -> Bool {
            lhs.executeWasCalled == rhs.executeWasCalled &&
            lhs.executeWasCalledTimes == rhs.executeWasCalledTimes &&
            lhs.finishedWasCalled == rhs.finishedWasCalled &&
            lhs.finishedWasCalledTimes == rhs.finishedWasCalledTimes &&
            lhs.finishedWasCalledErrors as [[NSError]] == rhs.finishedWasCalledErrors as [[NSError]]
        }
    }
}
