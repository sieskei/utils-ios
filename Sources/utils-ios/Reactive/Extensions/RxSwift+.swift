//
//  RxSwift+.swift
//  
//
//  Created by Miroslav Yozov on 2.12.19.
//

import Foundation

import RxSwift

public extension ObservableType {
    func subscribeNextWeakly<A: AnyObject>(weak obj: A, _ onNext: @escaping (A, Element) -> Void) -> Disposable {
        return subscribe(onNext: { [weak obj] element in
            guard let obj = obj else { return }
            onNext(obj, element)
        })
    }
    
    func subscribeNextWeakly<A: AnyObject, B: AnyObject>(weaks obj1: A?, _ obj2: B?, _ onNext: @escaping (A, B, Element) -> Void) -> Disposable {
        return subscribe(onNext: { [weak obj1, weak obj2] element in
            guard let obj1 = obj1, let obj2 = obj2 else { return }
            onNext(obj1, obj2, element)
        })
    }
}
