//
//  UIScrollView+Layout.swift
//  
//
//  Created by Miroslav Yozov on 29.12.20.
//

import UIKit

extension UIScrollView {
    public typealias Element = (view: UIView, insets: UIEdgeInsets)
    
    public enum Direction: Int {
        case vertical
        case horizontal
    }
}

public extension UIScrollView {
    convenience init(views: [UIView], insets: UIEdgeInsets = .zero) {
        self.init(elements: views.map { ($0, insets) })
    }
    
    convenience init(elements: [Element], direction: UIScrollView.Direction = .vertical) {
        self.init(frame: .zero)
        set(elements: elements, direction: direction)
    }
    
    func set(views: [UIView], insets: UIEdgeInsets = .zero, direction: UIScrollView.Direction = .vertical) {
        set(elements: views.map { ($0, insets) }, direction: direction)
    }
    
    func set(elements elems: [Element], direction: UIScrollView.Direction = .vertical) {
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
        
        elems.forEach { e in
            e.view.translatesAutoresizingMaskIntoConstraints = false
            parent.addSubview(e.view)
            
            switch direction {
            case .vertical:
                e.view.leftAnchor == content.leftAnchor + e.insets.left
                e.view.rightAnchor == content.rightAnchor - e.insets.right
                e.view.widthAnchor == frame.widthAnchor - e.insets.horizontal
            case .horizontal:
                e.view.topAnchor == content.topAnchor + e.insets.top
                e.view.bottomAnchor == content.bottomAnchor - e.insets.bottom
                e.view.heightAnchor == frame.heightAnchor - e.insets.vertical
            }
        }
        
        if direction == .horizontal, isPagingEnabled {
            elems.forEach { e in
                e.view.widthAnchor == frame.widthAnchor - e.insets.horizontal
            }
        }
        
        switch elems.count {
        case 1:
            let e = elems[0]
            switch direction {
            case .vertical:
                e.view.topAnchor == content.topAnchor + e.insets.top
                e.view.bottomAnchor == content.bottomAnchor - e.insets.bottom
            case .horizontal:
                e.view.leftAnchor == content.leftAnchor + e.insets.left
                e.view.rightAnchor == content.rightAnchor - e.insets.right
            }
        default:
            let f = elems[0] // first
            let l = elems[elems.count - 1] // last
            
            switch direction {
            case .vertical:
                f.view.topAnchor == content.topAnchor + f.insets.top
                
                // middle
                if elems.count > 2 {
                    for i in 1...elems.count - 2 {
                        let s = elems[i].insets.top + elems[i - 1].insets.bottom // spacing
                        elems[i].view.topAnchor == elems[i - 1].view.bottomAnchor + s
                    }
                }
                
                let ls = l.insets.top + elems[elems.count - 2].insets.bottom // spacing
                l.view.topAnchor == elems[elems.count - 2].view.bottomAnchor + ls
                l.view.bottomAnchor == content.bottomAnchor - l.insets.bottom
            case .horizontal:
                f.view.leftAnchor == content.leftAnchor + f.insets.left
                
                // middle
                if elems.count > 2 {
                    for i in 1...elems.count - 2 {
                        let s = elems[i].insets.left + elems[i - 1].insets.right // spacing
                        elems[i].view.leftAnchor == elems[i - 1].view.rightAnchor + s
                    }
                }
                
                let ls = l.insets.left + elems[elems.count - 2].insets.right // spacing
                l.view.leftAnchor == elems[elems.count - 2].view.rightAnchor + ls
                l.view.rightAnchor == content.rightAnchor - l.insets.right
            }
        }
    }
}

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
