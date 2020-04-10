//
//  File.swift
//  
//
//  Created by Miroslav Yozov on 31.10.19.
//

import Foundation

public extension CodingUserInfoKey {
    struct Decoder {
        static let root = CodingUserInfoKey(rawValue: "bg.netinfo.Decoder.root")!
        static let object = CodingUserInfoKey(rawValue: "bg.netinfo.Decoder.object")!
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
            var nc = try c.nestedUnkeyedContainer()
            return try nc.superDecoder()
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
    enum MultipleTimesDecodableResult<T: MultipleTimesDecodable>: Decodable {
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
    
    enum Result<T: Decodable>: Decodable {
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
    
    func decode<T: MultipleTimesDecodable>(to object: T, from data: Data?) -> MultipleTimesDecodableResult<T> {
        userInfo[CodingUserInfoKey.Decoder.object] = object
        do {
            return try decode(MultipleTimesDecodableResult<T>.self, from: data ?? Data())
        } catch (let error) {
            return .failure(error)
        }
    }
    
    func decode<T: Decodable>(from data: Data?) -> Result<T> {
        do {
            return try decode(Result<T>.self, from: data ?? Data())
        } catch (let error) {
            return .failure(error)
        }
    }
}
