//
//  File.swift
//  
//
//  Created by Miroslav Yozov on 6.04.22.
//

import UIKit

extension Utils {
    /// User interface namespace.
    public struct UI { }
}


// MARK: Async utils.
extension Utils.UI {
    public static func `async`(execution: @escaping () -> Void) {
        DispatchQueue.main.async(execute: execution)
    }
    
    public static func `async`(delay: TimeInterval, execution: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: execution)
    }
    
    public static func `async`<T: AnyObject>(delay: TimeInterval, with obj: T?, execution: @escaping (T) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak obj = obj] in
            guard let obj = obj else {
                return
            }
            execution(obj)
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


// MARK: Animation utils.
extension Utils.UI {
    /**
     Runs an animations in transaction with a specified duration.
     - Parameter duration: An animation duration time.
     - Parameter animations: An animation block.
     - Parameter timingFunction: A CAMediaTimingFunction.
     - Parameter completion: A completion block that is executed once
     the animations have completed.
     */
    public static func transaction(withDuration duration: CFTimeInterval,
                                   timingFunction: CAMediaTimingFunction = .easeInOut,
                                   animations: (() -> Void),
                                   completion: (() -> Void)? = nil) {
        CATransaction.begin()
        CATransaction.setAnimationDuration(duration)
        CATransaction.setCompletionBlock(completion)
        CATransaction.setAnimationTimingFunction(timingFunction)
        animations()
        CATransaction.commit()
    }
    
    /**
     Disables the default animations set on CALayers.
     - Parameter animations: A callback that wraps the animations to disable.
     */
    public static func disable(_ animations: (() -> Void)) {
        transaction(withDuration: 0, animations: animations)
    }
    
    public static func animate<T: AnyObject>(with obj: T?, delay: TimeInterval = .zero, duration: TimeInterval, options: UIView.AnimationOptions = [], animations: @escaping (T) -> Void, completion: ((T, Bool) -> Void)? = nil) {
        UIView.animate(withDuration: duration, delay: delay, options: options, animations: { [weak obj] in
            if let obj = obj {
                animations(obj)
            }
        }, completion: { [weak obj] flag in
            if let completion = completion, let obj = obj {
                completion(obj, flag)
            }
        })
    }
}
