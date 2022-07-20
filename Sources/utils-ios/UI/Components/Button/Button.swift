//
//  Button.swift
//  
//
//  Created by Miroslav Yozov on 20.07.22.
//

import UIKit

extension Utils.UI {
    open class Button: UIButton {
        /// Image and title orientation.
        public enum Orientation {
            case regular
            case vertical(spacing: CGFloat)

            fileprivate var isVertical: Bool {
                switch self {
                case .regular:
                    return false
                case .vertical:
                    return true
                }
            }
        }
        
        /// A property that accesses the backing layer's background
        open override var backgroundColor: UIColor? {
            didSet {
                layer.backgroundColor = backgroundColor?.cgColor
            }
        }
        
        /// A preset property for updated contentEdgeInsets.
        open var contentEdgeInsetsPreset: Utils.UI.EdgeInsetsPreset = .none {
            didSet {
                contentEdgeInsets = contentEdgeInsetsPreset.value
            }
        }
        
        /// Sets the normal and highlighted image for the button.
        open var image: UIImage? {
            didSet {
                setImage(image, for: .normal)
                setImage(image, for: .selected)
                setImage(image, for: .highlighted)
                setImage(image, for: .disabled)

                if #available(iOS 9, *) {
                    setImage(image, for: .application)
                    setImage(image, for: .focused)
                    setImage(image, for: .reserved)
                }
            }
        }
        
        /// Sets the normal and highlighted title for the button.
        open var title: String? {
            didSet {
                setTitle(title, for: .normal)
                setTitle(title, for: .selected)
                setTitle(title, for: .highlighted)
                setTitle(title, for: .disabled)

                if #available(iOS 9, *) {
                    setTitle(title, for: .application)
                    setTitle(title, for: .focused)
                    setTitle(title, for: .reserved)
                }
            }
        }
        
        /// Sets the normal and highlighted titleColor for the button.
        open var titleColor: UIColor? {
            didSet {
                setTitleColor(titleColor, for: .normal)
                setTitleColor(titleColor, for: .highlighted)
                setTitleColor(titleColor, for: .disabled)

                if nil == selectedTitleColor {
                    setTitleColor(titleColor, for: .selected)
                }

                if #available(iOS 9, *) {
                    setTitleColor(titleColor, for: .application)
                    setTitleColor(titleColor, for: .focused)
                    setTitleColor(titleColor, for: .reserved)
                }
            }
        }
        
        /// Sets the selected titleColor for the button.
        open var selectedTitleColor: UIColor? {
            didSet {
                setTitleColor(selectedTitleColor, for: .selected)
            }
        }
        
        /// Sets the orientation for the button..
        open var orienation: Orientation = .regular {
            didSet {
                if orienation.isVertical {
                    titleLabel?.textAlignment = .center
                }

                if nil != superview {
                    setNeedsLayout()
                    layoutIfNeeded()
                }
            }
        }
        
        /// Pulse animation type.
        open var pulseType: Utils.UI.Pulse.`Type` = .pointWithBacking
        
        /// Pulse animation style.
        open var pulseStyle: Utils.UI.Pulse.Style = .default
        
        /// Touch pulse.
        private lazy var touchPulse: Utils.UI.Pulse = .init(pulseType)
        
        /// Pulse layers container.
        private lazy var pulseContainer: CAShapeLayer = {
            let layer: CAShapeLayer = .init()
            layer.frame = bounds
            layer.cornerRadius = layer.cornerRadius
            layer.zPosition = CGFloat(Float.greatestFiniteMagnitude)
            layer.backgroundColor = UIColor.clear.cgColor
            layer.masksToBounds = true
            return layer
        }()
        
        open override var intrinsicContentSize: CGSize {
            let size = super.intrinsicContentSize

            guard case .vertical(let spacing) = orienation else {
                return size
            }

            guard let view = imageView, let image = view.image else {
                return size
            }

            var height = image.size.height
            if let size = titleLabel?.sizeThatFits(.init(width: contentRect(forBounds: bounds).width, height: CGFloat.greatestFiniteMagnitude)) {
                height += size.height
            }

            return .init(width: size.width, height: height + spacing)
        }
        
        /**
         An initializer that initializes the object with a NSCoder object.
         - Parameter aDecoder: A NSCoder instance.
         */
        public required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
            prepare()
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
         A convenience initializer that acceps an image and tint
         - Parameter image: A UIImage.
         - Parameter tintColor: A UIColor.
         */
        public init(image: UIImage?, tintColor: UIColor? = nil) {
            super.init(frame: .zero)
            prepare()
            prepare(with: image, tintColor: tintColor)
        }
        
        /**
         A convenience initializer that acceps a title and title
         - Parameter title: A String.
         - Parameter titleColor: A UIColor.
         */
        public init(title: String?, titleColor: UIColor? = nil) {
            super.init(frame: .zero)
            prepare()
            prepare(with: title, titleColor: titleColor)
        }
        
        open override func layoutSublayers(of layer: CALayer) {
            super.layoutSublayers(of: layer)
            
            guard layer == self.layer else {
                return
            }
            
            pulseContainer.frame = layer.bounds
            pulseContainer.cornerRadius = layer.cornerRadius
        }
        
        open override func titleRect(forContentRect contentRect: CGRect) -> CGRect {
            let titleRect = super.titleRect(forContentRect: contentRect)

            guard case .vertical(let spacing) = orienation else {
                return titleRect
            }

            let imageRect = super.imageRect(forContentRect: contentRect)
            return .init(x: 0,
                         y: contentRect.height - (contentRect.height - spacing - imageRect.size.height - titleRect.size.height) / 2 - titleRect.size.height,
                         width: contentRect.width,
                         height: titleRect.height)
        }
        
        open override func imageRect(forContentRect contentRect: CGRect) -> CGRect {
            let imageRect = super.imageRect(forContentRect: contentRect)
            guard case .vertical(let spacing) = orienation else {
                return imageRect
            }

            let titleRect = self.titleRect(forContentRect: contentRect)
            return .init(x: contentRect.width/2.0 - imageRect.width/2.0,
                         y: (contentRect.height - spacing - imageRect.size.height - titleRect.size.height) / 2,
                         width: imageRect.width,
                         height: imageRect.height)
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
            layer.addSublayer(pulseContainer)
        }
    }
}


extension Utils.UI.Button {
    /**
    Prepares the Button with an image and tint
    - Parameter image: A UIImage.
    - Parameter tintColor: A UI
    */
    fileprivate func prepare(with img: UIImage?, tintColor color: UIColor?) {
        image = img
        tintColor = color ?? tintColor
    }
    
    /**
     Prepares the Button with a title and title
     - Parameter title: A String.
     - Parameter titleColor: A UI
     */
    fileprivate func prepare(with text: String?, titleColor color: UIColor?) {
        title = text
        titleColor = color ?? titleColor
    }
}

// MARK: - Trigger pulse on touch events.
extension Utils.UI.Button {
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
