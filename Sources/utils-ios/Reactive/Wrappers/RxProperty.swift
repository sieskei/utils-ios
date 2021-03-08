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
public class RxProperty<P: Equatable>: RxNonEquatableProperty<P> {
    public override var wrappedValue: P {
        get { super.wrappedValue }
        set {
            if newValue != super.wrappedValue {
                super.wrappedValue = newValue
            }
        }
    }
    
    public override var projectedValue: Tools {
        .init(base: self)
    }
    
    public override init(wrappedValue: P) {
        super.init(wrappedValue: wrappedValue)
    }
}

public extension RxProperty {
    class Tools: RxNonEquatableProperty<P>.Tools { }
}
