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

public protocol Endpoint: URLRequestConvertible {
    var rootKey: String { get }
    var decodeType: DecodeType { get }
    
    @discardableResult
    func serialize<T: MultipleTimesDecodable>(to object: T?, userInfo: [CodingUserInfoKey: Any]) -> Single<T>
}

public protocol EndpointPageble: Endpoint {
    func next<T: MultipleTimesDecodable>(for object: T) -> Self
}

public extension Endpoint {
    var rootKey: String {
        return ""
    }
    
    var decodeType: DecodeType {
        return .replace
    }
    
    @discardableResult
    func serialize<T: MultipleTimesDecodable>(to object: T? = nil, userInfo: [CodingUserInfoKey: Any] = [:]) -> Single<T> {
        return Utils.Network.serialize(url: self, to: object,
                                       userInfo: userInfo.insert(value: self,       forKey: CodingUserInfoKey.Decoder.endpoint)
                                                         .insert(value: rootKey,    forKey: CodingUserInfoKey.Decoder.rootKey)
                                                         .insert(value: decodeType, forKey: CodingUserInfoKey.Decoder.decodeType))
    }
}
