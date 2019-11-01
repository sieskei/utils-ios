//
//  RemoteState.swift
//  
//
//  Created by Miroslav Yozov on 31.10.19.
//

import Foundation

public protocol Stoppable {
    func stop()
}

public indirect enum RemoteState {
    public enum `Type` {
        case reinit
        case other(Stoppable)
    }
    
    case not
    case ongoing(Type)
    case done
    case error(Error, last: RemoteState)
    
    var last: RemoteState {
        switch self {
        case .error(_, let last):
            return last
        default:
            return self
        }
    }
    
    var ongoing: Bool {
        switch self {
        case .ongoing:
            return true
        default:
            return false
        }
    }
}

extension RemoteState: Equatable {
    public static func == (lhs: RemoteState, rhs: RemoteState) -> Bool {
        switch lhs {
        case .not:
            if case .not = rhs { return true }
        case .ongoing(let lhsType):
            if case .ongoing(let rhsType) = rhs {
                switch lhsType {
                case .reinit:
                    if case .reinit = rhsType { return true }
                case .other:
                    if case .other = rhsType { return true }
                }
            }
        case .done:
            if case .done = rhs { return true }
        case .error(let lhsError, _):
            if case .error(let rhsError, _) = rhs {
                return lhsError.nsError == rhsError.nsError
            }
        }
        
        return false
    }
}
