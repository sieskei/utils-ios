//
//  Fault+Error.swift
//  
//
//  Created by Miroslav Yozov on 30.11.20.
//

import Foundation

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

// MARK: Еrror, which is an error container.
public protocol ErrorContainer: Error {
    var errorOrSelf: Error { get }
}

// MARK: Convert `Error` to `Fault`.
public extension Error {
    var fault: Fault {
        if let fault = self as? Fault {
            return fault
        } else if let container = self as? ErrorContainer {
            return container.errorOrSelf.fault
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
