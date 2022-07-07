//
//  NoScrollTableView.swift
//  
//
//  Created by Miroslav Yozov on 6.07.22.
//

import UIKit

extension Utils.UI {
    open class NoScrollTableView: Utils.UI.TableView {
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
}


