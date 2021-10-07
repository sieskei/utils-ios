//
//  UIView+.swift
//  
//
//  Created by Miroslav Yozov on 26.11.19.
//

import UIKit

public extension UIView {
    class var className: String {
        return String(describing: self)
    }
    
    class var nib: UINib? {
        return UINib(nibName: className, bundle: Bundle.main)
    }
    
    class func fromNib(nibNameOrNil: String? = nil) -> Self {
        return fromNib(nibNameOrNil: nibNameOrNil, type: self)
    }
    
    class func fromNib<T : UIView>(nibNameOrNil: String? = nil, type: T.Type) -> T {
        let v: T? = fromNib(nibNameOrNil:nibNameOrNil, type: T.self)
        return v!
    }
    
    class func fromNib<T : UIView>(nibNameOrNil: String? = nil, type: T.Type) -> T? {
        var view: T?
        let name: String
        if let nibName = nibNameOrNil {
            name = nibName
        } else {
            // Most nibs are demangled by practice, if not, just declare string explicitly
            name = className
        }
        let nibViews = Bundle.main.loadNibNamed(name, owner: nil, options: nil)
        for v in nibViews! {
            if let tog = v as? T {
                view = tog
            }
        }
        return view
    }
    
    func asyncLayout() {
        setNeedsLayout()
        DispatchQueue.main.async { [weak self] in
            self?.layoutIfNeeded()
        }
    }
    
    @discardableResult
    func forceUpdateConstraints(ifThereAreDifferences diff: Bool) -> Bool {
        guard diff else { return false }
        
        setNeedsUpdateConstraints()
        updateConstraintsIfNeeded()
        
        return true
    }
    
    @discardableResult
    func forceLayout(ifThereAreDifferences diff: Bool) -> Bool {
        guard diff else { return false }
        
        setNeedsLayout()
        layoutIfNeeded()
        
        return true
    }
    
    func roundCornersWithLayerMask(cornerRadii: CGFloat, corners: UIRectCorner) {
        let path = UIBezierPath(roundedRect: bounds,
                                byRoundingCorners: corners,
                                cornerRadii: CGSize(width: cornerRadii, height: cornerRadii))
        let maskLayer = CAShapeLayer()
        maskLayer.path = path.cgPath
        layer.mask = maskLayer
    }
    
    func randomBackground() {
        backgroundColor = .random
        subviews.forEach {
            $0.randomBackground()
        }
    }
}

public extension UIView {
    func `is`(childOf view: UIView) -> Bool {
        var v: UIView? = superview
        while nil != v {
            if v === view {
                return true
            }
            v = v?.superview
        }
        return false
    }
    
    func traverseViewHierarchyForClassType<T: UIView>() -> T? {
        var v: UIView? = self
        while nil != v {
            if v is T {
                return v as? T
            }
            v = v?.superview
        }
        return nil
    }
}
