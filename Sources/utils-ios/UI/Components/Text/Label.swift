//
//  File.swift
//  
//
//  Created by Miroslav Yozov on 17.05.22.
//

import UIKit

extension Utils.UI {
    open class Label: UILabel {
        open var insets: UIEdgeInsets = .zero {
            didSet {
                invalidateIntrinsicContentSize()
            }
        }
        
        override open func drawText(in rect: CGRect) {
            super.drawText(in: rect.inset(by: insets))
        }

        override open var intrinsicContentSize: CGSize {
            get {
                var cs = super.intrinsicContentSize
                cs.height += insets.top + insets.bottom
                cs.width += insets.left + insets.right
                return cs
           }
        }
        
        public convenience init() {
            self.init(frame: .zero)
        }
        
        public override init(frame: CGRect) {
            super.init(frame: frame)
            prepare()
        }
        
        required public init?(coder: NSCoder) {
            super.init(coder: coder)
            prepare()
        }
        
        open func prepare() { }
    }
}
