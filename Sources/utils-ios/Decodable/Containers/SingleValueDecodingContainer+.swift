//
//  SingleValueDecodingContainer+.swift
//  
//
//  Created by Miroslav Yozov on 23.12.20.
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
            return try decode(type)
        } catch {
            let stringValue = try decode(String.self)
            return type.init(from: stringValue)
        }
    }
    
    func parse<T>(to type: T.Type = T.self, default value: T) -> T where T : Decodable & StringParsable {
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
