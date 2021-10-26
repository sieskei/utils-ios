//
//  KeyedEncodingContainer+.swift
//  
//
//  Created by Miroslav Yozov on 22.10.21.
//

import Foundation

@dynamicMemberLookup
public class KeyedEncodingProperties {
    public enum ArrayEncodeStrategy {
        case all
        case each
    }
    
    private var container: KeyedEncodingContainer<CustomCodingKey>
    
    public init(_ container: KeyedEncodingContainer<CustomCodingKey>) {
        self.container = container
    }
    
    public subscript<T: Encodable>(dynamicMember member: String) -> (_ value: T?) throws -> Void {
        { [unowned self] in
            try self.container.encodeIfPresent($0, forKey: .custom(named: member))
        }
    }
    
    public subscript<T: Encodable>(dynamicMember member: String) -> (_ value: [T], _ strategy: ArrayEncodeStrategy) throws -> Void {
        { [unowned self] value, strategy in
            switch strategy {
            case .all:
                try self.container.encodeIfPresent(value, forKey: .custom(named: member))
            case .each:
                self[dynamicMember: member]() ~> { (props: UnkeyedEncodingProperties) in
                    props.encode(forEach: value)
                }
            }
        }
    }
    
    public subscript(dynamicMember member: String) -> () throws -> Void {
        { [unowned self] in
            try self.container.encodeNil(forKey: .custom(named: member))
        }
    }
    
    public subscript(dynamicMember member: String) -> () -> KeyedEncodingProperties {
        { [unowned self] in
            .init(container.nestedContainer(keyedBy: CustomCodingKey.self, forKey: .custom(named: member)))
        }
    }
    
    public subscript(dynamicMember member: String) -> () -> UnkeyedEncodingProperties {
        { [unowned self] in
            .init(container.nestedUnkeyedContainer(forKey: .custom(named: member)))
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
