//
//  DimmingPresentationController.swift
//  
//
//  Created by Miroslav Yozov on 4.22.15.
//


import UIKit

class DimmingPresentationController: UIPresentationController {
    private lazy var dimmingView: UIView = {
        let container = UIView(frame: self.containerView?.bounds ?? CGRect.zero)
        container.alpha = 0.00
        container.backgroundColor = UIColor(hex: 0x000000, alpha: 0.50)
        container.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        return container
    }()
    
    var insetX: CGFloat = 0.00
    var insetY: CGFloat = 0.00
    
    override var frameOfPresentedViewInContainerView: CGRect {
        guard let containerView = containerView else {
            return super.frameOfPresentedViewInContainerView
        }
        
        return containerView.bounds.insetBy(dx: insetX, dy: insetY)
    }
    
    override func presentationTransitionWillBegin() {
        guard let containerView = containerView else {
            return
        }
        
        // Add the dimming view and the presented view to the heirarchy
        dimmingView.frame = containerView.bounds
        containerView.addSubview(dimmingView)
        
        // Fade in the dimming view alongside the transition
        if let transitionCoordinator = presentingViewController.transitionCoordinator {
            transitionCoordinator.animate(alongsideTransition: { _ in
                self.dimmingView.alpha = 1.00
            })
        } else {
            dimmingView.alpha = 1.00
        }
    }
    
    override func presentationTransitionDidEnd(_ completed: Bool)  {
        // If the presentation didn't complete, remove the dimming view
        if !completed {
            dimmingView.removeFromSuperview()
        }
    }
    
    override func dismissalTransitionWillBegin()  {
        // Fade out the dimming view alongside the transition
        if let transitionCoordinator = self.presentingViewController.transitionCoordinator {
            transitionCoordinator.animate(alongsideTransition: { _ in
                self.dimmingView.alpha = 0.00
            })
        } else {
            dimmingView.alpha = 0.00
        }
    }
    
    override func dismissalTransitionDidEnd(_ completed: Bool) {
        // If the dismissal completed, remove the dimming view
        if completed {
            self.dimmingView.removeFromSuperview()
        }
    }
}
