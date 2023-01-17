//
//  File.swift
//  
//
//  Created by Miroslav Yozov on 19.07.22.
//

import UIKit

extension Utils.UI {
    /// VisualEffectView is a dynamic background blur view.
    open class VisualEffectView: UIVisualEffectView {
        /**
         А flag indicating whether the view is passthrough.
         */
        open var passthrough: Bool = false
        
        /// Returns the instance of UIBlurEffect.
        private lazy var blurEffect: UIBlurEffect = {
            (NSClassFromString("_UICustomBlurEffect") as! UIBlurEffect.Type).init()
        }()
        
        /**
         Tint color.
         
         The default value is nil.
         */
        open var colorTint: UIColor? {
            get {
                if #available(iOS 14, *) {
                    return ios14_colorTint
                } else {
                    return _value(forKey: .colorTint)
                }
            }
            set {
                if #available(iOS 14, *) {
                    ios14_colorTint = newValue
                } else {
                    _setValue(newValue, forKey: .colorTint)
                }
            }
        }
        
        /**
         Tint color alpha.
         Don't use it unless `colorTint` is not nil.
         The default value is 0.0.
         */
        open var colorTintAlpha: CGFloat {
            get { return _value(forKey: .colorTintAlpha) ?? 0.0 }
            set {
                if #available(iOS 14, *) {
                    ios14_colorTint = ios14_colorTint?.withAlphaComponent(newValue)
                } else {
                    _setValue(newValue, forKey: .colorTintAlpha)
                }
            }
        }
        
        /**
         Blur radius.
         The default value is 0.0.
         */
        open var blurRadius: CGFloat {
            get {
                if #available(iOS 14, *) {
                    return ios14_blurRadius
                } else {
                    return _value(forKey: .blurRadius) ?? 0.0
                }
            }
            set {
                if #available(iOS 14, *) {
                    ios14_blurRadius = newValue
                } else {
                    _setValue(newValue, forKey: .blurRadius)
                }
            }
        }
        
        /**
         Scale factor.
         The scale factor determines how content in the view is mapped from the logical coordinate space (measured in points) to the device coordinate space (measured in pixels).
         The default value is 1.0.
         */
        open var scale: CGFloat {
            get { _value(forKey: .scale) ?? 1.0 }
            set { _setValue(newValue, forKey: .scale) }
        }
        
        // MARK: - Initialization
        
        public override init(effect: UIVisualEffect?) {
            super.init(effect: effect)
            prepare()
        }
        
        required public init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
            prepare()
        }
        
        open func prepare() {
            scale = 1
        }
        
        override public func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
            let view = super.hitTest(point, with: event)
            guard passthrough else {
                return view
            }
            return view == self ? nil : view
        }
    }
}

// MARK: - Helpers
private extension Utils.UI.VisualEffectView {
    /// Returns the value for the key on the blurEffect.
    func _value<T>(forKey key: Key) -> T? {
        return blurEffect.value(forKeyPath: key.rawValue) as? T
    }
    
    /// Sets the value for the key on the blurEffect.
    func _setValue<T>(_ value: T?, forKey key: Key) {
        blurEffect.setValue(value, forKeyPath: key.rawValue)
        if #available(iOS 14, *) {} else {
            self.effect = blurEffect
        }
    }
    
    enum Key: String {
        case colorTint, colorTintAlpha, blurRadius, scale
    }
}

@available(iOS 14, *)
extension Utils.UI.VisualEffectView {
    var ios14_blurRadius: CGFloat {
        get {
            gaussianBlur?.requestedValues?["inputRadius"] as? CGFloat ?? 0
        }
        set {
            prepareForChanges(); defer { applyChanges() }
            gaussianBlur?.requestedValues?["inputRadius"] = newValue
        }
    }
    var ios14_colorTint: UIColor? {
        get {
            sourceOver?.value(forKeyPath: "color") as? UIColor
        }
        set {
            prepareForChanges(); defer { applyChanges() }
            overlayView?.backgroundColor = newValue
            sourceOver?.setValue(newValue, forKeyPath: "color")
            sourceOver?.perform(Selector(("applyRequestedEffectToView:")), with: overlayView)
        }
    }
}

private extension Utils.UI.VisualEffectView {
    var backdropView: UIView? {
        subview(of: NSClassFromString("_UIVisualEffectBackdropView"))
    }
    
    var overlayView: UIView? {
        subview(of: NSClassFromString("_UIVisualEffectSubview"))
    }
    
    var gaussianBlur: NSObject? {
        backdropView?.value(forKey: "filters", withFilterType: "gaussianBlur")
    }
    
    var sourceOver: NSObject? {
        overlayView?.value(forKey: "viewEffects", withFilterType: "sourceOver")
    }
    
    func prepareForChanges() {
        self.effect = UIBlurEffect(style: .light)
        gaussianBlur?.setValue(1.0, forKeyPath: "requestedScaleHint")
    }
    
    func applyChanges() {
        backdropView?.perform(Selector(("applyRequestedFilterEffects")))
    }
}

private extension NSObject {
    var requestedValues: [String: Any]? {
        get { return value(forKeyPath: "requestedValues") as? [String: Any] }
        set { setValue(newValue, forKeyPath: "requestedValues") }
    }
    
    func value(forKey key: String, withFilterType filterType: String) -> NSObject? {
        (value(forKeyPath: key) as? [NSObject])?.first { $0.value(forKeyPath: "filterType") as? String == filterType }
    }
}

private extension UIView {
    func subview(of classType: AnyClass?) -> UIView? {
        subviews.first { type(of: $0) == classType }
    }
}
