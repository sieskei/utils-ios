//
//  RxEndpointWrapper.swift
//  
//
//  Created by Miroslav Yozov on 14.09.20.
//

import Foundation
import RxSwift

public class RxEndpointWrapper: ReactiveCompatible {
    let origin: Endpoint
    
    init(_ origin: Endpoint) {
        self.origin = origin
    }
}

public extension Reactive where Base: RxEndpointWrapper {
    private func prepeare(userInfo ui: [CodingUserInfoKey: Any]) -> [CodingUserInfoKey: Any] {
        return ui.insert(value: base.origin,            forKey: CodingUserInfoKey.Decoder.endpoint)
                 .insert(value: base.origin.root,       forKey: CodingUserInfoKey.Decoder.root)
                 .insert(value: base.origin.decodeType, forKey: CodingUserInfoKey.Decoder.decodeType)
    }
    
    func data(network: Utils.Network = .default) -> Single<Data> {
        network.rx.data(url: base.origin, interceptor: base.origin.interceptor)
    }
    
    func serialize<T: Decodable>(userInfo ui: [CodingUserInfoKey: Any] = [:], network: Utils.Network = .default) -> Single<T> {
        network.rx.serialize(url: base.origin, interceptor: base.origin.interceptor, userInfo: prepeare(userInfo: ui))
    }
    
    func serialize<T: Decodable>(interval: RxTimeInterval, userInfo ui: [CodingUserInfoKey: Any] = [:], network: Utils.Network = .default) -> Observable<T> {
        network.rx.serialize(interval: interval, url: base.origin, interceptor: base.origin.interceptor, userInfo: prepeare(userInfo: ui))
    }

    func serialize<T: MultipleTimesDecodable>(to object: T, userInfo ui: [CodingUserInfoKey: Any] = [:], network: Utils.Network = .default) -> Single<T> {
        network.rx.serialize(url: base.origin, to: object, interceptor: base.origin.interceptor, userInfo: prepeare(userInfo: ui))
    }
}

public extension Endpoint {
    /// Reactive extensions.
    static var rx: Reactive<RxEndpointWrapper>.Type {
        Reactive<RxEndpointWrapper>.self
    }
    
    /// Reactive extensions.
    var rx: Reactive<RxEndpointWrapper> {
        RxEndpointWrapper(self).rx
    }
}
