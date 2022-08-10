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
    
    func set(elements: [Element], direction: UIScrollView.Direction = .vertical) {
        // allways create new one
        let container: UIView = container(direction: direction)
        
        guard !elements.isEmpty else {
            return
        }
        
        elements.forEach { e in
            e.view.translatesAutoresizingMaskIntoConstraints = false
            container.addSubview(e.view)
            
            switch direction {
            case .vertical:
                NSLayoutConstraint.activate([e.view.leftAnchor.constraint(equalTo: container.leftAnchor, constant: e.insets.left),
                                             e.view.rightAnchor.constraint(equalTo: container.rightAnchor, constant: -e.insets.right)])
            case .horizontal:
                NSLayoutConstraint.activate([e.view.topAnchor.constraint(equalTo: container.topAnchor, constant: e.insets.top),
                                             e.view.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -e.insets.bottom)])
            }
        }
        
        if direction == .horizontal, isPagingEnabled {
            elements.forEach { e in
                NSLayoutConstraint.activate([
                    e.view.widthAnchor.constraint(equalTo: widthAnchor, constant: -e.insets.horizontal)
                ])
            }
        }
        
        switch elements.count {
        case 1:
            let e = elements[0]
            switch direction {
            case .vertical:
                NSLayoutConstraint.activate([e.view.topAnchor.constraint(equalTo: container.topAnchor, constant: e.insets.top),
                                             e.view.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -e.insets.bottom)])
            case .horizontal:
                NSLayoutConstraint.activate([e.view.leftAnchor.constraint(equalTo: container.leftAnchor, constant: e.insets.left),
                                             e.view.rightAnchor.constraint(equalTo: container.rightAnchor, constant: -e.insets.right)])
            }
        default:
            let f = elements[0] // first
            let l = elements[elements.count - 1] // last
            
            switch direction {
            case .vertical:
                NSLayoutConstraint.activate([
                    f.view.topAnchor.constraint(equalTo: container.topAnchor, constant: f.insets.top)
                ])
                
                // middle
                if elements.count > 2 {
                    for i in 1...elements.count - 2 {
                        let s = elements[i].insets.top + elements[i - 1].insets.bottom // spacing
                        NSLayoutConstraint.activate([
                            elements[i].view.topAnchor.constraint(equalTo: elements[i - 1].view.bottomAnchor, constant: s)
                        ])
                    }
                }
                
                let ls = l.insets.top + elements[elements.count - 2].insets.bottom // spacing
                NSLayoutConstraint.activate([
                    l.view.topAnchor.constraint(equalTo: elements[elements.count - 2].view.bottomAnchor, constant: ls),
                    l.view.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -l.insets.bottom)
                ])
            case .horizontal:
                NSLayoutConstraint.activate([
                    f.view.leftAnchor.constraint(equalTo: container.leftAnchor, constant: f.insets.left)
                ])
                
                // middle
                if elements.count > 2 {
                    for i in 1...elements.count - 2 {
                        let s = elements[i].insets.left + elements[i - 1].insets.right // spacing
                        NSLayoutConstraint.activate([
                            elements[i].view.leftAnchor.constraint(equalTo: elements[i - 1].view.rightAnchor, constant: s)
                        ])
                    }
                }
                
                let ls = l.insets.left + elements[elements.count - 2].insets.right // spacing
                NSLayoutConstraint.activate([
                    l.view.leftAnchor.constraint(equalTo: elements[elements.count - 2].view.rightAnchor, constant: ls),
                    l.view.rightAnchor.constraint(equalTo: container.rightAnchor, constant: -l.insets.bottom)
                ])
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
            
            NSLayoutConstraint.activate([
                $0.leftAnchor.constraint(equalTo: leftAnchor),
                $0.rightAnchor.constraint(equalTo: rightAnchor),
                $0.topAnchor.constraint(equalTo: topAnchor),
                $0.bottomAnchor.constraint(equalTo: bottomAnchor),
                (direction == .vertical ? $0.widthAnchor.constraint(equalTo: widthAnchor) : $0.heightAnchor.constraint(equalTo: heightAnchor)) ~> { $0.priority = .init(rawValue: 995) }
            ])
            
            
            
            Utils.AssociatedObject.set(base: self, key: &containerViewKey, value: $0)
        }
    }
}
