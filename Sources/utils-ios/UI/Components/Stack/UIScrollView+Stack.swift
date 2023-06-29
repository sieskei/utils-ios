//
//  UIScrollView+Stack.swift
//  
//
//  Created by Miroslav Yozov on 29.06.23.
//

import UIKit

// MARK: - Container view.
fileprivate var containerViewKey: UInt8 = 0

fileprivate extension UIScrollView {
    func container(direction: UIScrollView.Direction) -> UIView {
        if let v: UIView = Utils.AssociatedObject.get(base: self, key: &containerViewKey) {
            v.removeFromSuperview()
        }
        
        return .init() ~> {
            $0.backgroundColor = .clear
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
            $0.edgeAnchors == edgeAnchors
            Utils.AssociatedObject.set(base: self, key: &containerViewKey, value: $0)
        }
    }
}

extension UIScrollView {
    public var container: UIView? {
        Utils.AssociatedObject.get(base: self, key: &containerViewKey)
    }
}

// MARK: - Elements
fileprivate var elementsKey: UInt8 = 0

fileprivate extension UIScrollView {
    var elements: [Element] {
        get {
            Utils.AssociatedObject.get(base: self, key: &elementsKey) { [] }
        }
        set {
            Utils.AssociatedObject.set(base: self, key: &elementsKey, value: newValue)
        }
    }
}

fileprivate extension Array where Element == UIScrollView.Element {
    mutating func swap(with elems: Self) -> Bool {
        forEach { $0.view.removeFromSuperview() }
        removeAll()
        append(contentsOf: elems)
        return !elems.isEmpty
    }
}

// MARK: UtilsUIStackCompatible
public extension UtilsUIStackCompatible where Self: UIScrollView {
    init(views: [UIView], insets: UIEdgeInsets = .zero) {
        self.init(elements: views.map { ($0, insets) })
    }
    
    init(elements: [UIView.Element], direction: UIView.Direction = .vertical) {
        self.init(frame: .zero)
        stack(elements: elements, direction: direction)
    }
    
    func stack(elements elems: [Element], direction: UIView.Direction = .vertical) {
        let frame: UtilsUIAnchorsCompatible
        let content: UtilsUIAnchorsCompatible
        let parent: UIView
        
        if #available(iOS 11, *) {
            parent = self
            frame = frameLayoutGuide
            content = contentLayoutGuide
        } else {
            // allways create new one
            let container: UIView = container(direction: direction)
            parent = container
            frame = self
            content = container
        }
        
        guard elements.swap(with: elems) else {
            return
        }
        
        if direction == .horizontal, isPagingEnabled {
            elems.forEach { e in
                e.view.widthAnchor == frame.widthAnchor - e.insets.horizontal
            }
        }
        
        UIView.stack(elements: elems, frame: frame, content: content, parent: parent)
    }
}
