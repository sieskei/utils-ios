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
    
    public func encodeNil() throws {
        try container.encodeNil()
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
