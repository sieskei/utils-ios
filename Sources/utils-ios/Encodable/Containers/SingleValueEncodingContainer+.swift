//
//  File.swift
//  
//
//  Created by Miroslav Yozov on 22.10.21.
//

import Foundation

public class SingleEncodingProperty {
    private var container: SingleValueEncodingContainer
    
    public init(_ container: SingleValueEncodingContainer) {
        self.container = container
    }
    
    public func encode<T: Encodable>(_ value: T) throws {
        try container.encode(value)
    }
    
    public func encodeNil() throws {
        try container.encodeNil()
    }
}

public extension SingleValueEncodingContainer {
    var property: SingleEncodingProperty {
        .init(self)
    }
}

public extension Encoder {
    func singleProperty() -> SingleEncodingProperty {
        singleValueContainer().property
    }
}
