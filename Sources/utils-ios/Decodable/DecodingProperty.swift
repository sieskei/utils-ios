//
//  DecodeProperties.swift
//  
//
//  Created by Miroslav Yozov on 22.12.20.
//

import Foundation

public enum DecodingProperty<Value> {
    case success(Value)
    case fail(Error)
    
    public func or(_ default: Value) -> Value {
        guard case .success(let value) = self else {
            return `default`
        }
        return value
    }
    
    public func `throw`() throws -> Value {
        switch self {
        case .success(let value):
            return value
        case .fail(let error):
            throw error
        }
    }
}
