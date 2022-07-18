//
//  Layout+UIView+.swift
//  
//
//  Created by Miroslav Yozov on 18.07.22.
//

import UIKit


extension UIView {
    public func anchor(subview view: UIView, layout: (Utils.UI.Layout.Anchor.Group, Utils.UI.Layout.Anchor.Group) -> Void) {
        if view.superview != self {
            addSubview(view)
        }
        view.translatesAutoresizingMaskIntoConstraints = false
        layout(anchors, view.anchors)
    }
}
