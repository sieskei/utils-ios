//
//  MultipleTimesDecodable.swift
//  
//
//  Created by Miroslav Yozov on 30.10.19.
//

import Foundation

public enum DecodeType: Int {
    case replace
    case append
}

public extension CodingUserInfoKey.Decoder {
    static let decodeType = CodingUserInfoKey(rawValue: "bg.netinfo.Decoder.decodeType")!
}

public extension Decoder {
    var decodeType: DecodeType {
        return userInfo[CodingUserInfoKey.Decoder.decodeType] as? DecodeType ?? .replace
    }
}

public protocol MultipleTimesDecodable: Decodable, Synchronized, IdentityEquitable {
    func runDecode(from decoder: Decoder) throws
    func decode(from decoder: Decoder) throws
}

extension MultipleTimesDecodable {
    public func runDecode(from decoder: Decoder) throws {
        try synchronized {
            try decode(from: decoder)
        }
    }
}
