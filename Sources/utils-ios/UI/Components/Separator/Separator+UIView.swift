//
//  Separator+UIView.swift
//  
//
//  Created by Miroslav Yozov on 25.07.22.
//

import UIKit

/// A memory reference to the Separator instance.
fileprivate var SeparatorKey: UInt8 = 0

extension UIView {
    /// Separator reference.
    internal var separator: Utils.UI.Separator {
        Utils.AssociatedObject.get(base: self, key: &SeparatorKey) {
            .init(view: self)
        }
    }

    /// Separator insets.
    open var separatorContentEdgeInsets: UIEdgeInsets {
        get {
            separator.contentEdgeInsets
        }
        set {
            separator.contentEdgeInsets = newValue
        }
    }

    /// Separator color.
    open var separatorColor: UIColor? {
        get {
            separator.color
        }
        set {
            separator.color = newValue
        }
    }

    /// Separator visibility.
    open var isSeparatorHidden: Bool {
        get {
            return separator.isHidden
        }
        set {
            separator.isHidden = newValue
        }
    }

    /// Separator alignment.
    open var separatorAlignment: Utils.UI.Separator.Alignment {
        get {
            separator.alignment
        }
        set {
            separator.alignment = newValue
        }
    }

    /// Separator thickness.
    open var separatorThickness: CGFloat {
        get {
            separator.thickness
        }
        set {
            separator.thickness = newValue
        }
    }

    /// Sets the separator frame.
    open func layoutSeparator() {
        separator.layout()
    }
}
