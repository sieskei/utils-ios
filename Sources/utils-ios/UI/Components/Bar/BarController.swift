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
        /**
         A UIView property that references the
         active bar view.
        */
        open fileprivate(set) var barView: UIView?
        
        /// A reference to the bar layout guide.
        public let bar: UILayoutGuide = .init()

        /// Position of bar guide container.
        public let position: Position
        
        /// Height of bar guide container
        public let dimensions: Dimensions
        
        public init(rootViewController controller: UIViewController? = nil,
                    barView view: UIView? = nil,
                    barPosition position: Position = .bottom,
                    barDimension dimension: Dimensions = .sizeToFit) {
            self.barView = view
            self.position = position
            self.dimensions = dimension
            super.init(rootViewController: controller)
        }
        
        required public init?(coder: NSCoder) {
            self.position = .top
            self.dimensions = .sizeToFit
            super.init(coder: coder)
        }
        
        open override func prepare() {
            super.prepare()
            
            view.layout(bar)
            layoutBar()
            
            if let barView {
                prepare(barView: barView, in: bar)
            }
        }
        
        // TODO: animated not implemented yet
        open func embed(bar view: UIView, animated: Bool = true) {
            guard isViewLoaded else {
                barView = view
                return
            }
            
            if let barView {
                remove(barView: barView)
            }
            
            barView = view
            prepare(barView: view, in: bar)
        }
    }
}

internal extension Utils.UI.BarController {
    override func layoutContainer() {
        let layout: Utils.UI.Layout.Methods = container.layout
        layout
            .left()
            .right()
        
        switch position {
        case .top:
            layout.bottom()
        case .bottom:
            layout.top()
        }
    }
    
    /// Layout the details guide.
    @objc dynamic func layoutBar() {
        let layout: Utils.UI.Layout.Methods = bar.layout
        layout
            .left()
            .right()
        
        switch position {
        case .top:
            layout.above(container)
            layout.top()
        case .bottom:
            layout.below(container)
            layout.bottom()
        }
    }
}

internal extension Utils.UI.BarController {
    /// Prepares the view before transition.
    func prepare(barView: UIView) {
        barView.contentScaleFactor = Utils.UI.Screen.scale
    }
    
    /**
     Add a given view to the controller's view subviews.
     - Parameter view: A UIView to add as a child.
     - Parameter in guide: A layout guide in which will be layouted.
     */
    func prepare(barView: UIView, in guide: UILayoutGuide) {
        guard barView.superview != view else {
            return
        }
      
        prepare(barView: barView)
        add(barView: barView, in: guide)
    }
}

internal extension Utils.UI.BarController {
    /**
    Add a given view to the controller's view subviews.
    - Parameter viewController: A UIView to add as a child.
    - Parameter in guide: A layout guide in which will be layouted.
    */
    func add(barView: UIView, in guide: UILayoutGuide) {
        view.layout(barView).edges(guide)
    }
  
    /**
    Removes a given view from the controller's view subviews.
    - Parameter viewController: A UIView to remove.
    */
    func remove(barView: UIView) {
        guard barView.superview == view else {
            return
        }
        barView.removeFromSuperview()
    }
}
