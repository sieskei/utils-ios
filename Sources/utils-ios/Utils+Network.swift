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
    }
}

public extension Fault.Utils {
    struct Network {
        public static func fail(response: HTTPURLResponse) -> Fault {
            .init(code: Fault.Codes.Utils.Network.responseFail,
                  messages: [.bg: "Неуспешна заявка.", .en: "Failed request."],
                  info: [Fault.Keys.Utils.Network.response: response])
        }
    }
}

extension Session: AssociatedObjectCompatible {
    public var network: Utils.Network? {
        return get(for: "utils.network") { () -> Utils.Network? in return nil }
    }
}

extension Utils {
    open class Network {
        public static let shared: Network = .init(factory: Factory.shared)
        
        public let session: Session
        public let validation: DataRequest.Validation
        
        public init(factory: Factory) {
            session = factory.session
            validation = factory.validation
        }
        
        public init(session s: Session, validation v: @escaping DataRequest.Validation) {
            session = s
            validation = v
            
            session.set(value: self, for: "utils.network", policy: .weak)
        }
        
        open func request(for url: URLRequestConvertible) -> DataRequest {
            session.request(url).validate(validation)
        }
    }
}

// MARK: Inner types.
extension Utils.Network {
    public typealias ParametersEncodingType = ParameterEncoding
    
    public typealias Method = HTTPMethod
    public typealias Parameters = [String: Any]
    public typealias Map = [AnyHashable: Any]
    
    open class Factory {
        // Can be project dependancy factory.
        public static var shared: Factory = .init()
        
        open var session: Session {
            .init(configuration: .default, startRequestsImmediately: false)
        }
        
        open var validation: DataRequest.Validation {
            { _, r, _ in
                switch r.statusCode {
                case 200:
                    return .success(())
                default:
                    return .failure(Fault.Utils.Network.fail(response: r))
                }
            }
        }
        
        public init() { }
    }
}


// MARK: Reachable helper.
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
    
    func serialize<T: Decodable>(url: URLRequestConvertible, userInfo: [CodingUserInfoKey: Any] = [:]) -> Single<T> {
        data(url: url).map {
            // print("[T] serialize:", Thread.current)
            try JSONDecoder(userInfo: userInfo).decode(from: $0)
        }
    }
    
    func serialize<T: MultipleTimesDecodable>(url: URLRequestConvertible, to object: T, userInfo: [CodingUserInfoKey: Any] = [:]) -> Single<T> {
        data(url: url).map {
            // print("[T] serialize to:", Thread.current)
            try JSONDecoder(userInfo: userInfo).decode(to: object, from: $0)
        }
    }
    
    func serialize<T: Decodable>(interval: RxTimeInterval, url: URLRequestConvertible, userInfo: [CodingUserInfoKey: Any] = [:]) -> Observable<T> {
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


// MARK: Class reactive extension.
public extension Reactive where Base: Utils.Network {
    static var isReachable: Observable<Bool> {
        Base.isReachableValue.asObservable()
    }
    
    static func data(url: URLRequestConvertible) -> Single<Data> {
        Base.shared.rx.data(url: url)
    }
    
    static func serialize<T: Decodable>(url: URLRequestConvertible, userInfo: [CodingUserInfoKey: Any] = [:]) -> Single<T> {
        Base.shared.rx.serialize(url: url, userInfo: userInfo)
    }
    
    static func serialize<T: MultipleTimesDecodable>(url: URLRequestConvertible, to object: T, userInfo: [CodingUserInfoKey: Any] = [:]) -> Single<T> {
        Base.shared.rx.serialize(url: url, to: object, userInfo: userInfo)
    }
    
    static func serialize<T: Decodable>(interval: RxTimeInterval, url: URLRequestConvertible, userInfo: [CodingUserInfoKey: Any] = [:]) -> Observable<T> {
        Base.shared.rx.serialize(interval: interval, url: url, userInfo: userInfo)
    }
}
