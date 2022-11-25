//
//  UIViewController+Child.swift
//  
//
//  Created by Miroslav Yozov on 10.11.22.
//

import UIKit

public extension UIViewController {
    /**
    Add a given view controller to the childViewControllers array.
    - Parameter viewController: A UIViewController to add as a child.
    - Parameter guide: A UILayoutGuide in which to be layouted.
    */
    @objc
    dynamic func add(viewController: UIViewController, in guide: UILayoutGuide) {
        if let parent = viewController.parent {
            parent.remove(viewController: viewController)
        }
        
        viewController.willMove(toParent: self)
        addChild(viewController)
        
        view.layout(viewController.view)
            .edges(guide)
        
        viewController.didMove(toParent: self)
    }
  
    /**
    Removes a given view controller from the childViewControllers array.
    - Parameter viewController: A UIViewController to remove.
    */
    @objc
    dynamic func remove(viewController: UIViewController) {
        guard viewController.parent == self else {
            return
        }
        viewController.willMove(toParent: nil)
        viewController.view.removeFromSuperview()
        viewController.removeFromParent()
        viewController.didMove(toParent: nil)
    }
}
