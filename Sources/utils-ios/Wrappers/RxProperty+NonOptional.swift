//
//  RxProperty+NonOptional.swift
//
//
//  Created by Miroslav Yozov on 13.07.21.
//

import Foundation
import RxSwift
import RxCocoa

// MARK: Reactive tools for non-optional RxRedecodable.
public extension RxProperty.Tools where P: RxRedecodable {
    var decode: ControlProperty<P> {
        let values: Observable<P> = base.v.flatMapLatest {
            $0.rx.decode.startWith($0)
        }
        let bindingObserver: Binder<P> = .init(base, scheduler: CurrentThreadScheduler.instance) {
            $0.wrappedValue = $1
        }
        return .init(values: values, valueSink: bindingObserver)
    }
}


// MARK: Reactive tools for non-optional RxRemoteCompatible.
public extension RxProperty.Tools where P: RxRemoteCompatible {
    var remoteState: Observable<RemoteState> {
        base.v.flatMapLatest {
            $0.rx.remoteState.distinctUntilChanged()
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
            $0.rx.remoteState.map {
                switch $0 {
                case .error(let error, _):
                    return error
                default:
                    return nil
                }
            }.unwrap()
        }
    }

    func reinit() -> Single<P> {
        base.wrappedValue.rx.reinit()
    }
}


// MARK: Reactive tools for non-optional RxRemotePageCompatible.
public extension RxProperty.Tools where P: RxRemotePageCompatible {
    func next() -> Single<P> {
        base.wrappedValue.rx.next()
    }
}
