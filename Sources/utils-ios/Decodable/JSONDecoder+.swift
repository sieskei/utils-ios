//
//  File.swift
//  
//
//  Created by Miroslav Yozov on 31.10.19.
//

import Foundation

public extension CodingUserInfoKey {
    struct Decoder {
        static let rootKey = CodingUserInfoKey(rawValue: "bg.netinfo.Decoder.rootKey")!
        static let object = CodingUserInfoKey(rawValue: "bg.netinfo.Decoder.object")!
    }
}

extension Decoder {
    func rootKeyDecoder() throws -> Decoder? {
        guard let name = userInfo[CodingUserInfoKey.Decoder.rootKey] as? String, !name.isEmpty else {
            return nil
        }
        return try container(keyedBy: CustomCodingKey.self).superDecoder(forKey: .custom(named: name))
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
    /// Enum describing the result of decoding an object.
    enum Result<T: MultipleTimesDecodable>: Decodable {
        case success(T)
        case failure(Error)
        
        init(from decoder: Decoder) throws {
            do {
                if let object: T = decoder.object() {
                    try object.runDecode(from: decoder.rootKeyDecoder() ?? decoder)
                    self = .success(object)
                } else {
                    self = .success(try T.init(from: decoder.rootKeyDecoder() ?? decoder))
                }
            } catch (let error) {
                self = .failure(error)
            }
        }
    }
    
    func decode<T: MultipleTimesDecodable>(to object: T?, from data: Data?) throws -> Result<T> {
        userInfo[CodingUserInfoKey.Decoder.object] = object
        return try decode(Result<T>.self, from: data ?? Data())
    }
}
