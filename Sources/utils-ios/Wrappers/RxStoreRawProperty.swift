//
//  RxStoreRawProperty.swift
//  
//
//  Created by Miroslav Yozov on 8.03.21.
//

import Foundation
import RxSwift
import RxCocoa

@propertyWrapper
public class RxStoreRawProperty<P: RawRepresentable>: RxProperty<P> where P.RawValue: PrimitiveType {
    public let key: String
    
    public override var wrappedValue: P {
        get { super.wrappedValue }
        set {
            super.wrappedValue = newValue
            Utils.Storage.set(key: key, value: newValue)
        }
    }
    
    public override var projectedValue: Tools {
        .init(base: self)
    }
    
    public init(wrappedValue: P, key: String) {
        self.key = key
        super.init(wrappedValue: Utils.Storage.get(for: key, default: wrappedValue))
    }
}

public extension RxStoreRawProperty {
    class Tools: RxProperty<P>.Projection { }
}
