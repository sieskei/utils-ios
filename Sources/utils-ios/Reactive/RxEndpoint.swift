//
//  File.swift
//  
//
//  Created by Miroslav Yozov on 14.09.20.
//

import Foundation
import RxSwift

public protocol RxEndpoint: Endpoint, ReactiveCompatible { }

public protocol RxEndpointPageble: RxEndpoint, EndpointPageble { }

public extension Reactive where Base: RxEndpoint {
    private func prepeare(userInfo ui: [CodingUserInfoKey: Any]) -> [CodingUserInfoKey: Any] {
        return ui.insert(value: base,            forKey: CodingUserInfoKey.Decoder.endpoint)
                 .insert(value: base.root,       forKey: CodingUserInfoKey.Decoder.root)
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
