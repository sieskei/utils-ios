//
//  Equatable+Identity.swift
//  
//
//  Created by Miroslav Yozov on 19.12.19.
//

import Foundation

public protocol IdentityEquatable: AnyObject, Equatable { }

public extension IdentityEquatable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs === rhs
    }
}
