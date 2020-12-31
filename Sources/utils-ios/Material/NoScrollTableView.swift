//
//  NoScrollTableView.swift
//  
//
//  Created by Miroslav Yozov on 31.12.20.
//

import UIKit
import Material

fileprivate extension UIEdgeInsets {
    var vertical: CGFloat {
        return top + bottom
    }
    
    var horizontal: CGFloat {
        return left + right
    }
}

open class NoScrollTableView: TableView {
    private lazy var heightConstraint: NSLayoutConstraint = {
        let c: NSLayoutConstraint = heightAnchor.constraint(equalToConstant: contentSize.height + contentInset.vertical)
        c.priority = .init(995)
        c.isActive = true
        return c
    }()
    
    open override var contentInset: UIEdgeInsets {
        didSet {
            if contentInset.vertical != oldValue.vertical {
                heightConstraint.constant = contentSize.height + contentInset.vertical
            }
        }
    }
    
    open override var contentSize: CGSize {
        didSet  {
            if contentSize.height != oldValue.height {
                heightConstraint.constant = contentSize.height + contentInset.vertical
            }
        }
    }
    
    open override func prepare() {
        super.prepare()
        bounces = false
        
        let _ = heightConstraint
    }
}

