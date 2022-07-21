//
//  EmbedController.swift
//  
//
//  Created by Miroslav Yozov on 5.04.22.
//

import UIKit
extension Utils.UI {
    open class EmbedController: Utils.UI.ViewController {
        open override var childForStatusBarStyle: UIViewController? {
            return rootViewController
        }
        
        open override var childForStatusBarHidden: UIViewController? {
            return rootViewController
        }
        
        open override var childForHomeIndicatorAutoHidden: UIViewController? {
            return rootViewController
        }
        
        open override var childForScreenEdgesDeferringSystemGestures: UIViewController? {
            return rootViewController
        }
        
        public override var isUserInteractionEnabled: Bool {
            get { (rootViewController ?? self).isUserInteractionEnabled }
            set { (rootViewController ?? self).view.isUserInteractionEnabled = newValue  }
        }
        
        open private(set) var rootViewController: UIViewController? = nil
        
        public let container = UIView()
        
        internal var containerFrame: CGRect {
            view.bounds
        }
        
        public init(rootViewController controller: UIViewController? = nil) {
            super.init(nibName: nil, bundle: nil)
            rootViewController = controller
        }
        
        required public init?(coder: NSCoder) {
            super.init(coder: coder)
        }
        
        public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
            super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        }
        
        open override func prepare() {
            super.prepare()
            
            prepareContainer()
            if let controller = rootViewController {
                prepare(viewController: controller, in: container)
            }
        }
        
        open func embed(controller: UIViewController, animated: Bool = true) {
            guard isViewLoaded else {
                rootViewController = controller
                return
            }
            
            if let c = rootViewController, c.presentedViewController != nil {
                c.dismiss(animated: animated) { [weak self] in
                    if let this = self {
                        this.embed(controller: controller)
                    }
                }
                return
            }
            
            if let controller = rootViewController {
                removeViewController(viewController: controller)
            }
            
            prepare(viewController: controller, in: container)
            rootViewController = controller
        }
    }
}


internal extension Utils.UI.EmbedController {
    /// Prepares the container view.
    @objc dynamic func prepareContainer() {
        container.backgroundColor = .clear
        container.clipsToBounds = true
        container.contentScaleFactor = Utils.UI.Screen.scale
        container.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        container.frame = containerFrame
        view.addSubview(container)
    }
    
    /// Prepares the view controller before transition.
    func prepare(viewController: UIViewController) {
        viewController.view.clipsToBounds = true
        viewController.view.contentScaleFactor = Utils.UI.Screen.scale
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

internal extension Utils.UI.EmbedController {
    /**
    Add a given view controller from the childViewControllers array.
    - Parameter viewController: A UIViewController to add as a child.
    */
    func addViewController(viewController: UIViewController, in container: UIView) {
        viewController.willMove(toParent: self)
        addChild(viewController)
        viewController.view.frame = container.bounds
        container.addSubview(viewController.view)
        viewController.didMove(toParent: self)
    }
  
    /**
    Removes a given view controller from the childViewControllers array.
    - Parameter viewController: A UIViewController to remove.
    */
    func removeViewController(viewController: UIViewController) {
        guard viewController.parent == self else {
            return
        }
        viewController.willMove(toParent: nil)
        viewController.view.removeFromSuperview()
        viewController.removeFromParent()
        viewController.didMove(toParent: nil)
    }
}
