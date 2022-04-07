//
//  UIViewController+Ext.swift
//  
//
//  Created by Miroslav Yozov on 7.04.22.
//

import UIKit

public extension UIViewController {
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
