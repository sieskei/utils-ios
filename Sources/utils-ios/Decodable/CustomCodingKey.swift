//
//  CustomCodingKey.swift
//  
//
//  Created by Miroslav Yozov on 31.10.19.
//

import Foundation

public enum CustomCodingKey: CodingKey {
    public init?(stringValue: String) {
        self = .custom(named: stringValue)
    }
    
    public init?(intValue: Int) {
        return nil
    }
    
    public var stringValue: String {
        switch self {
        case .custom(let name):
            return name
        }
    }
    
    public var intValue: Int? {
        return nil
    }
    
    case custom(named: String)
}
