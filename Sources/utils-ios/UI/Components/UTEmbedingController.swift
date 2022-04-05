//
//  UTContainerController.swift
//  
//
//  Created by Miroslav Yozov on 5.04.22.
//

import UIKit

open class UTEmbedingController: UТViewController {
    open private(set) var rootViewController: UIViewController? = nil
    
    public let container = UIView()
    
    internal var containerFrame: CGRect {
      view.bounds
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let controller = rootViewController {
            controller.beginAppearanceTransition(true, animated: animated)
        }
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let controller = rootViewController {
            controller.endAppearanceTransition()
        }
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if let controller = rootViewController {
            controller.beginAppearanceTransition(false, animated: animated)
        }
    }
    
    open override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if let controller = rootViewController {
            controller.endAppearanceTransition()
        }
    }
    
    open override func prepare() {
        super.prepare()
        
        prepareContainer()
        if let controller = rootViewController {
            prepare(viewController: controller, in: container)
        }
    }
    
    open func embed(controller: UIViewController) {
        guard isViewLoaded else {
            rootViewController = controller
            return
        }
        
        if let controller = rootViewController {
            removeViewController(viewController: controller)
        }
        
        prepare(viewController: controller, in: container)
        rootViewController = controller
    }
}

internal extension UTEmbedingController {
    /// Prepares the container view.
    @objc dynamic func prepareContainer() {
        container.backgroundColor = .clear
        container.clipsToBounds = true
        container.contentScaleFactor = Screen.scale
        container.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        container.frame = containerFrame
        view.addSubview(container)
    }
    
    /// Prepares the view controller before transition.
    func prepare(viewController: UIViewController) {
      viewController.view.clipsToBounds = true
      viewController.view.contentScaleFactor = Screen.scale
      viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
    /**
     A method that adds the passed in controller as a child of
     the BarController within the passed in
     container view.
     - Parameter viewController: A UIViewController to add as a child.
     - Parameter in container: A UIView that is the parent of the
     passed in controller view within the view hierarchy.
     */
    func prepare(viewController: UIViewController, in container: UIView) {
      guard viewController.parent != self else {
          return
      }
      
      prepare(viewController: viewController)
      addViewController(viewController: viewController, in: container)
    }
}

internal extension UTEmbedingController {
    /**
    Add a given view controller from the childViewControllers array.
    - Parameter viewController: A UIViewController to add as a child.
    */
    func addViewController(viewController: UIViewController, in container: UIView) {
        let flag = isInHierarchy
        
        if flag {
            viewController.beginAppearanceTransition(true, animated: false)
        }

        addChild(viewController)
        viewController.view.frame = container.bounds
        container.addSubview(viewController.view)
        viewController.didMove(toParent: self)

        if flag {
            viewController.endAppearanceTransition()
        }
    }
  
    /**
    Removes a given view controller from the childViewControllers array.
    - Parameter viewController: A UIViewController to remove.
    */
    func removeViewController(viewController: UIViewController) {
        guard viewController.parent == self else {
            return
        }

        let flag = isInHierarchy

        if flag {
            viewController.beginAppearanceTransition(false, animated: false)
        }

        viewController.willMove(toParent: nil)
        viewController.view.removeFromSuperview()
        viewController.removeFromParent()

        if flag {
            viewController.endAppearanceTransition()
        }
    }
}
