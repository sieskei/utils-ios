//
//  UITextField+Rx.swift
//  
//
//  Created by Miroslav Yozov on 16.11.21.
//

#if os(iOS) || os(tvOS)

import RxSwift
import RxCocoa
import UIKit

extension Reactive where Base: UITextField {
    /// Reactive wrapper for `delegate`.
    ///
    /// For more information take a look at `DelegateProxyType` protocol documentation.
    public var delegate: DelegateProxy<UITextField, UITextFieldDelegate> {
        return RxTextFieldDelegateProxy.proxy(for: base)
    }
    
    /// Reactive wrapper for `delegate` message.
    public var didBeginEditing: ControlEvent<()> {
        return ControlEvent<()>(events: self.delegate.methodInvoked(#selector(UITextFieldDelegate.textFieldDidBeginEditing(_:)))
            .map { _ in
                return ()
            })
    }

    /// Reactive wrapper for `delegate` message.
    public var didEndEditing: ControlEvent<()> {
        return ControlEvent<()>(events: self.delegate.methodInvoked(#selector(UITextFieldDelegate.textFieldDidEndEditing(_:)))
            .map { _ in
                return ()
            })
    }
}

#endif
