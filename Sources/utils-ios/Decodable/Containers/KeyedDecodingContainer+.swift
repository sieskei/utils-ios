//
//  KeyedDecodingContainer+.swift
//  
//
//  Created by Miroslav Yozov on 23.12.20.
//

import Foundation

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
    
    func decode<T>(to type: T.Type = T.self, forKeys keys: [KeyedDecodingContainer.Key], default value: T) -> T where T : Decodable {
        for key in keys {
            do {
                if let typeValue = try decodeIfPresent(type, forKey: key) {
                    return typeValue
                }
            } catch { /* ignore */ }
        }
        return value
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
            return try decode(type, forKey: key)
        } catch {
            let stringValue = try decode(String.self, forKey: key)
            return type.init(from: stringValue)
        }
    }
    
    func parse<T>(to type: T.Type = T.self, forKey key: KeyedDecodingContainer.Key, default value: T) -> T where T : Decodable & StringParsable {
        do {
            return try decode(type, forKey: key)
        } catch {
            do {
                let stringValue = try decode(String.self, forKey: key)
                return type.init(from: stringValue)
            } catch {
                return value
            }
        }
    }
    
    func parse<T>(to type: T.Type = T.self, forKeys keys: [KeyedDecodingContainer.Key], default value: T) -> T where T : Decodable & StringParsable {
        for key in keys {
            do {
                if let typeValue = try decodeIfPresent(type, forKey: key) {
                    return typeValue
                }
            } catch {
                do {
                    if let stringValue = try decodeIfPresent(String.self, forKey: key) {
                        return type.init(from: stringValue)
                    }
                } catch { /* ignore */ }
            }
        }
        return value
    }
}

@dynamicMemberLookup
public struct KeyedDecodingProperties {
    private let container: KeyedDecodingContainer<CustomCodingKey>
    
    public init(_ container: KeyedDecodingContainer<CustomCodingKey>) {
        self.container = container
    }
    
    // MARK: Decode methods
    
    public subscript<T: Decodable>(dynamicMember member: String) -> DecodingProperty<T> {
        do {
            return .success(try container.decode(forKey: .custom(named: member)))
        } catch (let error) {
            return .fail(error)
        }
    }
    
    public subscript<T: Decodable & StringParsable>(dynamicMember member: String) -> DecodingProperty<T> {
        do {
            return .success(try container.parse(forKey: .custom(named: member)))
        } catch (let error) {
            return .fail(error)
        }
    }
    
    public subscript(dynamicMember member: String) -> DecodingProperty<KeyedDecodingProperties> {
        do {
            return .success(.init(try container.nestedContainer(keyedBy: CustomCodingKey.self, forKey: .custom(named: member))))
        } catch (let error) {
            return .fail(error)
        }
    }
    
    public subscript(dynamicMember member: String) -> DecodingProperty<UnkeyedDecodingProperties> {
        do {
            return .success(.init(try container.nestedUnkeyedContainer(forKey: .custom(named: member))))
        } catch (let error) {
            return .fail(error)
        }
    }
    
    public subscript(dynamicMember member: String) -> DecodingProperty<Decoder> {
        do {
            return .success(try container.superDecoder(forKey: .custom(named: member)))
        } catch (let error) {
            return .fail(error)
        }
    }
}

public extension KeyedDecodingContainer where K == CustomCodingKey {
    var properties: KeyedDecodingProperties {
        .init(self)
    }
}

public extension Decoder {
    func keyedProperties() throws -> KeyedDecodingProperties {
        try container(keyedBy: CustomCodingKey.self).properties
    }
}
