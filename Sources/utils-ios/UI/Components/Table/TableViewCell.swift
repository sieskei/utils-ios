//
//  UITableViewCell.swift
//  
//
//  Created by Miroslav Yozov on 5.07.22.
//

import UIKit

extension Utils.UI {
    open class TableViewCell: UITableViewCell {
        private lazy var touchPulse: Utils.UI.Pulse = .init()
        
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
        
        /**
         An initializer that initializes the object.
         - Parameter style: A UITableViewCellStyle enum.
         - Parameter reuseIdentifier: A String identifier.
         */
        public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String!) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
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
            selectionStyle = .none
            separatorInset = .zero
            
            contentView.layer
                .addSublayer(pulseContainer)
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


// MARK: Trigger pulse on touch events.
extension Utils.UI.TableViewCell {
    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        if let touch = touches.first {
            touchPulse.expand(point: touch.location(in: self), in: pulseContainer)
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
