////
////  RxNonEquatableProperty.swift
////
////
////  Created by Miroslav Yozov on 8.03.21.
////

import Foundation
import RxSwift
import RxCocoa

@propertyWrapper
public class RxProperty<P> {
    internal let v: Value<P>

    public var wrappedValue: P {
        get { v.value }
        set { v.value = newValue }
    }

    public var projectedValue: Tools {
        .init(base: self)
    }
    
    public init(wrappedValue: P, willSet: @escaping Value<P>.Setter = { $0 }, areEqual: @escaping Value<P>.Comparator = { _, _ in false }) {
        v = .init(wrappedValue, willSet: willSet, areEqual: areEqual)
    }
    
    public init(wrappedValue: P, willSet: @escaping Value<P>.Setter = { $0 }, areEqual: @escaping Value<P>.Comparator = { $0 == $1 }) where P: Equatable {
        v = .init(wrappedValue, willSet: willSet, areEqual: areEqual)
    }
}

public extension RxProperty {
    class Tools {
        public private (set) var base: RxProperty<P>

        init(base: RxProperty<P>) {
            self.base = base
        }
    }
}

// MARK: Reactive tools.
public extension RxProperty.Tools {
    var value: ControlProperty<P> {
        let origin = base.v.asObservable()
        let bindingObserver: Binder<P> = .init(base, scheduler: CurrentThreadScheduler.instance) {
            $0.wrappedValue = $1
        }
        return .init(values: origin, valueSink: bindingObserver)
    }
}
