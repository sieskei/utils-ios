//
//  Model.swift
//  
//
//  Created by Miroslav Yozov on 30.10.19.
//

import Foundation

// --------------- //
// MARK: ModelType //
// --------------- //

public protocol ModelType {
    associatedtype M: Equatable
    init(_ model: M?)
}

// --------------- //
// MARK: ViewModel //
// --------------- //

public enum Model<M: Equatable>: ModelType {
    case empty
    case value(M)
    
    public init(_ model: M?) {
        if let model = model {
            self = .value(model)
        } else {
            self = .empty
        }
    }
    
    public var isEmpty: Bool {
        switch self {
        case .empty: return true
        case .value: return false
        }
    }
    
    public func onValue(_ action: (M) -> Void) {
        switch self {
        case .empty:
            return
        case .value(let model):
            action(model)
        }
    }
    
    public func onValue<R>(_ transform: (M) -> R?, action: (R) -> Void) {
        switch self {
        case .value(let model):
            guard let r = transform(model) else { fallthrough }
            action(r)
        default:
            return
        }
    }
    
    public func map<R: AnyObject>(_ default: R?,_ transform: (M) -> R?) -> Model<R> {
        switch self {
        case .empty:
            if let model = `default` {
                return .value(model)
            } else {
                return .empty
            }
        case .value(let model):
            if let model = transform(model) {
                return .value(model)
            } else {
                return .empty
            }
        }
    }
    
    public func map<R: AnyObject>(_ transform: (M) -> R?) -> Model<R> {
        switch self {
        case .empty:
            return .empty
        case .value(let model):
            if let model = transform(model) {
                return .value(model)
            } else {
                return .empty
            }
        }
    }
    
    public func map<R>(_ default: R, _ if: (M) -> Bool = { _ in return true }, transform: (M) -> R) -> R {
        switch self {
        case .empty:
            return `default`
        case .value(let model):
            return `if`(model) ? transform(model) : `default`
        }
    }
}


// --------------- //
// MARK: Equatable //
// --------------- //

extension Model: Equatable {
    public static func == (lhs: Model<M>, rhs: Model<M>) -> Bool {
        switch lhs {
        case .empty:
            switch rhs {
            case .empty: return true
            case .value: return false
            }
        case .value(let lhsValue):
            switch rhs {
            case .empty: return false
            case .value(let rhsValue): return lhsValue == rhsValue
            }
        }
    }
    
    public static func == (lhs: Model<M>, rhs: M?) -> Bool {
        switch lhs {
        case .empty:
            return rhs == nil
        case .value(let lhsValue):
            return lhsValue == rhs
        }
    }
}

public protocol ModelCompatible {
    associatedtype M: Equatable
    var model: Model<M> { get set }
}
