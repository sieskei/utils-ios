//
//  File.swift
//  
//
//  Created by Miroslav Yozov on 31.10.19.
//

import Foundation

import RxSwift
import Alamofire

public extension NetworkReachabilityManager.NetworkReachabilityStatus {
    var isReachable: Bool {
        return self == .reachable(.ethernetOrWiFi) || self == .reachable(.wwan)
    }
}

internal extension DataRequest {
    @discardableResult
    func responseJSONObject<T: MultipleTimesDecodable>(to object: T? = nil, userInfo: [CodingUserInfoKey: Any] = [:], queue: DispatchQueue? = nil, completionHandler: @escaping (DataResponse<T>) -> Void) -> Self {
        let responseSerializer = DataResponseSerializer<T> { request, response, data, error in
            if let error = error {
                return .failure(error)
            }
            
            let decoder = JSONDecoder()
            decoder.userInfo = userInfo
            do {
                switch try decoder.decode(to: object, from: data) {
                case .success(let object):
                    return .success(object)
                case .failure(let error):
                    return .failure(error)
                }
            } catch (let error) {
                return .failure(error)
            }
        }
        
        return response(queue: queue, responseSerializer: responseSerializer, completionHandler: completionHandler)
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
        
        @discardableResult
        public static func serialize<T: MultipleTimesDecodable>(url: URLRequestConvertible, to object: T? = nil, userInfo: [CodingUserInfoKey: Any] = [:]) -> Single<T> {
            return Single.create { single in
                let request = manager.request(url)
                request
                    .validate(validator)
                    .responseJSONObject(to: object, userInfo: userInfo, queue: Task.queue) { response in
                        switch response.result {
                        case .success(let object):
                            single(.success(object))
                        case .failure(let error):
                            print("Utils.Network: unable to serialize object: \(String(describing: object)) from url: \(url).")
                            print(error)
                            
                            single(.error(error))
                        }
                }
                
                if !manager.startRequestsImmediately {
                    request.resume()
                }
                
                return Disposables.create {
                    request.cancel()
                }
            }
        }
    }
}
