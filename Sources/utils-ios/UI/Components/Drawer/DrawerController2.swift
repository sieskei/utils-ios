//
//  DrawerController.swift
//  
//
//  Created by Miroslav Yozov on 2.11.22.
//

import UIKit

extension Utils.UI.DrawerController2 {
    /**
     State of drawer.
     */
    public enum State: Int {
        case opened
        case closed
    }
    
    /**
     Pair of width and min space (right) when
     drawer width exceed controller's view width.
     */
    public typealias Dimensions = (width: CGFloat, minSpace: CGFloat)
}

extension Utils.UI {
    open class DrawerController2: EmbedController {
        /**
         A UIViewController property that references the
         active drawer UIViewController.
         */
        open fileprivate(set) var drawerController: UIViewController?
        
        /**
         A UIView property that is used to hide and reveal the
         leftViewController. It is very rare that this property will
         need to be accessed externally.
         */
        open fileprivate(set) lazy var drawer: UIView = {
            .init() ~> {
                $0.backgroundColor = .white
                $0.clipsToBounds = true
                
                view.layout($0, aboveSubview: container)
                    .top()
                    .bottom()
            }
        }()
        
        
        /**
         A Boolean property that accesses the 'cancelsTouchesInView'
         property of panning and tapping gestures.
         */
        open var isGesturesCancelsTouches: Bool = true {
            didSet {
                [edgePanGesture, panGesture, tapGesture].forEach {
                    $0.cancelsTouchesInView = isGesturesCancelsTouches
                }
            }
        }
    
        /**
         A Boolean property that accesses the 'isEnabled'
         property of panning and tapping gestures.
         */
        open var isEnabled: Bool = true {
            didSet {
                [edgePanGesture, panGesture, tapGesture].forEach {
                    $0.isEnabled = isEnabled
                }
            }
        }
        
        fileprivate var stateProperty: State = .closed
        
        /**
         Current drawer state.
         Opened or closed.
         */
        open var state: State {
            get { stateProperty }
            set { set(state: newValue, animated: false) }
        }
        
        open var dimensions: Dimensions = (320, 54) {
            didSet {
                if isViewLoaded, dimensions != oldValue {
                    // update constraints
                }
            }
        }
        
        
        // MARK: - Position constraints
        fileprivate lazy var closedConstraint: NSLayoutConstraint = drawer.rightAnchor.constraint(equalTo: view.leftAnchor)
        fileprivate lazy var openedConstraint: NSLayoutConstraint = drawer.leftAnchor.constraint(equalTo: view.leftAnchor)
        fileprivate lazy var panConstraint: NSLayoutConstraint = {
            drawer.rightAnchor.constraint(equalTo: view.leftAnchor, constant: .zero) ~> {
                $0.priority = .init(901)
                $0.activate()
            }
        }()
        
        // MARK: Width constraints
        fileprivate lazy var widthConstraint: NSLayoutConstraint = {
            drawer.widthAnchor.constraint(equalToConstant: dimensions.width) ~> {
                $0.priority = .init(951)
                $0.activate()
            }
        }()
        
        fileprivate lazy var maxWidthConstraint: NSLayoutConstraint = drawer.widthAnchor.constraint(lessThanOrEqualTo: view.widthAnchor,
                                                                                                    constant: -dimensions.minSpace).activate()
        
        /**
         A UIPanGestureRecognizer property internally used for the opening drawer.
         */
        internal fileprivate(set) lazy var edgePanGesture: UIScreenEdgePanGestureRecognizer = {
            .init(target: self, action: #selector(onPan(recognizer:))) ~> {
                $0.edges = .left
                $0.delegate = self
                $0.isEnabled = isEnabled
                $0.cancelsTouchesInView = isGesturesCancelsTouches
                view.addGestureRecognizer($0)
            }
        }()
        
        /**
         A UIPanGestureRecognizer property internally used for the closing drawer.
         */
        internal fileprivate(set) lazy var panGesture: UIPanGestureRecognizer = {
            .init(target: self, action: #selector(onPan(recognizer:))) ~> {
                $0.delegate = self
                $0.isEnabled = isEnabled
                $0.cancelsTouchesInView = isGesturesCancelsTouches
                view.addGestureRecognizer($0)
            }
        }()
        
        /**
         A UITapGestureRecognizer property internally used for the
         leftView tap gesture.
         */
        internal fileprivate(set) lazy var tapGesture: UITapGestureRecognizer = {
            .init(target: self, action: #selector(onTap(recognizer:))) ~> {
                $0.delegate = self
                $0.isEnabled = isEnabled && state == .opened
                $0.cancelsTouchesInView = isGesturesCancelsTouches
                view.addGestureRecognizer($0)
            }
        }()
        
        fileprivate var lastPanPoint: CGPoint? = nil
        
        override func prepareContainer() {
            super.prepareContainer()
            container.backgroundColor = .black
        }
        
        open override func prepare() {
            super.prepare()
            
            let _ = drawer
            let _ = widthConstraint
            let _ = maxWidthConstraint
            
            let _ = panGesture
            let _ = tapGesture
            
            layoutDrawer()
            
            if let drawerController {
                prepare(viewController: drawerController, in: drawer)
            }
            
            drawer.backgroundColor = .random
        }
        
        open func embed(drawerController controller: UIViewController) {
            guard isViewLoaded else {
                drawerController = controller
                return
            }
            
            if let drawerController {
                removeViewController(viewController: drawerController)
            }
            
            drawerController = controller
            prepare(viewController: controller, in: drawer)
        }
    }
}


// MARK: - UIGestureRecognizerDelegate, 'on' pinning and tapping gestures.
extension Utils.UI.DrawerController2: UIGestureRecognizerDelegate {
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == edgePanGesture {
            guard state == .closed else {
                return false
            }
            
            let velocity = edgePanGesture.velocity(in: view)
            return velocity.x > 0 && abs(velocity.x) > abs(velocity.y)
        } else if gestureRecognizer == panGesture {
            guard state == .opened else {
                return false
            }
            
            let velocity = panGesture.velocity(in: view)
            return velocity.x < 0 && abs(velocity.x) > abs(velocity.y)
        } else if gestureRecognizer == tapGesture {
            guard state == .opened else {
                return false
            }
            
            let location = tapGesture.location(in: view)
            return location.x >= drawer.frame.maxX && location.x <= view.frame.maxX
        }
        
        return true
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    /**
     A method that is fired when the pan gesture is recognized
     for the drawer.
     - Parameter recognizer: A UIPanGestureRecognizer that is
     passed to the handler when recognized.
     */
    @objc
    fileprivate func onPan(recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
        case .possible:
            // nothing to do ...
            break
        case .began:
            lastPanPoint = recognizer.translation(in: view)
            
            [closedConstraint, openedConstraint].forEach {
                $0.isActive = false
            }
            
            panConstraint.constant = drawer.frame.maxX
        case .changed:
            guard let point = lastPanPoint else {
                break
            }

            let currentPoint = recognizer.translation(in: view)
            defer { lastPanPoint = currentPoint }
            
            let deltaX = currentPoint.x - point.x
            panConstraint.constant = min(drawer.bounds.width, max(0, panConstraint.constant + deltaX))
            rootViewIfLoaded?.alpha = 1 - (0.5 * (panConstraint.constant / drawer.bounds.width))
        case .ended, .cancelled, .failed:
            var value = state
            defer { set(state: value, animated: true) }

            let velocity = recognizer.velocity(in: view)
            let halfWidth = drawer.bounds.width / 2
            switch state {
            case .closed:
                if panConstraint.constant >= halfWidth || (velocity.x > 0 && abs(velocity.x) >= 1500) {
                    value = .opened
                }
            case .opened:
                if panConstraint.constant <= halfWidth || (velocity.x < 0 && abs(velocity.x) >= 1500) {
                    value = .closed
                }
            }
        @unknown default:
            break
        }
    }
    
    /**
     A method that is fired when the tap gesture is recognized
     for the drawer.
     - Parameter recognizer: A UITapGestureRecognizer that is
     passed to the handler when recognized.
     */
    @objc
    fileprivate func onTap(recognizer: UITapGestureRecognizer) {
        if recognizer.state == .ended {
            set(state: .closed, animated: true)
        }
    }
}

// MARK: - Public API
extension Utils.UI.DrawerController2 {
    fileprivate func layoutDrawer() {
        let flag = state == .opened
        openedConstraint.isActive = flag
        closedConstraint.isActive = !flag
        panConstraint.constant = .zero
    }
    
    public func set(state value: State, animated flag: Bool = true) {
        stateProperty = value
        
        tapGesture.isEnabled = isEnabled && value == .opened
        rootViewIfLoaded?.isUserInteractionEnabled = value == .closed
        
        layoutDrawer()
        
        guard flag, isViewLoaded, view.window != nil else {
            // animation is not posible
            rootViewIfLoaded?.alpha = state == .opened ? 0.5 : 1
            return
        }
        
        Utils.UI.animate(with: self, duration: 0.25) {
            $0.rootViewIfLoaded?.alpha = $0.state == .opened ? 0.5 : 1
            $0.view.layoutIfNeeded()
        }
    }
    
    public func toggleState(animated flag: Bool = true) {
        switch state {
        case .opened:
            set(state: .closed, animated: flag)
        case .closed:
            set(state: .opened, animated: flag)
        }
    }
}
