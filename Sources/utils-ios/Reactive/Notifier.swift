//
//  Notifier.swift
//  
//
//  Created by Miroslav Yozov on 22.01.20.
//

import Foundation
import RxSwift


/// Notifier is a wrapper for `PublishSubject`.
///
/// Unlike `PublishSubject` it can't terminate with error or completed.
open class Notifier<E>: ObservableType, ObserverType {
    private let subject: PublishSubject<E>
    
    /// Public constructor.
    public init() {
        self.subject = .init()
    }
    
    /// Publish event.
    public func notify(_ element: E) {
        subject.onNext(element)
    }
    
    /// Subscribes observer
    public func subscribe<Observer: ObserverType>(_ observer: Observer) -> Disposable where Observer.Element == E {
        return subject.subscribe(observer)
    }

    /// - returns: Canonical interface for push style sequence
    public func asObservable() -> Observable<E> {
        return subject.asObservable()
    }
    
    public func on(_ event: Event<E>) {
        if case .next(let e) = event {
            subject.onNext(e)
        }
    }
}
