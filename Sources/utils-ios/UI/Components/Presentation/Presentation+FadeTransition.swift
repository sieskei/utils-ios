//
//  File.swift
//  
//
//  Created by Miroslav Yozov on 17.08.22.
//

import UIKit

extension Utils.UI.Presentation {
    public class FadeTransition: NSObject, UIViewControllerAnimatedTransitioning {
        public enum Direction {
            case up(offset: CGFloat)
            case down(offset: CGFloat)
            
            fileprivate var transform: CGAffineTransform {
                switch self {
                case .up(let offset):
                     return .init(translationX: 0, y: offset)
                case .down(let offset):
                    return .init(translationX: 0, y: -offset)
                }
            }
        }
        
        let isPresenting: Bool
        let direction: Direction
        let duration: TimeInterval
        
        public init(isPresenting: Bool, direction: Direction, duration: TimeInterval) {
            self.isPresenting = isPresenting
            self.direction = direction
            self.duration = duration
            super.init()
        }
        
        private func animatePresentationWithTransitionContext(_ transitionContext: UIViewControllerContextTransitioning) {
            guard let presentedController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) else {
                return
            }
            
            presentedController.view.frame = transitionContext.finalFrame(for: presentedController)
            transitionContext.containerView.addSubview(presentedController.view)
            
            presentedController.view.alpha = 0.0
            
            presentedController.view.transform = direction.transform
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
                presentingController.view.transform = self.direction.transform
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
}
