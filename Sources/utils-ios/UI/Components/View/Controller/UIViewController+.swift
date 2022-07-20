//
//  UIViewController+.swift
//  
//
//  Created by Miroslav Yozov on 31.10.20.
//

import UIKit

public extension UIViewController {
    var safeTopAnchor: NSLayoutYAxisAnchor {
        if #available(iOS 11.0, *) {
            return view.safeAreaLayoutGuide.topAnchor
        } else {
            return topLayoutGuide.bottomAnchor
        }
    }
    
    var safeBottomAnchor: NSLayoutYAxisAnchor {
        if #available(iOS 11.0, *) {
            return view.safeAreaLayoutGuide.bottomAnchor
        } else {
            return bottomLayoutGuide.topAnchor
        }
    }
}

public extension UIViewController {
    /**
     Finds a view controller with a given type based on
     the view controller subclass.
     - Returns: An optional of type T.
    */
    func traverseViewControllerHierarchyForClassType<T: UIViewController>() -> T? {
        var v: UIViewController? = self
        while nil != v {
            if v is T {
                return v as? T
            }
            v = v?.parent
        }
        return nil
    }
    
    var isInHierarchy: Bool {
        if let view = viewIfLoaded, view.window != nil {
            return true
        } else {
            return false
        }
    }

    func relayout() {
        guard isViewLoaded else {
            return
        }

        view.setNeedsLayout()
        view.layoutIfNeeded()
    }
    
    var isUserInteractionEnabled: Bool {
        get {
            view.isUserInteractionEnabled
        }
        set(value) {
            view.isUserInteractionEnabled = value
        }
    }
}
