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
    
    let endpoint: EndpointType
    
    public required init(from decoder: Decoder) throws {
        self.endpoint = try decoder.endpoint()
        try super.init(from: decoder)
    }
    
    public var remoteEndpoint: EndpointType {
        return endpoint
    }
    
    public var remoteHasNextPage: Bool {
        return false
    }
    
    deinit {
        print(self, "deinit ...")
    }
}
