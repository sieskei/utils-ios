//
//  RxModel.swift
//  
//
//  Created by Miroslav Yozov on 25.12.20.
//

import Foundation
import RxSwift
import RxCocoa

@available(*, deprecated, message: "Use @RxProperty instead.")
@propertyWrapper
public class RxModel<M: Equatable>: RxProperty<Model<M>> {
    public override var wrappedValue: Model<M> {
        get { super.wrappedValue }
        set { super.wrappedValue = newValue }
    }
    
    public override var projectedValue: Tools {
        .init(base: self)
    }
}

public extension RxModel {
    class Tools: RxProperty<Model<M>>.Tools { }
}

// MARK: Reactive compatible for RxRedecodable models.
public extension RxModel.Tools where M: RxRedecodable {
    var decode: ControlProperty<Model<M>> {
        let values: Observable<Model<M>> = base.v.flatMapLatest {
            $0.map(.just(.empty)) { value -> Observable<Model<M>> in
                value.rx.decode.map { .value($0) }.startWith(.value(value))
            }
        }
        let bindingObserver: Binder<Model<M>> = .init(base, scheduler: CurrentThreadScheduler.instance) {
            $0.wrappedValue = $1
        }
        return .init(values: values, valueSink: bindingObserver)
    }
}

// MARK: Reactive compatible for RxRemoteCompatible models.
public extension RxModel.Tools where M: RxRemoteCompatible {
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

    func reinit() -> Single<Model<M>> {
        base.wrappedValue.map(.just(base.wrappedValue)) {
            $0.rx.reinit().map { .value($0) }
        }
    }
}

// MARK: Reactive compatible for RxRemoteCompatible models.
public extension RxModel.Tools where M: RxRemotePageCompatible {
    func next() -> Single<Model<M>> {
        base.wrappedValue.map(.just(base.wrappedValue)) {
            $0.rx.next().map { .value($0) }
        }
    }
}
