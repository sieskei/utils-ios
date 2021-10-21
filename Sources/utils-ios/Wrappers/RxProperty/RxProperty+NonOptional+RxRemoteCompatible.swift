//
//  RxProperty+NonOptional+RxRemoteCompatible.swift
//  
//
//  Created by Miroslav Yozov on 21.10.21.
//

import Foundation
import RxSwift
import RxCocoa

// MARK: Reactive tools for non-optional RxRemoteCompatible.
public extension RxProperty.Projection where P: RxRemoteCompatible {
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
public extension RxProperty.Projection where P: RxRemotePageCompatible {
    func next() -> Single<P> {
        base.wrappedValue.rx.next()
    }
}
