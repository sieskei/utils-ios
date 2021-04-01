//
//  Reference.swift
//  
//
//  Created by Miroslav Yozov on 22.12.20.
//

import Foundation

@dynamicMemberLookup
public protocol Reference {
    associatedtype T: AnyObject
    
    var ref: T? { get }
    
    init(_ ref: T)
    
    subscript<V>(dynamicMember keyPath: ReferenceWritableKeyPath<T, V>) -> V? { get }
}

public extension Reference {
    subscript<V>(dynamicMember keyPath: ReferenceWritableKeyPath<T, V>) -> V? {
        ref?[keyPath: keyPath]
    }
}

public class WeakReferance<T: AnyObject>: Reference {
    public fileprivate (set) weak var ref: T?
    
    public required init(_ ref: T) {
        self.ref = ref
    }
}

public class StrongReference<T: AnyObject>: Reference {
    public fileprivate (set) var ref: T?
    
    public required init(_ ref: T) {
        self.ref = ref
    }
}
