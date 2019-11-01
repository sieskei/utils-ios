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
    func endpoint() throws -> Endpoint {
        guard let router = userInfo[CodingUserInfoKey.Decoder.endpoint] as? Endpoint else {
            throw Fault.Endpoint.endpointMissing
        }
        
        return router
    }
}

public protocol Endpoint: URLRequestConvertible {
    var rootKey: String { get }
    
    @discardableResult
    func serialize<T: MultipleTimesDecodable>(to object: T?, userInfo: [CodingUserInfoKey: Any]) -> Single<T>
}

public extension Endpoint {
    var rootKey: String {
        return ""
    }
    
    @discardableResult
    func serialize<T: MultipleTimesDecodable>(to object: T? = nil, userInfo: [CodingUserInfoKey: Any] = [:]) -> Single<T> {
        return Utils.Network.serialize(url: self, to: object,
                                       userInfo: userInfo.insert(value: self,    forKey: CodingUserInfoKey.Decoder.endpoint)
                                                         .insert(value: rootKey, forKey: CodingUserInfoKey.Decoder.rootKey))
    }
}
