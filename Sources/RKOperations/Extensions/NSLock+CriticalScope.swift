import Foundation.NSLock

extension NSLock {
    func withCriticalScope<T>(block: () -> T) -> T {
        lock()
        let value = block()
        unlock()
        return value
    }
}
