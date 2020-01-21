//
//  Fault.swift
//  
//
//  Created by Miroslav Yozov on 31.10.19.
//

import Foundation

/// Describes a arror with message and more data.
public class Fault: Error, CustomStringConvertible {
    private enum CodingKeys: String, CodingKey {
        case error
    }
    
    public static var domain: String {
        return "bg.netinfo.fault"
    }
    
    /// Full fault code: Fault.codePrefix + "." + 'code'
    public static func code(for code: String) -> String {
        return "\(Fault.domain).\(code)"
    }
    
    public var domain: String {
        return Fault.domain
    }
    
    public var identifier: String {
        return Fault.code(for: code)
    }
    
    public let code: String
    public let message: String
    public let info: [AnyHashable: Any]
    public let parent: Error?
    
    public init(code: String, message: String, info: [AnyHashable: Any] = [:], parent: Error? = nil) {
        self.code = code
        self.message = message
        self.info = info
        self.parent = parent
    }
    
    public var description: String {
        return "Fault { identifier: \(identifier), message: \(message), parent: \(String(describing: parent)) }"
    }
}


// MARK: Basic `Fault` instances.
public extension Fault {
    static var cancelledCode = "cancelled"
    static var cancelled: Fault {
        return Fault(code: cancelledCode, message: "Спряна операция.")
    }
    
    static var notConnectedToInternetCode = "notConnectedToInternet"
    static var notConnectedToInternet: Fault {
        return Fault(code: notConnectedToInternetCode, message: "Няма връзка с интернет.")
    }
    
    static var errorCode = "error"
    static func error(_ error: Error? = nil) -> Fault {
        return Fault(code: errorCode, message: "Непозната грешка.", parent: error)
    }
}

// MARK: NSError help properties.
public extension NSError {
    var isCancelledURLRequest: Bool {
        return domain == NSURLErrorDomain && code == NSURLErrorCancelled
    }
    
    var isNotConnectedToInternet: Bool {
        return domain == NSURLErrorDomain && code == NSURLErrorNotConnectedToInternet
    }
}

// MARK: Error help properties.
public extension Error {
    var nsError: NSError {
        return self as NSError
    }
    
    var isCancelledURLRequest: Bool {
        return nsError.isCancelledURLRequest
    }
    
    var isNotConnectedToInternet: Bool {
        return nsError.isNotConnectedToInternet
    }
}

// MARK: Convert `Error` to `Fault`.
public extension Error {
    var fault: Fault {
        if let fault = self as? Fault {
            return fault
        } else {
            if isNotConnectedToInternet {
                return .notConnectedToInternet
            } else if isCancelledURLRequest {
                return .cancelled
            } else {
                return .error(self)
            }
        }
    }
}
