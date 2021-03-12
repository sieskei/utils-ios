//
//  RxSwiftExt+.swift
//  
//
//  Created by Miroslav Yozov on 6.09.20.
//

import RxSwift
import RxSwiftExt

public extension FilterMap {
    init(_ result: Result?) {
        if let result = result {
            self = .map(result)
        } else {
            self = .ignore
        }
    }
}

public extension ObservableType {
    func filterMap<A: AnyObject, Result>(with obj: A?, _ transform: @escaping (A, Element) throws -> FilterMap<Result>) -> Observable<Result> {
        return filterMap { [weak obj] element in
            guard let obj = obj else {
                return .ignore
            }
            return try transform(obj, element)
        }
    }
}
