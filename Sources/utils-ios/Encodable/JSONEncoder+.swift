//
//  File.swift
//  
//
//  Created by Miroslav Yozov on 17.12.20.
//

import Foundation

public extension JSONEncoder {
    static func encode<T: Encodable>(_ object: T, with info: [CodingUserInfoKey: Any] = [:]) throws -> Data {
        let encoder: JSONEncoder = .init(userInfo: info)
        return try encoder.encode(object)
    }
    
    convenience init(userInfo: [CodingUserInfoKey: Any]) {
        self.init()
        self.userInfo = userInfo
    }
}
