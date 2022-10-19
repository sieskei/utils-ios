//
//  RxTextFieldDelegateProxy.swift
//  
//
//  Created by Miroslav Yozov on 16.11.21.
//

#if os(iOS) || os(tvOS)

import UIKit
import RxSwift
import RxCocoa

extension UITextField: HasDelegate {
    public typealias Delegate = UITextFieldDelegate
}

/// For more information take a look at `DelegateProxyType`.
open class RxTextFieldDelegateProxy
    : DelegateProxy<UITextField, UITextFieldDelegate>
    , DelegateProxyType
    , UITextFieldDelegate {

    /// Typed parent object.
    public weak private(set) var field: UITextField?

    /// - parameter field: Parent object for delegate proxy.
    public init(field: ParentObject) {
        self.field = field
        super.init(parentObject: field, delegateProxy: RxTextFieldDelegateProxy.self)
    }

    // Register known implementations
    public static func registerKnownImplementations() {
        self.register { RxTextFieldDelegateProxy(field: $0) }
    }
}

#endif
