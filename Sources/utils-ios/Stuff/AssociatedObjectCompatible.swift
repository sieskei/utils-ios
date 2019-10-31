//
//  AssociatedObjectCompatible.swift
//  
//
//  Created by Miroslav Yozov on 30.10.19.
//

import Foundation

fileprivate struct AssociatedKey {
    private static var currentCode: UInt = 1
    private static var nextCode: UInt {
        defer { currentCode += 1 }
        return currentCode
    }
    
    private static var keys: [String: UnsafeRawPointer] = [:]
    
    static func pointer(for key: String) -> UnsafeRawPointer {
        if let exist = keys[key] {
            return exist
        } else {
            let pointer = UnsafeRawPointer(bitPattern: AssociatedKey.nextCode)
            let new = Utils.unwrapOrFatalError(pointer)
            keys[key] = new
            return new
        }
    }
}

public protocol Synchronized { }
extension Synchronized {
    func synchronized<T>(_ action: () throws -> T) rethrows -> T {
        objc_sync_enter(self)
        defer {
            objc_sync_exit(self)
        }
        return try action()
    }
}

public protocol AssociatedObjectCompatible: Synchronized {
    func get<T>(for key: String, default value: T) -> T
    func set<T>(value: T, for key: String)
}
public extension AssociatedObjectCompatible {
    func get<T>(for key: String, default value: T) -> T {
        return get(for: key) { return value }
    }
    
    func get<T>(for key: String, default value: () -> T) -> T {
        return synchronized {
            let key = "\(type(of: self)).\(key)"
            if let current = objc_getAssociatedObject(self, AssociatedKey.pointer(for: key)) as? T {
                return current
            }
            
            let `default` = value()
            objc_setAssociatedObject(self, AssociatedKey.pointer(for: key), `default`, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return `default`
        }
    }
    
    func set<T>(value: T, for key: String) {
        synchronized {
            let key = "\(type(of: self)).\(key)"
            objc_setAssociatedObject(self, AssociatedKey.pointer(for: key), value, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}
