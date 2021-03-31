//
//  RxNonEquatableProperty.swift
//  
//
//  Created by Miroslav Yozov on 8.03.21.
//

import Foundation
import RxSwift
import RxCocoa

@propertyWrapper
public class RxNonEquatableProperty<P> {
    internal let v: NonEquatableValue<P>
    
    public var wrappedValue: P {
        get { v.value }
        set { v.value = newValue }
    }
    
    public var projectedValue: Tools {
        .init(base: self)
    }
    
    public init(wrappedValue: P) {
        v = .init(wrappedValue)
    }
}

public extension RxNonEquatableProperty {
    class Tools {
        public private (set) var base: RxNonEquatableProperty<P>
        
        init(base: RxNonEquatableProperty<P>) {
            self.base = base
        }
    }
}

// MARK: Reactive compatible.
public extension RxNonEquatableProperty.Tools {
    var value: ControlProperty<P> {
        let origin = base.v.asObservable()
        let bindingObserver: Binder<P> = .init(base, scheduler: CurrentThreadScheduler.instance) {
            $0.wrappedValue = $1
        }
        return .init(values: origin, valueSink: bindingObserver)
    }
}
