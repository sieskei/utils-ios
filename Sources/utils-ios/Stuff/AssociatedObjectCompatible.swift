//
//  AssociatedObjectCompatible.swift
//  
//
//  Created by Miroslav Yozov on 30.10.19.
//

import Foundation

fileprivate struct AssociatedKey {
    private static let lock: NSLock = .init(name: "AssociatedKey.lock")
    
    private static var keys: [String: UnsafeRawPointer] = [:]
    
    static func pointer(for key: String) -> UnsafeRawPointer {
        lock.lock(); defer { lock.unlock() }
        
        if let exist = keys[key] {
            return exist
        } else {
            let new = Utils.unwrapOrFatalError(UnsafeRawPointer(bitPattern: Int.randomIdentifier))
            keys[key] = new
            return new
        }
    }
}

public enum AssociationPolicy: Int {
    case strong
    case weak
    
    fileprivate var objc_value: objc_AssociationPolicy {
        switch self {
        case .strong:
            return .OBJC_ASSOCIATION_RETAIN_NONATOMIC
        case .weak:
            return .OBJC_ASSOCIATION_ASSIGN
        }
    }
}

public protocol AssociatedObjectCompatible: Synchronized {
    func get<T>(for key: String, policy: AssociationPolicy, default value: () -> T) -> T
    func set<T>(value: T, for key: String, policy: AssociationPolicy)
}

public extension AssociatedObjectCompatible {
    func get<T>(for key: String, policy: AssociationPolicy = .strong, default value: () -> T) -> T {
        synchronized {
            let key = "\(type(of: self)).\(key)"
            if let current = objc_getAssociatedObject(self, AssociatedKey.pointer(for: key)) as? T {
                return current
            }
            
            let `default` = value()
            objc_setAssociatedObject(self, AssociatedKey.pointer(for: key), `default`, policy.objc_value)
            return `default`
        }
    }
    
    func set<T>(value: T, for key: String, policy: AssociationPolicy = .strong) {
        synchronized {
            let key = "\(type(of: self)).\(key)"
            objc_setAssociatedObject(self, AssociatedKey.pointer(for: key), value, policy.objc_value)
        }
    }
}
