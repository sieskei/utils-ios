//
//  Fault.swift
//  
//
//  Created by Miroslav Yozov on 31.10.19.
//

import Foundation

/// Describes a arror with message and more data.
class Fault: Error, CustomStringConvertible {
    private enum CodingKeys: String, CodingKey {
        case error
    }
    
    static var domain: String {
        return "bg.netinfo.fault"
    }
    
    /// Full fault code: Fault.codePrefix + "." + 'code'
    static func code(for code: String) -> String {
        return "\(Fault.domain).\(code)"
    }
    
    var domain: String {
        return Fault.domain
    }
    
    var identifier: String {
        return Fault.code(for: code)
    }
    
    let code: String
    let message: String
    let info: [AnyHashable: Any]
    let parent: Error?
    
    init(code: String, message: String, info: [AnyHashable: Any] = [:], parent: Error? = nil) {
        self.code = code
        self.message = message
        self.info = info
        self.parent = parent
    }
    
    var description: String {
        return "Fault { identifier: \(identifier), message: \(message), parent: \(String(describing: parent)) }"
    }
}


// MARK: Basic `Fault` instances.
extension Fault {
    static var cancelledCode = "cancelled"
    static var cancelled: Fault {
        return Fault(code: cancelledCode, message: "Спряна операция.")
    }
    
    static var notConnectedToInternetCode = "notConnectedToInternet"
    static var notConnectedToInternet: Fault {
        return Fault(code: notConnectedToInternetCode, message: "Няма връзка с интернет.")
    }
    
    static var unknownCode = "unknown"
    static func unknown(parent: Error? = nil) -> Fault {
        return Fault(code: unknownCode, message: "Непозната грешка.", parent: parent)
    }
}

// MARK: NSError help properties.
extension NSError {
    var isCancelledURLRequest: Bool {
        return domain == NSURLErrorDomain && code == NSURLErrorCancelled
    }
    
    var isNotConnectedToInternet: Bool {
        return domain == NSURLErrorDomain && code == NSURLErrorNotConnectedToInternet
    }
}

// MARK: Error help properties.
extension Error {
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
extension Error {
    var fault: Fault {
        if let fault = self as? Fault {
            return fault
        } else {
            if isNotConnectedToInternet {
                return .notConnectedToInternet
            } else if isCancelledURLRequest {
                return .cancelled
            } else {
                return .unknown(parent: self)
            }
        }
    }
}
