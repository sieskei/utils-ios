//
//  RemoteState.swift
//  
//
//  Created by Miroslav Yozov on 31.10.19.
//

import Foundation

public indirect enum RemoteState {
    public enum `Type`: Int {
        case reinit
        case other
    }
    
    case not
    case ongoing(Type, last: RemoteState)
    case done
    case error(Error, last: RemoteState)
    
    var last: RemoteState {
        switch self {
        case .ongoing(_, let last):
            return last
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
        case .ongoing(let lhsType, _):
            if case .ongoing(let rhsType, _) = rhs {
                return lhsType == rhsType
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
