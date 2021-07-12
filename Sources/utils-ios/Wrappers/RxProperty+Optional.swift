//
//  RxProperty+Optional.swift
//  
//
//  Created by Miroslav Yozov on 13.07.21.
//

import Foundation
import RxSwift
import RxCocoa

// MARK: Reactive tools for optional RxRedecodable.
public extension RxProperty.Tools where P: OptionalType, P.Wrapped: RxRedecodable {
    var decode: ControlProperty<P> {
        let values: Observable<P> = base.v.flatMapLatest {
            $0.wrapped.map(.just(P.nil)) { value -> Observable<P> in
                value.rx.decode.map { .init($0) }.startWith(.init(value))
            }
        }
        let bindingObserver: Binder<P> = .init(base, scheduler: CurrentThreadScheduler.instance) {
            $0.wrappedValue = $1
        }
        return .init(values: values, valueSink: bindingObserver)
    }
}

// MARK: Reactive tools for optional RxRemoteCompatible.
public extension RxProperty.Tools where P: OptionalType, P.Wrapped: RxRemoteCompatible {
    var remoteState: Observable<RemoteState> {
        base.v.flatMapLatest {
            $0.wrapped.map(.just(.not)) { value -> Observable<RemoteState> in
                value.rx.remoteState.distinctUntilChanged()
            }
        }
    }
    
    var decoding: Observable<Bool> {
        remoteState.map { $0.ongoing }
    }
    
    var decoded: Observable<Bool> {
        remoteState.map { $0.done }
    }
    
    var error: Observable<Error> {
        base.v.flatMapLatest {
            $0.map(.never()) { value -> Observable<Error> in
                value.rx.remoteState.map {
                    switch $0 {
                    case .error(let error, _):
                        return error
                    default:
                        return nil
                    }
                }.unwrap()
            }
        }
    }

    func reinit() -> Single<P> {
        base.wrappedValue.map(.just(base.wrappedValue)) {
            $0.rx.reinit().map { .init($0) }
        }
    }
}

// MARK: Reactive tools for optional RxRemotePageCompatible.
public extension RxProperty.Tools where P: OptionalType, P.Wrapped: RxRemotePageCompatible {
    func next() -> Single<P> {
        base.wrappedValue.map(.just(base.wrappedValue)) {
            $0.rx.next().map { .init($0) }
        }
    }
}
