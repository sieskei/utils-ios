//
//  File.swift
//  
//
//  Created by Miroslav Yozov on 31.10.19.
//

import Foundation

public extension CodingUserInfoKey {
    struct Decoder {
        static let root = CodingUserInfoKey(rawValue: "ios.utils.Decoder.root")!
        static let object = CodingUserInfoKey(rawValue: "ios.utils.Decoder.object")!
    }
}

extension Decoder {
    func rootDecoder() throws -> Decoder {
        guard let root = userInfo[CodingUserInfoKey.Decoder.root] as? EndpointRoot else {
            return self
        }
        switch root {
        case .none:
            return self
        case .firstOfArray:
            var c = try unkeyedContainer()
            return try c.superDecoder()
        case .key(let name):
            return try container(keyedBy: CustomCodingKey.self).superDecoder(forKey: .custom(named: name))
        }
    }
}

private extension Decoder {
    func object<T>() -> T? {
        guard let object = userInfo[CodingUserInfoKey.Decoder.object] else {
            return nil
        }
        
        if var objects = object as? [T] {
            return objects.isEmpty ? nil : objects.removeFirst()
        } else {
            return object as? T
        }
    }
}

extension JSONDecoder {
    private enum MultipleTimesDecodableResult<T: MultipleTimesDecodable>: Decodable {
        case success(T)
        case failure(Error)
        
        init(from decoder: Decoder) throws {
            do {
                if let object: T = decoder.object() {
                    try object.runDecode(from: decoder.rootDecoder())
                    self = .success(object)
                } else {
                    self = .success(try T.init(from: decoder.rootDecoder()))
                }
            } catch (let error) {
                self = .failure(error)
            }
        }
    }
    
    private enum Result<T: Decodable>: Decodable {
        case success(T)
        case failure(Error)
        
        init(from decoder: Decoder) throws {
            do {
                self = .success(try T.init(from: decoder.rootDecoder()))
            } catch (let error) {
                self = .failure(error)
            }
        }
    }
}

public extension JSONDecoder {
    static func decode<T: Decodable>(from data: Data, with info: [CodingUserInfoKey: Any] = [:]) throws -> T {
        let decoder: JSONDecoder = .init(userInfo: info)
        return try decoder.decode(from: data)
    }
    
    @discardableResult
    static func decode<T: MultipleTimesDecodable>(to object: T, from data: Data, with info: [CodingUserInfoKey: Any] = [:]) throws -> T {
        let decoder: JSONDecoder = .init(userInfo: info)
        return try decoder.decode(to: object, from: data)
    }
    
    convenience init(userInfo: [CodingUserInfoKey: Any]) {
        self.init()
        self.userInfo = userInfo
    }
    
    func decode<T: MultipleTimesDecodable>(to object: T, from data: Data) throws -> T {
        userInfo[CodingUserInfoKey.Decoder.object] = object
        
        switch try decode(MultipleTimesDecodableResult<T>.self, from: data) {
        case .success(let obj):
            return obj
        case .failure(let error):
            throw error
        }
    }
    
    func decode<T: Decodable>(from data: Data) throws -> T {
        switch try decode(Result<T>.self, from: data) {
        case .success(let obj):
            return obj
        case .failure(let error):
            throw error
        }
    }
}
