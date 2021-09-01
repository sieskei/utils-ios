//
//  UINavigationController+.swift
//  
//
//  Created by Miroslav Yozov on 1.01.21.
//

import UIKit

public extension UINavigationController {
    func traverseChildHierarchyForClassType<T: UIViewController>() -> T? {
        viewControllers.first(where: { $0 is T }) as? T
    }
}

public extension UINavigationController {
    /// Behaviors for the pop view controller functionality.
    enum PopBehavior {
        /// Include the view controller matching the predicate.
        case inclusive
        /// Exclude the view controller matching the predicate.
        case exclusive
    }
    
    @discardableResult
    func popToViewController(_ viewController: UIViewController, behavior: PopBehavior, animated flag: Bool) -> [UIViewController]? {
        let controllers = viewControllers
        switch behavior {
        case .inclusive:
            return popToViewController(viewController, animated: true)
        case .exclusive:
            guard let i = controllers.firstIndex(of: viewController) else {
                return nil
            }
            switch i {
            case 0:
                setViewControllers([], animated: flag)
                return controllers
            case 1:
                return popToRootViewController(animated: flag)
            default:
                return popToViewController(viewControllers[i - 1], animated: flag)
            }
        }
    }
}
