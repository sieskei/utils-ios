//
//  RemoteCompatible.swift
//  
//
//  Created by Miroslav Yozov on 31.10.19.
//

import Foundation

internal enum RemotePermission {
    case already
    case allowed
    case notAllowed
    case interrupt(Interruptible)
}

public protocol RemoteCompatible {
    var remoteState: RemoteState { get }
    var remoteEndpoint: Endpoint { get }
    
    func reinit()
}

public protocol RemotePagableCompatible: RemoteCompatible {
    var remoteHasNextPage: Bool { get }
    var remoteNextPageEndpoint: Endpoint { get }
    
    func nextPage()
}
