//
//  RxEndpointWrapper.swift
//  
//
//  Created by Miroslav Yozov on 14.09.20.
//

import Foundation
import RxSwift

internal class RxEndpointWrapper: ReactiveCompatible {
    let origin: Endpoint
    
    init(_ origin: Endpoint) {
        self.origin = origin
    }
}

extension Reactive where Base: RxEndpointWrapper {
    private func prepeare(userInfo ui: [CodingUserInfoKey: Any]) -> [CodingUserInfoKey: Any] {
        return ui.insert(value: base.origin,            forKey: CodingUserInfoKey.Decoder.endpoint)
                 .insert(value: base.origin.root,       forKey: CodingUserInfoKey.Decoder.root)
                 .insert(value: base.origin.decodeType, forKey: CodingUserInfoKey.Decoder.decodeType)
    }
    
    func serialize<T: Decodable>(userInfo ui: [CodingUserInfoKey: Any] = [:]) -> Single<T> {
        return Utils.Network.rx.serialize(url: base.origin, userInfo: prepeare(userInfo: ui))
    }
    
    func serialize<T: Decodable>(interval: RxTimeInterval, userInfo ui: [CodingUserInfoKey: Any] = [:]) -> Observable<T> {
        return Utils.Network.rx.serialize(interval: interval, url: base.origin, userInfo: prepeare(userInfo: ui))
    }

    func serialize<T: MultipleTimesDecodable>(to object: T, userInfo ui: [CodingUserInfoKey: Any] = [:]) -> Single<T> {
        return Utils.Network.rx.serialize(url: base.origin, to: object, userInfo: prepeare(userInfo: ui))
    }
}

internal extension Endpoint {
    var rxWrapper: RxEndpointWrapper {
        return .init(self)
    }
}
