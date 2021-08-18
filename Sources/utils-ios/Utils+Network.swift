//
//  Utils+Network.swift
//  
//
//  Created by Miroslav Yozov on 31.10.19.
//

import Foundation

import RxSwift
import Alamofire

internal extension NetworkReachabilityManager.NetworkReachabilityStatus {
    var isReachable: Bool {
        switch self {
        case .reachable:
            return true
        default:
            return false
        }
    }
}

public extension Fault.Keys.Utils {
    struct Network {
        public static let response = "HTTPURLResponse"
    }
}

public extension Fault.Codes.Utils {
    struct Network {
        public static var responseFail = "utils.network.response.fail"
        public static var downloadFail = "utils.network.download.missing.file"
    }
}

public extension Fault.Utils {
    struct Network {
        public static var downloadFail: Fault {
            .init(code: Fault.Codes.Utils.Network.downloadFail,
                  messages: [.bg: "Неуспешно сваляне на файл.", .en: "Failed download."])
        }
        
        public static func fail(response: HTTPURLResponse) -> Fault {
            .init(code: Fault.Codes.Utils.Network.responseFail,
                  messages: [.bg: "Неуспешна заявка.", .en: "Failed request."],
                  info: [Fault.Keys.Utils.Network.response: response])
        }
    }
}

extension Utils {
    open class Network {
        public static let shared: Network = .init(session: .init(configuration: .default, startRequestsImmediately: false),
                                                  validation: Network.status200Validation)
        
        public let session: Session
        public let validation: DataRequest.Validation
        
        public init(session s: Session, validation v: @escaping DataRequest.Validation) {
            session = s
            validation = v
        }
        
        open func request(for url: URLRequestConvertible) -> DataRequest {
            session.request(url).validate(validation)
        }
        
        open func download(for url: URLRequestConvertible, to destination: DownloadRequest.Destination? = nil) -> DownloadRequest {
            session.download(url, to: destination)
        }
    }
}

// MARK: Inner types.
extension Utils.Network {
    public typealias ParametersEncodingType = ParameterEncoding
    
    public typealias Method = HTTPMethod
    public typealias Parameters = [String: Any]
    public typealias Map = [AnyHashable: Any]
    
    public enum DownloadEvent {
        case start
        case progress(Double)
        case done(URL)
    }
    
    public static let status200Validation: DataRequest.Validation = {
        { _, r, _ in
            switch r.statusCode {
            case 200:
                return .success(())
            default:
                return .failure(Fault.Utils.Network.fail(response: r))
            }
        }
    }()
}


// MARK: Reachable helper.
public extension Utils.Network {
    fileprivate static var isReachableValue: Value<Bool> = {
        guard let manager = NetworkReachabilityManager() else {
            return .init(true)
        }
        
        manager.startListening {
            let _ = manager // need to store in memory
            Utils.Network.isReachableValue.value = $0.isReachable
        }
        
        return .init(manager.isReachable)
    }()
    
    static var isReachable: Bool {
        isReachableValue.value
    }
}


// MARK: Reactive compatible.
extension Utils.Network: ReactiveCompatible { }

// MARK: Instance reactive extension.
public extension Reactive where Base: Utils.Network {
    func data(url: URLRequestConvertible) -> Single<Data> {
        Single.create { single in
            // print("[T] data create:", Thread.current)
            
            let request = base.request(for: url)
                .responseData(queue: Utils.Task.concurrentUtilityQueue) {
                    // print("[T] data.responseData:", Thread.current)
                    
                    switch $0.result {
                    case .success(let data):
                        single(.success(data))
                    case .failure(let error):
                        Utils.Log.error("Utils.Network: unable to get data from url.", url, error)
                        single(.failure(error))
                    }
            }
            
            if !base.session.startRequestsImmediately {
                request.resume()
            }
            
            return Disposables.create {
                request.cancel()
            }
        }
    }
    
    func download(url source: URLRequestConvertible, to destination: DownloadRequest.Destination? = nil, estimatedSizeInBytes: Int64 = -1) -> Observable<Base.DownloadEvent> {
        Observable.create { observer in
            observer.onNext(.start)
            
            let request = base.download(for: source, to: destination)
                .downloadProgress(closure: { progress in
                    observer.onNext(.progress(progress.totalUnitCount > 0 ? progress.fractionCompleted :
                                                min(1, Double(progress.completedUnitCount) / Double(estimatedSizeInBytes))))
                })
                .response(queue: Utils.Task.concurrentUtilityQueue) {
                    switch $0.result {
                    case .success(let url):
                        if let url = url {
                            observer.onNext(.done(url))
                            observer.onCompleted()
                        } else {
                            Utils.Log.error("Utils.Network: download failure, missing destination url.", source)
                            observer.onError(Fault.Utils.Network.downloadFail)
                        }
                    case .failure(let error):
                        Utils.Log.error("Utils.Network: download failure.", source, error)
                        observer.onError(error)
                    }
                }
            
            if !base.session.startRequestsImmediately {
                request.resume()
            }
            
            return Disposables.create {
                request.cancel()
            }
        }
    }
    
    func download(url: URLRequestConvertible, to destination: DownloadRequest.Destination? = nil) -> Single<URL> {
        download(url: url, to: destination)
            .filterMap {
                switch $0 {
                case .done(let url):
                    return .map(url)
                default:
                    return .ignore
                }
            }
            .take(1)
            .asSingle()
    }
    
    func serialize<T: Decodable>(url: URLRequestConvertible, userInfo: [CodingUserInfoKey: Any] = [:]) -> Single<T> {
        data(url: url).map {
            // print("[T] serialize:", Thread.current)
            try JSONDecoder(userInfo: userInfo).decode(from: $0)
        }
    }
    
    func serialize<T: Redecodable>(url: URLRequestConvertible, to object: T, userInfo: [CodingUserInfoKey: Any] = [:]) -> Single<T> {
        data(url: url).map {
            // print("[T] serialize to:", Thread.current)
            try JSONDecoder(userInfo: userInfo).decode(to: object, from: $0)
        }
    }
    
    func serialize<T: Decodable>(interval: RxTimeInterval, url: URLRequestConvertible, userInfo: [CodingUserInfoKey: Any] = [:]) -> Observable<T> {
        let serializing: Value<Bool> = .init(false)
        return Utils.rx.interval(interval)
            .pausable(Utils.Network.rx.isReachable)
            .pausable(serializing.map { !$0 })
            .flatMapLatest { _ in
                serialize(url: url, userInfo: userInfo)
                    .do(onSubscribe: {
                        serializing.value = true
                    }, onDispose: {
                        serializing.value = false
                    })
            }
    }
}


// MARK: Class reactive extension.
public extension Reactive where Base: Utils.Network {
    static var isReachable: Observable<Bool> {
        Base.isReachableValue.asObservable()
    }
    
    static func data(url: URLRequestConvertible) -> Single<Data> {
        Base.shared.rx.data(url: url)
    }
    
    static func download(url: URLRequestConvertible, to destination: DownloadRequest.Destination? = nil) -> Single<URL> {
        Base.shared.rx.download(url: url, to: destination)
    }
    
    static func download(url: URLRequestConvertible, to destination: DownloadRequest.Destination? = nil, estimatedSizeInBytes size: Int64 = -1) -> Observable<Base.DownloadEvent> {
        Base.shared.rx.download(url: url, to: destination, estimatedSizeInBytes: size)
    }
    
    static func serialize<T: Decodable>(url: URLRequestConvertible, userInfo: [CodingUserInfoKey: Any] = [:]) -> Single<T> {
        Base.shared.rx.serialize(url: url, userInfo: userInfo)
    }
    
    static func serialize<T: Redecodable>(url: URLRequestConvertible, to object: T, userInfo: [CodingUserInfoKey: Any] = [:]) -> Single<T> {
        Base.shared.rx.serialize(url: url, to: object, userInfo: userInfo)
    }
    
    static func serialize<T: Decodable>(interval: RxTimeInterval, url: URLRequestConvertible, userInfo: [CodingUserInfoKey: Any] = [:]) -> Observable<T> {
        Base.shared.rx.serialize(interval: interval, url: url, userInfo: userInfo)
    }
}
