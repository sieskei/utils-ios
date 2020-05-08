//
//  Stuff.swift
//  
//
//  Created by Miroslav Yozov on 11.11.19.
//

import Foundation

public extension Fault {
    struct RemotePermission {
        static var notAllowedCode = "remote.permission.not.allowed"
        static var notAllowed: Fault {
            return Fault(code: notAllowedCode, message: "Заявката не е позволена.")
        }
        
        static var alreadyCode = "remote.permission.already"
        static var already: Fault {
            return Fault(code: alreadyCode, message: "Заявката e вече стартирана.")
        }
    }
}

internal enum RemotePermission {
    case already
    case allowed
    case notAllowed
    case interrupt
}

public protocol Initable {
    func reinit()
}

public protocol Pageable {
    func next()
}
