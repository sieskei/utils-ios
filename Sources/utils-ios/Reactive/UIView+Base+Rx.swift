//
//  UIView+Rx.swift
//  
//
//  Created by Miroslav Yozov on 30.10.19.
//

import UIKit

import RxSwift
import RxCocoa

public protocol RxViewType where Self: UIView {
    associatedtype M: AnyObject
}

public class RxView<M: AnyObject>: BaseView, RxViewType, ModelCompatible {
    fileprivate let valueModel: EquatableValue<Model<M>> = .init(.empty)
    
    public var model: Model<M> {
        get { return valueModel.value }
        set { valueModel.value = newValue }
    }
}

public extension Reactive where Base: RxViewType {
    var model: Observable<Model<Base.M>> {
        let view: RxView<Base.M> = Utils.castOrFatalError(base)
        return view.valueModel.asObservable()
    }
}
