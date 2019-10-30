//
//  MulticastDelegate.swift
//  sinoptik-ios
//
//  Created by Miroslav Yozov on 13.12.18.
//  Copyright © 2018 Net Info. All rights reserved.
//

import Foundation

infix operator =>
infix operator ~>

private struct WeakRef<T>: Equatable {
    private (set) weak var ref: AnyObject?
    
    var value: T? {
        get { return ref as? T }
        set {
            ref = newValue as AnyObject?
        }
    }
    
    init(value: T) {
        self.value = value
    }
}

private func ==<T>(lhs: WeakRef<T>, rhs: WeakRef<T>) -> Bool {
    return lhs.ref === rhs.ref
}

func += <T> (left: inout MulticastDelegate<T>?, right: T) {
    left = MulticastDelegate<T>.add(delegate: right, toMulticastDelegate: left)
}

func -= <T> (left: inout MulticastDelegate<T>?, right: T) {
    left = MulticastDelegate<T>.removeDelegate(delegate: right, fromMulticastDelegate: left)
}

func => <T> (left: MulticastDelegate<T>?, invocation: (T) -> ()) {
    MulticastDelegate.invoke(left, invocation: invocation)
}

func ~> <T, V> (left: MulticastDelegate<T>?, invocation: (V.Type, handler: (V) -> ())) {
    MulticastDelegate.invoke(left, invocation: invocation.handler)
}

class MulticastDelegate<T> {
    static func clean(_ multicastDelegate: MulticastDelegate<T>?) -> MulticastDelegate<T>? {
        guard let multicastDelegate = multicastDelegate else {
            return nil
        }
        
        var lost = [WeakRef<T>]()
        for ref in multicastDelegate.delegates {
            if ref.value == nil {
                lost.append(ref)
            }
        }
        
        lost.forEach {
            if let index = multicastDelegate.delegates.firstIndex(of: $0) {
                multicastDelegate.delegates.remove(at: index)
            }
        }
        
        return multicastDelegate.delegates.isEmpty ? nil : multicastDelegate
    }
    
    static func add(delegate: T, toMulticastDelegate multicastDelegate: MulticastDelegate<T>?) -> MulticastDelegate<T>? {
        guard let multicastDelegate = MulticastDelegate.clean(multicastDelegate) else {
            return MulticastDelegate<T>(delegate: delegate)
        }
        
        if !multicastDelegate.constains(delegate: delegate) {
            multicastDelegate.delegates.append(WeakRef(value: delegate))
        }
        
        return multicastDelegate
    }
    
    static func removeDelegate(delegate: T, fromMulticastDelegate multicastDelegate: MulticastDelegate<T>?) -> MulticastDelegate<T>? {
        guard let multicastDelegate = MulticastDelegate.clean(multicastDelegate) else {
            return nil
        }
        
        if let position = multicastDelegate.position(of: delegate) {
            if multicastDelegate.delegates.count == 1 {
                return nil
            } else {
                multicastDelegate.delegates.remove(at: position)
            }
        }
        
        return multicastDelegate
    }
    
    static func invoke<V>(_ multicastDelegate: MulticastDelegate<T>?, invocation: (V) -> ()) {
        (multicastDelegate?.delegates ?? []).forEach { ref in
            if let delegate = ref.value as? V {
                invocation(delegate)
            }
        }
    }
    
    fileprivate var delegates: [WeakRef<T>]
    
    fileprivate init(delegate: T) {
        self.delegates = [WeakRef(value: delegate)]
    }
    
    fileprivate func position(of delegate: T) -> Int? {
        for (index, ref) in delegates.enumerated() {
            if let ref = ref.ref, ref === (delegate as AnyObject) {
                return index
            }
        }
        return nil
    }
    
    func constains(delegate: T) -> Bool {
        return position(of: delegate) != nil
    }
}
