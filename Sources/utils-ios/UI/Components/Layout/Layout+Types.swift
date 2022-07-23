//
//  Layout+Types.swift
//  
//
//  Created by Miroslav Yozov on 7.07.22.
//

import Foundation
import UIKit

// MARK: - Abstract layout constant type.
public protocol UtilsUILayoutConstantType { }

extension CGFloat: UtilsUILayoutConstantType { }
extension CGSize: UtilsUILayoutConstantType { }
extension UIEdgeInsets: UtilsUILayoutConstantType { }


// MARK: - Abstract layout anchor type.
public protocol UtilsUILayoutAnchorType { }

extension NSLayoutAnchor: UtilsUILayoutAnchorType { }


// MARK: - Anchors compatible.
public protocol UtilsUIAnchorsCompatible {
    var leadingAnchor: NSLayoutXAxisAnchor { get }
    var trailingAnchor: NSLayoutXAxisAnchor { get }

    var leftAnchor: NSLayoutXAxisAnchor { get }
    var rightAnchor: NSLayoutXAxisAnchor { get }

    var topAnchor: NSLayoutYAxisAnchor { get }
    var bottomAnchor: NSLayoutYAxisAnchor { get }

    var widthAnchor: NSLayoutDimension { get }
    var heightAnchor: NSLayoutDimension { get }

    var centerXAnchor: NSLayoutXAxisAnchor { get }
    var centerYAnchor: NSLayoutYAxisAnchor { get }
    
    var horizontalAnchors: Utils.UI.Layout.Anchor.Pair<NSLayoutXAxisAnchor, NSLayoutXAxisAnchor> { get }
    var verticalAnchors: Utils.UI.Layout.Anchor.Pair<NSLayoutYAxisAnchor, NSLayoutYAxisAnchor> { get }
    var centerAnchors: Utils.UI.Layout.Anchor.Pair<NSLayoutXAxisAnchor, NSLayoutYAxisAnchor> { get }
    var sizeAnchors: Utils.UI.Layout.Anchor.Pair<NSLayoutDimension, NSLayoutDimension> { get }
    var edgeAnchors: Utils.UI.Layout.Anchor.Edges { get }
    
    var safeAnchors: UtilsUIAnchorsCompatible { get }
    var parentAnchors: UtilsUIAnchorsCompatible? { get }
}

extension UtilsUIAnchorsCompatible {
    public var horizontalAnchors: Utils.UI.Layout.Anchor.Pair<NSLayoutXAxisAnchor, NSLayoutXAxisAnchor> {
        .init(first: leadingAnchor, second: trailingAnchor)
    }

    public var verticalAnchors: Utils.UI.Layout.Anchor.Pair<NSLayoutYAxisAnchor, NSLayoutYAxisAnchor> {
        .init(first: topAnchor, second: bottomAnchor)
    }

    public var centerAnchors: Utils.UI.Layout.Anchor.Pair<NSLayoutXAxisAnchor, NSLayoutYAxisAnchor> {
        .init(first: centerXAnchor, second: centerYAnchor)
    }

    public var sizeAnchors: Utils.UI.Layout.Anchor.Pair<NSLayoutDimension, NSLayoutDimension> {
        .init(first: widthAnchor, second: heightAnchor)
    }

    public var edgeAnchors: Utils.UI.Layout.Anchor.Edges {
        .init(horizontal: horizontalAnchors, vertical: verticalAnchors)
    }
    
    internal var unwapParentAnchors: UtilsUIAnchorsCompatible {
        assert(parentAnchors != nil, "Utils.UI.Layout: Requires view/guide to have parent.")
        return parentAnchors!
    }
    
    internal func unwrapParentAnchor<T: UtilsUILayoutAnchorType>(_ path: KeyPath<UtilsUIAnchorsCompatible, T>, safe: Bool = false) -> T {
        let parent = unwapParentAnchors
        return safe ? parent.safeAnchors[keyPath: path] : parent[keyPath: path]
    }
}

extension UILayoutGuide: UtilsUIAnchorsCompatible {
    public var safeAnchors: UtilsUIAnchorsCompatible {
        self
    }
    
    public var parentAnchors: UtilsUIAnchorsCompatible? {
        owningView
    }
}

extension UIView: UtilsUIAnchorsCompatible {
    public var safeAnchors: UtilsUIAnchorsCompatible {
        if #available(iOS 11.0, *) {
            return safeAreaLayoutGuide
        } else if let guide = alternativeSafeAreaLayoutGuide {
            return guide
        } else {
            return self
        }
    }
    
    public var parentAnchors: UtilsUIAnchorsCompatible? {
        superview
    }
}
