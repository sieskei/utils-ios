//
//  Layout+UIView+.swift
//  
//
//  Created by Miroslav Yozov on 18.07.22.
//

import UIKit

extension UIView {
    @discardableResult
    fileprivate func prepare(subview view: UIView, mod: (UIView) -> Void) -> Utils.UI.Layout.Methods {
        view.translatesAutoresizingMaskIntoConstraints = false
        if view.superview != self {
            mod(view)
        }
        return .init(view)
    }
    
    public func layoutGuide(identifier: String, initializer: (UIView) -> UILayoutGuide = { _ in .init() }) -> UILayoutGuide {
        if let guide = layoutGuides.first(where: { $0.identifier == identifier }) {
            return guide
        } else {
            let guide = initializer(self)
            guide.identifier = identifier
            addLayoutGuide(guide)
            return guide
        }
    }

    /// Can be overriden with custom safe area layout guide reference.
    @available(iOS 9.0, *)
    @objc open dynamic var alternativeSafeAreaLayoutGuide: UILayoutGuide? {
        return nil
    }
}

extension UIView {
    public var anchor: Utils.UI.Layout.Anchor.Group {
        .init(self)
    }
    
    public var layout: Utils.UI.Layout.Methods {
        .init(self)
    }
}

extension UILayoutGuide {
    public var anchor: Utils.UI.Layout.Anchor.Group {
        .init(self)
    }
    
    public var layout: Utils.UI.Layout.Methods {
        .init(self)
    }
}


// MARK: - Anchor view/guide with methods.
extension UIView {
    @discardableResult
    public func layout(_ guide: UILayoutGuide) -> Utils.UI.Layout.Methods {
        if guide.owningView != self {
            addLayoutGuide(guide)
        }
        return guide.layout
    }
    
    @discardableResult
    public func layout(_ view: UIView) -> Utils.UI.Layout.Methods {
        prepare(subview: view) { addSubview($0) }
    }
    
    @discardableResult
    public func layout(_ view: UIView, aboveSubview siblingSubview: UIView) -> Utils.UI.Layout.Methods {
        prepare(subview: view) { insertSubview($0, aboveSubview: siblingSubview) }
    }
    
    @discardableResult
    public func layout(_ view: UIView, belowSubview siblingSubview: UIView) -> Utils.UI.Layout.Methods {
        prepare(subview: view) { insertSubview($0, belowSubview: siblingSubview) }
    }
    
    @discardableResult
    public func layout(_ view: UIView, at index: Int) -> Utils.UI.Layout.Methods {
        prepare(subview: view) { insertSubview($0, at: index) }
    }
}


// MARK: - Anchor view/guide with operators.
extension UIView {
    public typealias LayoutType = (_ superanchors: Utils.UI.Layout.Anchor.Group, _ anchors: Utils.UI.Layout.Anchor.Group) -> Void

    public func layout(_ guide: UILayoutGuide, layout: LayoutType) {
        if guide.owningView != self {
            addLayoutGuide(guide)
        }
        layout(anchor, guide.anchor)
    }
    
    public func layout(_ view: UIView, layout: LayoutType) {
        prepare(subview: view) { addSubview($0) }
        layout(anchor, view.anchor)
    }
    
    public func layout(_ view: UIView, aboveSubview siblingSubview: UIView, layout: LayoutType) {
        prepare(subview: view) { insertSubview($0, aboveSubview: siblingSubview) }
        layout(anchor, view.anchor)
    }
    
    public func layout(_ view: UIView, belowSubview siblingSubview: UIView, layout: LayoutType) {
        prepare(subview: view) { insertSubview($0, belowSubview: siblingSubview) }
        layout(anchor, view.anchor)
    }
    
    public func layout(_ view: UIView, at index: Int, layout: LayoutType) {
        prepare(subview: view) { insertSubview($0, at: index) }
        layout(anchor, view.anchor)
    }
}



