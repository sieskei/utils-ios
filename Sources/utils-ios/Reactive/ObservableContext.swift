//
//  File.swift
//  
//
//  Created by Miroslav Yozov on 9.07.21.
//

import Foundation
import RxSwift
import RxCocoa

fileprivate var NotifierKey: UInt8 = 0

public protocol ObservableContext: ReactiveCompatible, AnyObject {
    associatedtype EventType
}

extension ObservableContext {
    fileprivate var notifier: Notifier<EventType> {
        get { Utils.AssociatedObject.get(base: self, key: &NotifierKey) { .init() } }
        set { Utils.AssociatedObject.set(base: self, key: &NotifierKey, value: newValue) }
    }
}

extension Reactive where Base: ObservableContext {
    var event: Observable<Base.EventType> {
        base.notifier.asObservable()
    }
}



//extension Reactive {
//
//    
//
//
//    /// Automatically synthesized binder for a key path between the reactive
//    /// base and one of its properties
//    public subscript<Property>(dynamicMember keyPath: KeyPath<Base, RxProperty<Property>.Tools>) -> ControlProperty<Property> where Base: AnyObject {
//        base[keyPath: keyPath].value
//    }
//}
