//
//  KeyedEncodingContainer+.swift
//  
//
//  Created by Miroslav Yozov on 22.10.21.
//

import Foundation

@dynamicMemberLookup
public class KeyedEncodingProperties {
    private var container: KeyedEncodingContainer<CustomCodingKey>
    
    public init(_ container: KeyedEncodingContainer<CustomCodingKey>) {
        self.container = container
    }
    
    public subscript<T: Encodable>(dynamicMember member: String) -> (_ value: T?) throws -> Void {
        { [unowned self] in
            try self.container.encodeIfPresent($0, forKey: .custom(named: member))
        }
    }
}

public extension KeyedEncodingContainer where K == CustomCodingKey {
    var properties: KeyedEncodingProperties {
        .init(self)
    }
}

public extension Encoder {
    func keyedProperties() -> KeyedEncodingProperties {
        container(keyedBy: CustomCodingKey.self).properties
    }
}
