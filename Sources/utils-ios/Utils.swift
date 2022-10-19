//
//  Utils.swift
//  
//
//  Created by Miroslav Yozov on 29.10.19.
//

import Foundation
import RxSwift
import RxCocoa

public extension Fault.Keys {
    struct Utils { }
}

public extension Fault.Codes {
    struct Utils { }
}

public extension Fault {
    struct Utils { }
}

public extension Fault.Codes.Utils {
    static var unwrap = "utils.unwrap"
    static var casting = "utils.casting"
    static var resultOf = "utils.resultOf"
}

public extension Fault.Utils {
    static func unwrap(targetType: Any.Type) -> Fault {
        .init(code: Fault.Codes.Utils.unwrap, enMessage: "Failure unwrap to `\(targetType.self)`")
    }
    
    static func casting(object: Any, targetType: Any.Type) -> Fault {
        .init(code: Fault.Codes.Utils.casting, enMessage: "Error casting `\(object)` to `\(targetType)`")
    }
    
    static var resultOf: Fault {
        .init(code: Fault.Codes.Utils.resultOf, enMessage: "Missing result and error.")
    }
}

public struct Utils {
    private init() { }
    
    public static func unwrapOrFatalError<T>(_ value: T?) -> T {
        guard let result = value else {
            fatalError("Failure unwrap to \(T.self)")
        }
        return result
    }
    
    public static func unwrapOrThrow<T>(_ value: T?, _ fault: Fault? = nil) throws -> T {
        guard let result = value else {
            throw fault ?? Fault.Utils.unwrap(targetType: T.self)
        }
        return result
    }
    
    public static func castOrFatalError<T>(_ value: Any?) -> T {
        let v: Any = unwrapOrFatalError(value)
        let maybeResult: T? = v as? T
        guard let result = maybeResult else {
            fatalError("Failure converting from \(String(describing: value)) to \(T.self)")
        }
        return result
    }
    
    public static func castOrThrow<T>(_ value: Any?, _ fault: Fault? = nil) throws -> T {
        let v: Any = try unwrapOrThrow(value, fault)
        let maybeResult: T? = v as? T
        guard let result = maybeResult else {
            throw fault ?? Fault.Utils.casting(object: v, targetType: T.self)
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
    
    public static func resultOf<T>(value: Any?, error: Error?) -> Result<T, Error> {
        if let v = value {
            do {
                return .success(try castOrThrow(v))
            } catch {
                return .failure(error)
            }
        } else if let e = error {
            return .failure(e)
        } else {
            return .failure(Fault.Utils.resultOf) // must be missing result and error
        }
    }
}

extension Utils: ReactiveCompatible { }

public extension Reactive where Base == Utils {
    static func interval(_ period: RxTimeInterval) -> Observable<Int> {
        return .interval(period, scheduler: Base.Task.rx.concurrentScheduler)
    }
    
    static func timer(_ dueTime: RxTimeInterval, period: RxTimeInterval? = nil) -> Observable<Int> {
        return .timer(dueTime, period: period, scheduler: Base.Task.rx.concurrentScheduler)
    }
}
