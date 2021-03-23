//
//  BoolCounter.swift
//
//
//  Created by Miroslav Yozov on 13.04.18.
//

import Foundation

public class BoolCounter<T: AnyObject> {
    private unowned let object: T
    private let keyPath: ReferenceWritableKeyPath<T, Bool>
    
    private var count: Int = 0 {
        didSet {
            if oldValue == 0, count > 0 {
                object[keyPath: keyPath] = true
            } else if oldValue > 0, count == 0 {
                object[keyPath: keyPath] = false
            }
        }
    }
    
    public var isZero: Bool {
        return count == 0
    }
    
    public init(object: T, keyPath: ReferenceWritableKeyPath<T, Bool>, count: Int = 0) {
        self.object = object
        self.keyPath = keyPath
        self.count = count
    }
    
    public func clear() {
        count = 0
    }
}

public extension BoolCounter {
    @discardableResult
    static postfix func ++(counter: inout  BoolCounter) -> BoolCounter {
        counter.count += 1
        return counter
    }
    
    @discardableResult
    static postfix func --(counter: inout BoolCounter) -> BoolCounter {
        if counter.count > 0 {
            counter.count -= 1
        }
        return counter
    }
}
