//
//  CollectionViewCell.swift
//  
//
//  Created by Miroslav Yozov on 25.07.22.
//

import UIKit

extension Utils.UI {
    open class CollectionViewCell: UICollectionViewCell {
        /// Pulse animation type.
        open var pulseType: Utils.UI.Pulse.`Type` = .pointWithBacking
        
        /// Pulse animation style.
        open var pulseStyle: Utils.UI.Pulse.Style = .default
        
        /// Touch pulse.
        private lazy var touchPulse: Utils.UI.Pulse = .init(pulseType)
        
        private lazy var pulseContainer: CAShapeLayer = {
            let layer: CAShapeLayer = .init()
            layer.frame = contentView.bounds
            layer.cornerRadius = contentView.layer.cornerRadius
            layer.zPosition = CGFloat(Float.greatestFiniteMagnitude)
            layer.backgroundColor = UIColor.clear.cgColor
            layer.masksToBounds = true
            return layer
        }()
        
        /**
         An initializer that initializes the object with a NSCoder object.
         - Parameter aDecoder: A NSCoder instance.
         */
        public required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
            prepare()
        }
        
        public override init(frame: CGRect) {
            super.init(frame: frame)
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
            contentView.layer.addSublayer(pulseContainer)
        }
        
        open override func layoutSublayers(of layer: CALayer) {
            super.layoutSublayers(of: layer)
            
            guard layer == self.layer else {
                return
            }
            
            pulseContainer.frame = contentView.layer.bounds
            pulseContainer.cornerRadius = contentView.layer.cornerRadius
        }
        
        open override func prepareForReuse() {
            super.prepareForReuse()
            touchPulse.reset(in: pulseContainer)
        }
    }
}


// MARK: - Trigger pulse on touch events.
extension Utils.UI.CollectionViewCell {
    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        if let touch = touches.first {
            touchPulse.expand(point: touch.location(in: self), in: pulseContainer, withStyle: pulseStyle)
        }
    }
    
    open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        touchPulse.collapse()
    }
    
    open override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        touchPulse.collapse()
    }
}
