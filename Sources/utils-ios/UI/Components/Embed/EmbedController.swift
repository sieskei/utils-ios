//
//  EmbedController.swift
//  
//
//  Created by Miroslav Yozov on 5.11.22.
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
        
        open private(set) var rootViewController: UIViewController? = nil {
            didSet {
               setNeedsStatusBarAppearanceUpdate()
            }
        }
        
        public let container: UILayoutGuide = .init()
        
        public var rootViewIfLoaded: UIView? {
            rootViewController?.viewIfLoaded
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
            
            view.layout(container)
            layoutContainer()
            
            if let controller = rootViewController {
                add(viewController: controller, in: container)
            }
        }
        
        // TODO: animated not implemented yet
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
                remove(viewController: controller)
            }
            
            add(viewController: controller, in: container)
            rootViewController = controller
        }
    }
}


internal extension Utils.UI.EmbedController {
    /// layout the container guide.
    @objc dynamic func layoutContainer() {
        container.layout
            .edges()
    }
}
