//
//  RxModelCompatible.swift
//  
//
//  Created by Miroslav Yozov on 31.10.19.
//

import Foundation

import RxSwift
import RxCocoa
import RxSwiftExt

public protocol RxModelCompatible: class, ModelCompatible, AssociatedObjectCompatible, ReactiveCompatible { }

internal extension RxModelCompatible {
    var valueModel: EquatableValue<Model<M>> {
        return get(for: "valueModel") { .init(.empty) }
    }
}

// MARK: Default implementation.
public extension RxModelCompatible {
    var model: Model<M> {
        get { return valueModel.value }
        set { valueModel.value = newValue }
    }
}


// MARK: Reactive compatible.
public extension Reactive where Base: RxModelCompatible {
    var model: ControlProperty<Model<Base.M>> {
        let origin = base.valueModel.asObservable()
        let bindingObserver: Binder<Model<Base.M>> = .init(base, scheduler: CurrentThreadScheduler.instance) {
            $0.model = $1
        }
        return .init(values: origin, valueSink: bindingObserver)
    }
}


// MARK: Reactive compatible for RxMultipleTimesDecodable models.
public extension Reactive where Base: RxModelCompatible, Base.M: RxMultipleTimesDecodable {
    var decode: ControlProperty<Model<Base.M>> {
        let values: Observable<Model<Base.M>> = base.valueModel.flatMapLatest {
            return $0.map(.just(.empty)) { value -> Observable<Model<Base.M>> in
                value.rx.decode.map { .value($0) }.startWith(.value(value))
            }
        }
        let bindingObserver: Binder<Model<Base.M>> = .init(base, scheduler: CurrentThreadScheduler.instance) {
            $0.model = $1
        }
        return .init(values: values, valueSink: bindingObserver)
    }
}

// MARK: Reactive compatible for RxRemoteCompatible models.
public extension Reactive where Base: RxModelCompatible, Base.M: RxRemoteCompatible {
    var remoteState: Observable<RemoteState> {
        base.valueModel.flatMapLatest {
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
        return base.valueModel.flatMapLatest {
            return $0.map(.never()) { value -> Observable<Error> in
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
    
    func reinit() -> Single<Model<Base.M>> {
        return base.model.map(.just(base.model)) {
            $0.rx.reinit().map { .value($0) }
        }
    }
}

// MARK: Reactive compatible for RxRemoteCompatible models.
public extension Reactive where Base: RxModelCompatible, Base.M: RxRemotePageCompatible {
    func next() -> Single<Model<Base.M>> {
        return base.model.map(.just(base.model)) {
            $0.rx.next().map { .value($0) }
        }
    }
}
