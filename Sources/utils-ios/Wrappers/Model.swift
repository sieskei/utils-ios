//
//  Model.swift
//  
//
//  Created by Miroslav Yozov on 7.04.21.
//

import Foundation

// --------------- //
// MARK: ModelType //
// --------------- //

public protocol ModelType {
    associatedtype M: Equatable
    init(_ model: M?)
}

// ----------- //
// MARK: Model //
// ----------- //
@dynamicMemberLookup
@propertyWrapper
public enum Model<M: Equatable>: ModelType {
    case empty
    case value(M)
    
    public var wrappedValue: M? {
        get {
            switch self {
            case .empty:
                return nil
            case .value(let value):
                return value
            }
        }
        set {
            self = .init(newValue)
        }
    }
    
    public init(_ model: M?) {
        if let model = model {
            self = .value(model)
        } else {
            self = .empty
        }
    }
    
    public init(wrappedValue: M?) {
        self.init(wrappedValue)
    }
    
    public var isEmpty: Bool {
        switch self {
        case .empty: return true
        case .value: return false
        }
    }
    
    public func onValue(_ action: (M) throws -> Void) rethrows {
        switch self {
        case .empty:
            return
        case .value(let model):
            try action(model)
        }
    }
    
    public func onValue<R>(_ transform: (M) throws -> R?, action: (R) throws -> Void) rethrows {
        switch self {
        case .value(let model):
            guard let r = try transform(model) else { fallthrough }
            try action(r)
        default:
            return
        }
    }
}


// MARK: map method variations
extension Model {
    public func map<R: AnyObject>(_ default: R?,_ transform: (M) throws -> R?) rethrows -> Model<R> {
        switch self {
        case .empty:
            return .init(`default`)
        case .value(let model):
            return .init(try transform(model))
        }
    }
    
    public func map<R: AnyObject>(_ transform: (M) throws -> R?) rethrows -> Model<R> {
        switch self {
        case .empty:
            return .empty
        case .value(let model):
            return .init(try transform(model))
        }
    }
    
    public func map<R>(_ default: R, _ transform: (M) throws -> R) rethrows -> R {
        switch self {
        case .empty:
            return `default`
        case .value(let model):
            return try transform(model)
        }
    }
    
    public func mapIf<R>(_ if: (M) -> Bool, _ default: R, _ transform: (M) throws -> R) rethrows -> R {
        switch self {
        case .empty:
            return `default`
        case .value(let model):
            return `if`(model) ? try transform(model) : `default`
        }
    }
}


// MARK: Equatable implementation
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


// MARK: @dynamicMemberLookup implementation
extension Model {
    private func get<T>(for keyPath: KeyPath<M, T?>) -> T? {
        if case .value(let value) = self {
            return value[keyPath: keyPath]
        } else {
            return nil
        }
    }
    
    private func get<T>(for keyPath: KeyPath<M, T>) -> T? {
        if case .value(let value) = self {
            return value[keyPath: keyPath]
        } else {
            return nil
        }
    }
    
    // getter for read-only non nil properties
    public subscript<T>(dynamicMember keyPath: KeyPath<M, T>) -> T? {
        `get`(for: keyPath)
    }
    
    // getter for read-only optional properties
    public subscript<T>(dynamicMember keyPath: KeyPath<M, T?>) -> T? {
        `get`(for: keyPath)
    }
    
    // getter/setter for writable non nil properties
    public subscript<T>(dynamicMember keyPath: WritableKeyPath<M, T>) -> T? {
        get { `get`(for: keyPath) }
        set {
            if case .value(var value) = self, let newValue = newValue {
                value[keyPath: keyPath] = newValue
            }
        }
    }
    
    // getter/setter for writable optional properties
    public subscript<T>(dynamicMember keyPath: WritableKeyPath<M, T?>) -> T? {
        get { `get`(for: keyPath) }
        set {
            if case .value(var value) = self {
                value[keyPath: keyPath] = newValue
            }
        }
    }
}
