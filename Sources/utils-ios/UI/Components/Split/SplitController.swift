//
//  SplitController.swift
//  
//
//  Created by Miroslav Yozov on 11.04.22.
//

import UIKit

extension Utils.UI.SplitController {
    /**
     Type of spiltter width.
     */
    public enum Dimensions {
        case constant(CGFloat)
        case aspect(CGFloat)
    }
}

extension Utils.UI {
    open class SplitController: Utils.UI.EmbedController {
        /**
         A UIViewController property that references the
         active details UIViewController.
        */
        open fileprivate(set) var detailsViewController: UIViewController?

        /// A reference to the details view.
        public let details: UILayoutGuide = .init()
        
        public let dimensions: Dimensions

        /**
         An initializer for the NavigationDrawerController.
         - Parameter rootViewController: The main UIViewController.
         - Parameter detailsViewController: Тhe details UIViewController.
        */
        public init(rootViewController rootController: UIViewController? = nil,
                    detailsViewController detailsController: UIViewController? = nil,
                    containerDimensions dimensions: Dimensions = .aspect(0.45)) {
            self.detailsViewController = detailsController
            self.dimensions = dimensions
            super.init(rootViewController: rootController)
        }

        /**
        An initializer that initializes the object with a NSCoder object.
        - Parameter aDecoder: A NSCoder instance.
        */
        public required init?(coder aDecoder: NSCoder) {
            self.dimensions = .aspect(0.45)
            super.init(coder: aDecoder)
        }
        
        open override func prepare() {
            super.prepare()
          
            view.layout(details)
            layoutDetails()
            
            if let detailsViewController {
                prepare(viewController: detailsViewController, in: details)
            }
        }
        
        open func embed(detailsController controller: UIViewController) {
            guard isViewLoaded else {
                detailsViewController = controller
                return
            }
            
            if let detailsViewController {
                remove(viewController: detailsViewController)
            }
            
            detailsViewController = controller
            prepare(viewController: controller, in: details)
        }
    }
}

internal extension Utils.UI.SplitController {
    override func layoutContainer() {
        let layout: Utils.UI.Layout.Methods = container.layout
        
        layout
            .top()
            .bottom()
            .left()
        
        switch dimensions {
        case .constant(let value):
            layout.width(value)
        case .aspect(let value):
            layout.widthSuper(multiplier: value)
        }
    }
    
    /// Layout the details guide.
    @objc dynamic func layoutDetails() {
        details.layout
            .top()
            .bottom()
            .right()
            .after(container)
    }
}
