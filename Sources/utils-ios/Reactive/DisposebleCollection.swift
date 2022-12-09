//
//  DisposebleCollection.swift
//  
//
//  Created by Miroslav Yozov on 9.12.22.
//

import Foundation
import RxSwift

public typealias DisposableCollection = Array<Disposable>

extension DisposableCollection: Disposable {
    public func dispose() {
        forEach { $0.dispose() }
    }
}

extension Disposable {
    /// Adds `self` to `collection`
    ///
    /// - parameter bag: `DisposeBag` to add `self` to.
    public func disposed(by collection: inout DisposableCollection) {
        collection.append(self)
    }
}
