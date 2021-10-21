//
//  RxProperty+Optional+RxRedecodable.swift
//  
//
//  Created by Miroslav Yozov on 13.07.21.
//

import Foundation
import RxSwift
import RxCocoa

// MARK: Reactive tools for optional RxRedecodable.
public extension RxProperty.Projection where P: OptionalType, P.Wrapped: RxRedecodable {
    private var src: Observable<P> {
        base.v.flatMapLatest {
            $0.wrapped.map(.just(nil)) { value -> Observable<P> in
                value.rx.decode.map { .init($0) }.startWith(.init(value))
            }
        }
    }
    
    var decode: ControlProperty<P> {
        .init(values: src, valueSink: Binder(base, scheduler: CurrentThreadScheduler.instance) {
            $0.wrappedValue = $1
        })
    }
    
    subscript<Property>(dynamicMember keyPath: KeyPath<P.Wrapped, Property>) -> Observable<Property?> {
        src.map { $0.wrapped?[keyPath: keyPath] }
    }
    
    subscript<Property>(dynamicMember keyPath: KeyPath<P.Wrapped, Property?>) -> Observable<Property?> {
        src.map { $0.wrapped?[keyPath: keyPath] }
    }
}
