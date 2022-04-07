//
//  File.swift
//  
//
//  Created by Miroslav Yozov on 7.04.22.
//

import UIKit

extension Utils.UI {
    open class Window: UIWindow {
        public convenience init() {
            self.init(frame: .zero)
        }
        
        public override init(frame: CGRect) {
            super.init(frame: frame)
            prepare()
        }
        
        @available(iOS 13.0, *)
        public override init(windowScene: UIWindowScene) {
            super.init(windowScene: windowScene)
            prepare()
        }
        
        required public init?(coder: NSCoder) {
            super.init(coder: coder)
            prepare()
        }
        
        open func prepare() {
            contentScaleFactor = Screen.scale
            backgroundColor = .white
        }
    }
}
