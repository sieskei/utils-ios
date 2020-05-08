//
//  Utils.swift
//  
//
//  Created by Miroslav Yozov on 29.10.19.
//

import Foundation
import RxSwift
import RxCocoa

public extension Fault {
    struct Utils { }
}

public struct Utils {
    private init() { }
    
    public static func unwrapOrFatalError<T>(_ value: T?) -> T {
        guard let result = value else {
            fatalError("Failure unwrap to \(T.self)")
        }
        return result
    }
    
    public static func castOrFatalError<T>(_ value: Any) -> T {
        let maybeResult: T? = value as? T
        guard let result = maybeResult else {
            fatalError("Failure converting from \(String(describing: value)) to \(T.self)")
        }
        
        return result
    }
    
    public static let swizzling: (AnyClass, Selector, Selector) -> Bool = { forClass, originalSelector, swizzledSelector in
        guard let originalMethod = class_getInstanceMethod(forClass, originalSelector),
            let swizzledMethod = class_getInstanceMethod(forClass, swizzledSelector) else {
                return false
        }
        
        method_exchangeImplementations(originalMethod, swizzledMethod)
        return true
    }
}

extension Utils: ReactiveCompatible { }

public extension Reactive where Base == Utils {
    static func interval(_ period: RxTimeInterval) -> Observable<Int> {
        return .interval(period, scheduler: Base.Task.rx.concurrentScheduler)
    }
}
