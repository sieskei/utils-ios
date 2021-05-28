//
//  Value.swift
//  
//
//  Created by Miroslav Yozov on 30.10.19.
//

import Foundation
import RxSwift
import RxCocoa

/// Value is a wrapper for `BehaviorSubject`.
///
/// Unlike `BehaviorSubject` it can't terminate with error or completed.
public class Value<Element> {
    public typealias Comparator = (Element, Element) -> Bool
    
    private let subject: BehaviorSubject<Element>
    private let areEqual: Comparator
    
    /// Current value of behavior subject
    public var value: Element {
        // this try! is ok because subject can't error out or be disposed
        get { return try! subject.value() }
        set {
            if !areEqual(try! subject.value(), newValue) {
                subject.onNext(newValue)
            }
        }
    }
    
    /// Initializes with initial value and default comparator (allways false).
    public init(_ value: Element, _ areEqual: @escaping Comparator = { _, _ in false }) {
        self.subject = .init(value: value)
        self.areEqual = areEqual
    }
    
    /// Initializes with equatable initial value and default comparator (==).
    public init(_ value: Element, _ areEqual: @escaping Comparator = { $0 == $1 }) where Element: Equatable {
        self.subject = .init(value: value)
        self.areEqual = areEqual
    }
}

extension Value: ObservableType {
    public var binder: Binder<Element> {
        .init(self, scheduler: CurrentThreadScheduler.instance) { $0.value = $1 }
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
