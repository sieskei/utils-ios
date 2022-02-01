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
        public struct Configuration {
            public static var session: Session = .init(configuration: .default, startRequestsImmediately: false)
            public static var validation: DataRequest.Validation = Network.status200Validation
        }
        
        public static let shared: Network = {
            .init(session: Configuration.session, validation: Configuration.validation)
        }()
        
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
        
        open func upload(_ data: MultipartFormData, for url: URLRequestConvertible) -> UploadRequest {
            session.upload(multipartFormData: data, with: url).validate(validation)
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
    
    public enum UploadEvent<T: Decodable> {
        case start
        case progress(Double)
        case done(T)
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
    func data(url: URLRequestConvertible, waitForReachability: Bool = false) -> Single<Data> {
        let single: Single<Data> = .create { single in
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
        
        if waitForReachability {
            return Base.rx.isReachable
                .filter { $0 }
                .take(1)
                .asSingle()
                .flatMap { _ in single }
        } else {
            return single
        }
    }
    
    func download(url source: URLRequestConvertible, to destination: DownloadRequest.Destination? = nil, estimatedSizeInBytes: Int = -1, waitForReachability: Bool = false) -> Observable<Base.DownloadEvent> {
        let observable: Observable<Base.DownloadEvent> = .create { observer in
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
        
        if waitForReachability {
            return Base.rx.isReachable
                .filter { $0 }
                .take(1)
                .flatMap { _ in observable }
        } else {
            return observable
        }
    }
    
    func download(url: URLRequestConvertible, to destination: DownloadRequest.Destination? = nil, waitForReachability flag: Bool = false) -> Single<URL> {
        download(url: url, to: destination, waitForReachability: flag)
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
    
    func upload<T: Decodable>(data: MultipartFormData, to url: URLRequestConvertible, estimatedSizeInBytes: Int = -1, userInfo: [CodingUserInfoKey: Any] = [:], waitForReachability: Bool = false) -> Observable<Base.UploadEvent<T>> {
        let observable: Observable<Base.UploadEvent<T>> = .create { observer in
            observer.onNext(.start)
            
            let request = base.upload(data, for: url)
                .uploadProgress(queue: Utils.Task.concurrentUtilityQueue) { progress in
                    observer.onNext(.progress(progress.totalUnitCount > 0 ? progress.fractionCompleted :
                                                min(1, Double(progress.completedUnitCount) / Double(estimatedSizeInBytes))))
                }
                .responseData(queue: Utils.Task.concurrentUtilityQueue) {
                    switch $0.result {
                    case .success(let data):
                        do {
                            let o: T = try JSONDecoder(userInfo: userInfo).decode(from: data)
                            observer.onNext(.done(o))
                            observer.onCompleted()
                        } catch {
                            Utils.Log.error("Utils.Network: unable to decode data from url.", url, error)
                            observer.onError(error)
                        }
                    case .failure(let error):
                        Utils.Log.error("Utils.Network: unable to upload data to url.", url, error)
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
        
        if waitForReachability {
            return Base.rx.isReachable
                .filter { $0 }
                .take(1)
                .flatMap { _ in observable }
        } else {
            return observable
        }
    }
    
    func serialize<T: Decodable>(url: URLRequestConvertible, userInfo: [CodingUserInfoKey: Any] = [:], waitForReachability flag: Bool = false) -> Single<T> {
        data(url: url, waitForReachability: flag).map {
            // print("[T] serialize:", Thread.current)
            try JSONDecoder(userInfo: userInfo).decode(from: $0)
        }
    }
    
    func serialize<T: Redecodable>(url: URLRequestConvertible, to object: T, userInfo: [CodingUserInfoKey: Any] = [:], waitForReachability flag: Bool = false) -> Single<T> {
        data(url: url, waitForReachability: flag).map {
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
    
    static func data(url: URLRequestConvertible, waitForReachability flag: Bool = false) -> Single<Data> {
        Base.shared.rx.data(url: url, waitForReachability: flag)
    }
    
    static func download(url: URLRequestConvertible, to destination: DownloadRequest.Destination? = nil, waitForReachability flag: Bool = false) -> Single<URL> {
        Base.shared.rx.download(url: url, to: destination, waitForReachability: flag)
    }
    
    static func download(url: URLRequestConvertible, to destination: DownloadRequest.Destination? = nil, estimatedSizeInBytes size: Int = -1, waitForReachability flag: Bool = false) -> Observable<Base.DownloadEvent> {
        Base.shared.rx.download(url: url, to: destination, estimatedSizeInBytes: size, waitForReachability: flag)
    }
    
    static func upload<T: Decodable>(data: MultipartFormData, to url: URLRequestConvertible, estimatedSizeInBytes size: Int = -1, userInfo: [CodingUserInfoKey: Any] = [:], waitForReachability flag: Bool = false) -> Observable<Base.UploadEvent<T>> {
        Base.shared.rx.upload(data: data, to: url, estimatedSizeInBytes: size, userInfo: userInfo, waitForReachability: flag)
    }
    
    static func serialize<T: Decodable>(url: URLRequestConvertible, userInfo: [CodingUserInfoKey: Any] = [:], waitForReachability flag: Bool = false) -> Single<T> {
        Base.shared.rx.serialize(url: url, userInfo: userInfo, waitForReachability: flag)
    }
    
    static func serialize<T: Redecodable>(url: URLRequestConvertible, to object: T, userInfo: [CodingUserInfoKey: Any] = [:], waitForReachability flag: Bool = false) -> Single<T> {
        Base.shared.rx.serialize(url: url, to: object, userInfo: userInfo, waitForReachability: flag)
    }
    
    static func serialize<T: Decodable>(interval: RxTimeInterval, url: URLRequestConvertible, userInfo: [CodingUserInfoKey: Any] = [:]) -> Observable<T> {
        Base.shared.rx.serialize(interval: interval, url: url, userInfo: userInfo)
    }
}
