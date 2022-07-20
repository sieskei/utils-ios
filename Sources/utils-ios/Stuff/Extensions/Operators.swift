//
//  Operators.swift
//  
//
//  Created by Miroslav Yozov on 22.03.21.
//

import Foundation

infix operator ~>

@discardableResult
public func ~> <T: AnyObject>(object: T, onValue: (T) throws -> Void) rethrows -> T {
    try onValue(object)
    return object
}

@discardableResult
public func ~> <T>(optional: T?, onValue: (T) throws -> Void) rethrows -> T? {
    if let o = optional {
        try onValue(o)
    }
    return optional
}


public func ~> <M: Equatable>(model: Model<M>, onValue: (M) throws -> Void) rethrows {
    try model.onValue(onValue)
}
