//
//  File.swift
//  
//
//  Created by Miroslav Yozov on 26.05.22.
//

import UIKit

extension Utils.UI {
    open class NoBarNavigationController: UINavigationController {
        open override func viewDidLoad() {
            super.viewDidLoad()
            prepare()
        }

        open override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)

            guard let v = interactivePopGestureRecognizer else {
                return
            }

            guard let x: Utils.UI.DrawerController = traverseViewControllerHierarchyForClassType() else {
                return
            }
            
            x.edgePanGesture.require(toFail: v)
        }

        open override func viewWillLayoutSubviews() {
            super.viewWillLayoutSubviews()
            layoutSubviews()
        }

        open override func setNavigationBarHidden(_ hidden: Bool, animated: Bool) {
            // do not invoke super
            return
        }

        /**
        Prepares the view instance when intialized. When subclassing,
        it is recommended to override the prepare method
        to initialize property values and other setup operations.
        The super.prepare method should always be called immediately
        when subclassing.
        */
        open func prepare() {
            super.setNavigationBarHidden(true, animated: false)

            // This ensures the panning gesture is available when going back between views.
            if let v = interactivePopGestureRecognizer {
                v.isEnabled = true
                v.delegate = self
            }
        }

        /// Calls the layout functions for the view heirarchy.
        open func layoutSubviews() { }
    }
}

extension Utils.UI.NoBarNavigationController: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return interactivePopGestureRecognizer == gestureRecognizer && viewControllers.count > 1
    }
}
