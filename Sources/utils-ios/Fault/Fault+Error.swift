//
//  Fault+Error.swift
//  
//
//  Created by Miroslav Yozov on 30.11.20.
//

import Foundation

// MARK: NSError help properties.
public extension NSError {
    fileprivate var urlError: NSError? {
        var error: NSError? = self
        while error != nil {
            if error!.domain == NSURLErrorDomain {
                return error
            }
            
            if let wrapper = error as? ErrorWrapper, let v = wrapper.underlyingError {
                error = v.nsError
            }
        }
        
        return nil
    }
    
    var isNetwork: Bool {
        urlError?.domain == NSURLErrorDomain
    }
    
    var isCancelledURLRequest: Bool {
        urlError?.code == NSURLErrorCancelled
    }
    
    var isNotConnectedToInternet: Bool {
        urlError?.code == NSURLErrorNotConnectedToInternet
    }
    
    var isTimeOutURLRequest: Bool {
        urlError?.code == NSURLErrorTimedOut
    }
}

// MARK: Error help properties.
public extension Error {
    var nsError: NSError {
        self as NSError
    }
    
    var isNetwork: Bool {
        nsError.isNetwork
    }
    
    var isCancelledURLRequest: Bool {
        nsError.isCancelledURLRequest
    }
    
    var isNotConnectedToInternet: Bool {
        nsError.isNotConnectedToInternet
    }
    
    var isTimeOutURLRequest: Bool {
        nsError.isTimeOutURLRequest
    }
}

// MARK: Еrror, which is an error wrapper (like enum).
public protocol ErrorWrapper: Error {
    var underlyingError: Error? { get }
}

// MARK: Convert `Error` to `Fault`.
public extension Error {
    var fault: Fault {
        fault(or: .error(self))
    }
    
    func fault(or unknown: Fault) -> Fault {
        if let fault = self as? Fault {
            return fault
        } else if let wrapper = self as? ErrorWrapper, let error = wrapper.underlyingError {
            return error.fault(or: unknown)
        } else {
            if isNotConnectedToInternet {
                 return .notConnectedToInternet
            } else if isCancelledURLRequest {
                return .cancelled
            } else {
                return unknown
            }
        }
    }
}
