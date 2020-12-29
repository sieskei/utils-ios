//
//  UIScrollView+Layout.swift
//  
//
//  Created by Miroslav Yozov on 29.12.20.
//

import UIKit

public extension UIScrollView {
    convenience init(views: [UIView], insets: UIEdgeInsets = .zero, spacing: CGFloat = .zero) {
        self.init(frame: .zero)
        
        guard !views.isEmpty else {
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
            container.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor),
        ])
        
        let a = container.heightAnchor.constraint(equalTo: heightAnchor)
        a.priority = .defaultHigh
        a.isActive = true
        
        views.forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            container.addSubview($0)
            
            NSLayoutConstraint.activate([
                $0.leftAnchor.constraint(equalTo: container.leftAnchor, constant: insets.left),
                $0.rightAnchor.constraint(equalTo: container.rightAnchor, constant: -insets.right)
            ])
        }
        
        switch views.count {
        case 1:
            let v = views[0]
            NSLayoutConstraint.activate([
                v.topAnchor.constraint(equalTo: container.topAnchor),
                v.bottomAnchor.constraint(equalTo: container.bottomAnchor)
            ])
        default:
            let f = views[0] // first
            NSLayoutConstraint.activate([
                f.topAnchor.constraint(equalTo: container.topAnchor, constant: insets.top)
            ])
            
            // middle
            if views.count > 2 {
                for i in 1...views.count - 2 {
                    NSLayoutConstraint.activate([
                        views[i].topAnchor.constraint(equalTo: views[i - 1].bottomAnchor, constant: spacing)
                    ])
                }
            }
            
            // last
            let l = views[views.count - 1] // last
            NSLayoutConstraint.activate([
                l.topAnchor.constraint(equalTo: views[views.count - 2].bottomAnchor, constant: spacing),
                l.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -insets.bottom)
            ])
        }
        
    }
}
