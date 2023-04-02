//
//  Scroller.swift
//  
//
//  Created by Miroslav Yozov on 2.04.23.
//

import UIKit

extension Utils.UI {
    open class Scroller: UIScrollView {
        public override init(frame: CGRect) {
            super.init(frame: frame)
            prepare()
        }
        
        public required init?(coder: NSCoder) {
            super.init(coder: coder)
            prepare()
        }
        
        open func prepare() {
            contentScaleFactor = Screen.scale
            backgroundColor = .white
        }
    }
}
