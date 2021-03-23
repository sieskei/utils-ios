//
//  Operators.swift
//  
//
//  Created by Miroslav Yozov on 22.03.21.
//

import Foundation

infix operator ~>

public func ~> <T>(optional: T?, onValue: (T) throws -> Void) rethrows {
    if let o = optional {
        try onValue(o)
    }
}

public func ~> <M: Equatable>(model: Model<M>, onValue: (M) throws -> Void) rethrows {
    try model.onValue(onValue)
}
