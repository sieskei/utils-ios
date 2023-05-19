//
//  File.swift
//  
//
//  Created by Miroslav Yozov on 19.05.23.
//

import Foundation

// MARK: String
extension String: RawRepresentable {
    public typealias RawValue = String
    
    public var rawValue: String {
        return self
    }
    
    public init?(rawValue: String) {
        self = rawValue
    }
}

// MARK: Bool
extension Bool: RawRepresentable {
    public typealias RawValue = Bool
    
    public var rawValue: Bool {
        return self
    }
    
    public init?(rawValue: Bool) {
        self = rawValue
    }
}
