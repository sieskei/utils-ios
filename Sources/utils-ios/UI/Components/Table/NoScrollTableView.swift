//
//  NoScrollTableView.swift
//  
//
//  Created by Miroslav Yozov on 6.07.22.
//

import UIKit

extension Utils.UI {
    open class NoScrollTableView: Utils.UI.TableView {
        open var heightConstraintPriority: UILayoutPriority {
            .init(rawValue: 995)
        }
        
        open var isScrollable: Bool {
            false
        }
        
        private lazy var heightConstraint: NSLayoutConstraint = {
            let c: NSLayoutConstraint = heightAnchor.constraint(equalToConstant: contentSize.height + contentInset.vertical)
            c.priority = heightConstraintPriority
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
            bounces = isScrollable
            isScrollEnabled = isScrollable
            let _ = heightConstraint
        }
    }
}


