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
    
    public enum Languages: String {
        case english
        case bulgarian
    }
    
    public static let domain: String = "ios.utils.fault"
    public static var defaultLang: Languages = .english
    
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
    
    private var lang2messages: [Languages: String] = [:]
    
    public let code: String
    public let info: [AnyHashable: Any]
    public let parent: Error?
    
    public var message: String {
        return lang2messages[Fault.defaultLang] ?? lang2messages[.english] ?? ""
    }
    
    public convenience init(code: String, message: String, info: [AnyHashable: Any] = [:], parent: Error? = nil) {
        self.init(code: code, messages: [Fault.defaultLang: message], info: info, parent: parent)
    }
    
    public convenience init(code: String, enMessage: String, info: [AnyHashable: Any] = [:], parent: Error? = nil) {
        self.init(code: code, messages: [.english: enMessage], info: info, parent: parent)
    }
    
    public init(code: String, messages: [Languages: String], info: [AnyHashable: Any] = [:], parent: Error? = nil) {
        self.code = code
        self.lang2messages = messages
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
        return Fault(code: cancelledCode, messages: [.bulgarian: "Спряна операция.", .english: "Operation cancelled."])
    }
    
    static var notConnectedToInternetCode = "notConnectedToInternet"
    static var notConnectedToInternet: Fault {
        return Fault(code: notConnectedToInternetCode, messages: [.bulgarian: "Няма връзка с интернет.", .english: "No Internet connection."])
    }
    
    static var errorCode = "error"
    static func error(_ error: Error? = nil) -> Fault {
        return Fault(code: errorCode, messages: [.bulgarian: "Непозната грешка.", .english: "Unknown error."], parent: error)
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
