//
//  UIViewController+Ext.swift
//  
//
//  Created by Miroslav Yozov on 7.04.22.
//

import UIKit

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
