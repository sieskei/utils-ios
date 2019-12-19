//
//  IdentityEquitable.swift
//  
//
//  Created by Miroslav Yozov on 19.12.19.
//

import Foundation

public protocol IdentityEquitable: class, Equatable { }

public extension IdentityEquitable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs === rhs
    }
}
