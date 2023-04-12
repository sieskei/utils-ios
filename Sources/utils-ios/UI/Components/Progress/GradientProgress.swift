//
//  GradientProgress.swift
//  
//
//  Created by Miroslav Yozov on 21.10.22.
//

import UIKit

extension Utils.UI {
    open class GradientProgress: Utils.UI.View {
        open override class var layerClass: AnyClass {
            CAGradientLayer.self
        }
        
        public override var layer: CAGradientLayer {
            Utils.castOrFatalError(super.layer)
        }
        
        open var barColor: UIColor = .gray {
            didSet {
                prepareColors()
            }
        }
        
        private let accessQueue: DispatchQueue = .init(label: "ios.utils.UI.GradientProgress.serialIncrementQueue")
        private var waiters: Int = 0
        
        open override func prepare() {
            super.prepare()
            prepareColors()
        }
        
        open func prepareColors() {
            // Use a horizontal gradient
            layer.startPoint = CGPoint(x: 0.0, y: 0.5)
            layer.endPoint = CGPoint(x: 1.0, y: 0.5)
            
            layer.backgroundColor = UIColor.clear.cgColor
            
            var colors: [CGColor] = []
            
            for alpha in stride(from: 0, through: 40, by: 2) {
                let color = barColor.withAlphaComponent(CGFloat(Double(alpha)/100.0))
                colors.append(color.cgColor)
            }
            
            for alpha in stride(from: 40, through: 90, by: 10) {
                let color = barColor.withAlphaComponent(CGFloat(Double(alpha)/100.0))
                colors.append(color.cgColor)
            }
            
            for alpha in stride(from: 90, through: 100, by: 10) {
                let color = barColor.withAlphaComponent(CGFloat(Double(alpha)/100.0))
                colors.append(color.cgColor)
                colors.append(color.cgColor) // adding twice
            }
            
            for alpha in stride(from: 100, through: 0, by: -20) {
                let color = barColor.withAlphaComponent(CGFloat(Double(alpha)/100.0))
                colors.append(color.cgColor)
            }
            
            layer.colors = colors
        }
        
        open override func didMoveToSuperview() {
            super.didMoveToSuperview()
            
            if superview == nil {
                accessQueue.sync {
                    waiters = .zero
                    layer.removeAllAnimations()
                }
            }
        }
    }
}

extension Utils.UI.GradientProgress {
    private func performAnimation() {
        // Move the last color in the array to the front
        // shifting all the other colors.
        guard let color = layer.colors?.popLast() else {
            Utils.Log.error("Utils.UI.GradientProgress: Layer should contain colors!")
            return
        }
        
        layer.colors?.insert(color, at: 0)
        let shiftedColors = layer.colors!
        
        let animation = CABasicAnimation(keyPath: "colors")
        animation.toValue = shiftedColors
        animation.duration = 0.025
        animation.isRemovedOnCompletion = true
        animation.fillMode = CAMediaTimingFillMode.forwards
        animation.delegate = self
        layer.add(animation, forKey: "animateGradient")
    }
    
    public final func wait() {
        accessQueue.sync {
            waiters += 1
            if waiters > .zero {
                // rest will be called from animationDidStop
                performAnimation()
            }
        }
    }

    public final func signal() {
        accessQueue.sync {
            if waiters > .zero {
                waiters -= 1
            }
        }
    }
}

extension Utils.UI.GradientProgress: CAAnimationDelegate {
    public func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        accessQueue.sync {
            if waiters > .zero {
                performAnimation()
            }
        }
    }
}
