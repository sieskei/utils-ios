//
//  Layout+UIView+.swift
//  
//
//  Created by Miroslav Yozov on 18.07.22.
//

import UIKit


extension UIView {
    public typealias LayoutType = (_ superanchors: Utils.UI.Layout.Anchor.Group, _ anchors: Utils.UI.Layout.Anchor.Group) -> Void
    
    private func prepare(subview view: UIView, mod: (UIView) -> Void) {
        view.translatesAutoresizingMaskIntoConstraints = false
        if view.superview != self {
            mod(view)
        }
    }
    
    public func anchor(guide: UILayoutGuide, layout: LayoutType) {
        if guide.owningView != self {
            addLayoutGuide(guide)
        }
        layout(anchors, guide.anchors)
    }
    
    public func anchor(subview view: UIView, layout: LayoutType) {
        prepare(subview: view) {
            addSubview($0)
        }
        layout(anchors, view.anchors)
    }
    
    public func anchor(subview view: UIView, aboveSubview siblingSubview: UIView, layout: LayoutType) {
        prepare(subview: view) {
            insertSubview($0, aboveSubview: siblingSubview)
        }
        layout(anchors, view.anchors)
    }
    
    public func anchor(subview view: UIView, belowSubview siblingSubview: UIView, layout: LayoutType) {
        prepare(subview: view) {
            insertSubview($0, belowSubview: siblingSubview)
        }
        layout(anchors, view.anchors)
    }
    
    public func anchor(subview view: UIView, at index: Int, layout: LayoutType) {
        prepare(subview: view) {
            insertSubview($0, at: index)
        }
        layout(anchors, view.anchors)
    }
}
