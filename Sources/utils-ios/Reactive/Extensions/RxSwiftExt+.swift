//
//  RxSwiftExt+.swift
//  
//
//  Created by Miroslav Yozov on 6.09.20.
//

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
