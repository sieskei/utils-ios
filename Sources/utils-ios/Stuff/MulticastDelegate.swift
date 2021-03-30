//
//  MulticastDelegate.swift
//  sinoptik-ios
//
//  Created by Miroslav Yozov on 13.12.18.
//  Copyright © 2018 Net Info. All rights reserved.
//

import Foundation

infix operator =>

func += <T, R: Reference>(left: inout MulticastDelegate<T, R>?, right: T) where R.T == T {
    left = MulticastDelegate<T, R>.add(delegate: right, toMulticastDelegate: left)
}

func -= <T, R: Reference>(left: inout MulticastDelegate<T, R>?, right: T) where R.T == T {
    left = MulticastDelegate<T, R>.removeDelegate(delegate: right, fromMulticastDelegate: left)
}

func => <T, R: Reference>(left: MulticastDelegate<T, R>?, invocation: (T) -> ()) where R.T == T {
    MulticastDelegate<T, R>.invoke(left, invocation: invocation)
}

class MulticastDelegate<T, R: Reference> where R.T == T {
    static func clean(_ multicastDelegate: MulticastDelegate<T, R>?) -> MulticastDelegate<T, R>? {
        guard let md = multicastDelegate else {
            return nil
        }
        
        md.delegates.removeAll { $0.ref == nil }
        return md.delegates.isEmpty ? nil : md
    }
    
    static func add(delegate: T, toMulticastDelegate multicastDelegate: MulticastDelegate<T, R>?) -> MulticastDelegate<T, R>? {
        guard let md = MulticastDelegate.clean(multicastDelegate) else {
            return MulticastDelegate<T, R>(delegate: delegate)
        }
        
        if !md.constains(delegate: delegate) {
            md.delegates.append(R(delegate))
        }
        
        return md
    }
    
    static func removeDelegate(delegate: T, fromMulticastDelegate multicastDelegate: MulticastDelegate<T, R>?) -> MulticastDelegate<T, R>? {
        guard let md = MulticastDelegate.clean(multicastDelegate) else {
            return nil
        }
        
        md.delegates.removeAll { $0.ref === delegate }
        return md.delegates.isEmpty ? nil : md
    }
    
    static func invoke(_ multicastDelegate: MulticastDelegate<T, R>?, invocation: (T) -> ()) {
        (multicastDelegate?.delegates ?? []).forEach {
            if let delegate = $0.ref {
                invocation(delegate)
            }
        }
    }
    
    fileprivate var delegates: [R]
    
    public var references: [R.T] {
        var refs: [R.T] = []
        delegates.forEach {
            if let r = $0.ref {
                refs.append(r)
            }
        }
        return refs
    }
    
    fileprivate init(delegate: T) {
        delegates = [R(delegate)]
    }
    
    fileprivate func index(of delegate: T) -> Int? {
        delegates.firstIndex(where: {
            guard let ref = $0.ref else {
                return false
            }
            
            return ref === delegate
        })
    }
    
    func constains(delegate: T) -> Bool {
        return index(of: delegate) != nil
    }
}
