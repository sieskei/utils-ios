//
//  Container+RxRemoteCompatible.swift
//  
//
//  Created by Miroslav Yozov on 6.11.19.
//

import Foundation

open class RemoteContainer<Element: Decodable, EndpointType: EndpointPageble>: Container<Element>, RemoteCompatible, RxRemotePageCompatible {
    // MAK: RxRemoteCompatible, RxRemotePageCompatible
    open private (set) var remoteEndpoint: EndpointType
    open private (set) var defaultRemoteState: RemoteState
    open private (set) var remoteHasNextPage = true
    
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
    
    override open func decode(from decoder: Decoder) throws {
        let decodeType = decoder.decodeType
        let currentCount = count
        
        try super.decode(from: decoder)
        
        remoteHasNextPage = decodeType == .replace ? true : currentCount < count
    }
    
    deinit {
        print(self, "deinit ...")
    }
}
