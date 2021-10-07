//
//  SlidePresentationAnimationController.swift
//  
//
//  Created by Miroslav Yozov on 8.31.15.
//

import UIKit

public class SlidePresentationAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
    let isPresenting: Bool
    let duration: TimeInterval
    
    public init(isPresenting: Bool, duration: TimeInterval) {
        self.isPresenting = isPresenting
        self.duration = duration
        super.init()
    }
    
    private func animatePresentationWithTransitionContext(_ transitionContext: UIViewControllerContextTransitioning) {
        guard let presentedController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) else {
            return
        }
        
        let fframe = transitionContext.finalFrame(for: presentedController)
        presentedController.view.frame = fframe
        transitionContext.containerView.addSubview(presentedController.view)
        
        presentedController.view.alpha = 0.0
        presentedController.view.transform = CGAffineTransform(translationX: 0, y: fframe.height)
        UIView.animate(withDuration: duration, animations: {
            presentedController.view.alpha = 1.0
            presentedController.view.transform = .identity
        }, completion: { _ in
            transitionContext.completeTransition(true)
        })
    }
    
    private func animateDismissalWithTransitionContext(_ transitionContext: UIViewControllerContextTransitioning) {
        guard let presentingController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from) else {
            return
        }
        
        UIView.animate(withDuration: duration, animations: {
            presentingController.view.alpha = 0.0
            presentingController.view.transform = CGAffineTransform(translationX: 0, y: presentingController.view.frame.height)
        }, completion: { _ in
            presentingController.view.alpha = 1.0
            presentingController.view.transform = .identity
            
            transitionContext.completeTransition(true)
        })
    }
    
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning)  {
        if isPresenting {
            animatePresentationWithTransitionContext(transitionContext)
        } else {
            animateDismissalWithTransitionContext(transitionContext)
        }
    }
}
