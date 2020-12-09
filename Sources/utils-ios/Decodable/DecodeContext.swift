//
//  DecodeContext.swift
//  
//
//  Created by Miroslav Yozov on 8.12.20.
//

import Foundation

public class DecodeContext {
    public var userInfo: [CodingUserInfoKey: Any]
    
    init(_ userInfo: [CodingUserInfoKey: Any] = [:]) {
        self.userInfo = userInfo
    }
}

internal class InvalidDecodeContext: DecodeContext {
    override var userInfo: [CodingUserInfoKey : Any] {
        get { fatalError("Invalid decode context!") }
        set { fatalError("Invalid decode context!") }
    }
    
    init() {
        super.init()
    }
}

public extension CodingUserInfoKey.Decoder {
    static let context = CodingUserInfoKey(rawValue: "ios.utils.Decoder.context")!
}

public extension Decoder {
    var context: DecodeContext {
        (userInfo[CodingUserInfoKey.Decoder.context] as? DecodeContext) ?? InvalidDecodeContext()
    }
}
