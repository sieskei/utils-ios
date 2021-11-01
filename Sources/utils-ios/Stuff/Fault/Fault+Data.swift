//
//  File.swift
//  
//
//  Created by Miroslav Yozov on 19.11.20.
//

import Foundation

public extension Fault.Keys {
    static let data: Int = Int.randomIdentifier
}

public extension Fault {
    var data: Data {
        info[Keys.data] as? Data ?? .init()
    }
    
    convenience init(code: String, message: String, data: Data, parent: Error? = nil) {
        self.init(code: code, messages: [Fault.defaultLang: message], info: [Keys.data: data], parent: parent)
    }
    
    convenience init(code: String, enMessage: String, data: Data, parent: Error? = nil) {
        self.init(code: code, messages: [.en: enMessage], info: [Keys.data: data], parent: parent)
    }
    
    convenience init(code: String, messages: [Languages: String], data: Data, parent: Error? = nil) {
        self.init(code: code, messages: messages, info: [Keys.data: data], parent: parent)
    }
    
    func object<T: Decodable>() throws -> T {
        try JSONDecoder().decode(T.self, from: data)
    }
}
