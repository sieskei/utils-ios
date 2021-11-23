//
//  Node.swift
//  
//
//  Created by Miroslav Yozov on 18.11.21.
//

import Foundation

public indirect enum Node<T> {
    case value(T, next: Node<T> = .none)
    case none
    
    public var next: Self {
        switch self {
        case .none:
            return .none
        case .value(_, let next):
            return next
        }
    }
    
    public mutating func attach(value v: T) {
        switch self {
        case .none:
            self = .value(v, next: .none)
        case .value(let current, var next):
            next.attach(value: v)
            self = .value(current, next: next)
        }
    }
}

extension Node: CustomStringConvertible {
    public var description: String {
        switch self {
        case .none:
            return "none"
        case .value(let v, let next):
            return "value: \(v), next: \(next.description)"
        }
    }
}
