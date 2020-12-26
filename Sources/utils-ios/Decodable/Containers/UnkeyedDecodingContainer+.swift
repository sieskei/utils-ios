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
    private let container: UnkeyedDecodingContainer
    
    public init(_ container: UnkeyedDecodingContainer) {
        self.container = container
    }
}

public extension UnkeyedDecodingContainer {

}
