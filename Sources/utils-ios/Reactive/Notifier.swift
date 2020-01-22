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
public class Notifier<Event>: ObservableType {
    private let subject: PublishSubject<Event> = .init()
    
    /// Publish event.
    public func notify(_ element: Event) {
        subject.onNext(element)
    }
    
    /// Subscribes observer
    public func subscribe<Observer: ObserverType>(_ observer: Observer) -> Disposable where Observer.Element == Event {
        return subject.subscribe(observer)
    }

    /// - returns: Canonical interface for push style sequence
    public func asObservable() -> Observable<Event> {
        return subject.asObservable()
    }
}
