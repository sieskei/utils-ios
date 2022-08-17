//
//  File.swift
//  
//
//  Created by Miroslav Yozov on 17.08.22.
//

import UIKit

extension Utils.UI.Presentation {
    public class BlurController: UIPresentationController {
        private lazy var blurView: Utils.UI.VisualEffectView = {
            let view: Utils.UI.VisualEffectView = .init()
            
            view.alpha = 0
            view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            view.translatesAutoresizingMaskIntoConstraints = true
            
            view.colorTint = .black
            view.colorTintAlpha = 0.5
            view.blurRadius = 0
            
            return view
        }()
        
        public var insetX: CGFloat = 0.00
        public var insetY: CGFloat = 0.00
        
        public override var frameOfPresentedViewInContainerView: CGRect {
            guard let containerView = containerView else {
                return super.frameOfPresentedViewInContainerView
            }
            
            return containerView.bounds.insetBy(dx: insetX, dy: insetY)
        }
        
        public override func presentationTransitionWillBegin() {
            guard let containerView = containerView else {
                return
            }
            
            // Add the dimming view and the presented view to the heirarchy
            blurView.frame = containerView.bounds
            containerView.insertSubview(blurView, at: 0)
            
            // Fade in the dimming view alongside the transition
            if let transitionCoordinator = presentingViewController.transitionCoordinator {
                transitionCoordinator.animate(alongsideTransition: { _ in
                    self.blurView.alpha = 1
                    self.blurView.blurRadius = 4
                })
            } else {
                blurView.alpha = 1
                blurView.blurRadius = 4
            }
        }
        
        public override func presentationTransitionDidEnd(_ completed: Bool)  {
            // If the presentation didn't complete, remove the dimming view
            if !completed {
                blurView.removeFromSuperview()
            }
        }
        
        public override func dismissalTransitionWillBegin()  {
            // Fade out the dimming view alongside the transition
            if let transitionCoordinator = self.presentingViewController.transitionCoordinator {
                transitionCoordinator.animate(alongsideTransition: { _ in
                    self.blurView.alpha = 0
                    self.blurView.blurRadius = 0
                })
            } else {
                blurView.alpha = 0
                blurView.blurRadius = 0
            }
        }
        
        public override func dismissalTransitionDidEnd(_ completed: Bool) {
            // If the dismissal completed, remove the dimming view
            if completed {
                blurView.removeFromSuperview()
            }
        }
    }
}


