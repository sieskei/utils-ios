//
//  File.swift
//  
//
//  Created by Miroslav Yozov on 7.04.22.
//

import UIKit

extension Utils.UI {
    open class View: UIView {
        open override var intrinsicContentSize: CGSize {
            return bounds.size
        }
        
        /**
         An initializer that initializes the object with a CGRect object.
         If AutoLayout is used, it is better to initilize the instance
         using the init() initializer.
         - Parameter frame: A CGRect instance.
        */
        public override init(frame: CGRect) {
            super.init(frame: frame)
            prepare()
        }
        
        /**
         An initializer that initializes the object with a NSCoder object.
         - Parameter aDecoder: A NSCoder instance.
         */
        public required init?(coder: NSCoder) {
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
            backgroundColor = .white
        }
        
        open override func layoutSublayers(of layer: CALayer) {
            super.layoutSublayers(of: layer)
            
            guard layer == self.layer else {
                return
            }
            
            layer.layoutDepthPath()
        }
    }
}
