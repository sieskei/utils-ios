//
//  BarController.swift
//
//
//  Created by Miroslav Yozov on 5.11.22.
//

import UIKit

extension Utils.UI.BarController {
    /// Type of bar position.
    public enum Position {
        case top
        case bottom
    }
    
    public enum Dimensions {
        case constant(CGFloat)
        case sizeToFit
    }
}

extension Utils.UI {
    open class BarController: Utils.UI.EmbedController {
        /// A reference to the top bar layout guide.
        public let topBarGuide: UILayoutGuide = .init()
        
        /// A reference to the bottom bar layout guide.
        public let bottomBarGuide: UILayoutGuide = .init()
        
        /// A reference to the top bar view.
        public fileprivate(set) var topBar: UIView?
        
        /// A reference to the bottom bar view.
        public fileprivate(set) var bottomBar: UIView?
        
        /// Top bar dimensions type.
        public let topBarDimensions: Dimensions
        
        /// Top bar dimensions type.
        public let bottomBarDimensions: Dimensions
        
        public init(rootViewController controller: UIViewController? = nil,
                    topBar: UIView? = nil,
                    bottomBar: UIView? = nil,
                    topBarDimension: Dimensions = .sizeToFit,
                    bottomBarDimension: Dimensions = .sizeToFit) {
            self.topBar = topBar
            self.bottomBar = bottomBar
            self.topBarDimensions = topBarDimension
            self.bottomBarDimensions = bottomBarDimension
            super.init(rootViewController: controller)
        }
        
        required public init?(coder: NSCoder) {
            self.topBarDimensions = .sizeToFit
            self.bottomBarDimensions = .sizeToFit
            super.init(coder: coder)
        }
        
        open override func prepare() {
            view.layout(topBarGuide)
            layoutTopBarGuide()
            
            view.layout(bottomBarGuide)
            layoutBottomBarGuide()
            
            super.prepare() // must layout bars first!
            
            topBar ~> { add(bar: $0, in: topBarGuide) }
            bottomBar ~> { add(bar: $0, in: bottomBarGuide) }
        }
        
        // TODO: animated not implemented yet
        open func embed(topBar view: UIView, animated: Bool = true) {
            guard isViewLoaded else {
                topBar = view
                return
            }
            
            topBar ~> { remove(bar: $0) }
            topBar = view
            add(bar: view, in: topBarGuide)
        }
        
        // TODO: animated not implemented yet
        open func embed(bottomBar view: UIView, animated: Bool = true) {
            guard isViewLoaded else {
                bottomBar = view
                return
            }
            
            bottomBar ~> { remove(bar: $0) }
            bottomBar = view
            add(bar: view, in: bottomBarGuide)
        }
    }
}

internal extension Utils.UI.BarController {
    override func layoutContainer() {
        let layout: Utils.UI.Layout.Methods = container.layout
        layout
            .below(topBarGuide)
            .left()
            .right()
            .above(bottomBarGuide)
    }
    
    /// Layout the top bar guide.
    @objc dynamic func layoutTopBarGuide() {
        let layout: Utils.UI.Layout.Methods = topBarGuide.layout
        layout
            .top()
            .left()
            .right()
            .height(.zero, priority: 550)

        switch topBarDimensions {
        case .constant(let value):
            layout.height(value)
        case .sizeToFit:
            break
        }
    }
    
    /// Layout the top bar guide.
    @objc dynamic func layoutBottomBarGuide() {
        let layout: Utils.UI.Layout.Methods = bottomBarGuide.layout
        layout
            .left()
            .right()
            .bottom()
            .height(.zero, priority: 550)

        switch topBarDimensions {
        case .constant(let value):
            layout.height(value)
        case .sizeToFit:
            break
        }
    }
}

public extension Utils.UI.BarController {
    /**
    Add a given view to the controller's view subviews.
    - Parameter viewController: A UIView to add as a child.
    - Parameter in guide: A layout guide in which will be layouted.
    */
    func add(bar: UIView, in guide: UILayoutGuide) {
        view.layout(bar)
            .edges(guide)
        view.bringSubviewToFront(bar)
    }

    /**
    Removes a given view from the controller's view subviews.
    - Parameter viewController: A UIView to remove.
    */
    func remove(bar: UIView) {
        guard bar.superview == view else {
            return
        }
        bar.removeFromSuperview()
    }
}

public extension Utils.UI.BarController {
    override func add(viewController: UIViewController, in guide: UILayoutGuide) {
        defer {
            topBar ~> { view.bringSubviewToFront($0) }
            bottomBar ~> { view.bringSubviewToFront($0) }
        }
        
        super.add(viewController: viewController, in: guide)
    }
}
