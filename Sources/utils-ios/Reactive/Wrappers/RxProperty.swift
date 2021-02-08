//
//  RxWrapper.swift
//  
//
//  Created by Miroslav Yozov on 24.12.20.
//

import Foundation
import RxSwift
import RxCocoa

@propertyWrapper
public class RxProperty<P: Equatable> {
    internal let v: EquatableValue<P>
    
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

public extension RxProperty {
    class Tools {
        public private (set) var base: RxProperty<P>
        
        init(base: RxProperty<P>) {
            self.base = base
        }
    }
}

// MARK: Reactive compatible.
public extension RxProperty.Tools {
    var value: ControlProperty<P> {
        let origin = base.v.asObservable()
        let bindingObserver: Binder<P> = .init(base, scheduler: CurrentThreadScheduler.instance) {
            $0.wrappedValue = $1
        }
        return .init(values: origin, valueSink: bindingObserver)
    }
}
