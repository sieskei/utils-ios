//
//  DecodingContainer+.swift
//  
//
//  Created by Miroslav Yozov on 31.10.19.
//

import Foundation

public extension SingleValueDecodingContainer {
    func decode<T>() throws -> T where T : Decodable {
        return try decode(T.self)
    }
    
    func decode<T>(default value: T) -> T where T : Decodable {
        do {
            return try decode(T.self)
        } catch {
            return value
        }
    }
    
    func parse<T>() throws -> T where T : Decodable & StringParsable {
        do {
            let stringValue = try decode(String.self)
            return T.self.init(from: stringValue)
        } catch {
            return try decode(T.self)
        }
    }
    
    func parse<T>(default value: T) -> T where T : Decodable & StringParsable {
        do {
            let stringValue = try decode(String.self)
            return T.self.init(from: stringValue)
        } catch {
            do {
                return try decode(T.self)
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
    
    func decode<T>(forKey key: KeyedDecodingContainer.Key) throws -> T where T : Decodable {
        return try decode(T.self, forKey: key)
    }
    
    func decodeIfPresent<T>(forKey key: KeyedDecodingContainer.Key) throws -> T? where T : Decodable {
        return try decodeIfPresent(T.self, forKey: key)
    }
    
    func decode<T>(forKey key: KeyedDecodingContainer.Key, default value: T) -> T where T : Decodable {
        do {
            return try decode(T.self, forKey: key)
        } catch {
            return value
        }
    }
    
    func decodeIfPresent<T>(forKey key: KeyedDecodingContainer.Key, default value: T) throws -> T where T : Decodable {
        do {
            return try decodeIfPresent(T.self, forKey: key) ?? value
        } catch {
            return value
        }
    }
    
    func parse<T>(forKey key: KeyedDecodingContainer.Key) throws -> T where T : Decodable & StringParsable {
        do {
            let stringValue = try decode(String.self, forKey: key)
            return T.self.init(from: stringValue)
        } catch {
            return try decode(T.self, forKey: key)
        }
    }
    
    func parse<T>(forKey key: KeyedDecodingContainer.Key, default value: T) -> T where T : Decodable & StringParsable {
        do {
            let stringValue = try decode(String.self, forKey: key)
            return T.self.init(from: stringValue)
        } catch {
            do {
                return try decode(T.self, forKey: key)
            } catch {
                return value
            }
        }
    }
}


public extension UnkeyedDecodingContainer {
    func aaa() {
    }
}
