//
//  UIView+Rx.swift
//  
//
//  Created by Miroslav Yozov on 30.10.19.
//

import UIKit

import RxSwift
import RxCocoa

public protocol RxViewType: ModelCompatible where Self: UIView { }

public class RxView<M: AnyObject>: BaseView, RxViewType {
    fileprivate let valueModel: EquatableValue<Model<M>> = .init(.empty)
    
    public var model: Model<M> {
        get { return valueModel.value }
        set { valueModel.value = newValue }
    }
}

// MARK: Reactive compatible.
public extension Reactive where Base: RxViewType {
    var model: ControlProperty<Model<Base.M>>? {
        let view: RxView<Base.M> = Utils.castOrFatalError(base)
        let bindingObserver: Binder<Model<Base.M>> = .init(view, binding: {
            $0.model = $1
        })
        return .init(values: view.valueModel.asObservable(), valueSink: bindingObserver)
    }
}
