//
//  IdentityEquitable.swift
//  
//
//  Created by Miroslav Yozov on 19.12.19.
//

import Foundation

public protocol IdentityEquatable: class, Equatable { }

public extension IdentityEquatable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs === rhs
    }
}
