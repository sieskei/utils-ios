//
//  File.swift
//  
//
//  Created by Miroslav Yozov on 26.11.22.
//

import UIKit

extension Utils.UI {
    open class TableHeaderFooterView: UITableViewHeaderFooterView {
        open override var backgroundColor: UIColor? {
            didSet {
                contentView.backgroundColor = backgroundColor
            }
        }
        
        public override init(reuseIdentifier: String?) {
            super.init(reuseIdentifier: reuseIdentifier)
            prepare()
        }
        
        required public init?(coder: NSCoder) {
            super.init(coder: coder)
            prepare()
        }
        
        /**
         Prepares the view instance when intialized. When subclassing,
         it is recommended to override the prepare method
         to initialize property values and other setup operations.
         The super.prepare method should always be called immediately
         when subclassing.
         */
        open func prepare() {
            contentScaleFactor = Screen.scale
        }
    }
}
