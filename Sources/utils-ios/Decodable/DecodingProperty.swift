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
        switch self {
        case .success(let value):
            return value
        case .fail(let error):
            #if DEBUG
            Utils.Log.error(error)
            #endif
            return `default`
        }
    }
    
    public func `throw`() throws -> Value {
        switch self {
        case .success(let value):
            return value
        case .fail(let error):
            #if DEBUG
            Utils.Log.error(error)
            #endif
            throw error
        }
    }
}
