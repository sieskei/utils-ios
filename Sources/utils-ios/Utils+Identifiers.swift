//
//  Utils+Identifiers.swift
//  
//
//  Created by Miroslav Yozov on 20.12.21.
//

import Foundation

extension Utils {
    public struct Identifiers {
        public static let base62chars: [Character] = .init("0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz")
        public static let maxBase : UInt32 = 62
        
        public static func get(withBase base: UInt32 = maxBase, length: Int) -> String {
            var code = ""
            for _ in 0..<length {
                let random = Int(arc4random_uniform(min(base, maxBase)))
                code.append(base62chars[random])
            }
            return code
        }
    }
}
