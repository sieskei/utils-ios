//
//  UnkeyedDecodingContainer+.swift
//  
//
//  Created by Miroslav Yozov on 23.12.20.
//

import Foundation

public extension UnkeyedDecodingContainer {
    mutating func decode<T>(to type: T.Type = T.self) throws -> T where T : Decodable {
        return try decode(type)
    }
    
    mutating func decode<T>(to type: T.Type = T.self, default value: T) -> T where T : Decodable {
        do {
            return try decode(type)
        } catch {
            return value
        }
    }
    
    mutating func decodeIfPresent<T>(to type: T.Type = T.self) throws -> T? where T : Decodable {
        return try decodeIfPresent(type)
    }
    
    mutating func decodeIfPresent<T>(to type: T.Type = T.self, default value: T) throws -> T? where T : Decodable {
        do {
            return try decodeIfPresent(type)
        } catch {
            return value
        }
    }
    
    mutating func parse<T>(to type: T.Type = T.self) throws -> T where T : Decodable & StringParsable {
        do {
            return try decode(type)
        } catch {
            let stringValue = try decode(String.self)
            return type.init(from: stringValue)
        }
    }
    
    mutating func parse<T>(to type: T.Type = T.self, default value: T) -> T where T : Decodable & StringParsable {
        do {
            return try decode(type)
        } catch {
            do {
                let stringValue = try decode(String.self)
                return type.init(from: stringValue)
            } catch {
                return value
            }
        }
    }
}

public struct UnkeyedDecodingProperties {
    private var container: UnkeyedDecodingContainer
    private var lazyDecoder: LazyInit<Decoder> = .none
    
    public init(_ container: UnkeyedDecodingContainer) {
        self.container = container
    }
    
    public mutating func next() -> Bool {
        let f = !container.isAtEnd
        if f {
            lazyDecoder = .none
        }
        return f
    }
    
    public mutating func decoder() throws -> Decoder {
        switch lazyDecoder {
        case .none:
            do {
                let d = try container.superDecoder()
                lazyDecoder.set(d)
                return d
            } catch(let error) {
                lazyDecoder.set(error)
                throw error
            }
        case .value(let decoder):
            return decoder
        case .error(let error):
            throw error
        }
    }
    
    public mutating func keyedProperties() -> DecodingProperty<KeyedDecodingProperties> {
        do {
             return .success(try decoder().keyedProperties())
        } catch (let error) {
            return .fail(error)
        }
    }
    
    public mutating func unkeyedProperties() -> DecodingProperty<UnkeyedDecodingProperties> {
        do {
            return .success(try decoder().unkeyedProperties())
        } catch (let error) {
            return .fail(error)
        }
    }
}

public extension UnkeyedDecodingContainer {
    var properties: UnkeyedDecodingProperties {
        .init(self)
    }
}

public extension Decoder {
    func unkeyedProperties() throws -> UnkeyedDecodingProperties {
        try unkeyedContainer().properties
    }
}
