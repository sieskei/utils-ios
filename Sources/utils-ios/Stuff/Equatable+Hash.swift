//
//  Equatable+Hash.swift
//  
//
//  Created by Miroslav Yozov on 8.12.21.
//

import Foundation

public protocol HashEquatable: Hashable { }

public extension HashEquatable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
}
