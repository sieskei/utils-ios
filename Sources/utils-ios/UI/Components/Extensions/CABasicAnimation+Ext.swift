//
//  File.swift
//  
//
//  Created by Miroslav Yozov on 29.06.22.
//

import UIKit

extension CABasicAnimation {
    public enum KeyPath: String {
        case backgroundColor
        case borderColor
        case borderWidth
        case cornerRadius
        case transform
        
        case position
        case opacity
        case zPosition
        
        case bounds
        
        case shadowPath
        case shadowColor
        case shadowOffset
        case shadowOpacity
        case shadowRadius
    }
    
    public convenience init(keyPath: String, duration: CFTimeInterval, toValue: Any) {
        self.init(keyPath: keyPath)
        self.duration = duration
        self.toValue = toValue
    }
}

extension CABasicAnimation {
    public static func background(color: UIColor, withDuration duration: CFTimeInterval = .zero) -> CABasicAnimation {
        .init(keyPath: KeyPath.backgroundColor.rawValue, duration: duration, toValue: color.cgColor)
    }
    
    public static func border(color: UIColor, withDuration duration: CFTimeInterval = .zero) -> CABasicAnimation {
        .init(keyPath: KeyPath.borderColor.rawValue, duration: duration, toValue: color.cgColor)
    }
    
    public static func border(width: CGFloat, withDuration duration: CFTimeInterval = .zero) -> CABasicAnimation {
        .init(keyPath: KeyPath.borderWidth.rawValue, duration: duration, toValue: NSNumber(floatLiteral: width))
    }
    
    public static func corner(radius: CGFloat, withDuration duration: CFTimeInterval = .zero) -> CABasicAnimation {
        .init(keyPath: KeyPath.cornerRadius.rawValue, duration: duration, toValue: NSNumber(floatLiteral: radius))
    }
    
    public static func transform(_ transform: CATransform3D, withDuration duration: CFTimeInterval = .zero) -> CABasicAnimation {
        .init(keyPath: KeyPath.transform.rawValue, duration: duration, toValue: NSValue(caTransform3D: transform))
    }
    
    public static func scale(_ xyz: CGFloat, origin: CATransform3D = CATransform3DIdentity, withDuration duration: CFTimeInterval = .zero) -> CABasicAnimation {
        transform(CATransform3DScale(origin, xyz, xyz, xyz), withDuration: duration) // ??? may not work as exprected
    }
    
    public static func rotate(x: CGFloat, y: CGFloat, z: CGFloat, origin: CATransform3D = CATransform3DIdentity, withDuration duration: CFTimeInterval = .zero) -> CABasicAnimation {
        var t = CATransform3DRotate(origin, x, 1, 0, 0) // ??? may not work as exprected
        t = CATransform3DRotate(t, y, 0, 1, 0)
        t = CATransform3DRotate(t, z, 0, 0, 1)
        return transform(t, withDuration: duration)
    }
    
    public static func position(_ point: CGPoint, withDuration duration: CFTimeInterval = .zero) -> CABasicAnimation { // ok
        .init(keyPath: KeyPath.position.rawValue, duration: duration, toValue: NSValue(cgPoint: point))
    }
    
    public static func opacity(_ opacity: CGFloat, withDuration duration: CFTimeInterval = .zero) -> CABasicAnimation {
        .init(keyPath: KeyPath.opacity.rawValue, duration: duration, toValue: NSNumber(floatLiteral: opacity))
    }
    
    public static func zPosition(_ position: CGFloat, withDuration duration: CFTimeInterval = .zero) -> CABasicAnimation {
        .init(keyPath: KeyPath.zPosition.rawValue, duration: duration, toValue: NSNumber(floatLiteral: position))
    }
    
    public static func bounds(_ bounds: CGRect, withDuration duration: CFTimeInterval = .zero) -> CABasicAnimation {
        .init(keyPath: KeyPath.bounds.rawValue, duration: duration, toValue: NSValue(cgRect: bounds))
    }
    
    public static func shadow(path: CGPath, withDuration duration: CFTimeInterval = .zero) -> CABasicAnimation {
        .init(keyPath: KeyPath.shadowPath.rawValue, duration: duration, toValue: path)
    }
    
    public static func shadow(color: UIColor, withDuration duration: CFTimeInterval = .zero) -> CABasicAnimation {
        .init(keyPath: KeyPath.shadowColor.rawValue, duration: duration, toValue: color.cgColor)
    }
    
    public static func shadow(offset: CGSize, withDuration duration: CFTimeInterval = .zero) -> CABasicAnimation {
        .init(keyPath: KeyPath.shadowOffset.rawValue, duration: duration, toValue: NSValue(cgSize: offset))
    }
    
    public static func shadow(opacity: CGFloat, withDuration duration: CFTimeInterval = .zero) -> CABasicAnimation {
        .init(keyPath: KeyPath.shadowOpacity.rawValue, duration: duration, toValue: NSNumber(floatLiteral: opacity))
    }
    
    public static func shadow(radius: CGFloat, withDuration duration: CFTimeInterval = .zero) -> CABasicAnimation {
        .init(keyPath: KeyPath.shadowRadius.rawValue, duration: duration, toValue: NSNumber(floatLiteral: radius))
    }
}

extension CAAnimationGroup {
    public static func by(animations: [CABasicAnimation], withMaxDuration duration: CFTimeInterval, timingFunction: CAMediaTimingFunction = .easeInOut) -> Self {
        .init() ~> {
            animations.forEach {
                $0.duration = $0.duration == .zero ? duration : min($0.duration, duration)
            }
            
            $0.timingFunction = timingFunction
            $0.animations = animations
            $0.duration = duration
        }
    }
}


extension CALayer {
    private func apply(animation: CABasicAnimation) {
        if let keyPath = animation.keyPath {
            animation.fromValue = value(forKey: keyPath)
            setValue(animation.toValue, forKey: keyPath)
        }
    }
    
    public func animate(withMaxDuration duration: CFTimeInterval, animations: CABasicAnimation..., timingFunction: CAMediaTimingFunction = .easeInOut, completion: (() -> Void)? = nil) {
        guard !animations.isEmpty else {
            completion?()
            return
        }
        
        let group: CAAnimationGroup = .by(animations: animations, withMaxDuration: duration, timingFunction: timingFunction)
        animations.forEach {
            apply(animation: $0)
        }
        add(group, forKey: nil)
        
        if let c = completion {
            Utils.UI.async(delay: duration, execution: c)
        }
    }
}
