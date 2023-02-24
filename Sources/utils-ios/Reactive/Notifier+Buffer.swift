//
//  BufferedNotifier.swift
//  
//
//  Created by Miroslav Yozov on 24.02.23.
//

import Foundation
import RxSwift

extension BufferedNotifier {
    public enum State: Int {
        case buffer
        case passthrough
    }
}

open class BufferedNotifier<Element>: ObservableType, ObserverType {
    fileprivate var buffer: Buffer<Element>
    fileprivate let subject: PublishSubject<Element> = .init()
    
    public init(state: State = .buffer) {
        switch state {
        case .buffer:
            buffer = .buffer()
        case .passthrough:
            buffer = .passthrough(subject)
        }
    }
    
    public final func set(state: State) {
        switch state {
        case .buffer:
            buffer = .buffer()
        case .passthrough:
            buffer.flush(to: subject)
        }
    }
    
    // MARK: ObservableType
    public func subscribe<Observer>(_ observer: Observer) -> RxSwift.Disposable where Observer : RxSwift.ObserverType, Element == Observer.Element {
        subject.subscribe(observer)
    }
    
    public func asObservable() -> Observable<Element> {
        subject
    }
    
    // MARK: ObserverType
    public func on(_ event: RxSwift.Event<Element>) {
        buffer.push(event)
    }
}


