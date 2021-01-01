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
