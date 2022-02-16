import Foundation.NSOperation

public extension Operation {
    /// Add completion block
    /// - Parameter block: Additional completiion block
    func add(completion block: @escaping () -> Void) {
        if let completion = completionBlock {
            completionBlock = {
                completion()
                block()
            }
        } else {
            completionBlock = block
        }
    }
}
