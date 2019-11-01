//
//  RemoteCompatible.swift
//  
//
//  Created by Miroslav Yozov on 31.10.19.
//

import Foundation

import RxSwift

public protocol RemoteCompatible: AssociatedObjectCompatible, ReactiveCompatible {
    var remoteEndpoint: Endpoint { get }
    var remoteState: RemoteState { get }
}

public protocol RemotePagableCompatible: RemoteCompatible {
    var remoteNextPageEndpoint: Endpoint { get }
}

internal extension RemoteCompatible {
    var valueRemoteState: EquatableValue<RemoteState> {
        return get(for: "valueRemoteState") { .init(.not) }
    }
}

// MARK: Default implementation.
public extension RemoteCompatible {
    fileprivate (set) var remoteState: RemoteState {
        get { return valueRemoteState.value }
        set { valueRemoteState.value = newValue }
    }
    
    func reinit() {
        
    }
}

public extension RemotePagableCompatible {
    func nextPage() {
        
    }
}

extension Reactive where Base: RemoteCompatible {
    var remoteState: Observable<RemoteState> {
        return base.valueRemoteState.asObservable()
    }
}
