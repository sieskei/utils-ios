//
//  UtilsUIStackCompatible.swift
//  
//
//  Created by Miroslav Yozov on 29.06.23.
//

import UIKit

extension UIView {
    public typealias Element = (view: UIView, insets: UIEdgeInsets)
    
    @objc
    public enum Direction: Int {
        case vertical
        case horizontal
    }
}

public protocol UtilsUIStackCompatible {
    init(views: [UIView], insets: UIEdgeInsets, direction: UIView.Direction)
    init(elements: [UIView.Element], direction: UIView.Direction)
    
    func stack(views: [UIView], insets: UIEdgeInsets, direction: UIView.Direction)
    func stack(elements elems: [UIView.Element], direction: UIView.Direction)
}

public extension UtilsUIStackCompatible {
    init(views: [UIView], insets: UIEdgeInsets = .zero, direction: UIView.Direction = .vertical) {
        self.init(elements: views.map { ($0, insets) }, direction: direction)
    }
    
    func stack(views: [UIView], insets: UIEdgeInsets = .zero, direction: UIView.Direction = .vertical) {
        stack(elements: views.map { ($0, insets) }, direction: direction)
    }
}
