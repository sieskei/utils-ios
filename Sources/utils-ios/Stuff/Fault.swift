//
//  Fault.swift
//  
//
//  Created by Miroslav Yozov on 31.10.19.
//

import Foundation

/// Describes a arror with message and more data.
public class Fault: Error, CustomStringConvertible {
    public enum Languages: String {
        case en
        case bg
    }
    
    public static let domain: String = "ios.utils.fault"
    public static var defaultLang: Languages = .en
    
    /// Full fault code: Fault.codePrefix + "." + 'code'
    public static func identifier(for code: String) -> String {
        return "\(Fault.domain).\(code)"
    }
    
    public var domain: String {
        return Fault.domain
    }
    
    public var identifier: String {
        return Fault.identifier(for: code)
    }
    
    private var lang2messages: [Languages: String] = [:]
    
    public let code: String
    public let info: [AnyHashable: Any]
    public let parent: Error?
    
    public var message: String {
        return lang2messages[Fault.defaultLang] ?? lang2messages[.en] ?? ""
    }
    
    public var description: String {
        return "Fault { identifier: \(identifier), message: \(message), parent: \(String(describing: parent)) }"
    }
    
    public convenience init(code: String, message: String, info: [AnyHashable: Any] = [:], parent: Error? = nil) {
        self.init(code: code, messages: [Fault.defaultLang: message], info: info, parent: parent)
    }
    
    public convenience init(code: String, enMessage: String, info: [AnyHashable: Any] = [:], parent: Error? = nil) {
        self.init(code: code, messages: [.en: enMessage], info: info, parent: parent)
    }
    
    public init(code: String, messages: [Languages: String], info: [AnyHashable: Any] = [:], parent: Error? = nil) {
        self.code = code
        self.lang2messages = messages
        self.info = info
        self.parent = parent
    }
    
    public func `is`(code c: String) -> Bool {
        identifier == Fault.identifier(for: c)
    }
}

// MARK: Global `Fault` struct for info keys.
public extension Fault {
    struct Keys { }
}

// MARK: Global `Fault` struct for codes.
public extension Fault {
    struct Codes { }
}

// MARK: Basic `Fault` instances.
public extension Fault.Codes {
    static let cancelled = "cancelled"
    static let notConnectedToInternet = "notConnectedToInternet"
    static let error = "error"
}

public extension Fault {
    static var cancelled: Fault {
        .init(code: Codes.cancelled, messages: [.bg: "Спряна операция.", .en: "Operation cancelled."])
    }
    
    static var notConnectedToInternet: Fault {
        .init(code: Codes.notConnectedToInternet, messages: [.bg: "Няма връзка с интернет.", .en: "No Internet connection."])
    }
    
    static func error(_ error: Error? = nil) -> Fault {
        .init(code: Codes.error, messages: [.bg: "Непозната грешка.", .en: "Unknown error."], parent: error)
    }
}
