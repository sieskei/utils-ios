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
        return self == .reachable(.ethernetOrWiFi) || self == .reachable(.wwan)
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
            return Fault(code: resposeErrorCode, message: "Неуспешна заявка.", info: [Key.HTTPStatusCode: httpCode], parent: parent)
        }
    }
}

public extension Utils {
    struct Network {
        private init() { }
        
        fileprivate static var isReachableValue: EquatableValue<Bool> = {
            guard let manager = NetworkReachabilityManager() else {
                return .init(true)
            }
            
            manager.listener = {
                let _ = manager // need to store in memory
                Utils.Network.isReachableValue.value = $0.isReachable
            }
            manager.startListening()
            
            return .init(manager.isReachable)
        }()
        
        public static var isReachable: Bool {
            return isReachableValue.value
        }
        
        public typealias ParametersEncodingType = ParameterEncoding
        
        public typealias Method = HTTPMethod
        public typealias Parameters = [String: Any]
        public typealias Map = [AnyHashable: Any]
        
        private (set) static var manager: SessionManager = {
            let configuration = URLSessionConfiguration.default
            configuration.httpAdditionalHeaders = SessionManager.defaultHTTPHeaders
            configuration.timeoutIntervalForRequest  = 30
            configuration.timeoutIntervalForResource = 30
            
            let manager = SessionManager(configuration: configuration)
            manager.startRequestsImmediately = false
            return manager
        }()
        
        static let validator: DataRequest.Validation = { request, response, data in
            guard response.statusCode != 200 else {
                return .success
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
        }
    }
}

extension Utils.Network: ReactiveCompatible { }

public extension Reactive where Base == Utils.Network {
    static var isReachable: Observable<Bool> {
        return Base.isReachableValue.asObservable()
    }
    
    static func data(url: URLRequestConvertible) -> Single<Data> {
        return Single.create { single in
            // print("[T] data create:", Thread.current)
            
            let request = Base.manager.request(url)
            request
                .validate(Base.validator)
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
            
            if !Base.manager.startRequestsImmediately {
                request.resume()
            }
            
            return Disposables.create {
                request.cancel()
            }
        }
    }
    
    static func serialize<T: Decodable>(url: URLRequestConvertible, userInfo: [CodingUserInfoKey: Any] = [:]) -> Single<T> {
        return data(url: url).map {
            // print("[T] serialize:", Thread.current)
            return try JSONDecoder(userInfo: userInfo)
                .decode(from: $0)
        }
    }
    
    static func serialize<T: MultipleTimesDecodable>(url: URLRequestConvertible, to object: T, userInfo: [CodingUserInfoKey: Any] = [:]) -> Single<T> {
        return data(url: url).map {
            // print("[T] serialize to:", Thread.current)
            return try JSONDecoder(userInfo: userInfo)
                .decode(to: object, from: $0)
        }
    }
    
    static func serialize<T: Decodable>(interval: RxTimeInterval, url: URLRequestConvertible, userInfo: [CodingUserInfoKey: Any] = [:]) -> Observable<T> {
        let serializing: EquatableValue<Bool> = .init(false)
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
