//
//  RemoteCompatible.swift
//  
//
//  Created by Miroslav Yozov on 31.10.19.
//

import Foundation

public extension Fault {
    struct RemotePageCompatible {
        static var noMorePagesCode = "remote.page.compatible.no.more.pages"
        static var noMorePages: Fault {
            return Fault(code: noMorePagesCode, enMessage: "No more pages.")
        }
    }
}


public protocol RemoteCompatible: Initable {
    associatedtype EndpointType: Endpoint
    
    var remoteState: RemoteState { get }
    var remoteEndpoint: EndpointType { get }
}

public protocol RemotePageCompatible: RemoteCompatible, Pageable where EndpointType: EndpointPageble {
    var remoteHasNextPage: Bool { get }
}


