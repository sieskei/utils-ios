//
//  Container+RxRemoteCompatible.swift
//  
//
//  Created by Miroslav Yozov on 6.11.19.
//

import Foundation

public class RemoteContainer<Element: Decodable, EndpointType: EndpointPageble>:
    Container<Element>,
    RxRemoteCompatible,
    RxRemotePageCompatible {
    
    // MAK: RxRemoteCompatible, RxRemotePageCompatible
    public let remoteEndpoint: EndpointType
    public private (set) var defaultRemoteState: RemoteState
    public private (set) var remoteHasNextPage = true
    
    public required init(from decoder: Decoder) throws {
        self.remoteEndpoint = try decoder.endpoint()
        self.defaultRemoteState = .done
        try super.init(from: decoder)
    }
    
    public init(endpoint: EndpointType, elements: [Element] = []) {
        self.remoteEndpoint = endpoint
        self.defaultRemoteState = .done
        super.init(elements: elements)
    }
    
    override public func decode(from decoder: Decoder) throws {
        let decodeType = decoder.decodeType
        let currentCount = count
        
        try super.decode(from: decoder)
        
        remoteHasNextPage = decodeType == .replace ? true : currentCount < count
    }
    
    deinit {
        print(self, "deinit ...")
    }
}

extension RemoteContainer: RxMultipleTimesDecodable { }
