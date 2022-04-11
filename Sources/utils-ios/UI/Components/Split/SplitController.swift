//
//  SplitController.swift
//  
//
//  Created by Miroslav Yozov on 11.04.22.
//

import UIKit

extension Utils.UI {
    open class SplitController: Utils.UI.EmbedController {
        /**
         A UIViewController property that references the
         active details UIViewController.
        */
        open fileprivate(set) var detailsViewController: UIViewController?

        /// A reference to the details view.
        @IBInspectable
        public let details = UIView()

        internal override var containerFrame: CGRect {
            var f = view.bounds
            f.size.width *= 0.4
            return f
        }

        internal var detailsFrame: CGRect {
            var f = view.bounds
            f.size.width *= 0.6
            f.origin.x = view.bounds.width - f.size.width
            return f
        }

        /**
         An initializer for the NavigationDrawerController.
         - Parameter rootViewController: The main UIViewController.
         - Parameter leftViewController: Тhe details UIViewController.
        */
        public init(rootViewController: UIViewController, detailsViewController: UIViewController) {
            self.detailsViewController = detailsViewController
            super.init(rootViewController: rootViewController)
        }

        /**
        An initializer that initializes the object with a NSCoder object.
        - Parameter aDecoder: A NSCoder instance.
        */
        public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        }

        /**
         An initializer that initializes the object with an Optional nib and bundle.
         - Parameter nibNameOrNil: An Optional String for the nib.
         - Parameter bundle: An Optional NSBundle where the nib is located.
        */
        public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
            super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        }
        
        open override func prepare() {
            super.prepare()
          
            prepareDetails()
            if let controller = detailsViewController {
                prepare(viewController: controller, in: details)
            }
        }
        
        open func embed(detailsController controller: UIViewController) {
            guard isViewLoaded else {
                detailsViewController = controller
                return
            }
            
            if let controller = detailsViewController {
                removeViewController(viewController: controller)
            }
            
            detailsViewController = controller
            prepare(viewController: controller, in: details)
        }
    }
}

internal extension Utils.UI.SplitController {
    override func prepareContainer() {
        super.prepareContainer()
        container.autoresizingMask = [container.autoresizingMask, .flexibleRightMargin]
    }

    /// Prepares the details view.
    @objc dynamic func prepareDetails() {
        details.backgroundColor = .clear
        details.clipsToBounds = true
        details.contentScaleFactor = Utils.UI.Screen.scale
        details.frame = detailsFrame
        details.autoresizingMask = [.flexibleWidth, .flexibleHeight, .flexibleLeftMargin]
        view.addSubview(details)
    }
}
