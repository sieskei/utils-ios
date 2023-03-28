//
//  FastArrowLayer.swift
//
//  Created by Miroslav Yozov on 14.05.18.
//  Copyright © 2018 Net Info.BG EAD. All rights reserved.
//

import UIKit

extension Utils.UI.ScrollRefresher {
    class FastArrowLayer: CALayer, CAAnimationDelegate {
        private var line: CAShapeLayer {
            guard let layers = sublayers, layers.count == 2 else {
                fatalError("Missing sublayers!")
            }
            return Utils.castOrFatalError(layers[0])
        }
        
        private var arrow: CAShapeLayer {
            guard let layers = sublayers, layers.count == 2 else {
                fatalError("Missing sublayers!")
            }
            return Utils.castOrFatalError(layers[1])
        }
        
        func prepare(frame: CGRect, color: UIColor = .init(rgb: (165, 165, 165)), lineWidth: CGFloat = 1) {
            self.frame = frame
            self.backgroundColor = UIColor.clear.cgColor
            
            let width  = frame.size.width
            let height = frame.size.height
            
            addSublayer({
                let path = UIBezierPath()
                path.move(to: .init(x: width/2, y: 0))
                path.addLine(to: .init(x: width/2, y: height/2 + height/3))
                
                let layer = CAShapeLayer()
                layer.lineWidth   = lineWidth * 2
                layer.strokeColor = color.cgColor
                layer.fillColor   = UIColor.clear.cgColor
                layer.lineCap     = CAShapeLayerLineCap.round
                layer.path        = path.cgPath
                layer.strokeStart = 0.5
                
                return layer
            }())
            
            addSublayer({
                let path = UIBezierPath()
                path.move(to: .init(x: width/2 - height/6, y: height/2 + height/6))
                path.addLine(to: .init(x: width/2, y: height/2 + height/3))
                path.addLine(to: .init(x: width/2 + height/6, y: height/2 + height/6))
                
                let layer = CAShapeLayer()
                layer.lineWidth   = lineWidth * 2
                layer.strokeColor = color.cgColor
                layer.lineCap     = CAShapeLayerLineCap.round
                layer.lineJoin    = CAShapeLayerLineJoin.round
                layer.fillColor   = UIColor.clear.cgColor
                layer.path        = path.cgPath
                
                return layer
            }())
        }
        
        //MARK: public Methods
        @discardableResult
        func start(_ callback: (() -> Void)? = nil) -> Self {
            guard !started else {
                return self
            }

            completion = callback
            started = true
            
            let start = CABasicAnimation(keyPath: "strokeStart")
            start.duration  = 0.2
            start.fromValue = 0
            start.toValue   = 0.5
            start.isRemovedOnCompletion = false
            start.fillMode  = .forwards
            start.delegate  = self
            start.timingFunction = .init(name: .easeInEaseOut)
            
            let end = CABasicAnimation(keyPath: "strokeEnd")
            end.duration  = 0.2
            end.fromValue = 1
            end.toValue   = 0.5
            end.isRemovedOnCompletion = false
            end.fillMode  = .forwards
            end.timingFunction = .init(name: .easeInEaseOut)
            
            arrow.add(start, forKey: "strokeStart")
            arrow.add(end, forKey: "strokeEnd")
            
            return self
        }

        func stop() {
            guard started else {
                return
            }
            
            started = false
            
            arrow.isHidden = false
            line.isHidden  = false
            
            arrow.removeAllAnimations()
            line.removeAllAnimations()
        }

        private func addLineAnimation() {
            let start = CABasicAnimation(keyPath: "strokeStart")
            start.fromValue = 0.5
            start.toValue = 0
            start.isRemovedOnCompletion = false
            start.fillMode  = .forwards
            start.timingFunction = .init(name: .easeInEaseOut)
            start.duration  = 0.2 / 2
            line.add(start, forKey: "strokeStart")
            
            let end = CABasicAnimation(keyPath: "strokeEnd")
            // end.beginTime = CACurrentMediaTime() + (0.2 / 3)
            end.duration  = 0.2 / 2
            end.fromValue = 1
            end.toValue   = 0.03
            end.isRemovedOnCompletion = false
            end.fillMode  = .forwards
            end.delegate  = self
            end.timingFunction = .init(name: .easeInEaseOut)
            line.add(end, forKey: "strokeEnd")
        }
    }
}



// --------------------- //
// MARK: CALayerDelegate //
// --------------------- //
extension Utils.UI.ScrollRefresher.FastArrowLayer: CALayerDelegate {
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        guard let anim = anim as? CABasicAnimation  else { return }
        
        switch anim.keyPath {
        case "strokeStart":
            arrow.isHidden = true
            addLineAnimation()
        case "strokeEnd":
            line.isHidden = true
            completion?()
        default:
            Utils.Log.warning("Unknown animation:", anim)
        }
    }
}

extension Utils.UI.ScrollRefresher.FastArrowLayer: AssociatedObjectCompatible {
    class Props {
        var started: Bool = false
        var completion: (()->Void)? = nil
    }
    
    private var props: Props {
        return get(for: "props") { .init() }
    }
    
    var started: Bool {
        get { props.started }
        set { props.started = newValue }
    }
    
    var completion: (()->Void)? {
        get { props.completion }
        set { props.completion = newValue }
    }
}
