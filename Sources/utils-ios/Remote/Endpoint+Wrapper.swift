//
//  Endpoint+Wrapper.swift
//  
//
//  Created by Miroslav Yozov on 1.11.20.
//

import Foundation

public class EndpointWrapper: Endpoint {
    let origin: Endpoint
    
    public init(_ origin: Endpoint) {
        self.origin = origin
    }
    
    public var root: EndpointRoot {
        origin.root
    }
    
    public var decodeType: DecodeType {
        origin.decodeType
    }
    
    public func prepare(response data: Data) -> Data {
        origin.prepare(response: data)
    }
    
    public func asURLRequest() throws -> URLRequest {
        try origin.asURLRequest()
    }
}

public class EndpointPagebleWrapper: EndpointWrapper, EndpointPageble {
    public required init(_ origin: EndpointPageble) {
        super.init(origin)
    }
    
    public func next(for object: Redecodable) -> Self {
        let o: EndpointPageble = Utils.castOrFatalError(origin)
        let n = o.next(for: object)
        return .init(n)
    }
}
