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

//public struct UnkeyedDecodeProperties {
//    private var container: UnkeyedDecodingContainer
//
//    fileprivate init(_ container: UnkeyedDecodingContainer) {
//        self.container = container
//    }
//    
//    public var isAtEnd: Bool {
//        container.isAtEnd
//    }
//    
//    
//    // MARK: Decode methods
//    
//    public mutating func property<T: Decodable>() -> DecodingProperty<T> {
//        do {
//            return .success(try container.decode())
//        } catch (let error) {
//            return .fail(error)
//        }
//    }
//    
//    public mutating func property<T: Decodable & StringParsable>() -> DecodingProperty<T> {
//        do {
//            return .success(try container.parse())
//        } catch (let error) {
//            return .fail(error)
//        }
//    }
//    
//    // MARK: Nested Contaienr Methods
//    
//    public mutating func properties() -> DecodingProperty<KeyedDecodeProperties> {
//        do {
//            return .success(.init(try container.nestedContainer(keyedBy: CustomCodingKey.self)))
//        } catch (let error) {
//            return .fail(error)
//        }
//    }
//    
//    public mutating func properties() -> DecodingProperty<UnkeyedDecodeProperties> {
//        do {
//            return .success(.init(try container.nestedUnkeyedContainer()))
//        } catch (let error) {
//            return .fail(error)
//        }
//    }
//    
//    
//    // MARK: Super Decoder Methods
//    
//    public mutating func superDecoder() -> DecodingProperty<Decoder> {
//        do {
//            return .success(try container.superDecoder())
//        } catch (let error) {
//            return .fail(error)
//        }
//    }
//}
//
//
//@dynamicMemberLookup
//public struct KeyedDecodeProperties {
//    private let container: KeyedDecodingContainer<CustomCodingKey>
//    
//    fileprivate init(_ container: KeyedDecodingContainer<CustomCodingKey>) {
//        self.container = container
//    }
//    
//    
//    // MARK: Decode methods
//    
//    public subscript<T: Decodable>(dynamicMember member: String) -> DecodingProperty<T> {
//        do {
//            return .success(try container.decode(forKey: .custom(named: member)))
//        } catch (let error) {
//            return .fail(error)
//        }
//    }
//    
//    public subscript<T: Decodable & StringParsable>(dynamicMember member: String) -> DecodingProperty<T> {
//        do {
//            return .success(try container.parse(forKey: .custom(named: member)))
//        } catch (let error) {
//            return .fail(error)
//        }
//    }
//    
//    
//    // MARK: Nested Contaienr Methods
//    
//    public subscript(dynamicMember member: String) -> DecodingProperty<KeyedDecodeProperties> {
//        do {
//            return .success(.init(try container.nestedContainer(keyedBy: CustomCodingKey.self, forKey: .custom(named: member))))
//        } catch (let error) {
//            return .fail(error)
//        }
//    }
//    
//    public subscript(dynamicMember member: String) -> DecodingProperty<UnkeyedDecodeProperties> {
//        do {
//            return .success(.init(try container.nestedUnkeyedContainer(forKey: .custom(named: member))))
//        } catch (let error) {
//            return .fail(error)
//        }
//    }
//    
//    
//    // MARK: Super Decoder Methods
//    
//    public subscript(dynamicMember member: String) -> DecodingProperty<Decoder> {
//        do {
//            return .success(try container.superDecoder(forKey: .custom(named: member)))
//        } catch (let error) {
//            return .fail(error)
//        }
//    }
//    
//    public func superDecoder() -> DecodingProperty<Decoder> {
//        do {
//            return .success(try container.superDecoder())
//        } catch (let error) {
//            return .fail(error)
//        }
//    }
//}
//
//
//public extension Decoder {
//    func properties() -> DecodingProperty<KeyedDecodeProperties> {
//        do {
//            return .success(.init(try container(keyedBy: CustomCodingKey.self)))
//        } catch (let error) {
//            return .fail(error)
//        }
//    }
//    
//    func properties() -> DecodingProperty<UnkeyedDecodeProperties> {
//        do {
//            return .success(.init(try unkeyedContainer()))
//        } catch (let error) {
//            return .fail(error)
//        }
//    }
//}
