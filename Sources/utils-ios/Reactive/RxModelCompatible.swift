//
//  RxModelCompatible.swift
//  
//
//  Created by Miroslav Yozov on 31.10.19.
//

import Foundation

import RxSwift
import RxCocoa

public protocol RxModelCompatible:
    class,
    ModelCompatible,
    AssociatedObjectCompatible,
    ReactiveCompatible { }

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
        let bindingObserver: Binder<Model<Base.M>> = .init(base, binding: {
            $0.model = $1
        })
        return .init(values: origin, valueSink: bindingObserver)
    }
}


// MARK: Reactive compatible for RxMultipleTimesDecodable models.
public extension Reactive where Base: RxModelCompatible, Base.M: RxMultipleTimesDecodable {
    var decode: ControlProperty<Model<Base.M>> {
        let origin: Observable<Model<Base.M>> = base.valueModel.asObservable()
        let decode: Observable<Model<Base.M>> = origin.skip(1).flatMapLatest {
            return $0.map(.just(.empty)) {
                $0.rx.decode.map {
                    .value($0)
                }
            }
        }

        let values = Observable.merge(origin, decode)
        let bindingObserver: Binder<Model<Base.M>> = .init(base, binding: {
            $0.model = $1
        })
        return .init(values: values, valueSink: bindingObserver)
    }
}

