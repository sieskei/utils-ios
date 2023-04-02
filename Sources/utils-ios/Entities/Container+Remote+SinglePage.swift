//
//  File.swift
//  
//
//  Created by Miroslav Yozov on 25.08.22.
//

import Foundation

open class SinglePageRemoteContainer<Element: Decodable, EndpointType: Endpoint>: Container<Element>, RemoteCompatible, RxRemoteCompatible {
    open private (set) var remoteEndpoint: EndpointType
    open private (set) var defaultRemoteState: RemoteState
    
    open var network: Utils.Network {
        .shared
    }
    
    public required init(from decoder: Decoder) throws {
        self.remoteEndpoint = try decoder.endpoint()
        self.defaultRemoteState = .done
        try super.init(from: decoder)
    }
    
    public init(endpoint: EndpointType, remoteState: RemoteState = .done, elements: [Element] = []) {
        self.remoteEndpoint = endpoint
        self.defaultRemoteState = remoteState
        super.init(elements: elements)
    }
    
    deinit {
        Utils.Log.debug("deinit ...", self)
    }
    
}
