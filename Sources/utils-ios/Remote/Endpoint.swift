//
//  Endpoint.swift
//  
//
//  Created by Miroslav Yozov on 31.10.19.
//

import Foundation
import Alamofire

public extension Fault.Codes {
    struct Endpoint {
        public static let missing = "endpoint.missing"
    }
}

public extension Fault {
    struct Endpoint {
        static var missing: Fault {
            .init(code: Fault.Codes.Endpoint.missing, enMessage: "Missing `Еndpoint`.")
        }
    }
}

public extension CodingUserInfoKey.Decoder {
    static let endpoint = CodingUserInfoKey(rawValue: "ios.utils.Decoder.endpoint")!
}

public extension Decoder {
    func endpoint<T: Endpoint>() throws -> T {
        try Utils.castOrThrow(userInfo[CodingUserInfoKey.Decoder.endpoint], Fault.Endpoint.missing)
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
        .none
    }
    
    var decodeType: DecodeType {
        .replace
    }
    
    func prepare(response data: Data) -> Data {
        data
    }
}
