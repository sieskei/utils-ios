//
//  RxEndpointWrapper.swift
//  
//
//  Created by Miroslav Yozov on 14.09.20.
//

import Foundation
import Alamofire
import RxSwift

public class RxEndpointWrapper: ReactiveCompatible {
    let origin: Endpoint
    
    init(_ origin: Endpoint) {
        self.origin = origin
    }
}

public extension Reactive where Base: RxEndpointWrapper {
    private func prepeare(userInfo ui: [CodingUserInfoKey: Any]) -> [CodingUserInfoKey: Any] {
        return ui.insert(value: base.origin,                   forKey: CodingUserInfoKey.Decoder.endpoint)
                 .insert(value: base.origin.verboseCodingData, forKey: CodingUserInfoKey.Decoder.verboseCodingData)
                 .insert(value: base.origin.root,              forKey: CodingUserInfoKey.Decoder.root)
                 .insert(value: base.origin.decodeType,        forKey: CodingUserInfoKey.Decoder.decodeType)
    }
    
    func data(network: Utils.Network = .shared, waitForReachability flag: Bool = false) -> Single<Data> {
        network.rx.data(url: base.origin, waitForReachability: flag)
    }
    
    func download(to destination: DownloadRequest.Destination? = nil, network: Utils.Network = .shared, waitForReachability flag: Bool = false) -> Single<URL> {
        network.rx.download(url: base.origin, to: destination, waitForReachability: flag)
    }
    
    func download(to destination: DownloadRequest.Destination? = nil, estimatedSizeInBytes size: Int = -1, network: Utils.Network = .shared, waitForReachability flag: Bool = false) -> Observable<Utils.Network.DownloadEvent> {
        network.rx.download(url: base.origin, to: destination, estimatedSizeInBytes: size, waitForReachability: flag)
    }
    
    func upload<T: Decodable>(data: MultipartFormData, estimatedSizeInBytes size: Int = -1, userInfo ui: [CodingUserInfoKey: Any] = [:], network: Utils.Network = .shared, waitForReachability flag: Bool = false) -> Observable<Utils.Network.UploadEvent<T>> {
        network.rx.upload(data: data, to: base.origin, estimatedSizeInBytes: size, userInfo: prepeare(userInfo: ui), waitForReachability: flag)
    }
    
    func serialize<T: Decodable>(userInfo ui: [CodingUserInfoKey: Any] = [:], network: Utils.Network = .shared, waitForReachability flag: Bool = false) -> Single<T> {
        network.rx.serialize(url: base.origin, userInfo: prepeare(userInfo: ui), waitForReachability: flag)
    }
    
    func serialize<T: Decodable>(interval: RxTimeInterval, userInfo ui: [CodingUserInfoKey: Any] = [:], network: Utils.Network = .shared) -> Observable<T> {
        network.rx.serialize(interval: interval, url: base.origin, userInfo: prepeare(userInfo: ui))
    }

    func serialize<T: Redecodable>(to object: T, userInfo ui: [CodingUserInfoKey: Any] = [:], network: Utils.Network = .shared, waitForReachability flag: Bool = false) -> Single<T> {
        network.rx.serialize(url: base.origin, to: object, userInfo: prepeare(userInfo: ui), waitForReachability: flag)
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
