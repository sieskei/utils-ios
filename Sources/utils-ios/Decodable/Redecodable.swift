//
//  File 2.swift
//  
//
//  Created by Miroslav Yozov on 29.01.21.
//

import Foundation

public enum DecodeType: Int {
    case replace
    case append
}

public extension CodingUserInfoKey.Decoder {
    static let decodeType = CodingUserInfoKey(rawValue: "ios.utils.Decoder.decodeType")!
}

public extension Decoder {
    var decodeType: DecodeType {
        return userInfo[CodingUserInfoKey.Decoder.decodeType] as? DecodeType ?? .replace
    }
}

public protocol Redecodable: class, Synchronized {
    func runDecode(fromJson data: Data) throws
    func runDecode(from decoder: Decoder) throws
    
    func decode(from decoder: Decoder) throws
}

extension Redecodable {
    public func runDecode(fromJson data: Data) throws {
        try JSONDecoder.decode(to: self, from: data)
    }
    
    public func runDecode(from decoder: Decoder) throws {
        try synchronized {
            try decode(from: decoder)
        }
    }
}
