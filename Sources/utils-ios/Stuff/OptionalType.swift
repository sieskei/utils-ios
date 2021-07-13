//
//  OptionalType.swift
//  
//
//  Created by Miroslav Yozov on 12.07.21.
//

import Foundation

public protocol OptionalType: ExpressibleByNilLiteral {
    associatedtype Wrapped
    
    var wrapped: Optional<Wrapped> { get }
    init(_ wrapped: Wrapped)
}

public extension OptionalType {
    func map<U>(_ default: U, transform: (Wrapped) throws -> U) rethrows -> U {
        if let wrapped = wrapped {
            return try transform(wrapped)
        } else {
            return `default`
        }
    }
    
    func onValue(_ action: (Wrapped) throws -> Void) rethrows {
        if let value = wrapped {
            try action(value)
        }
    }
}

// MARK: Implement OptionalType.
extension Optional: OptionalType {
    public var wrapped: Optional<Wrapped> { self }
}
