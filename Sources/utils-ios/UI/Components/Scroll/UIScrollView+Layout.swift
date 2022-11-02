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
        set1(elements: elements, direction: direction)
    }
    
    func set1(views: [UIView], insets: UIEdgeInsets = .zero, direction: UIScrollView.Direction = .vertical) {
        set1(elements: views.map { ($0, insets) }, direction: direction)
    }
    
    func set1(elements: [Element], direction: UIScrollView.Direction = .vertical) {
        let frameAnchors: UtilsUIAnchorsCompatible
        let contentAnchros: UtilsUIAnchorsCompatible
        let parent: UIView
        
//        if #available(iOS 11, *) {
//            parent = self
//            frameAnchors = frameLayoutGuide
//            contentAnchros = contentLayoutGuide
//        } else {
            // allways create new one
            let container: UIView = container(direction: direction)
            parent = container
            frameAnchors = self
            contentAnchros = container
//        }
        
        /*
        parent.subviews.forEach {
            $0.removeFromSuperview()
        }
        */
        
        
        guard !elements.isEmpty else {
            return
        }
        
        elements.forEach { e in
            e.view.translatesAutoresizingMaskIntoConstraints = false
            parent.addSubview(e.view)
            
            switch direction {
            case .vertical:
                e.view.leftAnchor == contentAnchros.leftAnchor + e.insets.left
                e.view.rightAnchor == contentAnchros.rightAnchor - e.insets.right
                e.view.widthAnchor == frameAnchors.widthAnchor - e.insets.horizontal
            case .horizontal:
                e.view.topAnchor == contentAnchros.topAnchor + e.insets.top
                e.view.bottomAnchor == contentAnchros.bottomAnchor - e.insets.bottom
                e.view.heightAnchor == frameAnchors.heightAnchor - e.insets.vertical
            }
        }
        
        if direction == .horizontal, isPagingEnabled {
            elements.forEach { e in
                e.view.widthAnchor == frameAnchors.widthAnchor - e.insets.horizontal
            }
        }
        
        switch elements.count {
        case 1:
            let e = elements[0]
            switch direction {
            case .vertical:
                e.view.topAnchor == contentAnchros.topAnchor + e.insets.top
                e.view.bottomAnchor == contentAnchros.bottomAnchor - e.insets.bottom
            case .horizontal:
                e.view.leftAnchor == contentAnchros.leftAnchor + e.insets.left
                e.view.rightAnchor == contentAnchros.rightAnchor - e.insets.right
            }
        default:
            let f = elements[0] // first
            let l = elements[elements.count - 1] // last
            
            switch direction {
            case .vertical:
                f.view.topAnchor == contentAnchros.topAnchor + f.insets.top
                
                // middle
                if elements.count > 2 {
                    for i in 1...elements.count - 2 {
                        let s = elements[i].insets.top + elements[i - 1].insets.bottom // spacing
                        elements[i].view.topAnchor == elements[i - 1].view.bottomAnchor + s
                    }
                }
                
                let ls = l.insets.top + elements[elements.count - 2].insets.bottom // spacing
                l.view.topAnchor == elements[elements.count - 2].view.bottomAnchor + ls
                l.view.bottomAnchor == contentAnchros.bottomAnchor - l.insets.bottom
            case .horizontal:
                f.view.leftAnchor == contentAnchros.leftAnchor + f.insets.left
                
                // middle
                if elements.count > 2 {
                    for i in 1...elements.count - 2 {
                        let s = elements[i].insets.left + elements[i - 1].insets.right // spacing
                        elements[i].view.leftAnchor == elements[i - 1].view.rightAnchor + s
                    }
                }
                
                let ls = l.insets.left + elements[elements.count - 2].insets.right // spacing
                l.view.leftAnchor == elements[elements.count - 2].view.rightAnchor + ls
                l.view.rightAnchor == contentAnchros.rightAnchor - l.insets.right
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
