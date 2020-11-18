//
//  File.swift
//  
//
//  Created by Miroslav Yozov on 31.10.19.
//

import Foundation

import RxSwift
import Alamofire

internal extension NetworkReachabilityManager.NetworkReachabilityStatus {
    var isReachable: Bool {
        return self == .reachable(.ethernetOrWiFi) || self == .reachable(.cellular)
    }
}

public extension Fault.Utils {
    struct Network {
        public struct Key {
            static let HTTPStatusCode = "HTTPStatusCode"
        }
        
        public static let resposeErrorCode = "Tools.Network.resposeError"
        public static func resposeError(with message: String) -> Fault {
            return Fault(code: resposeErrorCode, message: message)
        }
        
        public static let responseUnknownCode = "Tools.Network.responseUnkwnon"
        public static func responseUnknown(with httpCode: Int, parent: Error? = nil) -> Fault {
            return Fault(code: resposeErrorCode, messages: [.bg: "Неуспешна заявка.", .en: "Failed request."], info: [Key.HTTPStatusCode: httpCode], parent: parent)
        }
    }
}

public extension Utils {
    struct Network {
        public typealias ParametersEncodingType = ParameterEncoding
        
        public typealias Method = HTTPMethod
        public typealias Parameters = [String: Any]
        public typealias Map = [AnyHashable: Any]
        
        public static let `default`: Network = .init()
        
        fileprivate let session: Session
        fileprivate let validator: DataRequest.Validation
        
        public init(session s: Session, validator v: @escaping DataRequest.Validation) {
            session = s
            validator = v
        }
        
        public init() {
            self.init(session: {
                let configuration = URLSessionConfiguration.default
                configuration.timeoutIntervalForRequest  = 30
                configuration.timeoutIntervalForResource = 30
                let manager = Session(configuration: configuration, startRequestsImmediately: false)
                return manager
            }(), validator: { request, response, data in
                guard response.statusCode != 200 else {
                    return .success(Void())
                }
                
                struct ResposeError: Decodable {
                    let message: String
                }
                
                let fault: Fault
                
                do {
                    let decoder = JSONDecoder()
                    let responseError = try decoder.decode(ResposeError.self, from: data ?? Data())
                    fault = Fault.Utils.Network.resposeError(with: responseError.message)
                } catch (let error) {
                    fault = Fault.Utils.Network.responseUnknown(with: response.statusCode, parent: error)
                }
                
                return .failure(fault)
            })
        }
    }
}

public extension Utils.Network {
    fileprivate static var isReachableValue: EquatableValue<Bool> = {
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

extension Utils.Network: ReactiveCompatible { }

// MARK: Instance reactive extension.
public extension Reactive where Base == Utils.Network {
    func data(url: URLRequestConvertible, interceptor: RequestInterceptor? = nil) -> Single<Data> {
        Single.create { single in
            // print("[T] data create:", Thread.current)
            
            let request = base.session.request(url, interceptor: interceptor)
            request
                .validate(base.validator)
                .responseData(queue: Utils.Task.concurrentUtilityQueue) {
                    // print("[T] data.responseData:", Thread.current)
                    
                    switch $0.result {
                    case .success(let data):
                        single(.success(data))
                    case .failure(let error):
                        print("Utils.Network: unable to get data from url: \(url).")
                        print(error)
                        
                        single(.error(error))
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
    
    func serialize<T: Decodable>(url: URLRequestConvertible, interceptor: RequestInterceptor? = nil, userInfo: [CodingUserInfoKey: Any] = [:]) -> Single<T> {
        data(url: url, interceptor: interceptor).map {
            // print("[T] serialize:", Thread.current)
            try JSONDecoder(userInfo: userInfo).decode(from: $0)
        }
    }
    
    func serialize<T: MultipleTimesDecodable>(url: URLRequestConvertible, to object: T, interceptor: RequestInterceptor? = nil, userInfo: [CodingUserInfoKey: Any] = [:]) -> Single<T> {
        data(url: url, interceptor: interceptor).map {
            // print("[T] serialize to:", Thread.current)
            try JSONDecoder(userInfo: userInfo).decode(to: object, from: $0)
        }
    }
    
    func serialize<T: Decodable>(interval: RxTimeInterval, url: URLRequestConvertible, interceptor: RequestInterceptor? = nil, userInfo: [CodingUserInfoKey: Any] = [:]) -> Observable<T> {
        let serializing: EquatableValue<Bool> = .init(false)
        return Utils.rx.interval(interval)
            .pausable(Utils.Network.rx.isReachable)
            .pausable(serializing.map { !$0 })
            .flatMapLatest { _ in
                serialize(url: url, interceptor: interceptor, userInfo: userInfo)
                    .do(onSubscribe: {
                        serializing.value = true
                    }, onDispose: {
                        serializing.value = false
                    })
            }
    }
}


// MARK: Class reactive extension.
public extension Reactive where Base == Utils.Network {
    static var isReachable: Observable<Bool> {
        Base.isReachableValue.asObservable()
    }
    
    static func data(url: URLRequestConvertible, interceptor: RequestInterceptor? = nil) -> Single<Data> {
        Base.default.rx.data(url: url, interceptor: interceptor)
    }
    
    static func serialize<T: Decodable>(url: URLRequestConvertible, interceptor: RequestInterceptor? = nil, userInfo: [CodingUserInfoKey: Any] = [:]) -> Single<T> {
        Base.default.rx.serialize(url: url, interceptor: interceptor, userInfo: userInfo)
    }
    
    static func serialize<T: MultipleTimesDecodable>(url: URLRequestConvertible, to object: T, interceptor: RequestInterceptor? = nil, userInfo: [CodingUserInfoKey: Any] = [:]) -> Single<T> {
        Base.default.rx.serialize(url: url, to: object, interceptor: interceptor, userInfo: userInfo)
    }
    
    static func serialize<T: Decodable>(interval: RxTimeInterval, url: URLRequestConvertible, interceptor: RequestInterceptor? = nil, userInfo: [CodingUserInfoKey: Any] = [:]) -> Observable<T> {
        Base.default.rx.serialize(interval: interval, url: url, interceptor: interceptor, userInfo: userInfo)
    }
}
