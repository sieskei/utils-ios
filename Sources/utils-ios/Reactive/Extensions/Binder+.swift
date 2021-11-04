//
//  Binder+.swift
//  
//
//  Created by Miroslav Yozov on 4.11.21.
//

import Foundation
import RxSwift

extension Binder {
    public func on(_ value: Value) {
        on(.next(value))
    }
}
