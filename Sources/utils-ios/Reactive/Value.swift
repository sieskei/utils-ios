//
//  Value.swift
//  
//
//  Created by Miroslav Yozov on 30.10.19.
//

import Foundation
import RxSwift

/// Value is a wrapper for `BehaviorSubject`.
///
/// Unlike `BehaviorSubject` it can't terminate with error or completed.
public class Value<Element>: ObservableType {
    private let subject: BehaviorSubject<Element>
    
    /// Current value of behavior subject
    public var value: Element {
        // this try! is ok because subject can't error out or be disposed
        get { return try! subject.value() }
        set { subject.onNext(newValue) }
    }

    /// Initializes behavior relay with initial value.
    public init(_ value: Element) {
        subject = BehaviorSubject(value: value)
    }

    /// Subscribes observer
    public func subscribe<Observer: ObserverType>(_ observer: Observer) -> Disposable where Observer.Element == Element {
        return subject.subscribe(observer)
    }

    /// - returns: Canonical interface for push style sequence
    public func asObservable() -> Observable<Element> {
        return subject.asObservable()
    }
}

/// Value with Element type that confirm Equatable.
public class EquatableValue<Element: Equatable>: Value<Element> {
    public override var value: Element {
        get { return super.value }
        set {
            guard newValue != super.value else { return }
            super.value = newValue
        }
    }
}
