//
//  String+.swift
//  
//
//  Created by Miroslav Yozov on 3.01.20.
//

import Foundation

public extension String {
    var fromBase64: String? {
        guard let data = Data(base64Encoded: self) else {
            return nil
        }

        return String(data: data, encoding: .utf8)
    }
    
    var base64: String {
        return Data(utf8).base64EncodedString()
    }
}
