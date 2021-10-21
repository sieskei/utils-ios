//
//  RxProperty+Optional+RxRemoteCompatible.swift
//  
//
//  Created by Miroslav Yozov on 21.10.21.
//

import Foundation
import RxSwift
import RxCocoa

// MARK: Reactive tools for optional RxRemoteCompatible.
public extension RxProperty.Projection where P: OptionalType, P.Wrapped: RxRemoteCompatible {
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
public extension RxProperty.Projection where P: OptionalType, P.Wrapped: RxRemotePageCompatible {
    func next() -> Single<P> {
        base.wrappedValue.map(.just(base.wrappedValue)) {
            $0.rx.next().map { .init($0) }
        }
    }
}
