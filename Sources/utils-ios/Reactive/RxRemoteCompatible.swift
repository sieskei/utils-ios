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
    ReactiveCompatible {
    
    /// Default remote state aka when constructed.
    var defaultRemoteState: RemoteState { get }
}

// MARK: Default implementation.
public extension RxRemoteCompatible {
    fileprivate (set) var remoteState: RemoteState {
        get { return valueRemoteState.value }
        set { valueRemoteState.value = newValue }
    }
    
    var defaultRemoteState: RemoteState {
        return .not
    }
    
    func reinit() {
        Utils.Task.async(guard: self) {
            self.runReinit()
        }
    }
}

public protocol RxRemotePageCompatible:
    RxRemoteCompatible,
    RemotePageCompatible {
}

// MARK: Default implementation.
public extension RxRemotePageCompatible {
    func next() {
        Utils.Task.async(guard: self) {
            self.runNext()
        }
    }
}

fileprivate extension RxRemoteCompatible {
    var valueRemoteState: EquatableValue<RemoteState> {
        return get(for: "valueRemoteState") { .init(defaultRemoteState) }
    }
    
    var disposeBag: DisposeBag {
        return get(for: "disposeBag") { .init() }
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
}

internal extension RxRemoteCompatible {
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
    
    func runNext() {
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
            
            execute(endpoint: remoteEndpoint.nextPage) {
                .other(RemoteNextPageAction(disposable: $0))
            }
        }
    }
}

// MARK: Reactive compatible.
public extension Reactive where Base: RxRemoteCompatible {
    var remoteState: Observable<RemoteState> {
        return base.valueRemoteState.asObservable()
    }
}
