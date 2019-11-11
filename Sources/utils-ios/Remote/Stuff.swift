//
//  Stuff.swift
//  
//
//  Created by Miroslav Yozov on 11.11.19.
//

import Foundation

internal enum RemotePermission {
    case already
    case allowed
    case notAllowed
    case interrupt(Interruptible)
}

public protocol Initable {
    func reinit()
}

public protocol Pageable {
    func next()
}
