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

public protocol Endpoint: URLRequestConvertible, ReactiveCompatible {
    var rootKey: String { get }
    var decodeType: DecodeType { get }
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
}

public extension Reactive where Base: Endpoint {
    private func prepeare(userInfo ui: [CodingUserInfoKey: Any]) -> [CodingUserInfoKey: Any] {
        return ui.insert(value: base,            forKey: CodingUserInfoKey.Decoder.endpoint)
                 .insert(value: base.rootKey,    forKey: CodingUserInfoKey.Decoder.rootKey)
                 .insert(value: base.decodeType, forKey: CodingUserInfoKey.Decoder.decodeType)
    }
    
    func serialize<T: Decodable>(userInfo ui: [CodingUserInfoKey: Any] = [:]) -> Single<T> {
        return Utils.Network.rx.serialize(url: base, userInfo: prepeare(userInfo: ui))
    }
    
    func serialize<T: Decodable>(interval: RxTimeInterval, userInfo ui: [CodingUserInfoKey: Any] = [:]) -> Observable<T> {
        return Utils.Network.rx.serialize(interval: interval, url: base, userInfo: prepeare(userInfo: ui))
    }

    func serialize<T: MultipleTimesDecodable>(to object: T, userInfo ui: [CodingUserInfoKey: Any] = [:]) -> Single<T> {
        return Utils.Network.rx.serialize(url: base, to: object, userInfo: prepeare(userInfo: ui))
    }
}
