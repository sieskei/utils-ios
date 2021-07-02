//
//  File.swift
//  
//
//  Created by Miroslav Yozov on 2.07.21.
//

import Foundation
import RxSwift

fileprivate var DisposeContextBagKey: UInt8 = 0

public protocol DisposeContext: AnyObject { }

extension DisposeContext {
    fileprivate var disposeBag: DisposeBag {
        get { Utils.AssociatedObject.get(base: self, key: &DisposeContextBagKey) { .init() } }
        set { Utils.AssociatedObject.set(base: self, key: &DisposeContextBagKey, value: newValue) }
    }
    
    public func contextDispose() {
        disposeBag = .init()
    }
}

extension Disposable {
    public func disposed(by context: DisposeContext) {
        disposed(by: context.disposeBag)
    }
}
