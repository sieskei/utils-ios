//
//  File.swift
//  
//
//  Created by Miroslav Yozov on 31.03.20.
//

import Foundation

public extension Int {
    private static var identifiers: Set<Int> = .init()
    
    static var randomIdentifier: Self {
        assert(identifiers.count < Int.max, "WTF!??? Too many identifiers! :)")
        
        let identifier = random(in: 1 ... Int.max)
        if identifiers.contains(identifier) {
            return Int.randomIdentifier
        } else {
            identifiers.insert(identifier)
            return identifier
        }
    }
}
