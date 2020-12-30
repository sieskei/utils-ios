//
//  UIScrollView+Layout.swift
//  
//
//  Created by Miroslav Yozov on 29.12.20.
//

import UIKit

public extension UIScrollView {
    typealias Element = (view: UIView, insets: UIEdgeInsets)
    
    convenience init(views: [UIView], insets: UIEdgeInsets = .zero, spacing: CGFloat = .zero) {
        self.init(elements: views.map { ($0, insets) }, spacing: spacing)
    }
    
    convenience init(elements: [Element], spacing: CGFloat = .zero) {
        self.init(frame: .zero)
        
        alwaysBounceVertical = true
        
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

        /*
        let a = container.heightAnchor.constraint(equalTo: heightAnchor)
        a.priority = .defaultHigh
        a.isActive = true
        */
        
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
            let v = elements[0].view
            let i = elements[0].insets
            NSLayoutConstraint.activate([
                v.topAnchor.constraint(equalTo: container.topAnchor, constant: i.top),
                v.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -i.bottom)
            ])
        default:
            let f = elements[0] // first
            NSLayoutConstraint.activate([
                f.view.topAnchor.constraint(equalTo: container.topAnchor, constant: f.insets.top)
            ])
            
            // middle
            if elements.count > 2 {
                for i in 1...elements.count - 2 {
                    NSLayoutConstraint.activate([
                        elements[i].view.topAnchor.constraint(equalTo: elements[i - 1].view.bottomAnchor, constant: spacing)
                    ])
                }
            }
            
            // last
            let l = elements[elements.count - 1] // last
            NSLayoutConstraint.activate([
                l.view.topAnchor.constraint(equalTo: elements[elements.count - 2].view.bottomAnchor, constant: spacing),
                l.view.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -l.insets.bottom)
            ])
        }
        
    }
}
