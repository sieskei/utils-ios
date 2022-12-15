//
//  RxRemoteCompatible.swift
//  
//
//  Created by Miroslav Yozov on 1.11.19.
//

import Foundation

import RxSwift
import RxCocoa

fileprivate var RemoteStateKey: UInt8 = 0

public protocol RxRemoteCompatible: RemoteCompatible, RxRedecodable, DisposeContext {
    /// Default remote state aka when constructed.
    var defaultRemoteState: RemoteState { get }
}

// MARK: Default implementation.
public extension RxRemoteCompatible {
    fileprivate var valueRemoteState: Value<RemoteState> {
        Utils.AssociatedObject.get(base: self, key: &RemoteStateKey) {
            .init(defaultRemoteState)
        }
    }
    
    fileprivate (set) var remoteState: RemoteState {
        get { return valueRemoteState.value }
        set { valueRemoteState.value = newValue }
    }
    
    var defaultRemoteState: RemoteState {
        return .not
    }
    
    func reinit() {
        runReinit()
    }
}

public protocol RxRemotePageCompatible: RxRemoteCompatible, RemotePageCompatible { }

// MARK: Default implementation.
public extension RxRemotePageCompatible {
    func next(forceReinit: Bool = true) {
        runNext(forceReinit: forceReinit)
    }
}


fileprivate var DisposeBagKey: UInt8 = 0

fileprivate extension RxRemoteCompatible {
    func serialize(endpoint: EndpointType) -> Single<Self> {
        endpoint.rx.serialize(to: self, network: network)
            .do(onSuccess: {
                // print("[T] serialize on success:", Thread.current)
                $0.remoteState = .done
            }, onError: { [this = self] in
                let laststate = this.remoteState.last
                this.remoteState = $0.isCancelledURLRequest ? laststate : .error($0, last: laststate)
            })
    }
}

internal extension RxRemoteCompatible {
    private func permission(for state: RemoteState) -> RemotePermission {
        switch state {
        case .not, .done:
            return .allowed
        case .ongoing(let type, _):
            switch type {
            case .reinit:
                return .already
            case .other:
                return .interrupt
            }
        case .error(_, let last):
            return permission(for: last)
        }
    }
    
    func serializeReinit() -> Single<Self> {
        let permission: Single<Self> = Single.create { [this = self] in
            // print("[T] reinit create:", Thread.current)
            
            let access = this.permission(for: this.remoteState)
            Utils.Log.debug(access)
            
            switch access {
            case .already:
                $0(.failure(Fault.RemotePermission.already))
            case .notAllowed:
                $0(.failure(Fault.RemotePermission.notAllowed))
            case .interrupt:
                this.contextDispose()
                fallthrough
            case .allowed:
                 $0(.success(this))
            }
            
            return Disposables.create { }
        }
        
        return permission
            .subscribe(on: Utils.Task.rx.serialScheduler)
            .do(onSuccess: {
                // print("[T] reinit create after success:", Thread.current)
                $0.remoteState = .ongoing(.reinit, last: $0.remoteState.last)
            })
            .flatMap {
                $0.serialize(endpoint: $0.remoteEndpoint)
        }
    }
    
    func runReinit() {
        serializeReinit()
            .subscribe()
            .disposed(by: self)
    }
}

internal extension RxRemotePageCompatible {
    private func isNeedReinit(for state: RemoteState) -> Bool {
        switch state {
        case .not:
            return true
        case .error(_, let last):
            return isNeedReinit(for: last)
        default:
            return false
        }
    }
    
    private func permission(for state: RemoteState) -> RemotePermission {
        switch state {
        case .not:
            return .notAllowed
        case .done:
            return .allowed
        case .ongoing(let type, _):
            switch type {
            case .reinit:
                return .notAllowed
            case .other:
                return .already
            }
        case .error(_, let last):
            return permission(for: last)
        }
    }
    
    func serializeNext(forceReinit: Bool) -> Single<Self> {
        if isNeedReinit(for: remoteState), forceReinit {
            return serializeReinit()
        }
        
        let permission: Single<Self> = Single.create { [this = self] in
            let access = this.permission(for: this.remoteState)
            Utils.Log.debug(access)
            
            switch access {
            case .already:
                $0(.failure(Fault.RemotePermission.already))
            case .notAllowed:
                $0(.failure(Fault.RemotePermission.notAllowed))
            case .interrupt:
                this.contextDispose()
                fallthrough
            case .allowed:
                if this.remoteHasNextPage {
                    $0(.success(this))
                } else {
                    $0(.failure(Fault.RemotePageCompatible.noMorePages))
                }
            }
            
            return Disposables.create { }
        }
        
        return permission
            .subscribe(on: Utils.Task.rx.serialScheduler)
            .do(onSuccess: {
                $0.remoteState = .ongoing(.other, last: $0.remoteState.last)
            })
            .flatMap { $0.serialize(endpoint: $0.remoteEndpoint.next(for: $0)) }
    }
    
    func runNext(forceReinit: Bool) {
        serializeNext(forceReinit: forceReinit)
            .subscribe()
            .disposed(by: self)
    }
}

// MARK: RxRemoteCompatible - reactive compatible.
public extension Reactive where Base: RxRemoteCompatible {
    var remoteState: Observable<RemoteState> {
        return base.valueRemoteState.asObservable()
    }
    
    var decoding: Observable<Bool> {
        remoteState.map { $0.ongoing }
    }
    
    func reinit() -> Single<Base> {
        return base.serializeReinit()
    }
}

// MARK: RxRemoteCompatible - reactive compatible.
public extension Reactive where Base: RxRemotePageCompatible {
    func next(forceReinit: Bool = true) -> Single<Base> {
        return base.serializeNext(forceReinit: forceReinit)
    }
}
