//
//  RemoteCompatible.swift
//  
//
//  Created by Miroslav Yozov on 31.10.19.
//

import Foundation

public extension Fault.Codes {
    struct RemotePageCompatible {
        static var noMorePages = "remote.page.compatible.no.more.pages"
    }
}

public extension Fault {
    struct RemotePageCompatible {
        static var noMorePages: Fault {
            return Fault(code: Fault.Codes.RemotePageCompatible.noMorePages, enMessage: "No more pages.")
        }
    }
}

public protocol RemoteCompatible: Redecodable, Initable {
    associatedtype EndpointType: Endpoint
    
    var network: Utils.Network { get }
    var remoteState: RemoteState { get }
    var remoteEndpoint: EndpointType { get }
}

public protocol RemotePageCompatible: RemoteCompatible, Pageable where EndpointType: EndpointPageble {
    var remoteHasNextPage: Bool { get }
}

public extension RemoteCompatible {
    var network: Utils.Network {
        Utils.Network.shared
    }
}

