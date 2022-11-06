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
    public var separatorContentEdgeInsets: UIEdgeInsets {
        get {
            separator.contentEdgeInsets
        }
        set {
            separator.contentEdgeInsets = newValue
        }
    }

    /// Separator color.
    public var separatorColor: UIColor? {
        get {
            separator.color
        }
        set {
            separator.color = newValue
        }
    }

    /// Separator visibility.
    public var isSeparatorHidden: Bool {
        get {
            return separator.isHidden
        }
        set {
            separator.isHidden = newValue
        }
    }

    /// Separator alignment.
    public var separatorAlignment: Utils.UI.Separator.Alignment {
        get {
            separator.alignment
        }
        set {
            separator.alignment = newValue
        }
    }

    /// Separator thickness.
    public var separatorThickness: CGFloat {
        get {
            separator.thickness
        }
        set {
            separator.thickness = newValue
        }
    }

    /// Sets the separator frame.
    public func layoutSeparator() {
        separator.layout()
    }
}
