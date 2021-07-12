//
//  ReactiveProperty.swift
//  
//
//  Created by Miroslav Yozov on 10.07.21.
//

import Foundation
import RxSwift
import RxCocoa

fileprivate var SubjectKey: UInt8 = 0
fileprivate extension ReactiveCompatible where Self: AnyObject {
    var subject: PublishSubject<PartialKeyPath<Self>> {
        Utils.AssociatedObject.get(base: self, key: &SubjectKey, policy: .strong) { .init() }
    }
}

@propertyWrapper
public struct ReactiveProperty<Value> {
    public typealias Comparator = (Value, Value) -> Bool
    
    public static subscript<T: ReactiveCompatible & AnyObject>(
        _enclosingInstance instance: T,
        wrapped wrappedKeyPath: ReferenceWritableKeyPath<T, Value>,
        storage storageKeyPath: ReferenceWritableKeyPath<T, Self>
    ) -> Value {
        get {
            instance[keyPath: storageKeyPath].storage
        }
        set {
            let wrapper = instance[keyPath: storageKeyPath]
            if !wrapper.areEqual(wrapper.storage, newValue) {
                instance[keyPath: storageKeyPath].storage = newValue
                instance.subject.onNext(wrappedKeyPath)
            }
        }
    }

    @available(*, unavailable, message: "@ReactiveProperty can only be applied to classes")
    public var wrappedValue: Value {
        get { fatalError() }
        set { fatalError() }
    }
    
    private var storage: Value
    private let areEqual: Comparator

    public init(wrappedValue: Value, areEqual comparator: @escaping Comparator = { _, _ in false }) {
        storage = wrappedValue
        areEqual = comparator
    }
    
    public init(wrappedValue: Value, areEqual comparator: @escaping Comparator = { $0 == $1 }) where Value: Equatable {
        storage = wrappedValue
        areEqual = comparator
    }
}

// MARK: Extension for enclosing instance.
extension Reactive where Base: ReactiveCompatible & AnyObject {
    public subscript<Property>(dynamicMember keyPath: KeyPath<Base, Property>) -> Observable<Property> {
        base.subject
            .filter { $0 == keyPath }
            .withUnretained(base)
            .map { base, _ in base[keyPath: keyPath] }
            .startWith(base[keyPath: keyPath])
    }
}
