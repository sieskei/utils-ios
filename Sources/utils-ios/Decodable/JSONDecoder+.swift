//
//  File.swift
//  
//
//  Created by Miroslav Yozov on 31.10.19.
//

import Foundation

public extension Fault.Codes {
    struct Decoder {
        public static let missing = "object.missing"
    }
}

public extension Fault {
    struct Decoder {
        static var missingObject: Fault {
            .init(code: Fault.Codes.Decoder.missing, enMessage: "Missing redecodable object.")
        }
    }
}


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
    func object<T>() throws -> T {
        try Utils.castOrThrow(userInfo[CodingUserInfoKey.Decoder.object], Fault.Decoder.missingObject)
    }
}

extension JSONDecoder {
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
    
    private enum RedecodableResult<T: Redecodable>: Decodable {
        case success(T)
        case failure(Error)
        
        init(from decoder: Decoder) throws {
            do {
                let object: T = try decoder.object()
                try object.runDecode(from: decoder.rootDecoder())
                self = .success(object)
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
    static func decode<T: Redecodable>(to object: T, from data: Data, with info: [CodingUserInfoKey: Any] = [:]) throws -> T {
        let decoder: JSONDecoder = .init(userInfo: info)
        return try decoder.decode(to: object, from: data)
    }
    
    convenience init(userInfo: [CodingUserInfoKey: Any]) {
        self.init()
        self.userInfo = userInfo
    }
    
    func decode<T: Redecodable>(to object: T, from data: Data) throws -> T {
        userInfo[CodingUserInfoKey.Decoder.object] = object
        
        switch try decode(RedecodableResult<T>.self, from: data) {
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
