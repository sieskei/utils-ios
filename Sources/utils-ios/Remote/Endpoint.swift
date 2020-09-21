//
//  File.swift
//  
//
//  Created by Miroslav Yozov on 31.10.19.
//

import Foundation

import RxSwift
import Alamofire

public extension Fault {
    struct Endpoint {
        static var endpointMissingCode = "endpoint.missing"
        static var endpointMissing: Fault {
            return Fault(code: endpointMissingCode, message: "Не е наличен `Еndpoint`.")
        }
    }
}

public extension CodingUserInfoKey.Decoder {
    static let endpoint = CodingUserInfoKey(rawValue: "bg.netinfo.Decoder.endpoint")!
}

public extension Decoder {
    func endpoint<T: Endpoint>() throws -> T {
        guard let router = userInfo[CodingUserInfoKey.Decoder.endpoint] as? T else {
            throw Fault.Endpoint.endpointMissing
        }
        
        return router
    }
}

public enum EndpointRoot {
    case none
    case firstOfArray
    case key(String)
}

public protocol Endpoint: URLRequestConvertible {
    var root: EndpointRoot { get }
    var decodeType: DecodeType { get }
    
    func prepare(response data: Data) -> Data
}

public protocol EndpointPageble: Endpoint {
    func next<T: MultipleTimesDecodable>(for object: T) -> Self
}

public extension Endpoint {
    var root: EndpointRoot {
        return .none
    }
    
    var decodeType: DecodeType {
        return .replace
    }
    
    func prepare(response data: Data) -> Data {
        return data
    }
}

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
    
    public func next<T>(for object: T) -> Self where T : MultipleTimesDecodable {
        let o: EndpointPageble = Utils.castOrFatalError(origin)
        let n = o.next(for: object)
        return .init(n)
    }
}
