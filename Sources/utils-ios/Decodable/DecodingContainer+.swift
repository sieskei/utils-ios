//
//  DecodingContainer+.swift
//  
//
//  Created by Miroslav Yozov on 31.10.19.
//

import Foundation

public extension SingleValueDecodingContainer {
    func decode<T>(to type: T.Type = T.self) throws -> T where T : Decodable {
        return try decode(type)
    }
    
    func decode<T>(to type: T.Type = T.self, default value: T) -> T where T : Decodable {
        do {
            return try decode(type)
        } catch {
            return value
        }
    }
    
    func parse<T>(to type: T.Type = T.self) throws -> T where T : Decodable & StringParsable {
        do {
            let stringValue = try decode(String.self)
            return type.init(from: stringValue)
        } catch {
            return try decode(type)
        }
    }
    
    func parse<T>(to type: T.Type = T.self, default value: T) -> T where T : Decodable & StringParsable {
        do {
            let stringValue = try decode(String.self)
            return type.init(from: stringValue)
        } catch {
            do {
                return try decode(type)
            } catch {
                return value
            }
        }
    }
}

public extension KeyedDecodingContainer {
    func superDecoder(forKey key: KeyedDecodingContainer.Key, default decoder: Decoder) -> Decoder {
        do {
            return try superDecoder(forKey: key)
        } catch {
            return decoder
        }
    }
    
    func decode<T>(to type: T.Type = T.self, forKey key: KeyedDecodingContainer.Key) throws -> T where T : Decodable {
        return try decode(type, forKey: key)
    }
    
    func decode<T>(to type: T.Type = T.self, forKey key: KeyedDecodingContainer.Key, default value: T) -> T where T : Decodable {
        do {
            return try decode(type, forKey: key)
        } catch {
            return value
        }
    }
    
    func decodeIfPresent<T>(to type: T.Type = T.self, forKey key: KeyedDecodingContainer.Key) throws -> T? where T : Decodable {
        return try decodeIfPresent(type, forKey: key)
    }
    
    func decodeIfPresent<T>(to type: T.Type = T.self, forKey key: KeyedDecodingContainer.Key, default value: T) -> T where T : Decodable {
        do {
            return try decodeIfPresent(type, forKey: key) ?? value
        } catch {
            return value
        }
    }
    
    func parse<T>(to type: T.Type = T.self, forKey key: KeyedDecodingContainer.Key) throws -> T where T : Decodable & StringParsable {
        do {
            let stringValue = try decode(String.self, forKey: key)
            return type.init(from: stringValue)
        } catch {
            return try decode(type, forKey: key)
        }
    }
    
    func parse<T>(to type: T.Type = T.self, forKey key: KeyedDecodingContainer.Key, default value: T) -> T where T : Decodable & StringParsable {
        do {
            let stringValue = try decode(String.self, forKey: key)
            return type.init(from: stringValue)
        } catch {
            do {
                return try decode(type, forKey: key)
            } catch {
                return value
            }
        }
    }
}
