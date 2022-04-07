//
//  File.swift
//  
//
//  Created by Miroslav Yozov on 6.04.22.
//

import Foundation

extension Utils {
    // User interface namespace.
    public struct UI {
        public static func `async`(execution: @escaping () -> Void) {
            DispatchQueue.main.async {
                execution()
            }
        }
        
        public static func `async`<T: AnyObject>(with obj: T?, execution: @escaping (T) -> Void) {
            DispatchQueue.main.async { [weak obj = obj] in
                guard let obj = obj else {
                    return
                }
                execution(obj)
            }
        }
        
        public static func `async`<A: AnyObject, B: AnyObject>(with objA: A?, objB: B?, execution: @escaping (A, B) -> Void) {
            DispatchQueue.main.async { [weak objA, weak objB] in
                guard let objA = objA, let objB = objB else {
                    return
                }
                execution(objA, objB)
            }
        }
        
        public static func `async`<A: AnyObject, B: AnyObject>(with objA: A?, objB: B?, exec0: @escaping (A, B) -> Void, exec1: @escaping (A, B) -> Void) {
            DispatchQueue.main.async { [weak objA, weak objB] in
                if let objA = objA, let objB = objB {
                    exec0(objA, objB)
                    DispatchQueue.main.async { [weak objA, weak objB] in
                        if let objA = objA, let objB = objB {
                            exec1(objA, objB)
                        }
                    }
                }
            }
        }
    }
}
