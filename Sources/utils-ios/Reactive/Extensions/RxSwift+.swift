//
//  RxSwift+.swift
//  
//
//  Created by Miroslav Yozov on 2.12.19.
//

import Foundation
import RxSwift

// MARK: ObservableType - map utils.
public extension ObservableType {
    func map<A: AnyObject, Result>(unowned obj: A, _ transform: @escaping (A, Element) -> Result) -> Observable<Result> {
        return map { [unowned obj = obj] element in
            return transform(obj, element)
        }
    }
    
    func map<A: AnyObject, B: AnyObject, Result>(unowned obj1: A, _ obj2: B, _ transform: @escaping (A, B, Element) -> Result) -> Observable<Result> {
        return map { [unowned obj1 = obj1, unowned obj2 = obj2] element in
            return transform(obj1, obj2, element)
        }
    }
    
    func map<A: AnyObject, Result>(with obj: A?, `default`: Result, _ transform: @escaping (A, Element) -> Result) -> Observable<Result> {
        return map { [weak obj] element in
            guard let obj = obj else {
                return `default`
            }
            return transform(obj, element)
        }
    }
    
    func map<A: AnyObject, B: AnyObject, Result>(with obj1: A?, _ obj2: B?, `default`: Result, _ transform: @escaping (A, B, Element) -> Result) -> Observable<Result> {
        return map { [weak obj1, weak obj2] element in
            guard let obj1 = obj1, let obj2 = obj2 else {
                return `default`
            }
            return transform(obj1, obj2, element)
        }
    }
}

// MARK: ObservableType - filter utils.
public extension ObservableType {
    func filter<A: AnyObject>(with obj: A?, _ predicate: @escaping (A, Element) -> Bool) -> Observable<Element> {
        return filter { [weak obj] element in
            guard let obj = obj else {
                return false
            }
            return predicate(obj, element)
        }
    }
}

// MARK: ObservableType - subscribe/do utils.
public extension ObservableType {
    func subscribeNext(_ onNext: @escaping (Element) -> Void) -> Disposable {
        return subscribe(onNext: { element in
            onNext(element)
        })
    }
    
    func subscribeNext<A: AnyObject>(with obj: A?, _ onNext: @escaping (A, Element) -> Void) -> Disposable {
        return subscribe(onNext: { [weak obj] element in
            guard let obj = obj else { return }
            onNext(obj, element)
        })
    }
    
    func subscribeNext<A: AnyObject, B: AnyObject>(with obj1: A?, _ obj2: B?, _ onNext: @escaping (A, B, Element) -> Void) -> Disposable {
        return subscribe(onNext: { [weak obj1, weak obj2] element in
            guard let obj1 = obj1, let obj2 = obj2 else { return }
            onNext(obj1, obj2, element)
        })
    }
    
    func subscribeNext<A: AnyObject, B: AnyObject, C: AnyObject>(with obj1: A?, _ obj2: B?, _ obj3: C?, _ onNext: @escaping (A, B, C, Element) -> Void) -> Disposable {
        return subscribe(onNext: { [weak obj1, weak obj2, weak obj3] element in
            guard let obj1 = obj1, let obj2 = obj2, let obj3 = obj3 else { return }
            onNext(obj1, obj2, obj3, element)
        })
    }
    
    func `do`<A: AnyObject>(with obj: A?, onNext: ((A, Element) throws -> Void)? = nil, afterNext: ((A, Element) throws -> Void)? = nil, onError: ((A, Swift.Error) throws -> Void)? = nil, afterError: ((A, Swift.Error) throws -> Void)? = nil, onCompleted: ((A) throws -> Void)? = nil, afterCompleted: ((A) throws -> Void)? = nil, onSubscribe: ((A) -> Void)? = nil, onSubscribed: ((A) -> Void)? = nil, onDispose: ((A) -> Void)? = nil)
    -> Observable<Element> {
        return `do`(
            onNext: { [weak obj] in
                if let o = obj, let c = onNext {
                    try c(o, $0)
                }
            }, afterNext: { [weak obj] in
                if let o = obj, let c = afterNext {
                    try c(o, $0)
                }
            }, onError: { [weak obj] in
                if let o = obj, let c = onError {
                    try c(o, $0)
                }
            }, afterError: { [weak obj] in
                if let o = obj, let c = afterError {
                    try c(o, $0)
                }
            }, onCompleted: { [weak obj] in
                if let o = obj, let c = onCompleted {
                    try c(o)
                }
            }, afterCompleted: { [weak obj] in
                if let o = obj, let c = afterCompleted {
                    try c(o)
                }
            }, onSubscribe: { [weak obj] in
                if let o = obj, let c = onSubscribe {
                    c(o)
                }
            }, onSubscribed: { [weak obj] in
                if let o = obj, let c = onSubscribed {
                    c(o)
                }
            }, onDispose: { [weak obj] in
                if let o = obj, let c = onDispose {
                    c(o)
                }
        })
    }
}

// MARK: PrimitiveSequenceType - do utils.
public extension PrimitiveSequenceType where Trait == SingleTrait {
    func `do`<A: AnyObject>(with obj: A?, onSuccess: ((A, Element) throws -> Void)? = nil, afterSuccess: ((A, Element) throws -> Void)? = nil, onError: ((A, Error) throws -> Void)? = nil, afterError: ((A, Error) throws -> Void)? = nil, onSubscribe: ((A) -> Void)? = nil, onSubscribed: ((A) -> Void)? = nil, onDispose: ((A) -> Void)? = nil) -> Single<Element> {
        return `do`(
            onSuccess: { [weak obj] in
                if let o = obj, let c = onSuccess {
                    try c(o, $0)
                }
            }, afterSuccess: { [weak obj] in
                if let o = obj, let c = afterSuccess {
                    try c(o, $0)
                }
            }, onError: { [weak obj] in
                if let o = obj, let c = onError {
                    try c(o, $0)
                }
            }, afterError: { [weak obj] in
                if let o = obj, let c = afterError {
                    try c(o, $0)
                }
            }, onSubscribe: { [weak obj] in
                if let o = obj, let c = onSubscribe {
                    c(o)
                }
            }, onSubscribed: { [weak obj] in
                if let o = obj, let c = onSubscribed {
                    c(o)
                }
            }, onDispose: { [weak obj] in
                if let o = obj, let c = onDispose {
                    c(o)
                }
        })
    }
}
