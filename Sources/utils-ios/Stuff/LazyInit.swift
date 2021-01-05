//
//  LazyInit.swift
//  
//
//  Created by Miroslav Yozov on 5.01.21.
//

import Foundation

public enum LazyInit<V> {
    case none
    case value(V)
    case error(Error)
    
    mutating func set(_ v: V) {
        self = .value(v)
    }
    
    mutating func set(_ e: Error) {
        self = .error(e)
    }
}
