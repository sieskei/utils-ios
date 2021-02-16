//
//  UIScrollView+Layout.swift
//  
//
//  Created by Miroslav Yozov on 29.12.20.
//

import UIKit

public extension UIScrollView {
    typealias Element = (view: UIView, insets: UIEdgeInsets)
    
    convenience init(views: [UIView], insets: UIEdgeInsets = .zero) {
        self.init(elements: views.map { ($0, insets) })
    }
    
    convenience init(elements: [Element]) {
        self.init(frame: .zero)
        alwaysBounceVertical = true
        set(elements: elements)
    }
    
    func set(views: [UIView], insets: UIEdgeInsets = .zero) {
        set(elements: views.map { ($0, insets) })
    }
    
    func set(elements: [Element]) {
        subviews.forEach {
            $0.removeFromSuperview()
        }
        
        guard !elements.isEmpty else {
            return
        }
        
        let container: UIView = .init()
        container.backgroundColor = .clear
        container.translatesAutoresizingMaskIntoConstraints = false
        addSubview(container)

        NSLayoutConstraint.activate([
            container.leftAnchor.constraint(equalTo: leftAnchor),
            container.rightAnchor.constraint(equalTo: rightAnchor),
            container.topAnchor.constraint(equalTo: topAnchor),
            container.widthAnchor.constraint(equalTo: widthAnchor),
            container.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
        
        elements.forEach {
            $0.view.translatesAutoresizingMaskIntoConstraints = false
            container.addSubview($0.view)
            
            NSLayoutConstraint.activate([
                $0.view.leftAnchor.constraint(equalTo: container.leftAnchor, constant: $0.insets.left),
                $0.view.rightAnchor.constraint(equalTo: container.rightAnchor, constant: -$0.insets.right)
            ])
        }
        
        switch elements.count {
        case 1:
            let e = elements[0]
            NSLayoutConstraint.activate([
                e.view.topAnchor.constraint(equalTo: container.topAnchor, constant: e.insets.top),
                e.view.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -e.insets.bottom)
            ])
        default:
            let f = elements[0] // first
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
            
            // last
            let l = elements[elements.count - 1]
            let ls = l.insets.top + elements[elements.count - 2].insets.bottom // spacing
            NSLayoutConstraint.activate([
                l.view.topAnchor.constraint(equalTo: elements[elements.count - 2].view.bottomAnchor, constant: ls),
                l.view.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -l.insets.bottom)
            ])
        }
    }
}
