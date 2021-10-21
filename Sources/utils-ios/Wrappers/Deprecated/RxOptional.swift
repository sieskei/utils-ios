//
//  RxOptional.swift
//  
//
//  Created by Miroslav Yozov on 19.04.21.
//

import Foundation
import RxSwift
import RxCocoa

@available(*, deprecated, message: "Use @RxProperty instead.")
@propertyWrapper
public class RxOptional<W>: RxProperty<Optional<W>> {
    public override var wrappedValue: Optional<W> {
        get { super.wrappedValue }
        set { super.wrappedValue = newValue }
    }
    
    public override var projectedValue: Tools {
        .init(base: self)
    }
}

public extension RxOptional {
    class Tools: RxProperty<Optional<W>>.Projection { }
}

// MARK: Reactive tools for RxRedecodable optionals.
public extension RxOptional.Tools where W: RxRedecodable {
    var decode: ControlProperty<Optional<W>> {
        let values: Observable<Optional<W>> = base.v.flatMapLatest {
            $0.map(.just(.none)) { value -> Observable<Optional<W>> in
                value.rx.decode.map { .some($0) }.startWith(.some(value))
            }
        }
        let bindingObserver: Binder<Optional<W>> = .init(base, scheduler: CurrentThreadScheduler.instance) {
            $0.wrappedValue = $1
        }
        return .init(values: values, valueSink: bindingObserver)
    }
}

// MARK: Reactive tools for RxRemoteCompatible optionals.
public extension RxOptional.Tools where W: RxRemoteCompatible {
    var remoteState: Observable<RemoteState> {
        base.v.flatMapLatest {
            $0.map(.just(.not)) { value -> Observable<RemoteState> in
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

    func reinit() -> Single<Optional<W>> {
        base.wrappedValue.map(.just(base.wrappedValue)) {
            $0.rx.reinit().map { .some($0) }
        }
    }
}

// MARK: Reactive tools for RxRemoteCompatible optionals.
public extension RxOptional.Tools where W: RxRemotePageCompatible {
    func next() -> Single<Optional<W>> {
        base.wrappedValue.map(.just(base.wrappedValue)) {
            $0.rx.next().map { .some($0) }
        }
    }
}
