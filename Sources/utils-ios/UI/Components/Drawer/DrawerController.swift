//
//  DrawerController.swift
//  
//
//  Created by Miroslav Yozov on 7.04.22.
//

import UIKit

extension Utils.UI {
    open class DrawerController: EmbedController {
        /// A boolean indicating if the panel is animating.
        fileprivate var isAnimating = false
        
        /**
         A CGFloat property that is used internally to track
         the original (x) position of the container view when panning.
         */
        fileprivate var originalX: CGFloat = 0
        
        /**
         A UIPanGestureRecognizer property internally used for the
         leftView pan gesture.
         */
        internal fileprivate(set) var leftPanGesture: UIPanGestureRecognizer?
        
        /**
         A UITapGestureRecognizer property internally used for the
         leftView tap gesture.
         */
        internal fileprivate(set) var leftTapGesture: UITapGestureRecognizer?
        
        /**
         A Boolean property that accesses the 'cancelsTouchesInView'
         property of panning and tapping gestures.
         */
        open var isGesturesCancelsTouches: Bool = true {
            didSet {
                leftPanGesture?.cancelsTouchesInView = isGesturesCancelsTouches
                leftTapGesture?.cancelsTouchesInView = isGesturesCancelsTouches
            }
        }
        
        /**
         A CGFloat property that accesses the leftView threshold of
         the NavigationDrawerController. When the panning gesture has
         ended, if the position is beyond the threshold,
         the leftView is opened, if it is below the threshold, the
         leftView is closed. If -1, threshold is disabled.
         */
        open var leftThreshold: CGFloat = 64
        
        /**
         A CGFloat property that sets the animation duration of the
         leftView when closing and opening. Defaults to 0.25.
         */
        open var animationDuration: TimeInterval = 0.25
        
        /**
         A Boolean property that enables and disables the leftView from
         opening and closing. Defaults to true.
         */
        open var isEnabled: Bool {
            get {
                isLeftViewEnabled
            }
            set(value) {
                if nil != leftView {
                    isLeftViewEnabled = value
                }
            }
        }
        
        /**
         A Boolean property that enables and disables the leftView from
         opening and closing. Defaults to true.
         */
        open var isLeftViewEnabled = false {
            didSet {
                isLeftPanGestureEnabled = isLeftViewEnabled
                isLeftTapGestureEnabled = isLeftViewEnabled
            }
        }
        
        /// Enables the left pan gesture.
        open var isLeftPanGestureEnabled = false {
            didSet {
                if isLeftPanGestureEnabled {
                    prepareLeftPanGesture()
                } else {
                    removeLeftPanGesture()
                }
            }
        }
        
        /// Enables the left tap gesture.
        open var isLeftTapGestureEnabled = false {
            didSet {
                if isLeftTapGestureEnabled {
                    prepareLeftTapGesture()
                } else {
                    removeLeftTapGesture()
                }
            }
        }
        
        /**
         A UIView property that is used to hide and reveal the
         leftViewController. It is very rare that this property will
         need to be accessed externally.
         */
        open fileprivate(set) var leftView: UIView?
        
        /// Indicates whether the leftView or rightView is opened.
        open var isOpened: Bool {
            return isLeftViewOpened
        }
        
        /// indicates if the leftView is opened.
        open var isLeftViewOpened: Bool {
            guard let v = leftView else {
                return false
            }
            return v.frame.origin.x != -v.bounds.width
        }
        
        /// Width aspect ratio for views.
        open var ratio: CGFloat {
            0.8
        }
        
        /**
         A UIViewController property that references the
         active left UIViewController.
         */
        open fileprivate(set) var leftViewController: UIViewController?
        
        /**
         An initializer for the NavigationDrawerController.
         - Parameter rootViewController: The main UIViewController.
         - Parameter leftViewController: An Optional left UIViewController.
         */
        public init(rootViewController: UIViewController?, leftViewController: UIViewController? = nil) {
            super.init(rootViewController: rootViewController)
            self.leftViewController = leftViewController
        }
        
        required public init?(coder: NSCoder) {
            super.init(coder: coder)
        }
        
        open override func prepare() {
            super.prepare()
            prepareLeftViewController()
        }
        
        internal override func prepareContainer() {
            super.prepareContainer()
            container.backgroundColor = .black
        }
        
        open override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
            super.viewWillTransition(to: size, with: coordinator)

            guard .phone == UIDevice.current.userInterfaceIdiom else {
                return
            }

            let r = size.width <= size.height ? ratio : ratio / 2
            coordinator.animate(alongsideTransition: { [weak self] context in
                guard let this = self, let v = this.leftView else {
                    return
                }
                
                v.frame.size.width = r * size.width
                if !this.isLeftViewOpened {
                    v.frame.origin.x = v.frame.width
                }
            })
        }
        
        open func embed(leftController controller: UIViewController) {
            guard isViewLoaded else {
                leftViewController = controller
                return
            }
            
            if let controller = leftViewController {
                removeViewController(viewController: controller)
            }
            
            leftViewController = controller
            prepareLeftViewController()
        }
        
        /**
         A method that opens the leftView.
         - Parameter velocity: A CGFloat value that sets the
         velocity of the user interaction when animating the
         leftView. Defaults to 0.
         */
        open func openLeftView(velocity: CGFloat = 0) {
            guard !isAnimating, isLeftViewEnabled, let v = leftView else {
                return
            }

            isAnimating = true

            // statusBarHidden = true
            showView(container: v)

            // isUserInteractionEnabled = false

            let duration: TimeInterval = .init(0 == velocity ? animationDuration : fmax(0.1, fmin(1, Double(v.frame.origin.x / velocity))))
            UIView.animate(withDuration: duration, animations: { [weak self, v = v] in
                guard let this = self else {
                return
                }

                v.frame.origin.x = 0
                this.rootViewController?.view.alpha = 0.5
            }) { [weak self] _ in
                guard let this = self else {
                    return
                }
                this.isAnimating = false
            }
        }
        
        /**
         A method that closes the leftView.
         - Parameter velocity: A CGFloat value that sets the
         velocity of the user interaction when animating the
         leftView. Defaults to 0.
         */
        open func closeLeftView(velocity: CGFloat = 0) {
            guard !isAnimating, isLeftViewEnabled, let v = leftView else {
                return
            }

            isAnimating = true

            let duration: TimeInterval = .init(0 == velocity ? animationDuration : fmax(0.1, fmin(1, Double(v.frame.origin.x / velocity))))
            UIView.animate(withDuration: duration, animations: { [weak self, v = v] in
                guard let this = self else {
                    return
                }

                v.frame.origin.x = -v.bounds.width
                this.rootViewController?.view.alpha = 1
            }) { [weak self, v = v] _ in
                guard let this = self else {
                    return
                }

                this.hideView(container: v)

                // this.statusBarHidden = false
                this.isAnimating = false
                // this.isUserInteractionEnabled = true
            }
        }
    
        /**
         A method that toggles the leftView opened if previously closed,
         or closed if previously opened.
         - Parameter velocity: A CGFloat value that sets the
         velocity of the user interaction when animating the
         leftView. Defaults to 0.
         */
        open func toggleLeftView(velocity: CGFloat = 0) {
            isLeftViewOpened ? closeLeftView(velocity: velocity) : openLeftView(velocity: velocity)
        }
    }
}

fileprivate extension Utils.UI.DrawerController {
    /// Prepares the contentViewController.
    func prepareContentViewController() {
        if let controller = rootViewController {
            view.sendSubviewToBack(controller.view)
        }
    }

    func prepareLeftViewController() {
        if let controller = leftViewController {
            prepare(viewController: controller, in: prepareLeftView())
            isLeftViewEnabled = true
        } else {
            leftView?.removeFromSuperview()
            leftView = nil
            isLeftViewEnabled = true
        }
    }
    
    @discardableResult
    func prepareLeftView() -> UIView {
        guard leftView == nil else {
            return leftView!
        }
        
        let r = .phone == UIDevice.current.userInterfaceIdiom ? (view.bounds.width < view.bounds.height ? ratio : ratio / 2) : ratio / 2
        let w = view.bounds.width * r
        let lv: UIView = .init(frame: .init(origin: .zero, size: .init(width: w, height: view.bounds.height)))
        leftView = lv

        lv.autoresizingMask = [.flexibleHeight, .flexibleWidth, .flexibleRightMargin, .flexibleLeftMargin]
        lv.backgroundColor = .white
        lv.clipsToBounds = true

        view.addSubview(lv)

        lv.isHidden = true
        lv.frame.origin.x = -w
        lv.layer.zPosition = 2000

        return lv
    }
    
    /// Prepare the left pan gesture.
    func prepareLeftPanGesture() {
        guard nil == leftPanGesture else {
            return
        }
        
        UIPanGestureRecognizer(target: self, action: #selector(handleLeftViewPanGesture(recognizer:))) ~> {
            $0.delegate = self
            $0.cancelsTouchesInView = isGesturesCancelsTouches
            
            view.addGestureRecognizer($0)
            leftPanGesture = $0
        }
    }
    
    /// Prepare the left tap gesture.
    func prepareLeftTapGesture() {
        guard nil == leftTapGesture else {
            return
        }
        
        UITapGestureRecognizer(target: self, action: #selector(handleLeftViewTapGesture(recognizer:))) ~> {
            $0.delegate = self
            $0.cancelsTouchesInView = isGesturesCancelsTouches
            
            view.addGestureRecognizer($0)
            leftTapGesture = $0
        }
    }
    
    /// Removes the left pan gesture.
    func removeLeftPanGesture() {
        guard let v = leftPanGesture else {
            return
        }

        view.removeGestureRecognizer(v)
        leftPanGesture = nil
    }
    
    /// Removes the left tap gesture.
    func removeLeftTapGesture() {
        guard let v = leftTapGesture else {
            return
        }

        view.removeGestureRecognizer(v)
        leftTapGesture = nil
    }
    
    /**
     A method that shows a view.
     - Parameter container: A container view.
     */
    func showView(container: UIView) {
        // container.depthPreset = depthPreset
        container.isHidden = false
    }
    
    /**
     A method that hides a view.
     - Parameter container: A container view.
     */
    func hideView(container: UIView) {
        // container.depthPreset = .none
        container.isHidden = true
    }
}

extension Utils.UI.DrawerController: UIGestureRecognizerDelegate {
    /**
     A method that determines whether the passed point is
     contained within the bounds of the leftViewThreshold
     and height of the NavigationDrawerController view frame
     property.
     - Parameter point: A CGPoint to test against.
     - Returns: A Boolean of the result, true if yes, false
     otherwise.
     */
    fileprivate func isPointContainedWithinLeftThreshold(point: CGPoint) -> Bool {
        return leftThreshold >= 0 ? point.x <= leftThreshold : true
    }
    
    /**
     A method that determines whether the passed in point is
     contained within the bounds of the passed in container view.
     - Parameter container: A UIView that sets the bounds to test
     against.
     - Parameter point: A CGPoint to test whether or not it is
     within the bounds of the container parameter.
     - Returns: A Boolean of the result, true if yes, false
     otherwise.
     */
    fileprivate func isPointContainedWithinView(container: UIView, point: CGPoint) -> Bool {
      return container.bounds.contains(point)
    }
    
    /**
     Detects the gesture recognizer being used.
     - Parameter gestureRecognizer: A UIGestureRecognizer to detect.
     - Parameter touch: The UITouch event.
     - Returns: A Boolean of whether to continue the gesture or not.
     */
    @objc
    open func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if gestureRecognizer == leftPanGesture && (isLeftViewOpened || isPointContainedWithinLeftThreshold(point: touch.location(in: view))) {
            return true
        }

        if isLeftViewOpened, gestureRecognizer == leftTapGesture, let leftView = leftView, !leftView.bounds.contains(touch.location(in: view)) {
            return true
        }

        return false
    }
    
    /**
     A method that is fired when the tap gesture is recognized
     for the leftView.
     - Parameter recognizer: A UITapGestureRecognizer that is
     passed to the handler when recognized.
     */
    @objc
    fileprivate func handleLeftViewTapGesture(recognizer: UITapGestureRecognizer) {
        guard isLeftViewOpened, let v = leftView else {
            return
        }

        if isLeftViewEnabled && isLeftViewOpened && !isPointContainedWithinView(container: v, point: recognizer.location(in: v)) {
            closeLeftView()
        }
    }
    
    /**
     A method that is fired when the pan gesture is recognized
     for the leftView.
     - Parameter recognizer: A UIPanGestureRecognizer that is
     passed to the handler when recognized.
     */
    @objc
    fileprivate func handleLeftViewPanGesture(recognizer: UIPanGestureRecognizer) {
        guard isLeftViewEnabled, (isLeftViewOpened || isPointContainedWithinLeftThreshold(point: recognizer.location(in: view))), let v = leftView else {
            return
        }

        // Animate the panel.
        switch recognizer.state {
        case .began:
            originalX = v.frame.origin.x

            showView(container: v)

            case .changed:
            let translationX = recognizer.translation(in: v).x
            v.frame.origin.x = min(originalX + translationX, 0)

            let ratio = min(max(1 - (abs(v.frame.origin.x) / v.bounds.width), 0), 1)
            rootViewController?.view.alpha = 1 - (0.5 * ratio)

            if translationX >= leftThreshold {
                //statusBarHidden = true
            }
        case .ended, .cancelled, .failed:
            let p = recognizer.velocity(in: recognizer.view)
            let x = p.x >= 1000 || p.x <= -1000 ? p.x : 0

            let w = v.bounds.width
            let t = w / 2
            if v.frame.origin.x <= -w + t || x < -1000 {
                closeLeftView(velocity: x)
            } else {
                openLeftView(velocity: x)
            }
        case .possible:
            break
        default:
            break
        }
    }
}
