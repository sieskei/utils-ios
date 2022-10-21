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
        
        open var barColor: UIColor = .init(hue: (29.0/360.0), saturation: 1.0, brightness: 1.0, alpha: 1.0) {
            didSet {
                prepareColors()
            }
        }
        
        private let serialIncrementQueue: DispatchQueue = .init(label: "ios.utils.UI.GradientProgress.serialIncrementQueue")
        private var numberOfOperations: Int = 0
        
        open override func prepare() {
            super.prepare()
            prepareColors()
        }
        
        open func prepareColors() {
            // Use a horizontal gradient
            layer.startPoint = CGPoint(x: 0.0, y: 0.5)
            layer.endPoint = CGPoint(x: 1.0, y: 0.5)
            
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
    }
}

extension Utils.UI.GradientProgress {
    private func performAnimation() {
        // Move the last color in the array to the front
        // shifting all the other colors.
        guard let color = layer.colors?.popLast() else {
            print("FATAL ERR: GradientProgress : Layer should contain colors!")
            return
        }
        
        layer.colors?.insert(color, at: 0)
        let shiftedColors = layer.colors!
        
        let animation = CABasicAnimation(keyPath: "colors")
        animation.toValue = shiftedColors
        animation.duration = 0.03
        animation.isRemovedOnCompletion = true
        animation.fillMode = CAMediaTimingFillMode.forwards
        animation.delegate = self
        layer.add(animation, forKey: "animateGradient")
    }
    
    public func wait() {
        serialIncrementQueue.sync {
            numberOfOperations += 1
            
            if numberOfOperations == 1 { // rest will be called from animationDidStop
                performAnimation()
            }
        }
    }

    public func signal() {
        serialIncrementQueue.sync {
            if numberOfOperations == 0 {
                return
            }

            serialIncrementQueue.sync {
                numberOfOperations -= 1
            }
        }
    }
}

extension Utils.UI.GradientProgress: CAAnimationDelegate {
    public func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        serialIncrementQueue.sync {
            if flag && numberOfOperations > 0 {
                performAnimation()
            }
        }
    }
}
