//
//  File.swift
//  
//
//  Created by Miroslav Yozov on 31.10.19.
//

import Foundation

import RxSwift
import RxCocoa

public extension Reactive where Base: BaseView {
    var initialize: ControlEvent<Void> {
        return .init(events: methodInvoked(#selector(Base.initialize)).map { _ in })
    }
}

public extension Reactive where Base: BaseTableView {
    var initialize: ControlEvent<Void> {
        return .init(events: methodInvoked(#selector(Base.initialize)).map { _ in })
    }
}

public extension Reactive where Base: BaseCollectionView {
    var initialize: ControlEvent<Void> {
        return .init(events: methodInvoked(#selector(Base.initialize)).map { _ in })
    }
}

public extension Reactive where Base: BaseTableViewCell {
    var initialize: ControlEvent<Void> {
        return .init(events: methodInvoked(#selector(Base.initialize)).map { _ in })
    }
}

public extension Reactive where Base: BaseCollectionViewCell {
    var initialize: ControlEvent<Void> {
        return .init(events: methodInvoked(#selector(Base.initialize)).map { _ in })
    }
}
