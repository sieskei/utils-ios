//
//  UnkeyedEncodingProperties+.swift
//  
//
//  Created by Miroslav Yozov on 22.10.21.
//

import Foundation

public class UnkeyedEncodingProperties {
    private var container: UnkeyedEncodingContainer
    
    public init(_ container: UnkeyedEncodingContainer) {
        self.container = container
    }
    
    public func encode<T: Encodable>(_ value: T) throws {
        try container.encode(value)
    }
    
    public func encode<T: Encodable>(forEach value: [T]) {
        value.forEach {
            do {
                try container.encode($0)
            } catch(let error) {
                Utils.Log.error($0, "encode fail.", error)
            }
        }
    }
    
    public func encodeNil() throws {
        try container.encodeNil()
    }
    
    public func nestedUnkeyedProperties() -> UnkeyedEncodingProperties {
        .init(container.nestedUnkeyedContainer())
    }
    
    public func nestedKeyedProperties() -> KeyedEncodingProperties {
        .init(container.nestedContainer(keyedBy: CustomCodingKey.self))
    }
}

public extension UnkeyedEncodingContainer {
    var properties: UnkeyedEncodingProperties {
        .init(self)
    }
}

public extension Encoder {
    func unkeyedProperties() -> UnkeyedEncodingProperties {
        unkeyedContainer().properties
    }
}
