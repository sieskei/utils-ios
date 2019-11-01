//
//  File.swift
//  
//
//  Created by Miroslav Yozov on 1.11.19.
//

import Foundation

import RxSwift
import RxCocoa

public protocol RxRemoteCompatible:
    RemoteCompatible,
    MultipleTimesDecodable,
    AssociatedObjectCompatible,
    ReactiveCompatible { }

public protocol RxRemotePagableCompatible:
    RxRemoteCompatible,
    RemotePagableCompatible { }

fileprivate extension RxRemoteCompatible {
    var valueRemoteState: EquatableValue<RemoteState> {
        return get(for: "valueRemoteState") { .init(.not) }
    }
    
    var disposeBag: DisposeBag {
        return get(for: "disposeBag") { .init() }
    }
    
    private func permission(for state: RemoteState) -> RemotePermission {
        switch state {
        case .not, .done:
            return .allowed
        case .ongoing(let type):
            switch type {
            case .reinit:
                return .already
            case .other(let interruptible):
                return .interrupt(interruptible)
            }
        case .error(_, let last):
            return permission(for: last)
        }
    }
    
    func execute(endpoint: Endpoint, for type: (Disposable) -> RemoteState.`Type`) {
        let laststate = remoteState.last
        let disposable = endpoint.serialize(to: self)
            .subscribeOn(CurrentThreadScheduler.instance)
            .observeOn(CurrentThreadScheduler.instance)
            .subscribe { event in
                self.synchronized {
                    switch event {
                    case .success:
                        self.remoteState = .done
                    case .error(let error):
                        self.remoteState = error.isCancelledURLRequest ? laststate : .error(error, last: laststate)
                    }
                }
        }

        remoteState = .ongoing(type(disposable))
        disposable.disposed(by: disposeBag)
    }
    
    func runReinit() {
        let access = permission(for: remoteState)
        print(access)
        
        switch access {
        case .already, .notAllowed:
            return
        case .interrupt(let interruptible):
            interruptible.interrupt()
            fallthrough
        case .allowed:
            execute(endpoint: remoteEndpoint) { _ in .reinit }
        }
    }
}

internal struct RemoteNextPageAction: Interruptible {
    let disposable: Disposable
    func interrupt() {
        disposable.dispose()
    }
}

internal extension RxRemotePagableCompatible {
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
        case .not, .done:
            return .allowed
        case .ongoing(let type):
            switch type {
            case .reinit:
                return .notAllowed
            case .other(let interruptible):
                return interruptible is RemoteNextPageAction ? .already : .notAllowed
            }
        case .error(_, let last):
            return permission(for: last)
        }
    }
    
    func runNextPage() {
        guard !isNeedReinit(for: remoteState) else {
            return runReinit()
        }
        
        let access = permission(for: remoteState)
        print(access)
        
        switch access {
        case .already, .notAllowed:
            return
        case .interrupt(let interruptible):
            interruptible.interrupt()
            fallthrough
        case .allowed:
            guard remoteHasNextPage else { return }
            
            execute(endpoint: remoteNextPageEndpoint) {
                .other(RemoteNextPageAction(disposable: $0))
            }
        }
    }
}

// MARK: Default implementation.
public extension RxRemoteCompatible {
    fileprivate (set) var remoteState: RemoteState {
        get { return valueRemoteState.value }
        set { valueRemoteState.value = newValue }
    }
    
    func reinit() {
        Utils.Task.async(guard: self) {
            self.runReinit()
        }
    }
}

// MARK: Default implementation.
public extension RxRemotePagableCompatible {
    func nextPage() {
        Utils.Task.async(guard: self) {
            self.runNextPage()
        }
    }
}

// MARK: Reactive compatible.
extension Reactive where Base: RxRemoteCompatible {
    var remoteState: Observable<RemoteState> {
        return base.valueRemoteState.asObservable()
    }
}
