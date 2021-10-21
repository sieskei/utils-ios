//
//  RxProperty+NonOptional+RxRedecodable.swift
//
//
//  Created by Miroslav Yozov on 13.07.21.
//

import Foundation
import RxSwift
import RxCocoa

// MARK: Reactive tools for non-optional RxRedecodable.
public extension RxProperty.Projection where P: RxRedecodable {
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
