//
//  ViewModel.swift
//  
//
//  Created by Miroslav Yozov on 30.10.19.
//

import Foundation

protocol ViewModelType {
    associatedtype M: AnyObject
    init(model: M?)
}

enum ViewModel<M: AnyObject>: ViewModelType {
    case empty
    case model(M)
    
    init(model: M?) {
        if let model = model {
            self = .model(model)
        } else {
            self = .empty
        }
    }
    
    var isEmpty: Bool {
        switch self {
        case .empty: return true
        case .model: return false
        }
    }
    
    func onModel(_ action: (M) -> Void) {
        switch self {
        case .empty:
            return
        case .model(let model):
            action(model)
        }
    }
    
    func onModel<R>(_ transform: (M) -> R?, action: (R) -> Void) {
        switch self {
        case .model(let model):
            guard let r = transform(model) else { fallthrough }
            action(r)
        default:
            return
        }
    }
    
    func map<R: AnyObject>(_ default: R?,_ transform: (M) -> R?) -> ViewModel<R> {
        switch self {
        case .empty:
            if let model = `default` {
                return .model(model)
            } else {
                return .empty
            }
        case .model(let model):
            if let model = transform(model) {
                return .model(model)
            } else {
                return .empty
            }
        }
    }
    
    func map<R: AnyObject>(_ transform: (M) -> R?) -> ViewModel<R> {
        switch self {
        case .empty:
            return .empty
        case .model(let model):
            if let model = transform(model) {
                return .model(model)
            } else {
                return .empty
            }
        }
    }
    
    func map<R>(_ default: R, _ transform: (M) -> R) -> R {
        switch self {
        case .empty:
            return `default`
        case .model(let model):
            return transform(model)
        }
    }
}

extension ViewModel: Equatable {
    static func == (lhs: ViewModel<M>, rhs: ViewModel<M>) -> Bool {
        switch lhs {
        case .empty:
            switch rhs {
            case .empty: return true
            case .model: return false
            }
        case .model(let lhsValue):
            switch rhs {
            case .empty: return false
            case .model(let rhsValue): return lhsValue === rhsValue
            }
        }
    }
    
    static func == (lhs: ViewModel<M>, rhs: M?) -> Bool {
        switch lhs {
        case .empty:
            return rhs === nil
        case .model(let lhsValue):
            return lhsValue === rhs
        }
    }
}
