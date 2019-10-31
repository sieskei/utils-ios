//
//  File.swift
//  
//
//  Created by Miroslav Yozov on 31.10.19.
//

import Foundation

import RxSwift
import RxCocoa

public extension Reactive where Base: BaseViewController {
    var initialize: ControlEvent<Void> {
        return .init(events: methodInvoked(#selector(Base.initialize)).map { _ in })
    }
}

public extension Reactive where Base: BaseNavigationConroller {
    var initialize: ControlEvent<Void> {
        return .init(events: methodInvoked(#selector(Base.initialize)).map { _ in })
    }
}

