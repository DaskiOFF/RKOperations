import Foundation

precedencegroup CompositionPrecedence {
    associativity: left
    higherThan: BitwiseShiftPrecedence
}
infix operator <- : CompositionPrecedence

@discardableResult
public func <- (l: Operation, r: Operation) -> Operation {
    r.addDependency(l)
    return r
}

@discardableResult
public func <- (l: Operation, r: [Operation]) -> [Operation] {
    r.forEach { $0.addDependency(l) }
    return r
}

@discardableResult
public func <- (l: [Operation], r: Operation) -> Operation {
    l.forEach { r.addDependency($0) }
    return r
}
